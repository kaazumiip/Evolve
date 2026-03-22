const admin = require('firebase-admin');
const path = require('path');

try {
    const serviceAccount = require(path.join(__dirname, '../firebase-service-account.json'));
    
    admin.initializeApp({
        credential: admin.credential.cert(serviceAccount)
    });
    
    console.log('Firebase Admin initialized successfully');
} catch (error) {
    console.warn('Firebase Admin could not be initialized. Push notifications will be disabled until firebase-service-account.json is provided.');
}

module.exports = admin;
