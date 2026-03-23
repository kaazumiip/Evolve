const admin = require('firebase-admin');

try {
  let serviceAccount;

  if (process.env.FIREBASE_SERVICE_ACCOUNT) {
    // Priority: Load from Environment Variable (Production/Railway)
    serviceAccount = JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT);
    console.log('Firebase Admin: Initializing via Environment Variable');
  } else {
    // Fallback: Load from local file (Development)
    const path = require('path');
    serviceAccount = require(path.join(__dirname, '../firebase-service-account.json'));
    console.log('Firebase Admin: Initializing via local JSON file');
  }

  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
  });

  console.log('Firebase Admin initialized successfully');
} catch (error) {
  console.warn('Firebase Admin could not be initialized:', error.message);
  console.warn('Ensure FIREBASE_SERVICE_ACCOUNT is set in Railway or firebase-service-account.json exists locally.');
}

module.exports = admin;
