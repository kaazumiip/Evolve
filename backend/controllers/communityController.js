const db = require('../config/db');
const admin = require('../config/firebase');

// Get all posts (feed)
exports.getAllPosts = async (req, res) => {
    try {
        const [posts] = await db.execute(`
            SELECT 
                p.*, 
                u.name as userName, 
                u.profile_picture as userImage,
                u.current_streak,
                (SELECT COUNT(*) FROM post_likes pl WHERE pl.post_id = p.id) as likeCount,
                (SELECT COUNT(*) FROM comments c WHERE c.post_id = p.id) as commentCount,
                EXISTS(SELECT 1 FROM post_likes pl WHERE pl.post_id = p.id AND pl.user_id = ?) as isLiked
            FROM posts p
            JOIN users u ON p.user_id = u.id
            WHERE NOT EXISTS (
                SELECT 1 FROM user_blocks 
                WHERE (blocker_id = ? AND blocked_id = u.id) 
                   OR (blocker_id = u.id AND blocked_id = ?)
            )
            ORDER BY p.created_at DESC
        `, [req.user.id, req.user.id, req.user.id]);

        const formattedPosts = posts.map(post => ({
            ...post,
            tags: typeof post.tags === 'string' ? JSON.parse(post.tags) : post.tags,
            media_urls: typeof post.media_urls === 'string' ? JSON.parse(post.media_urls) : post.media_urls,
            isVerified: false,
            isHot: post.view_count > 1000
        }));

        res.json(formattedPosts);
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server Error');
    }
};

// Create a new post
exports.createPost = async (req, res) => {
    const { title, body, tags, image_url, media_urls } = req.body;
    try {
        const [result] = await db.execute(
            'INSERT INTO posts (user_id, title, body, tags, image_url, media_urls, created_at) VALUES (?, ?, ?, ?, ?, ?, DATE_ADD(UTC_TIMESTAMP(), INTERVAL 7 HOUR))',
            [req.user.id, title, body, JSON.stringify(tags || []), image_url || null, JSON.stringify(media_urls || [])]
        );
        const newPostId = result.insertId;
        await db.execute(
            'INSERT INTO activities (user_id, action_type, entity_title) VALUES (?, ?, ?)',
            [req.user.id, 'created_post', title]
        );
        const [post] = await db.execute(`
            SELECT p.*, u.name as userName, u.profile_picture as userImage, u.current_streak 
            FROM posts p 
            JOIN users u ON p.user_id = u.id 
            WHERE p.id = ?
        `, [newPostId]);
        const returnedPost = post[0];
        returnedPost.tags = typeof returnedPost.tags === 'string' ? JSON.parse(returnedPost.tags) : returnedPost.tags;
        returnedPost.media_urls = typeof returnedPost.media_urls === 'string' ? JSON.parse(returnedPost.media_urls) : returnedPost.media_urls;
        res.json({ ...returnedPost, likeCount: 0, commentCount: 0, isLiked: false });
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server Error');
    }
};

// Get single post details with comments
exports.getPostDetails = async (req, res) => {
    try {
        const postId = req.params.id;
        await db.execute('UPDATE posts SET view_count = view_count + 1 WHERE id = ?', [postId]);
        const [posts] = await db.execute(`
            SELECT 
                p.*, 
                u.name as userName, 
                u.profile_picture as userImage,
                u.current_streak,
                (SELECT COUNT(*) FROM post_likes pl WHERE pl.post_id = p.id) as likeCount,
                (SELECT COUNT(*) FROM comments c WHERE c.post_id = p.id) as commentCount,
                EXISTS(SELECT 1 FROM post_likes pl WHERE pl.post_id = p.id AND pl.user_id = ?) as isLiked
            FROM posts p
            JOIN users u ON p.user_id = u.id
            WHERE p.id = ?
            AND NOT EXISTS (
                SELECT 1 FROM user_blocks 
                WHERE (blocker_id = ? AND blocked_id = u.id) 
                   OR (blocker_id = u.id AND blocked_id = ?)
            )
        `, [req.user.id, postId, req.user.id, req.user.id]);

        if (posts.length === 0) {
            return res.status(404).json({ msg: 'Post not found or inaccessible' });
        }

        const post = posts[0];
        post.tags = typeof post.tags === 'string' ? JSON.parse(post.tags) : post.tags;
        post.media_urls = typeof post.media_urls === 'string' ? JSON.parse(post.media_urls) : post.media_urls;

        const [comments] = await db.execute(`
            SELECT 
                c.*, 
                u.name as userName, 
                u.profile_picture as userImage, 
                u.current_streak,
                (SELECT COUNT(*) FROM comment_likes cl WHERE cl.comment_id = c.id) as likeCount,
                EXISTS(SELECT 1 FROM comment_likes cl WHERE cl.comment_id = c.id AND cl.user_id = ?) as isLiked
            FROM comments c
            JOIN users u ON c.user_id = u.id
            WHERE c.post_id = ?
              AND NOT EXISTS (
                SELECT 1 FROM user_blocks 
                WHERE (blocker_id = ? AND blocked_id = u.id) 
                   OR (blocker_id = u.id AND blocked_id = ?)
              )
            ORDER BY c.created_at DESC
        `, [req.user.id, postId, req.user.id, req.user.id]);

        res.json({ post, comments });
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server Error');
    }
};

