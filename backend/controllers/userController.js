const db = require('../config/db');
const admin = require('../config/firebase');

// Get a user's profile
exports.getUserProfile = async (req, res) => {
    const targetUserId = req.params.id;
    const currentUserId = req.user.id;

    try {
        // Fetch user data
        const [users] = await db.execute(
            'SELECT id, name, email, profile_picture, bio, last_seen, current_streak, subscription_plan FROM users WHERE id = ?',
            [targetUserId]
        );

        if (users.length === 0) {
            return res.status(404).json({ msg: 'User not found' });
        }

        const user = users[0];

        // Fetch interests
        const [interests] = await db.execute(`
            SELECT i.id, i.title, i.color_hex 
            FROM interests i
            JOIN user_interests ui ON i.id = ui.interest_id
            WHERE ui.user_id = ?
        `, [targetUserId]);

        // Fetch sub-interests
        const [subInterests] = await db.execute(`
            SELECT si.id, si.name 
            FROM sub_interests si
            JOIN user_sub_interests usi ON si.id = usi.sub_interest_id
            WHERE usi.user_id = ?
        `, [targetUserId]);

        // Check friendship status
        const [friendship] = await db.execute(`
            SELECT * FROM friendships 
            WHERE (requester_id = ? AND receiver_id = ?) 
               OR (requester_id = ? AND receiver_id = ?)
        `, [currentUserId, targetUserId, targetUserId, currentUserId]);

        let friendshipStatus = 'none';
        let requesterId = null;

        if (friendship.length > 0) {
            friendshipStatus = friendship[0].status;
            requesterId = friendship[0].requester_id;
        }

        // Fetch user posts
        const [posts] = await db.execute(`
            SELECT 
                p.id, p.title, p.body, p.created_at, p.image_url,
                (SELECT COUNT(*) FROM post_likes pl WHERE pl.post_id = p.id) as likesCount,
                (SELECT COUNT(*) FROM comments c WHERE c.post_id = p.id) as commentsCount
            FROM posts p
            WHERE p.user_id = ? 
            ORDER BY p.created_at DESC
        `, [targetUserId]);

        // Fetch counts
        const [[{ friendsCount }]] = await db.execute(`
            SELECT COUNT(*) as friendsCount FROM friendships 
            WHERE (requester_id = ? OR receiver_id = ?) AND status = 'accepted'
        `, [targetUserId, targetUserId]);

        res.json({
            ...user,
            interests,
            subInterests,
            posts,
            friendshipStatus,
            friendsCount,
            followersCount: friendsCount, // Simplified
            followingCount: friendsCount, // Simplified
            isRequester: requesterId === currentUserId
        });
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server Error');
    }
};

// Send a friend request
exports.sendFriendRequest = async (req, res) => {
    const receiverId = req.params.id;
    const requesterId = req.user.id;

    if (requesterId == receiverId) {
        return res.status(400).json({ msg: 'You cannot add yourself as a friend' });
    }

    try {
        // Check if exists
        const [existing] = await db.execute(
            'SELECT * FROM friendships WHERE (requester_id = ? AND receiver_id = ?) OR (requester_id = ? AND receiver_id = ?)',
            [requesterId, receiverId, receiverId, requesterId]
        );

        if (existing.length > 0) {
            return res.status(400).json({ msg: 'Friendship or request already exists' });
        }

        await db.execute(
            'INSERT INTO friendships (requester_id, receiver_id, status) VALUES (?, ?, ?)',
            [requesterId, receiverId, 'pending']
        );

        // Create new conversation
        const [conversationResult] = await db.execute('INSERT INTO conversations (created_at, updated_at) VALUES (NOW(), NOW())');
        const conversationId = conversationResult.insertId;

        // Add participants to the conversation
        await db.execute('INSERT INTO conversation_participants (conversation_id, user_id) VALUES (?, ?)', [conversationId, requesterId]);
        await db.execute('INSERT INTO conversation_participants (conversation_id, user_id) VALUES (?, ?)', [conversationId, receiverId]);

        // Also add a system notification
        await db.execute(
            'INSERT INTO notifications (user_id, sender_id, type, created_at) VALUES (?, ?, ?, NOW())',
            [receiverId, requesterId, 'friend_request']
        );

        res.json({ msg: 'Friend request sent' });

        // Send FCM notification
        try {
            const [users] = await db.execute('SELECT name FROM users WHERE id = ?', [requesterId]);
            const [recipient] = await db.execute('SELECT fcm_token FROM users WHERE id = ?', [receiverId]);
            
            if (recipient.length > 0 && recipient[0].fcm_token && users.length > 0) {
                const requesterName = users[0].name;
                const message = {
                    notification: {
                        title: 'New Friend Request',
                        body: `${requesterName} sent you a friend request!`
                    },
                    data: {
                        type: 'friend_request',
                        requesterId: requesterId.toString()
                    },
                    token: recipient[0].fcm_token
                };
                await admin.messaging().send(message);
            }
        } catch (pushErr) {
            console.warn('Push notification for friend request failed:', pushErr.message);
        }

    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server Error');
    }
};

