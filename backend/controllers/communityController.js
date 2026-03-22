const db = require('../config/db');

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
            ORDER BY p.created_at DESC
        `, [req.user.id]);

        // Parse tags if stored as JSON string, though mysql2 might handle JSON type automatically
        // If p.tags is a string, parse it.
        const formattedPosts = posts.map(post => ({
            ...post,
            tags: typeof post.tags === 'string' ? JSON.parse(post.tags) : post.tags,
            media_urls: typeof post.media_urls === 'string' ? JSON.parse(post.media_urls) : post.media_urls,
            isVerified: false, // Placeholder logic
            isHot: post.view_count > 1000 // Placeholder logic
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
            'INSERT INTO posts (user_id, title, body, tags, image_url, media_urls) VALUES (?, ?, ?, ?, ?, ?)',
            [req.user.id, title, body, JSON.stringify(tags || []), image_url || null, JSON.stringify(media_urls || [])]
        );

        const newPostId = result.insertId;

        // Log the activity
        await db.execute(
            'INSERT INTO activities (user_id, action_type, entity_title) VALUES (?, ?, ?)',
            [req.user.id, 'created_post', title]
        );

        // Fetch the created post to return
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

        // Update view count
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
        `, [req.user.id, postId]);

        if (posts.length === 0) {
            return res.status(404).json({ msg: 'Post not found' });
        }

        const post = posts[0];
        post.tags = typeof post.tags === 'string' ? JSON.parse(post.tags) : post.tags;
        post.media_urls = typeof post.media_urls === 'string' ? JSON.parse(post.media_urls) : post.media_urls;

        // Fetch comments
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
            ORDER BY c.created_at DESC
        `, [req.user.id, postId]);

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

        // Log the activity
        await db.execute(
            'INSERT INTO activities (user_id, action_type, entity_title) VALUES (?, ?, ?)',
            [req.user.id, 'commented_post', 'a community post']
        );

        // Notify the appropriate user (either the post author, or the parent comment author)
        try {
            let targetUserId;
            let notifyType = 'comment';
            let notifyTitle = 'New Comment';
            let notifyBody = `${comment[0].userName} commented on your post: "${content.substring(0, 50)}${content.length > 50 ? '...' : ''}"`;

            if (parent_id) {
                const [parentComm] = await db.execute('SELECT user_id, content FROM comments WHERE id = ?', [parent_id]);
                if (parentComm.length > 0) {
                    targetUserId = parentComm[0].user_id;
                    notifyType = 'reply';
                    notifyTitle = `${comment[0].userName}`;
                    notifyBody = `Replied to your comment: "${content.substring(0, 50)}${content.length > 50 ? '...' : ''}"`;
                }
            } else {
                const [targetPost] = await db.execute('SELECT user_id, title FROM posts WHERE id = ?', [postId]);
                if (targetPost.length > 0) {
                    targetUserId = targetPost[0].user_id;
                    notifyTitle = `${comment[0].userName}`;
                    notifyBody = `Commented on your post: "${content.substring(0, 50)}${content.length > 50 ? '...' : ''}"`;
                }
            }

            if (targetUserId && targetUserId !== req.user.id) {
                // Save to database
                await db.execute(
                    'INSERT INTO notifications (user_id, sender_id, type, post_id, comment_id) VALUES (?, ?, ?, ?, ?)',
                    [targetUserId, req.user.id, notifyType, postId, parent_id || null]
                );

                // Send FCM
                const [recipient] = await db.execute('SELECT fcm_token FROM users WHERE id = ?', [targetUserId]);
                if (recipient.length > 0 && recipient[0].fcm_token) {
                    const message = {
                        notification: {
                            title: notifyTitle,
                            body: notifyBody,
                            image: comment[0].userImage // Pass sender profile pic for system display
                        },
                        data: {
                            type: notifyType,
                            postId: postId.toString(),
                            commentId: (parent_id || result.insertId).toString(),
                            imageUrl: comment[0].userImage || '' // Backup for data-only processing
                        },
                        token: recipient[0].fcm_token
                    };
                    await admin.messaging().send(message).catch(e => console.error('FCM Error:', e.message));
                }
            }
        } catch (err) {
            console.error('Notification Error:', err.message);
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
            [
                title || post[0].title, 
                body || post[0].body, 
                tags ? JSON.stringify(tags) : post[0].tags, 
                image_url !== undefined ? image_url : post[0].image_url,
                media_urls !== undefined ? JSON.stringify(media_urls) : post[0].media_urls,
                postId
            ]
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

// Toggle Like on Post
exports.toggleLike = async (req, res) => {
    const postId = req.params.id;
    const userId = req.user.id;

    try {
        const [existing] = await db.execute(
            'SELECT * FROM post_likes WHERE post_id = ? AND user_id = ?',
            [postId, userId]
        );

        if (existing.length > 0) {
            // Unlike
            await db.execute('DELETE FROM post_likes WHERE post_id = ? AND user_id = ?', [postId, userId]);
            res.json({ liked: false });
        } else {
            // Like
            await db.execute('INSERT INTO post_likes (post_id, user_id) VALUES (?, ?)', [postId, userId]);

            // Log the activity
            await db.execute(
                'INSERT INTO activities (user_id, action_type, entity_title) VALUES (?, ?, ?)',
                [userId, 'liked_post', 'a community post']
            );

            // Notify the post author
            try {
                const [targetPost] = await db.execute('SELECT user_id, title FROM posts WHERE id = ?', [postId]);
                if (targetPost.length > 0 && targetPost[0].user_id !== userId) {
                    await db.execute(
                        'INSERT INTO notifications (user_id, sender_id, type, post_id) VALUES (?, ?, ?, ?)',
                        [targetPost[0].user_id, userId, 'like_post', postId]
                    );

                    // Send FCM
                    const [[sender]] = await db.execute('SELECT name, profile_picture FROM users WHERE id = ?', [userId]);
                    const [[recipient]] = await db.execute('SELECT fcm_token FROM users WHERE id = ?', [targetPost[0].user_id]);
                    
                    if (recipient && recipient.fcm_token) {
                        const message = {
                            notification: {
                                title: `${sender.name}`,
                                body: `Liked your post: "${targetPost[0].title}"`,
                                image: sender.profile_picture || ''
                            },
                            data: {
                                type: 'like_post',
                                postId: postId.toString(),
                                imageUrl: sender.profile_picture || ''
                            },
                            token: recipient.fcm_token
                        };
                        await admin.messaging().send(message).catch(e => console.error('FCM Error:', e.message));
                    }
                }
            } catch (err) {
                console.error('Like Notification Error:', err.message);
            }

            res.json({ liked: true });
        }
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server Error');
    }
};

// Toggle Like on Comment
exports.toggleCommentLike = async (req, res) => {
    const commentId = req.params.id;
    const userId = req.user.id;

    try {
        const [existing] = await db.execute(
            'SELECT * FROM comment_likes WHERE comment_id = ? AND user_id = ?',
            [commentId, userId]
        );

        if (existing.length > 0) {
            // Unlike
            await db.execute('DELETE FROM comment_likes WHERE comment_id = ? AND user_id = ?', [commentId, userId]);
            res.json({ liked: false });
        } else {
            // Like
            await db.execute('INSERT INTO comment_likes (comment_id, user_id) VALUES (?, ?)', [commentId, userId]);

            // Notify the comment author
            const [targetComm] = await db.execute('SELECT user_id, post_id FROM comments WHERE id = ?', [commentId]);
            if (targetComm.length > 0 && targetComm[0].user_id !== userId) {
                await db.execute(
                    'INSERT INTO notifications (user_id, sender_id, type, post_id, comment_id) VALUES (?, ?, ?, ?, ?)',
                    [targetComm[0].user_id, userId, 'like_comment', targetComm[0].post_id, commentId]
                );
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
            SELECT id, name, profile_picture, email 
            FROM users 
            WHERE (name LIKE ? OR email LIKE ?) AND id != ? 
            LIMIT 15
        `, [`%${q}%`, `%${q}%`, req.user.id]);

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
            SELECT 
                p.*, 
                u.name as userName, 
                u.profile_picture as userImage,
                u.current_streak,
                (SELECT COUNT(*) FROM post_likes pl WHERE pl.post_id = p.id) as likeCount,
                (SELECT COUNT(*) FROM comments c WHERE c.post_id = p.id) as commentCount
            FROM posts p
            JOIN users u ON p.user_id = u.id
            WHERE p.title LIKE ? OR p.body LIKE ?
            ORDER BY p.created_at DESC
            LIMIT 20
        `, [`%${q}%`, `%${q}%`]);

        const formattedPosts = posts.map(post => ({
            ...post,
            tags: typeof post.tags === 'string' ? JSON.parse(post.tags) : post.tags
        }));

        res.json(formattedPosts);
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
        // Use JSON_CONTAINS or simple LIKE if stored as JSON string
        const [posts] = await db.execute(`
            SELECT 
                p.*, 
                u.name as userName, 
                u.profile_picture as userImage,
                u.current_streak,
                (SELECT COUNT(*) FROM post_likes pl WHERE pl.post_id = p.id) as likeCount,
                (SELECT COUNT(*) FROM comments c WHERE c.post_id = p.id) as commentCount
            FROM posts p
            JOIN users u ON p.user_id = u.id
            WHERE p.tags LIKE ?
            ORDER BY p.created_at DESC
            LIMIT 20
        `, [`%${q}%`]);

        const formattedPosts = posts.map(post => ({
            ...post,
            tags: typeof post.tags === 'string' ? JSON.parse(post.tags) : post.tags
        }));

        res.json(formattedPosts);
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server Error');
    }
};

// Get Recommended Users (People like you)
exports.getRecommendations = async (req, res) => {
    try {
        // Find users with overlapping interests OR mutual friends
        // Exclude self and current friends/pending requests
        const userId = req.user.id;

        const [recommended] = await db.execute(`
            SELECT DISTINCT u.id, u.name, u.profile_picture as userImage,
                (SELECT COUNT(*) FROM user_interests ui2 WHERE ui2.user_id = u.id AND ui2.interest_id IN (
                    SELECT interest_id FROM user_interests WHERE user_id = ?
                )) as commonInterests,
                (SELECT COUNT(*) FROM friendships f1 JOIN friendships f2 ON f1.receiver_id = f2.receiver_id 
                 WHERE f1.requester_id = ? AND f2.requester_id = u.id AND f1.status = 'accepted' AND f2.status = 'accepted') as mutualFriends
            FROM users u
            WHERE u.id != ?
            AND u.id NOT IN (
                SELECT receiver_id FROM friendships WHERE requester_id = ?
                UNION
                SELECT requester_id FROM friendships WHERE receiver_id = ?
            )
            ORDER BY commonInterests DESC, mutualFriends DESC
            LIMIT 15
        `, [userId, userId, userId, userId, userId]);

        res.json(recommended);
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server Error');
    }
};

// Get user activities (Recent activities for profile)
exports.getUserActivities = async (req, res) => {
    const targetUserId = req.params.id || req.user.id;
    try {
        const [activities] = await db.execute(`
            SELECT id, action_type, entity_title as title, created_at
            FROM activities
            WHERE user_id = ?
            ORDER BY created_at DESC
            LIMIT 10
        `, [targetUserId]);

        res.json(activities);
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server Error');
    }
};
