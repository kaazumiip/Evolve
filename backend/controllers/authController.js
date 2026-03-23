const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const db = require('../config/db');
const axios = require('axios');
const mailService = require('../utils/mailService');

// Generate JWT Token
exports.generateToken = (id) => {
    return jwt.sign({ user: { id } }, process.env.JWT_SECRET, {
        expiresIn: '30d'
    });
};

exports.register = async (req, res) => {
    const { name, email, password, otp } = req.body;
    console.log('Registering user:', email, 'OTP:', otp);
    if (!otp) {
        return res.status(400).json({ msg: 'OTP is required for registration' });
    }

    try {
        // Verify OTP
        const [otpRows] = await db.execute(
            'SELECT * FROM otps WHERE email = ? AND otp = ? AND type = ? AND expires_at > NOW()',
            [email, otp, 'registration']
        );

        if (otpRows.length === 0) {
            return res.status(400).json({ msg: 'Invalid or expired OTP' });
        }

        let [user] = await db.execute('SELECT * FROM users WHERE email = ?', [email]);

        if (user.length > 0) {
            return res.status(400).json({ msg: 'User already exists' });
        }

        const salt = await bcrypt.genSalt(10);
        const hashedPassword = await bcrypt.hash(password, salt);

        const [result] = await db.execute(
            'INSERT INTO users (name, email, password, is_password_set, last_seen) VALUES (?, ?, ?, ?, NOW())',
            [name, email, hashedPassword, 1]
        );

        // Delete used OTP
        await db.execute('DELETE FROM otps WHERE email = ? AND type = ?', [email, 'registration']);

        const token = exports.generateToken(result.insertId);

        res.json({
            token,
            user: {
                id: result.insertId,
                name,
                email,
                interestIds: [],
                subInterestIds: [],
                is_password_set: 1
            }
        });
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server Error');
    }
};

exports.sendOTP = async (req, res) => {
    const { email, type } = req.body; // type: 'registration' or 'password_reset'
    console.log('Sending OTP to:', email, 'Type:', type);
    if (!email || !type) return res.status(400).json({ msg: 'Email and type are required' });

    try {
        const otp = Math.floor(100000 + Math.random() * 900000).toString();
        const expiresAt = new Date(Date.now() + 10 * 60 * 1000); // 10 mins

        // Delete old OTPs for this email/type
        await db.execute('DELETE FROM otps WHERE email = ? AND type = ?', [email, type]);

        // Insert new OTP
        await db.execute(
            'INSERT INTO otps (email, otp, type, expires_at) VALUES (?, ?, ?, ?)',
            [email, otp, type, expiresAt]
        );
        console.log(`Stored OTP ${otp} for ${email} with type ${type}`);

        // Send Email
        const mailResult = await mailService.sendOTP(email, otp, type);
        if (!mailResult.success) {
            console.error('--- MAIL FAILURE ---', mailResult.error);
            return res.status(500).json({ 
                msg: 'Failed to send OTP email',
                error: mailResult.error?.message 
            });
        }

        res.json({ msg: 'OTP sent successfully' });
    } catch (err) {
        console.error(err);
        res.status(500).send('Server Error');
    }
};

exports.verifyOTP = async (req, res) => {
    const { email, otp, type } = req.body;
    if (!email || !otp || !type) return res.status(400).json({ msg: 'Missing parameters' });

    try {
        const [rows] = await db.execute(
            'SELECT * FROM otps WHERE email = ? AND otp = ? AND type = ? AND expires_at > NOW()',
            [email, otp, type]
        );

        if (rows.length === 0) {
            return res.status(400).json({ msg: 'Invalid or expired OTP', success: false });
        }

        res.json({ msg: 'OTP verified successfully', success: true });
    } catch (err) {
        console.error(err);
        res.status(500).send('Server Error');
    }
};