// Accept a friend request
exports.acceptFriendRequest = async (req, res) => {
    const requesterId = req.params.id;
    const receiverId = req.user.id;

    try {
        const [result] = await db.execute(
            'UPDATE friendships SET status = ? WHERE requester_id = ? AND receiver_id = ? AND status = ?',
            ['accepted', requesterId, receiverId, 'pending']
        );

        if (result.affectedRows === 0) {
            return res.status(400).json({ msg: 'No pending request found' });
        }

        // Update the original friend request notification for the accepter to reflect the new friendship
        await db.execute(
            'UPDATE notifications SET type = ? WHERE user_id = ? AND sender_id = ? AND type = ?',
            ['friend_mutual', receiverId, requesterId, 'friend_request']
        );

        // Notify the requester that their request was accepted
        try {
            await db.execute(
                'INSERT INTO notifications (user_id, sender_id, type, created_at) VALUES (?, ?, ?, NOW())',
                [requesterId, receiverId, 'friend_accepted']
            );

            const [[accepter]] = await db.execute('SELECT name, profile_picture FROM users WHERE id = ?', [receiverId]);
            const [[recipient]] = await db.execute('SELECT fcm_token FROM users WHERE id = ?', [requesterId]);

            if (recipient && recipient.fcm_token) {
                const message = {
                    notification: {
                        title: 'Friend Request Accepted',
                        body: `${accepter.name} accepted your friend request!`
                    },
                    data: {
                        type: 'friend_accepted',
                        accepterId: receiverId.toString(),
                        imageUrl: accepter.profile_picture || ''
                    },
                    token: recipient.fcm_token
                };
                await admin.messaging().send(message);
            }
        } catch (notifyErr) {
            console.error('Error sending friend acceptance notification:', notifyErr.message);
        }

        res.json({ msg: 'Friend request accepted' });
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server Error');
    }
};

// Remove a friend or cancel a request
exports.removeFriend = async (req, res) => {
    const targetUserId = req.params.id;
    const currentUserId = req.user.id;

    try {
        await db.execute(
            'DELETE FROM friendships WHERE (requester_id = ? AND receiver_id = ?) OR (requester_id = ? AND receiver_id = ?)',
            [currentUserId, targetUserId, targetUserId, currentUserId]
        );

        res.json({ msg: 'Friendship removed/cancelled' });
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server Error');
    }
};

// Search for users
exports.searchUsers = async (req, res) => {
    const query = req.query.q;
    const currentUserId = req.user.id;

    if (!query) return res.json([]);

    try {
        const [users] = await db.execute(`
            SELECT id, name, email, profile_picture 
            FROM users 
            WHERE (name LIKE ? OR email LIKE ?) AND id != ?
            LIMIT 20
        `, [`%${query}%`, `%${query}%`, currentUserId]);

        res.json(users);
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server Error');
    }
};

// Get user's friend list (can be for self or another user)
exports.getFriends = async (req, res) => {
    const targetUserId = req.params.userId || req.user.id;
    const currentUserId = req.user.id;

    try {
        const [friends] = await db.execute(`
            SELECT 
                u.id, u.name, u.profile_picture, u.last_seen,
                f2.status as friendshipStatus,
                f2.requester_id as requesterId
            FROM users u
            JOIN friendships f ON (u.id = f.requester_id OR u.id = f.receiver_id)
            LEFT JOIN friendships f2 ON (
                (f2.requester_id = ? AND f2.receiver_id = u.id) OR 
                (f2.requester_id = u.id AND f2.receiver_id = ?)
            )
            WHERE (f.requester_id = ? OR f.receiver_id = ?) 
              AND u.id != ? 
              AND f.status = 'accepted'
        `, [currentUserId, currentUserId, targetUserId, targetUserId, targetUserId]);

        res.json(friends);
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server Error');
    }
};

// Update user subscription
exports.updateSubscription = async (req, res) => {
    const userId = req.user.id;
    const { planName } = req.body;

    if (!planName) {
        return res.status(400).json({ msg: 'Please provide a plan name' });
    }

    try {
        await db.execute(
            'UPDATE users SET subscription_plan = ? WHERE id = ?',
            [planName, userId]
        );

        res.json({ msg: 'Subscription updated successfully', subscription_plan: planName });
    } catch (err) {
        console.error('Update Subscription Error:', err.message);
        res.status(500).send('Server Error');
    }
};
