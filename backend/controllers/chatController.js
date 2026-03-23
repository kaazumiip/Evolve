const db = require('../config/db');
const admin = require('../config/firebase');

// Get all conversations for the user
exports.getConversations = async (req, res) => {
    try {
        // This complex query fetches the last message and the other participant's info
        // Simplified assumption: 1-on-1 chats mostly
        const [conversations] = await db.execute(`
            SELECT 
                c.id, 
                c.updated_at,
                (
                    SELECT m.content FROM messages m 
                    WHERE m.conversation_id = c.id 
                    ORDER BY m.created_at DESC LIMIT 1
                ) as lastMessage,
                (
                    SELECT m.created_at FROM messages m 
                    WHERE m.conversation_id = c.id 
                    ORDER BY m.created_at DESC LIMIT 1
                ) as lastMessageTime,
                (
                    SELECT COUNT(*) FROM messages m 
                    WHERE m.conversation_id = c.id AND m.is_read = 0 AND m.sender_id != cp_me.user_id
                ) as unreadCount,
                u.id as otherUserId,
                u.name as otherUserName,
                u.profile_picture as otherUserImage,
                u.last_seen as otherUserLastSeen,
                c.status,
                c.archived_by,
                (
                    SELECT m.type FROM messages m 
                    WHERE m.conversation_id = c.id 
                    ORDER BY m.created_at DESC LIMIT 1
                ) as lastMessageType,
                (
                    SELECT m.media_gallery FROM messages m 
                    WHERE m.conversation_id = c.id 
                    ORDER BY m.created_at DESC LIMIT 1
                ) as lastMediaGallery
            FROM conversations c
            JOIN conversation_participants cp_me ON c.id = cp_me.conversation_id
            JOIN conversation_participants cp_other ON c.id = cp_other.conversation_id
            JOIN users u ON cp_other.user_id = u.id
            WHERE cp_me.user_id = ? AND cp_other.user_id != cp_me.user_id
              AND NOT EXISTS (
                  SELECT 1 FROM user_blocks 
                  WHERE (blocker_id = cp_me.user_id AND blocked_id = u.id) 
                     OR (blocker_id = u.id AND blocked_id = cp_me.user_id)
              )
            ORDER BY c.updated_at DESC
        `, [req.user.id]);

        res.json(conversations);
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server Error');
    }
};

// Create or get existing conversation with a user
exports.startConversation = async (req, res) => {
    const { targetUserId } = req.body;
    const userId = req.user.id;

    try {
        // Check if conversation already exists between these two
        const [existing] = await db.execute(`
            SELECT c.id 
            FROM conversations c
            JOIN conversation_participants cp1 ON c.id = cp1.conversation_id
            JOIN conversation_participants cp2 ON c.id = cp2.conversation_id
            WHERE cp1.user_id = ? AND cp2.user_id = ?
        `, [userId, targetUserId]);

        if (existing.length > 0) {
            const conversationId = existing[0].id;
            // If it exists but is archived, check if they are friends now
            const [isFriend] = await db.execute(
                'SELECT * FROM friendships WHERE (requester_id = ? AND receiver_id = ? AND status = "accepted") OR (requester_id = ? AND receiver_id = ? AND status = "accepted")',
                [userId, targetUserId, targetUserId, userId]
            );
            
            if (isFriend.length > 0) {
                await db.execute('UPDATE conversations SET status = "active", archived_by = NULL WHERE id = ?', [conversationId]);
            }
            
            return res.json({ conversationId });
        }

        // Check if they are friends for new conversation
        const [isFriend] = await db.execute(
            'SELECT * FROM friendships WHERE (requester_id = ? AND receiver_id = ? AND status = "accepted") OR (requester_id = ? AND receiver_id = ? AND status = "accepted")',
            [userId, targetUserId, targetUserId, userId]
        );

        const status = isFriend.length > 0 ? 'active' : 'archived';
        // If not friends, the RECEIVER sees it as archived
        const archivedBy = isFriend.length > 0 ? null : targetUserId;

        // Create new conversation
        const [result] = await db.execute(
            'INSERT INTO conversations (created_at, updated_at, status, archived_by) VALUES (DATE_ADD(UTC_TIMESTAMP(), INTERVAL 7 HOUR), DATE_ADD(UTC_TIMESTAMP(), INTERVAL 7 HOUR), ?, ?)',
            [status, archivedBy]
        ); 
        const conversationId = result.insertId;

        await db.execute('INSERT INTO conversation_participants (conversation_id, user_id, joined_at) VALUES (?, ?, DATE_ADD(UTC_TIMESTAMP(), INTERVAL 7 HOUR)), (?, ?, DATE_ADD(UTC_TIMESTAMP(), INTERVAL 7 HOUR))',
            [conversationId, userId, targetUserId]
        );

        res.json({ conversationId, status });
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server Error');
    }
};