exports.forgotPassword = async (req, res) => {
    const { email } = req.body;
    if (!email) return res.status(400).json({ msg: 'Email is required' });

    try {
        const [userRows] = await db.execute('SELECT * FROM users WHERE email = ?', [email]);
        if (userRows.length === 0) {
            return res.status(400).json({ msg: 'User with this email does not exist' });
        }

        const otp = Math.floor(100000 + Math.random() * 900000).toString();
        const expiresAt = new Date(Date.now() + 10 * 60 * 1000);

        await db.execute('DELETE FROM otps WHERE email = ? AND type = ?', [email, 'password_reset']);
        await db.execute(
            'INSERT INTO otps (email, otp, type, expires_at) VALUES (?, ?, ?, ?)',
            [email, otp, 'password_reset', expiresAt]
        );

        const mailResult = await mailService.sendOTP(email, otp, 'password_reset');
        if (!mailResult.success) {
            console.error('--- FORGOT PWD MAIL FAILURE ---', mailResult.error);
            return res.status(500).json({ msg: 'Failed to send reset code' });
        }

        res.json({ msg: 'Password reset OTP sent' });
    } catch (err) {
        console.error(err);
        res.status(500).send('Server Error');
    }
};

exports.resetPassword = async (req, res) => {
    const { email, otp, newPassword } = req.body;
    if (!email || !otp || !newPassword) return res.status(400).json({ msg: 'Missing fields' });

    try {
        const [otpRows] = await db.execute(
            'SELECT * FROM otps WHERE email = ? AND otp = ? AND type = ? AND expires_at > NOW()',
            [email, otp, 'password_reset']
        );

        if (otpRows.length === 0) {
            return res.status(400).json({ msg: 'Invalid or expired OTP' });
        }

        const salt = await bcrypt.genSalt(10);
        const hashedPassword = await bcrypt.hash(newPassword, salt);

        await db.execute('UPDATE users SET password = ? WHERE email = ?', [hashedPassword, email]);
        await db.execute('DELETE FROM otps WHERE email = ? AND type = ?', [email, 'password_reset']);

        res.json({ msg: 'Password reset successfully' });
    } catch (err) {
        console.error(err);
        res.status(500).send('Server Error');
    }
};

const { OAuth2Client } = require('google-auth-library');
const client = new OAuth2Client(process.env.GOOGLE_CLIENT_ID);

const updateStreak = async (user) => {
    // 1. Helper for consistent local date string (YYYY-MM-DD at +07:00)
    const formatLocalDate = (date) => {
        const local = new Date(date.getTime() + (7 * 60 * 60 * 1000));
        return local.toISOString().split('T')[0];
    };

    const todayStr = formatLocalDate(new Date());

    let lastLoginStr = null;
    if (user.last_login_date) {
        try {
            // mysql2 returns DATE as a Date object, but its UTC representation
            // may differ from the literal YYYY-MM-DD stored.
            // We use the same offset helper to match our comparison logic.
            const d = new Date(user.last_login_date);
            lastLoginStr = formatLocalDate(d);
        } catch (e) {
            console.error("Error parsing last_login_date:", e.message);
        }
    }

    // BREAK: If we already logged in TODAY, do not increment. Return existing.
    if (todayStr === lastLoginStr) {
        const [weeklyRows] = await db.execute(`
            SELECT login_date FROM user_daily_logins 
            WHERE user_id = ? 
            AND login_date >= DATE_SUB(CURDATE(), INTERVAL (WEEKDAY(CURDATE())) DAY)
        `, [user.id]);
        
        const thisWeekLogins = [...new Set(weeklyRows.map(row => {
            const d = new Date(row.login_date);
            return (d.getDay() + 6) % 7;
        }))];

        return {
            currentStreak: user.current_streak || 0,
            longestStreak: user.longest_streak || 0,
            thisWeekLogins
        };
    }

    let currentStreak = user.current_streak || 0;
    let longestStreak = user.longest_streak || 0;

    if (lastLoginStr) {
        // Date difference calculation using days from Midnight to Midnight
        const t = new Date(todayStr);
        const l = new Date(lastLoginStr);
        const diffTime = Math.abs(t - l);
        const diffDays = Math.round(diffTime / (1000 * 60 * 60 * 24));

        if (diffDays === 1) {
            // Consecutive login
            currentStreak += 1;
        } else if (diffDays > 1) {
            // Broken streak, reset to 1
            currentStreak = 1;
        }
    } else {
        // First login ever
        currentStreak = 1;
    }

    if (currentStreak > longestStreak) {
        longestStreak = currentStreak;
    }

    // Save to DB (last_login_date is stored as today's local string)
    await db.execute(
        'UPDATE users SET current_streak = ?, longest_streak = ?, last_login_date = ? WHERE id = ?',
        [currentStreak, longestStreak, todayStr, user.id]
    );

    try {
        await db.execute('INSERT IGNORE INTO user_daily_logins (user_id, login_date) VALUES (?, ?)', [user.id, todayStr]);
    } catch (e) {
        console.log("Daily login log error (minor): ", e.message);
    }

    const [weeklyRows] = await db.execute(`
        SELECT login_date FROM user_daily_logins 
        WHERE user_id = ? 
        AND login_date >= DATE_SUB(CURDATE(), INTERVAL (WEEKDAY(CURDATE())) DAY)
    `, [user.id]);

    const thisWeekLogins = [...new Set(weeklyRows.map(row => {
        const d = new Date(row.login_date);
        return (d.getDay() + 6) % 7; // Monday = 0
    }))];

    return { currentStreak, longestStreak, thisWeekLogins };
};

