const axios = require('axios');

async function testSendOTP() {
    try {
        const response = await axios.post('http://localhost:5000/api/auth/send-otp', {
            email: 'test@example.com',
            type: 'password_reset'
        });
        console.log('Success:', response.data);
    } catch (error) {
        console.log('--- ERROR FROM API ---');
        console.log('Status:', error.response?.status);
        console.log('Data:', JSON.stringify(error.response?.data, null, 2));
    }
}

testSendOTP();
