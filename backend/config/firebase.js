const admin = require('firebase-admin');
const path = require('path');

try {
    let serviceAccount;
    
    // Cloud parsing (Railway/Render) using Environment Variable priority
    if (process.env.FIREBASE_SERVICE_ACCOUNT_JSON) {
        serviceAccount = JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT_JSON);
    } else {
        serviceAccount = require(path.join(__dirname, '../firebase-service-account.json'));
    }
    
    admin.initializeApp({
        credential: admin.credential.cert(serviceAccount)
    });
    
    console.log('Firebase Admin initialized successfully');
} catch (error) {
    console.warn('Firebase Admin could not be initialized. Push notifications will be disabled until environment variables or firebase-service-account.json is provided.');
}

module.exports = admin;