exports.googleNativeLogin = async (req, res) => {
    const { idToken } = req.body;

    try {
        const ticket = await client.verifyIdToken({
            idToken,
            audience: process.env.GOOGLE_CLIENT_ID,
        });
        const payload = ticket.getPayload();
        const { email, name, sub: googleId } = payload;

        // Check if user exists
        let [rows] = await db.execute('SELECT * FROM users WHERE email = ?', [email]);
        let user;

        if (rows.length > 0) {
            user = rows[0];
            if (!user.google_id) {
                await db.execute('UPDATE users SET google_id = ? WHERE id = ?', [googleId, user.id]);
            }
        } else {
            const randomPassword = Math.random().toString(36).slice(-8) + Math.random().toString(36).slice(-8);
            const salt = await bcrypt.genSalt(10);
            const hashedPassword = await bcrypt.hash(randomPassword, salt);

            const [result] = await db.execute(
                'INSERT INTO users (name, email, password, google_id, is_password_set, last_seen) VALUES (?, ?, ?, ?, ?, NOW())',
                [name, email, hashedPassword, googleId, 0]
            );
            user = { id: result.insertId, name, email, is_password_set: 0 };
        }

        const token = exports.generateToken(user.id);

        // Update Streak
        const { currentStreak, longestStreak, thisWeekLogins } = await updateStreak(user);

        // Parallelize interest fetching
        const [userInterestRows, userSubInterestRows] = await Promise.all([
            db.execute('SELECT interest_id FROM user_interests WHERE user_id = ?', [user.id]),
            db.execute('SELECT sub_interest_id FROM user_sub_interests WHERE user_id = ?', [user.id])
        ]);

        const interestIds = userInterestRows[0].map(row => row.interest_id);
        const subInterestIds = userSubInterestRows[0].map(row => row.sub_interest_id);

        res.json({
            token,
            user: {
                id: user.id,
                name: user.name,
                email: user.email,
                profile_picture: user.profile_picture,
                current_streak: currentStreak,
                longest_streak: longestStreak,
                this_week_logins: thisWeekLogins,
                interestIds,
                subInterestIds,
                is_password_set: user.is_password_set || 0
            }
        });
    } catch (err) {
        console.error('Google Native Login Error:', err.message);
        res.status(401).json({ msg: err.message });
    }
};

exports.facebookLogin = async (req, res) => {
    const { accessToken } = req.body;

    try {
        // Verify token with Facebook Graph API
        const fbResponse = await axios.get(
            `https://graph.facebook.com/me?access_token=${accessToken}&fields=id,name,email`
        );

        const { email, name, id: facebookId } = fbResponse.data;

        if (!email) {
            return res.status(400).json({ msg: 'Email not provided by Facebook' });
        }

        // Check if user exists by email or facebook_id
        let [rows] = await db.execute('SELECT * FROM users WHERE email = ?', [email]);
        let user;

        if (rows.length > 0) {
            user = rows[0];
            if (!user.facebook_id) {
                await db.execute('UPDATE users SET facebook_id = ? WHERE id = ?', [facebookId, user.id]);
            }
        } else {
            const randomPassword = Math.random().toString(36).slice(-8) + Math.random().toString(36).slice(-8);
            const salt = await bcrypt.genSalt(10);
            const hashedPassword = await bcrypt.hash(randomPassword, salt);

            const [result] = await db.execute(
                'INSERT INTO users (name, email, password, facebook_id, is_password_set, last_seen) VALUES (?, ?, ?, ?, ?, NOW())',
                [name, email, hashedPassword, facebookId, 0]
            );
            user = { id: result.insertId, name, email, is_password_set: 0 };
        }

        const token = exports.generateToken(user.id);
        const { currentStreak, longestStreak, thisWeekLogins } = await updateStreak(user);

        const [userInterestRows, userSubInterestRows] = await Promise.all([
            db.execute('SELECT interest_id FROM user_interests WHERE user_id = ?', [user.id]),
            db.execute('SELECT sub_interest_id FROM user_sub_interests WHERE user_id = ?', [user.id])
        ]);

        const interestIds = userInterestRows[0].map(row => row.interest_id);
        const subInterestIds = userSubInterestRows[0].map(row => row.sub_interest_id);

        res.json({
            token,
            user: {
                id: user.id,
                name: user.name,
                email: user.email,
                profile_picture: user.profile_picture,
                current_streak: currentStreak,
                longest_streak: longestStreak,
                this_week_logins: thisWeekLogins,
                interestIds,
                subInterestIds,
                is_password_set: user.is_password_set || 0
            }
        });
    } catch (err) {
        console.error('Facebook Login Error:', err.message);
        res.status(401).json({ msg: err.message });
    }
};

