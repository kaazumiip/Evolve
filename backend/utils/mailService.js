const nodemailer = require('nodemailer');
require('dotenv').config();

// Create a transporter using Gmail SMTP
const transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: process.env.SMTP_USER, // Your Gmail address
    pass: process.env.SMTP_PASS, // Your 16-character App Password
  },
});

/**
 * Send OTP via Gmail SMTP
 * @param {string} email - Recipient email address
 * @param {string} otp - 6-digit code
 * @param {string} type - 'registration', 'password_reset', or 'password_change'
 */
const sendOTP = async (email, otp, type = 'registration') => {
  const subject = type === 'registration' ? 'Verify your Evolve account' : 'Reset your Evolve password';
  const title = type === 'registration' ? 'Welcome to Evolve!' : 'Password Reset Request';
  const description = type === 'registration' 
    ? 'Use the following code to complete your registration:' 
    : 'Use the following code to reset your password:';

  const mailOptions = {
    from: `"Evolve App" <${process.env.SMTP_USER}>`,
    to: email,
    subject: subject,
    html: `
      <div style="font-family: sans-serif; max-width: 600px; margin: 0 auto; padding: 20px; border: 1px solid #e2e8f0; border-radius: 12px;">
        <h2 style="color: #2563eb; text-align: center;">${title}</h2>
        <p style="color: #475569; font-size: 16px;">Hello,</p>
        <p style="color: #475569; font-size: 16px;">${description}</p>
        <div style="background-color: #f8fafc; padding: 20px; text-align: center; border-radius: 8px; margin: 20px 0;">
          <span style="font-size: 32px; font-weight: bold; letter-spacing: 5px; color: #1e293b;">${otp}</span>
        </div>
        <p style="color: #64748b; font-size: 14px;">This code will expire in 10 minutes. If you did not request this, please ignore this email.</p>
        <hr style="border: 0; border-top: 1px solid #e2e8f0; margin: 20px 0;" />
        <p style="color: #94a3b8; font-size: 12px; text-align: center;">&copy; ${new Date().getFullYear()} Evolve App. All rights reserved.</p>
      </div>
    `,
  };

  try {
    const info = await transporter.sendMail(mailOptions);
    console.log(`Email successfully sent to ${email} (Nodemailer). MessageId: ${info.messageId}`);
    return { success: true, data: info };
  } catch (err) {
    console.error('NODEMAILER ERROR:', err);
    return { success: false, error: err };
  }
};

module.exports = {
  sendOTP,
};
