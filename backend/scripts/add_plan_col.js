require('dotenv').config();
const { sql, poolPromise } = require('./config/db');

async function main() {
  try {
    const pool = await poolPromise;
    await pool.request().query("ALTER TABLE users ADD subscription_plan nvarchar(255) DEFAULT 'Free Access'");
    console.log("Added subscription_plan column.");
  } catch(e) {
    if (e.message.includes('Column names in each table must be unique')) {
      console.log('Column already exists.');
    } else {
      console.error(e);
    }
  } finally {
    process.exit(0);
  }
}
main();