// Get messages for a conversation
exports.getMessages = async (req, res) => {
    const conversationId = req.params.id;

    try {
        const [messages] = await db.execute(`
            SELECT 
                m.id, m.conversation_id, m.sender_id, m.content, m.image_url, m.created_at, m.is_read, m.type, m.media_url, m.reply_to_id, m.is_edited, m.deleted_at, m.media_gallery,
                u.name as senderName, 
                u.profile_picture as senderImage, 
                rm.content as replyToContent,
                ru.name as replyToSenderName
            FROM messages m
            JOIN users u ON m.sender_id = u.id
            LEFT JOIN messages rm ON m.reply_to_id = rm.id
            LEFT JOIN users ru ON rm.sender_id = ru.id
            WHERE m.conversation_id = ? AND m.deleted_at IS NULL
            ORDER BY m.created_at ASC
        `, [conversationId]);

        // Mark as read (simple logic: if I fetch them, I read them)
        // In real app, might want more granular read receipts
        await db.execute('UPDATE messages SET is_read = TRUE WHERE conversation_id = ? AND sender_id != ?',
            [conversationId, req.user.id]);

        res.json(messages);
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server Error');
    }
};

// Send a message
exports.sendMessage = async (req, res) => {
    const conversationId = req.params.id;
    const { content, image_url, media_url, type, reply_to_id, media_gallery } = req.body;
    const userId = req.user.id;

    try {
        // 1. Block Check
        const [participants] = await db.execute(
            'SELECT user_id FROM conversation_participants WHERE conversation_id = ? AND user_id != ?',
            [conversationId, userId]
        );
        
        if (participants.length > 0) {
            const targetId = participants[0].user_id;
            const [isBlocked] = await db.execute(
                'SELECT * FROM user_blocks WHERE (blocker_id = ? AND blocked_id = ?) OR (blocker_id = ? AND blocked_id = ?)',
                [userId, targetId, targetId, userId]
            );
            if (isBlocked.length > 0) {
                return res.status(403).json({ msg: "Cannot message blocked user", blocked: true });
            }
        }

        // 2. Stranger/Archived Check
        const [conv] = await db.execute(
            'SELECT status, archived_by FROM conversations WHERE id = ?',
            [conversationId]
        );

        if (conv.length > 0 && conv[0].status === 'archived' && conv[0].archived_by === userId) {
            return res.status(403).json({ 
                msg: "Please accept the message request before replying", 
                isArchived: true 
            });
        }

        const [result] = await db.execute(
            'INSERT INTO messages (conversation_id, sender_id, content, image_url, media_url, type, reply_to_id, media_gallery, created_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, DATE_ADD(UTC_TIMESTAMP(), INTERVAL 7 HOUR))',
            [conversationId, userId, content || null, image_url || null, media_url || null, type || 'text', reply_to_id || null, media_gallery ? JSON.stringify(media_gallery) : null]
        );

        await db.execute('UPDATE conversations SET updated_at = DATE_ADD(UTC_TIMESTAMP(), INTERVAL 7 HOUR) WHERE id = ?', [conversationId]);
        
        // ... (rest of sendMessage logic)

        const [msg] = await db.execute(`
            SELECT 
                m.id, m.conversation_id, m.sender_id, m.content, m.image_url, m.created_at, m.is_read, m.type, m.media_url, m.reply_to_id, m.is_edited, m.deleted_at, m.media_gallery,
                u.name as senderName, 
                u.profile_picture as senderImage,
                rm.content as replyToContent,
                ru.name as replyToSenderName
            FROM messages m
            JOIN users u ON m.sender_id = u.id
            LEFT JOIN messages rm ON m.reply_to_id = rm.id
            LEFT JOIN users ru ON rm.sender_id = ru.id
            WHERE m.id = ?
        `, [result.insertId]);

        const finalMsg = msg[0];

        // Send Push Notification
        try {
            const [recipientRows] = await db.execute(`
                SELECT u.id, u.fcm_token 
                FROM conversation_participants cp
                JOIN users u ON cp.user_id = u.id
                WHERE cp.conversation_id = ? AND cp.user_id != ?
            `, [conversationId, req.user.id]);

            if (recipientRows.length > 0 && recipientRows[0].fcm_token) {
                const message = {
                    notification: {
                        title: `${finalMsg.senderName}`,
                        body: finalMsg.content || (finalMsg.type === 'image' ? 'Sent an image' : 'New attachment'),
                        image: finalMsg.senderImage || ''
                    },
                    data: {
                        conversationId: conversationId.toString(),
                        senderId: req.user.id.toString(),
                        type: 'chat',
                        imageUrl: finalMsg.senderImage || ''
                    },
                    token: recipientRows[0].fcm_token
                };

                await admin.messaging().send(message);
            }
        } catch (pushErr) {
            console.warn('Push notification failed:', pushErr.message);
        }

        res.json(finalMsg);
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server Error');
    }
};