// Add a comment
exports.addComment = async (req, res) => {
    const { content, parent_id, type, media_url } = req.body;
    const postId = req.params.id;
    try {
        const [result] = await db.execute(
            'INSERT INTO comments (post_id, user_id, content, parent_id, type, media_url) VALUES (?, ?, ?, ?, ?, ?)',
            [postId, req.user.id, content || '', parent_id || null, type || 'text', media_url || null]
        );
        const [comment] = await db.execute(`
            SELECT c.*, u.name as userName, u.profile_picture as userImage, u.current_streak
            FROM comments c
            JOIN users u ON c.user_id = u.id
            WHERE c.id = ?
        `, [result.insertId]);
        await db.execute(
            'INSERT INTO activities (user_id, action_type, entity_title) VALUES (?, ?, ?)',
            [req.user.id, 'commented_post', 'a community post']
        );
        try {
            let targetUserId;
            let notifyType = 'comment';
            let notifyTitle = 'New Comment';
            let notifyBody = `${comment[0].userName} commented on your post`;
            if (parent_id) {
                const [parentComm] = await db.execute('SELECT user_id FROM comments WHERE id = ?', [parent_id]);
                if (parentComm.length > 0) {
                    targetUserId = parentComm[0].user_id;
                    notifyType = 'reply';
                }
            } else {
                const [targetPost] = await db.execute('SELECT user_id FROM posts WHERE id = ?', [postId]);
                if (targetPost.length > 0) targetUserId = targetPost[0].user_id;
            }
            if (targetUserId && targetUserId !== req.user.id) {
                await db.execute(
                    'INSERT INTO notifications (user_id, sender_id, type, post_id, comment_id) VALUES (?, ?, ?, ?, ?)',
                    [targetUserId, req.user.id, notifyType, postId, parent_id || null]
                );

                // Push Notification
                const [targetUser] = await db.execute('SELECT fcm_token FROM users WHERE id = ?', [targetUserId]);
                if (targetUser.length > 0 && targetUser[0].fcm_token) {
                    const message = {
                        notification: {
                            title: notifyTitle,
                            body: notifyBody,
                            image: comment[0].userImage || ''
                        },
                        data: {
                            type: notifyType,
                            postId: postId.toString(),
                            senderName: comment[0].userName,
                            imageUrl: comment[0].userImage || ''
                        },
                        token: targetUser[0].fcm_token
                    };
                    await admin.messaging().send(message);
                }
            }
        } catch (err) {
            if (err.code === 'messaging/registration-token-not-registered' || err.message.toLowerCase().includes('not found')) {
                // Background cleanup if token is invalid
                const [targetPost] = await db.execute('SELECT user_id FROM posts WHERE id = ?', [postId]);
                if (targetPost.length > 0) {
                   await db.execute('UPDATE users SET fcm_token = NULL WHERE id = ?', [targetPost[0].user_id]);
                }
            }
        }
        res.json(comment[0]);
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server Error');
    }
};

// Update a post
exports.updatePost = async (req, res) => {
    const { title, body, tags, image_url, media_urls } = req.body;
    const postId = req.params.id;
    try {
        const [post] = await db.execute('SELECT * FROM posts WHERE id = ?', [postId]);
        if (post.length === 0) return res.status(404).json({ msg: 'Post not found' });
        if (post[0].user_id !== req.user.id) return res.status(401).json({ msg: 'Unauthorized' });
        await db.execute(
            'UPDATE posts SET title = ?, body = ?, tags = ?, image_url = ?, media_urls = ? WHERE id = ?',
            [title || post[0].title, body || post[0].body, JSON.stringify(tags || []), image_url, JSON.stringify(media_urls || []), postId]
        );
        res.json({ msg: 'Post updated' });
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server Error');
    }
};

