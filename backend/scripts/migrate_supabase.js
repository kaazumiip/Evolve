const db = require('../config/db');

async function migrateToSupabase() {
  console.log('Starting Supabase schema migration & seeding...');
  const client = await db.pool.connect();

  try {
    await client.query('BEGIN');

    // 1. users
    await client.query(`
      CREATE TABLE IF NOT EXISTS users (
        id SERIAL PRIMARY KEY,
        name VARCHAR(255) NOT NULL,
        email VARCHAR(255) UNIQUE NOT NULL,
        password VARCHAR(255),
        google_id VARCHAR(255),
        facebook_id VARCHAR(255),
        profile_picture TEXT,
        bio TEXT,
        current_streak INTEGER DEFAULT 0,
        longest_streak INTEGER DEFAULT 0,
        last_login_date DATE,
        is_password_set INTEGER DEFAULT 0,
        subscription_plan VARCHAR(100) DEFAULT 'Free Access',
        fcm_token TEXT,
        last_seen TIMESTAMPTZ DEFAULT NOW(),
        created_at TIMESTAMPTZ DEFAULT NOW()
      );
    `);

    // 2. otps
    await client.query(`
      CREATE TABLE IF NOT EXISTS otps (
        id SERIAL PRIMARY KEY,
        email VARCHAR(255) NOT NULL,
        otp VARCHAR(10) NOT NULL,
        type VARCHAR(50) NOT NULL,
        expires_at TIMESTAMPTZ NOT NULL,
        created_at TIMESTAMPTZ DEFAULT NOW()
      );
    `);

    // 3. user_daily_logins
    await client.query(`
      CREATE TABLE IF NOT EXISTS user_daily_logins (
        id SERIAL PRIMARY KEY,
        user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
        login_date DATE NOT NULL,
        created_at TIMESTAMPTZ DEFAULT NOW(),
        UNIQUE (user_id, login_date)
      );
    `);

    // 4. interests
    await client.query(`
      CREATE TABLE IF NOT EXISTS interests (
        id INTEGER PRIMARY KEY,
        title VARCHAR(255) NOT NULL,
        description TEXT,
        icon_name VARCHAR(100),
        color_hex VARCHAR(50)
      );
    `);

    // 5. sub_interests
    await client.query(`
      CREATE TABLE IF NOT EXISTS sub_interests (
        id SERIAL PRIMARY KEY,
        interest_id INTEGER NOT NULL REFERENCES interests(id) ON DELETE CASCADE,
        name VARCHAR(255) NOT NULL,
        UNIQUE (interest_id, name)
      );
    `);

    // 6. user_interests
    await client.query(`
      CREATE TABLE IF NOT EXISTS user_interests (
        id SERIAL PRIMARY KEY,
        user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
        interest_id INTEGER NOT NULL REFERENCES interests(id) ON DELETE CASCADE,
        UNIQUE (user_id, interest_id)
      );
    `);

    // 7. user_sub_interests
    await client.query(`
      CREATE TABLE IF NOT EXISTS user_sub_interests (
        id SERIAL PRIMARY KEY,
        user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
        sub_interest_id INTEGER NOT NULL REFERENCES sub_interests(id) ON DELETE CASCADE,
        UNIQUE (user_id, sub_interest_id)
      );
    `);

    // 8. posts
    await client.query(`
      CREATE TABLE IF NOT EXISTS posts (
        id SERIAL PRIMARY KEY,
        user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
        title VARCHAR(500) NOT NULL,
        body TEXT,
        tags TEXT,
        image_url TEXT,
        media_urls TEXT,
        view_count INTEGER DEFAULT 0,
        created_at TIMESTAMPTZ DEFAULT NOW()
      );
    `);

    // 9. post_likes
    await client.query(`
      CREATE TABLE IF NOT EXISTS post_likes (
        id SERIAL PRIMARY KEY,
        post_id INTEGER NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
        user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
        created_at TIMESTAMPTZ DEFAULT NOW(),
        UNIQUE (post_id, user_id)
      );
    `);

    // 10. comments
    await client.query(`
      CREATE TABLE IF NOT EXISTS comments (
        id SERIAL PRIMARY KEY,
        post_id INTEGER NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
        user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
        content TEXT,
        parent_id INTEGER REFERENCES comments(id) ON DELETE CASCADE,
        type VARCHAR(50) DEFAULT 'text',
        media_url TEXT,
        created_at TIMESTAMPTZ DEFAULT NOW()
      );
    `);

    // 11. comment_likes
    await client.query(`
      CREATE TABLE IF NOT EXISTS comment_likes (
        id SERIAL PRIMARY KEY,
        comment_id INTEGER NOT NULL REFERENCES comments(id) ON DELETE CASCADE,
        user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
        created_at TIMESTAMPTZ DEFAULT NOW(),
        UNIQUE (comment_id, user_id)
      );
    `);

    // 12. friendships
    await client.query(`
      CREATE TABLE IF NOT EXISTS friendships (
        id SERIAL PRIMARY KEY,
        requester_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
        receiver_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
        status VARCHAR(50) DEFAULT 'pending',
        created_at TIMESTAMPTZ DEFAULT NOW(),
        updated_at TIMESTAMPTZ DEFAULT NOW(),
        UNIQUE (requester_id, receiver_id)
      );
    `);

    // 13. user_blocks
    await client.query(`
      CREATE TABLE IF NOT EXISTS user_blocks (
        id SERIAL PRIMARY KEY,
        blocker_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
        blocked_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
        created_at TIMESTAMPTZ DEFAULT NOW(),
        UNIQUE (blocker_id, blocked_id)
      );
    `);

    // 14. user_reports
    await client.query(`
      CREATE TABLE IF NOT EXISTS user_reports (
        id SERIAL PRIMARY KEY,
        reporter_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
        reported_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
        reason TEXT,
        created_at TIMESTAMPTZ DEFAULT NOW()
      );
    `);

    // 15. conversations
    await client.query(`
      CREATE TABLE IF NOT EXISTS conversations (
        id SERIAL PRIMARY KEY,
        status VARCHAR(50) DEFAULT 'active',
        archived_by INTEGER REFERENCES users(id) ON DELETE SET NULL,
        created_at TIMESTAMPTZ DEFAULT NOW(),
        updated_at TIMESTAMPTZ DEFAULT NOW()
      );
    `);

    // 16. conversation_participants
    await client.query(`
      CREATE TABLE IF NOT EXISTS conversation_participants (
        id SERIAL PRIMARY KEY,
        conversation_id INTEGER NOT NULL REFERENCES conversations(id) ON DELETE CASCADE,
        user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
        joined_at TIMESTAMPTZ DEFAULT NOW(),
        UNIQUE (conversation_id, user_id)
      );
    `);

    // 17. messages
    await client.query(`
      CREATE TABLE IF NOT EXISTS messages (
        id SERIAL PRIMARY KEY,
        conversation_id INTEGER NOT NULL REFERENCES conversations(id) ON DELETE CASCADE,
        sender_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
        content TEXT,
        image_url TEXT,
        media_url TEXT,
        type VARCHAR(50) DEFAULT 'text',
        reply_to_id INTEGER REFERENCES messages(id) ON DELETE SET NULL,
        media_gallery TEXT,
        is_read BOOLEAN DEFAULT FALSE,
        is_edited BOOLEAN DEFAULT FALSE,
        deleted_at TIMESTAMPTZ,
        created_at TIMESTAMPTZ DEFAULT NOW()
      );
    `);

    // 18. notifications
    await client.query(`
      CREATE TABLE IF NOT EXISTS notifications (
        id SERIAL PRIMARY KEY,
        user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
        sender_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
        type VARCHAR(50) NOT NULL,
        post_id INTEGER REFERENCES posts(id) ON DELETE CASCADE,
        comment_id INTEGER REFERENCES comments(id) ON DELETE CASCADE,
        is_read BOOLEAN DEFAULT FALSE,
        created_at TIMESTAMPTZ DEFAULT NOW()
      );
    `);

    // 19. activities
    await client.query(`
      CREATE TABLE IF NOT EXISTS activities (
        id SERIAL PRIMARY KEY,
        user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
        action_type VARCHAR(100) NOT NULL,
        entity_title VARCHAR(500) NOT NULL,
        created_at TIMESTAMPTZ DEFAULT NOW()
      );
    `);

    // 20. scholarships
    await client.query(`
      CREATE TABLE IF NOT EXISTS scholarships (
        id SERIAL PRIMARY KEY,
        title VARCHAR(500) NOT NULL,
        provider VARCHAR(255),
        amount VARCHAR(255),
        deadline VARCHAR(100),
        applicantsCount VARCHAR(100),
        pacing VARCHAR(100),
        description TEXT,
        requirements TEXT,
        processes TEXT,
        quickFacts TEXT,
        aboutProvider TEXT,
        providerDetails TEXT,
        checklist TEXT,
        color VARCHAR(50),
        website TEXT,
        type VARCHAR(100),
        eligibility TEXT,
        logo_url TEXT,
        created_at TIMESTAMPTZ DEFAULT NOW(),
        expires_at TIMESTAMPTZ
      );
    `);

    // 21. favorites
    await client.query(`
      CREATE TABLE IF NOT EXISTS favorites (
        id SERIAL PRIMARY KEY,
        user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
        item_type VARCHAR(50) NOT NULL,
        item_id INTEGER NOT NULL,
        created_at TIMESTAMPTZ DEFAULT NOW(),
        UNIQUE (user_id, item_type, item_id)
      );
    `);

    // 22. career_cache
    await client.query(`
      CREATE TABLE IF NOT EXISTS career_cache (
        id SERIAL PRIMARY KEY,
        cache_key VARCHAR(255) UNIQUE NOT NULL,
        content TEXT NOT NULL,
        created_at TIMESTAMPTZ DEFAULT NOW()
      );
    `);

    // 23. stickers
    await client.query(`
      CREATE TABLE IF NOT EXISTS stickers (
        id SERIAL PRIMARY KEY,
        user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
        name VARCHAR(255) NOT NULL,
        image_url TEXT NOT NULL,
        is_public BOOLEAN DEFAULT FALSE,
        created_at TIMESTAMPTZ DEFAULT NOW()
      );
    `);

    // Seed Interests & Sub-Interests
    const interestsData = [
      {
        id: 1,
        title: 'STEM & Tech',
        description: 'Software engineering, AI, data science, cybersecurity, and modern technology.',
        icon_name: 'memory',
        color_hex: '0xFF2196F3',
        subs: ['IT', 'Cybersecurity', 'AI', 'Software Development', 'Data Science', 'Robotics']
      },
      {
        id: 2,
        title: 'Business',
        description: 'Entrepreneurship, finance, marketing, management, and global commerce.',
        icon_name: 'business_center',
        color_hex: '0xFFFF9800',
        subs: ['Management', 'Finance', 'Marketing', 'Entrepreneurship', 'Economics', 'Accounting']
      },
      {
        id: 3,
        title: 'Health',
        description: 'Medicine, nursing, psychology, physical therapy, and public healthcare.',
        icon_name: 'medical_services',
        color_hex: '0xFFF44336',
        subs: ['Nursing', 'Psychology', 'Medicine', 'Public Health', 'Pharmacy', 'Nutrition']
      },
      {
        id: 4,
        title: 'Education',
        description: 'Teaching, academic research, educational leadership, law, and social sciences.',
        icon_name: 'school',
        color_hex: '0xFFFFC107',
        subs: ['Teaching', 'Law', 'Politics', 'Curriculum Design', 'Linguistics', 'Counseling']
      },
      {
        id: 5,
        title: 'Craftsmanship',
        description: 'Mechanical engineering, electrical trades, construction, and culinary arts.',
        icon_name: 'handyman',
        color_hex: '0xFF795548',
        subs: ['Engineering', 'Mechanics', 'Culinary', 'Architecture', 'Electrical', 'Woodworking']
      },
      {
        id: 6,
        title: 'Public Service',
        description: 'Social work, community advocacy, international relations, and public policy.',
        icon_name: 'volunteer_activism',
        color_hex: '0xFF3F51B5',
        subs: ['Social Work', 'Policy', 'Advocacy', 'International Relations', 'Non-Profit', 'Environmental']
      },
      {
        id: 7,
        title: 'Arts & Design',
        description: 'UI/UX design, graphic arts, digital media, animation, and creative direction.',
        icon_name: 'palette',
        color_hex: '0xFFE91E63',
        subs: ['UI/UX', 'Graphic Design', 'Animation', 'Photography', 'Video Production', 'Fine Arts']
      }
    ];

    for (const item of interestsData) {
      await client.query(`
        INSERT INTO interests (id, title, description, icon_name, color_hex)
        VALUES ($1, $2, $3, $4, $5)
        ON CONFLICT (id) DO UPDATE SET
          title = EXCLUDED.title,
          description = EXCLUDED.description,
          icon_name = EXCLUDED.icon_name,
          color_hex = EXCLUDED.color_hex;
      `, [item.id, item.title, item.description, item.icon_name, item.color_hex]);

      for (const subName of item.subs) {
        await client.query(`
          INSERT INTO sub_interests (interest_id, name)
          VALUES ($1, $2)
          ON CONFLICT (interest_id, name) DO NOTHING;
        `, [item.id, subName]);
      }
    }

    await client.query('COMMIT');
    console.log('✅ All 23 tables created and interests/sub_interests seeded in Supabase!');
    process.exit(0);
  } catch (err) {
    await client.query('ROLLBACK');
    console.error('❌ Migration failed:', err);
    process.exit(1);
  } finally {
    client.release();
  }
}

migrateToSupabase();

