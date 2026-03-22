const passport = require('passport');
const GoogleStrategy = require('passport-google-oauth20').Strategy;
const db = require('./db');

passport.use(new GoogleStrategy({
    clientID: process.env.GOOGLE_CLIENT_ID,
    clientSecret: process.env.GOOGLE_CLIENT_SECRET,
    callbackURL: "http://10.220.185.8:5000/api/auth/google/callback"
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

                // Create new user
                const [result] = await db.execute(
                    'INSERT INTO users (name, email, google_id) VALUES (?, ?, ?)',
                    [name, email, googleId]
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
