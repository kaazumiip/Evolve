const { Resend } = require('resend');
require('dotenv').config();

// Initialize Resend with the API Key provided in Railway variables
const resend = new Resend(process.env.RESEND_API_KEY);

/**
 * Send OTP via Resend API (Firewall-Proof)
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

  // Use the verified domain email or onboarding email as fallback
  const fromEmail = process.env.RESEND_FROM_EMAIL || 'onboarding@resend.dev';

  try {
    const { data, error } = await resend.emails.send({
      from: `Evolve App <${fromEmail}>`,
      to: [email],
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
    });

    if (error) {
      console.error('RESEND ERROR:', error);
      return { success: false, error: error };
    }

    console.log(`Email successfully sent to ${email} via Resend. ID: ${data.id}`);
    return { success: true, data: data };
  } catch (err) {
    console.error('RESEND EXCEPTION:', err);
    return { success: false, error: err };
  }
};

module.exports = {
  sendOTP,
};
