const express = require('express');
const cors = require('cors');
const http = require('http');
const { Server } = require('socket.io');
require('dotenv').config();

// Import routes
const authRoutes = require('./routes/authRoutes');
const communityRoutes = require('./routes/communityRoutes');
const chatRoutes = require('./routes/chatRoutes');
const interestRoutes = require('./routes/interestRoutes');
const uploadRoutes = require('./routes/uploadRoutes');
const userRoutes = require('./routes/userRoutes');
const scholarshipRoutes = require('./routes/scholarshipRoutes');
const favoritesRoutes = require('./routes/favoritesRoutes');
const careerRoutes = require('./routes/careerRoutes');
const notificationRoutes = require('./routes/notificationRoutes');
const stickerRoutes = require('./routes/stickerRoutes');
const aiRoutes = require('./routes/aiRoutes');
require('./config/passport'); // Import passport configuration

const app = express();
const server = http.createServer(app);
const io = new Server(server, {
    cors: {
        origin: "*", // Adjust as needed for security
        methods: ["GET", "POST"]
    }
});

// Middleware
app.use(cors());
app.use(express.json({ limit: '50mb' }));
app.use(express.urlencoded({ limit: '50mb', extended: true }));

app.use('/api/auth', authRoutes);
app.use('/api/interests', interestRoutes);
app.use('/api/community', communityRoutes);
app.use('/api/chat', chatRoutes);
app.use('/api/upload', uploadRoutes);
app.use('/api/users', userRoutes);
app.use('/api/scholarships', scholarshipRoutes);
app.use('/api/favorites', favoritesRoutes);
app.use('/api/careers', careerRoutes);
app.use('/api/notifications', notificationRoutes);
app.use('/api/stickers', stickerRoutes);
app.use('/api/ai', aiRoutes);

const db = require('./config/db');

// Socket user mapping
const userSockets = new Map();

io.on('connection', (socket) => {
    console.log('A user connected:', socket.id);

    socket.on('user_connected', (userId) => {
        if (!userId) return;
        userSockets.set(socket.id, userId);
        socket.join(`user_${userId}`);
        
        // Broadcast that this user is online
        io.emit('user_status_changed', { userId, status: 'online' });
    });

    socket.on('join_conversation', (conversationId) => {
        socket.join(`conversation_${conversationId}`);
        console.log(`User joined conversation: ${conversationId}`);
    });

    socket.on('send_message', async (data) => {
        try {
            const [participants] = await db.execute(
                'SELECT user_id FROM conversation_participants WHERE conversation_id = ?',
                [data.conversationId]
            );
            
            let broadcast = io.to(`conversation_${data.conversationId}`);
            participants.forEach(p => {
                broadcast = broadcast.to(`user_${p.user_id}`);
            });
            
            broadcast.emit('receive_message', data);
        } catch (e) {
            console.error('Error fetching participants for notification:', e);
            io.to(`conversation_${data.conversationId}`).emit('receive_message', data);
        }
    });

    socket.on('edit_message', async (data) => {
        try {
            const [participants] = await db.execute(
                'SELECT user_id FROM conversation_participants WHERE conversation_id = ?',
                [data.conversationId]
            );
            
            let broadcast = io.to(`conversation_${data.conversationId}`);
            participants.forEach(p => {
                broadcast = broadcast.to(`user_${p.user_id}`);
            });
            
            broadcast.emit('message_edited', data);
        } catch (e) {
            console.error('Error fetching participants for notification:', e);
            io.to(`conversation_${data.conversationId}`).emit('message_edited', data);
        }
    });

    socket.on('delete_message', async (data) => {
        try {
            const [participants] = await db.execute(
                'SELECT user_id FROM conversation_participants WHERE conversation_id = ?',
                [data.conversationId]
            );
            
            let broadcast = io.to(`conversation_${data.conversationId}`);
            participants.forEach(p => {
                broadcast = broadcast.to(`user_${p.user_id}`);
            });
            
            broadcast.emit('message_deleted', data);
        } catch (e) {
            console.error('Error fetching participants for notification:', e);
            io.to(`conversation_${data.conversationId}`).emit('message_deleted', data);
        }
    });

    socket.on('seen_message', async (data) => {
        const { conversationId, userId } = data;
        io.to(`conversation_${conversationId}`).emit('message_seen', data);
        
        if (conversationId && userId) {
            try {
                await db.execute(
                    'UPDATE messages SET is_read = 1 WHERE conversation_id = ? AND sender_id != ? AND (is_read = 0 OR is_read IS NULL)',
                    [conversationId, userId]
                );
            } catch (e) {
                console.error('Error updating read status:', e);
            }
        }
    });

    socket.on('disconnect', async () => {
        console.log('User disconnected');
        const userId = userSockets.get(socket.id);
        if (userId) {
            userSockets.delete(socket.id);
            // Check if user has other active sockets
            const isUserStillConnected = Array.from(userSockets.values()).includes(userId);
            
            if (!isUserStillConnected) {
                try {
                    // Update last seen to current timestamp (SQL Server)
                    const lastSeenDate = new Date().toISOString().slice(0, 19).replace('T', ' ');
                    await db.execute('UPDATE users SET last_seen = CURRENT_TIMESTAMP WHERE id = ?', [userId]);
                    io.emit('user_status_changed', { userId, status: 'offline', last_seen: lastSeenDate });
                } catch (e) {
                    console.error('Error updating last seen:', e);
                }
            }
        }
    });
});

// Health Check for Render (Keep-Alive)
app.get('/health', (req, res) => {
    res.status(200).send('Server is alive and breathing');
});

// Test Route
app.get('/', (req, res) => {
    res.send('API is running...');
});

const PORT = process.env.PORT || 5000;

server.listen(PORT, '0.0.0.0', () => {
    console.log(`Server running on port ${PORT} at 0.0.0.0`);
});
