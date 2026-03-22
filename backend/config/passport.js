const passport = require('passport');
const GoogleStrategy = require('passport-google-oauth20').Strategy;
const db = require('./db');

passport.use(new GoogleStrategy({
    clientID: (process.env.GOOGLE_CLIENT_ID || "").trim(),
    clientSecret: (process.env.GOOGLE_CLIENT_SECRET || "").trim(),
    callbackURL: process.env.GOOGLE_CALLBACK_URL || "https://evolve-rv6a.onrender.com/api/auth/google/callback",
    scope: ['profile', 'email'],
    proxy: true
},
    async function (accessToken, refreshToken, profile, done) {
        try {
            // Check if user exists
            const [rows] = await db.execute('SELECT * FROM users WHERE google_id = ?', [profile.id]);

            if (rows.length > 0) {
                return done(null, rows[0]);
            } else {
                const name = profile.displayName;
                const email = profile.emails[0].value;
                const googleId = profile.id;

                // Create new user (setting is_password_set to 0 for social users)
                const [result] = await db.execute(
                    'INSERT INTO users (name, email, google_id, is_password_set) VALUES (?, ?, ?, ?)',
                    [name, email, googleId, 0]
                );

                // Return user object without extra SELECT
                const user = {
                    id: result.insertId,
                    name,
                    email,
                    google_id: googleId
                };
                return done(null, user);
            }
        } catch (err) {
            return done(err, null);
        }
    }
));

module.exports = passport;