exports.login = async (req, res) => {
    const { email, password } = req.body;

    try {
        // Fetch user and all interests/sub-interests in one go using JSON aggregation if supported, or multiple results
        const [rows] = await db.execute('SELECT * FROM users WHERE email = ?', [email]);

        if (rows.length === 0) {
            return res.status(400).json({ msg: 'Invalid Credentials' });
        }

        const user = rows[0];

        const isMatch = await bcrypt.compare(password, user.password);

        if (!isMatch) {
            return res.status(400).json({ msg: 'Invalid Credentials' });
        }

        const token = exports.generateToken(user.id);

        // Parallelize interest fetching
        const [userInterestRows, userSubInterestRows] = await Promise.all([
            db.execute('SELECT interest_id FROM user_interests WHERE user_id = ?', [user.id]),
            db.execute('SELECT sub_interest_id FROM user_sub_interests WHERE user_id = ?', [user.id])
        ]);

        const interestIds = userInterestRows[0].map(row => row.interest_id);
        const subInterestIds = userSubInterestRows[0].map(row => row.sub_interest_id);

        // Update Streak
        const { currentStreak, longestStreak, thisWeekLogins } = await updateStreak(user);

        res.json({
            token,
            user: {
                id: user.id,
                name: user.name,
                email: user.email,
                profile_picture: user.profile_picture,
                current_streak: currentStreak,
                longest_streak: longestStreak,
                this_week_logins: thisWeekLogins,
                interestIds,
                subInterestIds,
                is_password_set: user.is_password_set || 0
            }
        });
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server Error');
    }
};




exports.updateProfile = async (req, res) => {
    const { name, bio, email } = req.body;
    const userId = req.user.id;

    try {
        let updateQuery = 'UPDATE users SET name = ?';
        let updateParams = [name];

        if (bio !== undefined) {
            updateQuery += ', bio = ?';
            updateParams.push(bio);
        }

        if (email !== undefined) {
            // Check if email already exists for another user
            const [existing] = await db.execute('SELECT id FROM users WHERE email = ? AND id != ?', [email, userId]);
            if (existing.length > 0) {
                return res.status(400).json({ msg: 'Email is already taken' });
            }
            updateQuery += ', email = ?';
            updateParams.push(email);
        }

        updateQuery += ' WHERE id = ?';
        updateParams.push(userId);

        await db.execute(updateQuery, updateParams);

        // Fetch updated user data to return
        const [rows] = await db.execute('SELECT id, name, email, profile_picture, bio FROM users WHERE id = ?', [userId]);
        const user = rows[0];

        res.json({
            user: {
                id: user.id,
                name: user.name,
                email: user.email,
                profile_picture: user.profile_picture,
                bio: user.bio
            }
        });
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server Error');
    }
};

const cloudinary = require('cloudinary').v2;

// Cloudinary Configuration
cloudinary.config({
    cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
    api_key: process.env.CLOUDINARY_API_KEY,
    api_secret: process.env.CLOUDINARY_API_SECRET
});