// Delete a post
exports.deletePost = async (req, res) => {
    const postId = req.params.id;
    try {
        const [post] = await db.execute('SELECT * FROM posts WHERE id = ?', [postId]);
        if (post.length === 0) return res.status(404).json({ msg: 'Post not found' });
        if (post[0].user_id !== req.user.id) return res.status(401).json({ msg: 'Unauthorized' });
        await db.execute('DELETE FROM posts WHERE id = ?', [postId]);
        res.json({ msg: 'Post deleted' });
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server Error');
    }
};

// Toggle Like
exports.toggleLike = async (req, res) => {
    const postId = req.params.id;
    const userId = req.user.id;
    try {
        const [existing] = await db.execute('SELECT * FROM post_likes WHERE post_id = ? AND user_id = ?', [postId, userId]);
        if (existing.length > 0) {
            await db.execute('DELETE FROM post_likes WHERE post_id = ? AND user_id = ?', [postId, userId]);
            res.json({ liked: false });
        } else {
            await db.execute('INSERT INTO post_likes (post_id, user_id) VALUES (?, ?)', [postId, userId]);
            
            // Push Notification for Like
            try {
                const [post] = await db.execute('SELECT user_id, title FROM posts WHERE id = ?', [postId]);
                if (post.length > 0 && post[0].user_id !== userId) {
                    const targetUserId = post[0].user_id;
                    const [[sender]] = await db.execute('SELECT name, profile_picture FROM users WHERE id = ?', [userId]);
                    
                    // Insert DB notification
                    await db.execute(
                        'INSERT INTO notifications (user_id, sender_id, type, post_id) VALUES (?, ?, ?, ?)',
                        [targetUserId, userId, 'like', postId]
                    );

                    const [targetUser] = await db.execute('SELECT fcm_token FROM users WHERE id = ?', [targetUserId]);
                    if (targetUser.length > 0 && targetUser[0].fcm_token) {
                        const message = {
                            notification: {
                                title: 'New Like',
                                body: `${sender.name} liked your post: ${post[0].title.substring(0, 20)}...`
                            },
                            data: {
                                type: 'like',
                                postId: postId.toString(),
                                senderName: sender.name,
                                imageUrl: sender.profile_picture || ''
                            },
                            token: targetUser[0].fcm_token
                        };
                        await admin.messaging().send(message);
                    }
                }
            } catch (notifyErr) {}
            
            res.json({ liked: true });
        }
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server Error');
    }
};

// Toggle Comment Like
exports.toggleCommentLike = async (req, res) => {
    const commentId = req.params.id;
    const userId = req.user.id;
    try {
        const [existing] = await db.execute('SELECT * FROM comment_likes WHERE comment_id = ? AND user_id = ?', [commentId, userId]);
        if (existing.length > 0) {
            await db.execute('DELETE FROM comment_likes WHERE comment_id = ? AND user_id = ?', [commentId, userId]);
            res.json({ liked: false });
        } else {
            await db.execute('INSERT INTO comment_likes (comment_id, user_id) VALUES (?, ?)', [commentId, userId]);
            
            // Push Notification for Comment Like
            try {
                const [comm] = await db.execute('SELECT user_id, post_id FROM comments WHERE id = ?', [commentId]);
                if (comm.length > 0 && comm[0].user_id !== userId) {
                    const targetUserId = comm[0].user_id;
                    const postId = comm[0].post_id;
                    const [[sender]] = await db.execute('SELECT name, profile_picture FROM users WHERE id = ?', [userId]);
                    
                    // Insert DB notification
                    await db.execute(
                        'INSERT INTO notifications (user_id, sender_id, type, post_id, comment_id) VALUES (?, ?, ?, ?, ?)',
                        [targetUserId, userId, 'like_comment', postId, commentId]
                    );

                    const [targetUser] = await db.execute('SELECT fcm_token FROM users WHERE id = ?', [targetUserId]);
                    if (targetUser.length > 0 && targetUser[0].fcm_token) {
                        const message = {
                            notification: {
                                title: 'New Comment Like',
                                body: `${sender.name} liked your comment`
                            },
                            data: {
                                type: 'like_comment',
                                postId: postId.toString(),
                                senderName: sender.name,
                                imageUrl: sender.profile_picture || ''
                            },
                            token: targetUser[0].fcm_token
                        };
                        await admin.messaging().send(message);
                    }
                }
            } catch (notifyErr) {
                console.error("Error sending comment like notification:", notifyErr);
            }

            res.json({ liked: true });
        }
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server Error');
    }
};