// Edit a message
exports.editMessage = async (req, res) => {
    const { id } = req.params;
    const { content } = req.body;

    try {
        // Check if message belongs to user
        const [msg] = await db.execute('SELECT * FROM messages WHERE id = ?', [id]);
        if (msg.length === 0) return res.status(404).json({ msg: 'Message not found' });
        if (msg[0].sender_id !== req.user.id) return res.status(401).json({ msg: 'Unauthorized' });

        await db.execute(
            'UPDATE messages SET content = ?, is_edited = TRUE WHERE id = ?',
            [content, id]
        );

        const [updated] = await db.execute(`
            SELECT m.*, u.name as senderName, u.profile_picture as senderImage
            FROM messages m
            JOIN users u ON m.sender_id = u.id
            WHERE m.id = ?
        `, [id]);

        res.json(updated[0]);
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server Error');
    }
};

// Delete a message (soft delete)
exports.deleteMessage = async (req, res) => {
    const { id } = req.params;

    try {
        // Check if message belongs to user
        const [msg] = await db.execute('SELECT * FROM messages WHERE id = ?', [id]);
        if (msg.length === 0) return res.status(404).json({ msg: 'Message not found' });
        if (msg[0].sender_id !== req.user.id) return res.status(401).json({ msg: 'Unauthorized' });

        await db.execute(
            'UPDATE messages SET deleted_at = CURRENT_TIMESTAMP WHERE id = ?',
            [id]
        );

        res.json({ id, conversationId: msg[0].conversation_id, msg: 'Message deleted' });
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server Error');
    }
};

// Accept stranger chat
exports.handleStrangerChat = async (req, res) => {
    const { conversationId, action } = req.body; // action: 'accept' or 'reject'
    const userId = req.user.id;

    try {
        if (action === 'accept') {
            await db.execute(
                'UPDATE conversations SET status = "active", archived_by = NULL WHERE id = ? AND archived_by = ?',
                [conversationId, userId]
            );
            res.json({ msg: 'Chat accepted' });
        } else {
            // Delete conversation and messages if rejected
            await db.execute('DELETE FROM messages WHERE conversation_id = ?', [conversationId]);
            await db.execute('DELETE FROM conversation_participants WHERE conversation_id = ?', [conversationId]);
            await db.execute('DELETE FROM conversations WHERE id = ?', [conversationId]);
            res.json({ msg: 'Chat rejected and deleted' });
        }
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server Error');
    }
};

// Delete entire conversation
exports.deleteConversation = async (req, res) => {
    const { id } = req.params;
    const userId = req.user.id;

    try {
        // Only allow if user is a participant
        const [participant] = await db.execute(
            'SELECT * FROM conversation_participants WHERE conversation_id = ? AND user_id = ?',
            [id, userId]
        );

        if (participant.length === 0) {
            return res.status(401).json({ msg: 'Unauthorized' });
        }

        // We could do a soft delete, but for now full deletion of history for everyone in this 1-on-1 chat
        await db.execute('DELETE FROM messages WHERE conversation_id = ?', [id]);
        await db.execute('DELETE FROM conversation_participants WHERE conversation_id = ?', [id]);
        await db.execute('DELETE FROM conversations WHERE id = ?', [id]);

        res.json({ msg: 'Conversation deleted successfully' });
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server Error');
    }
};