exports.uploadProfilePicture = async (req, res) => {
    if (!req.file) {
        return res.status(400).json({ msg: 'No file uploaded' });
    }

    const userId = req.user.id;

    try {
        // Upload to Cloudinary using buffer
        const uploadResult = await new Promise((resolve, reject) => {
            const uploadStream = cloudinary.uploader.upload_stream(
                {
                    folder: 'profile_pictures',
                    public_id: `user_${userId}_${Date.now()}`,
                    resource_type: 'image'
                },
                (error, result) => {
                    if (error) reject(error);
                    else resolve(result);
                }
            );
            uploadStream.end(req.file.buffer);
        });

        const imageUrl = uploadResult.secure_url;

        await db.execute('UPDATE users SET profile_picture = ? WHERE id = ?', [imageUrl, userId]);

        res.json({
            msg: 'File uploaded successfully',
            filePath: imageUrl
        });
    } catch (err) {
        console.error('Cloudinary Upload Error:', err.message);
        res.status(500).send('Server Error');
    }
};

exports.getMe = async (req, res) => {
    try {
        const [rows] = await db.execute('SELECT id, name, email, google_id, created_at, profile_picture, current_streak, longest_streak, last_login_date, is_password_set, subscription_plan FROM users WHERE id = ?', [req.user.id]);
        const user = rows[0];

        // Update Streak on session validation
        const { currentStreak, longestStreak, thisWeekLogins } = await updateStreak(user);

        // Fetch user interests
        const [userInterestRows] = await db.execute('SELECT interest_id FROM user_interests WHERE user_id = ?', [user.id]);
        const interestIds = userInterestRows.map(row => row.interest_id);

        // Fetch user sub-interests
        const [userSubInterestRows] = await db.execute('SELECT sub_interest_id FROM user_sub_interests WHERE user_id = ?', [user.id]);
        const subInterestIds = userSubInterestRows.map(row => row.sub_interest_id);

        res.json({
            ...user,
            subscription_plan: user.subscription_plan || 'Free Access',
            current_streak: currentStreak,
            longest_streak: longestStreak,
            this_week_logins: thisWeekLogins,
            interestIds,
            subInterestIds,
            is_password_set: user.is_password_set || 0
        });
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server Error');
    }
};

exports.changePassword = async (req, res) => {
    const { oldPassword, newPassword, otp } = req.body;
    const userId = req.user.id;

    try {
        const [rows] = await db.execute('SELECT email, password, google_id, is_password_set FROM users WHERE id = ?', [userId]);
        const user = rows[0];

        if (!user) {
            console.log('Change Password: User not found', userId);
            return res.status(404).json({ msg: 'User not found' });
        }

        console.log('Changing password for user:', user.email, 'Using:', otp ? 'OTP' : 'Old Password');

        // If OTP is provided, verify it (supports forgot-password, in-app otp change, etc.)
        if (otp) {
            console.log('Verifying Change Password OTP for:', user.email);
            const [otpRows] = await db.execute(
                'SELECT * FROM otps WHERE email = ? AND otp = ? AND (type = ? OR type = ? OR type = ?) AND expires_at > NOW()',
                [user.email, otp, 'password_reset', 'password_change', 'registration']
            );

            if (otpRows.length === 0) {
                console.log('Change Password: OTP Invalid or Expired');
                return res.status(400).json({ msg: 'Invalid or expired OTP' });
            }
            await db.execute('DELETE FROM otps WHERE email = ? AND (type = ? OR type = ? OR type = ?)', [user.email, 'password_reset', 'password_change', 'registration']);
        } else if (!user.is_password_set) {
            // Social user setting password for the first time
            console.log('Social user setting password for first time:', user.email);
        } else if (oldPassword) {
            const isMatch = await bcrypt.compare(oldPassword, user.password);
            if (!isMatch) {
                return res.status(400).json({ msg: 'Incorrect old password' });
            }
        } else {
            return res.status(400).json({ msg: 'Old password is required' });
        }

        const salt = await bcrypt.genSalt(10);
        const hashedPassword = await bcrypt.hash(newPassword, salt);
        await db.execute('UPDATE users SET password = ?, is_password_set = ? WHERE id = ?', [hashedPassword, 1, userId]);
        console.log('Password updated successfully for:', user.email);
        res.json({ msg: 'Password updated successfully' });
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server Error');
    }
};

exports.updateFcmToken = async (req, res) => {
    const { fcmToken } = req.body;
    const userId = req.user.id;

    try {
        await db.execute('UPDATE users SET fcm_token = ? WHERE id = ?', [fcmToken, userId]);
        res.json({ msg: 'FCM token updated successfully' });
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server Error');
    }
};