// Search Users
exports.searchUsers = async (req, res) => {
    const { q } = req.query;
    if (!q) return res.json([]);
    try {
        const [users] = await db.execute(`
            SELECT id, name, profile_picture, email FROM users 
            WHERE (name LIKE ? OR email LIKE ?) AND id != ? 
            AND id NOT IN (SELECT blocked_id FROM user_blocks WHERE blocker_id = ? UNION SELECT blocker_id FROM user_blocks WHERE blocked_id = ?)
            LIMIT 15
        `, [`%${q}%`, `%${q}%`, req.user.id, req.user.id, req.user.id]);
        res.json(users);
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server Error');
    }
};

// Search Posts
exports.searchPosts = async (req, res) => {
    const { q } = req.query;
    if (!q) return res.json([]);
    try {
        const [posts] = await db.execute(`
            SELECT p.*, u.name as userName, u.profile_picture as userImage, u.current_streak,
                (SELECT COUNT(*) FROM post_likes pl WHERE pl.post_id = p.id) as likeCount,
                (SELECT COUNT(*) FROM comments c WHERE c.post_id = p.id) as commentCount
            FROM posts p JOIN users u ON p.user_id = u.id
            WHERE (p.title LIKE ? OR p.body LIKE ?)
              AND NOT EXISTS (SELECT 1 FROM user_blocks WHERE (blocker_id = ? AND blocked_id = u.id) OR (blocker_id = u.id AND blocked_id = ?))
            ORDER BY p.created_at DESC LIMIT 20
        `, [`%${q}%`, `%${q}%`, req.user.id, req.user.id]);
        res.json(posts.map(post => ({ ...post, tags: typeof post.tags === 'string' ? JSON.parse(post.tags) : post.tags })));
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server Error');
    }
};

// Search by Tag
exports.searchByTag = async (req, res) => {
    const { q } = req.query;
    if (!q) return res.json([]);
    try {
        const [posts] = await db.execute(`
            SELECT p.*, u.name as userName, u.profile_picture as userImage, u.current_streak,
                (SELECT COUNT(*) FROM post_likes pl WHERE pl.post_id = p.id) as likeCount,
                (SELECT COUNT(*) FROM comments c WHERE c.post_id = p.id) as commentCount
            FROM posts p JOIN users u ON p.user_id = u.id
            WHERE p.tags LIKE ?
              AND NOT EXISTS (SELECT 1 FROM user_blocks WHERE (blocker_id = ? AND blocked_id = u.id) OR (blocker_id = u.id AND blocked_id = ?))
            ORDER BY p.created_at DESC LIMIT 20
        `, [`%${q}%`, req.user.id, req.user.id]);
        res.json(posts.map(post => ({ ...post, tags: typeof post.tags === 'string' ? JSON.parse(post.tags) : post.tags })));
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server Error');
    }
};

// Get Recommendations
exports.getRecommendations = async (req, res) => {
    try {
        const userId = req.user.id;
        const [recommended] = await db.execute(`
            SELECT DISTINCT u.id, u.name, u.profile_picture as userImage,
                (SELECT COUNT(*) FROM user_interests ui2 WHERE ui2.user_id = u.id AND ui2.interest_id IN (SELECT interest_id FROM user_interests WHERE user_id = ?)) as commonInterests
            FROM users u
            WHERE u.id != ?
            AND u.id NOT IN (SELECT receiver_id FROM friendships WHERE requester_id = ? UNION SELECT requester_id FROM friendships WHERE receiver_id = ?)
            AND u.id NOT IN (SELECT blocked_id FROM user_blocks WHERE blocker_id = ? UNION SELECT blocker_id FROM user_blocks WHERE blocked_id = ?)
            ORDER BY commonInterests DESC LIMIT 15
        `, [userId, userId, userId, userId, userId, userId]);
        res.json(recommended);
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server Error');
    }
};

// Get Activities
exports.getUserActivities = async (req, res) => {
    const targetUserId = req.params.id || req.user.id;
    try {
        const [activities] = await db.execute(`
            SELECT a.id, a.action_type, a.entity_title as title, a.created_at
            FROM activities a JOIN users u ON a.user_id = u.id
            WHERE a.user_id = ?
              AND NOT EXISTS (SELECT 1 FROM user_blocks WHERE (blocker_id = ? AND blocked_id = u.id) OR (blocker_id = u.id AND blocked_id = ?))
            ORDER BY a.created_at DESC LIMIT 10
        `, [targetUserId, req.user.id, req.user.id]);
        res.json(activities);
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server Error');
    }
};
