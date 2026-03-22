const axios = require('axios');
const db = require('../config/db');

exports.generateCareerComparison = async (req, res) => {
    try {
        const { interestIds } = req.body;

        if (!interestIds || !Array.isArray(interestIds) || interestIds.length === 0) {
            return res.status(400).json({ message: "interestIds array is required." });
        }

        // 1. Check Cache First
        const cacheKey = `compare_${interestIds.sort().join('_')}`;
        try {
            const [cacheRows] = await db.query('SELECT content FROM career_cache WHERE cache_key = ?', [cacheKey]);
            if (cacheRows && cacheRows.length > 0) {
                console.log(`[Cache Hit] Serving comparison for ${cacheKey}`);
                return res.json(JSON.parse(cacheRows[0].content));
            }
        } catch (cacheErr) {
            console.warn("Cache fetch failed, proceeding to AI:", cacheErr.message);
        }

        // 2. Fetch the actual interest names from the DB
        let interestNames = "";
        let results = [];
        try {
            const placeholders = interestIds.map(() => '?').join(',');
            const query = `SELECT title FROM interests WHERE id IN (${placeholders})`;
            const dbResults = await db.query(query, interestIds);
            results = dbResults[0] || [];
            interestNames = results.map(r => r.title).join(', ');
        } catch (e) {
            console.warn("Could not map interest IDs, proceeding with raw IDs:", e.message);
            interestNames = interestIds.join(', ');
        }

        // 3. Build the OpenRouter prompt
        const prompt = `
You are an expert career counselor operating in Cambodia.
The user has expressed strong interest in the following fields: ${interestNames}.

Your task is to head-to-head compare these exact two educational fields/career sectors: ${interestNames}.
Do not invent or assume other fields; strictly compare these two areas.

CRITICAL INSTRUCTIONS:
1. Provide accurate data specifically tailored to the Cambodian market (e.g. realistic entry-level salaries in USD, local market demand).
2. The output MUST be strictly valid JSON matching the exact schema below, with no markdown formatting around it.
3. For the "title" of field1 and field2, provide a concise, shortened version of the field name (max 1-2 words).

SCHEMA:
{
    "field1": {
        "title": "SHORTENED NAME",
        "salary_range": "$XXX - $XXX USD/month",
        "market_demand": "High/Medium/Low with 1 sentence context",
        "work_life_balance": "Brief description",
        "core_skills": ["Skill 1", "Skill 2"]
    },
    "field2": {
        "title": "SHORTENED NAME",
        "salary_range": "$XXX - $XXX USD/month",
        "market_demand": "High/Medium/Low with 1 sentence context",
        "work_life_balance": "Brief description",
        "core_skills": ["Skill 1", "Skill 2"]
    },
    "summary_verdict": "A 2-sentence conclusion."
}
        `;

        const openRouterResponse = await axios.post(
            'https://openrouter.ai/api/v1/chat/completions',
            {
                model: 'openai/gpt-4o-mini',
                messages: [
                    { role: 'system', content: 'You are a career counseling JSON API. Always return raw JSON.' },
                    { role: 'user', content: prompt }
                ],
                temperature: 0.3,
                max_tokens: 1500,
            },
            {
                headers: {
                    'Authorization': `Bearer ${process.env.OPENROUTER_API_KEY}`,
                    'HTTP-Referer': 'http://localhost:3000',
                    'X-Title': 'Evolve AI',
                    'Content-Type': 'application/json'
                },
                timeout: 30000
            }
        );

        let content = openRouterResponse.data.choices[0].message.content;
        content = content.replace(/```json/g, '').replace(/```/g, '').trim();
        const careerData = JSON.parse(content);
        careerData.interest_labels = [careerData.field1.title, careerData.field2.title];

        // 4. Save to Cache
        try {
            await db.execute('INSERT INTO career_cache (cache_key, content) VALUES (?, ?)', [cacheKey, JSON.stringify(careerData)]);
        } catch (saveErr) {
            console.warn("Failed to save to cache:", saveErr.message);
        }

        return res.json(careerData);

    } catch (error) {
        console.error("Career Comparison Generation Error:", error.response?.data || error.message);
        res.status(500).json({ message: "Failed to generate AI careers." });
    }
};

exports.generateCareerRoadmap = async (req, res) => {
    try {
        const { careerTitle } = req.body;
        if (!careerTitle) return res.status(400).json({ message: "careerTitle is required." });

        // 1. Check Cache
        const cacheKey = `roadmap_${careerTitle.toLowerCase().replace(/\s+/g, '_')}`;
        try {
            const [cacheRows] = await db.query('SELECT content FROM career_cache WHERE cache_key = ?', [cacheKey]);
            if (cacheRows && cacheRows.length > 0) {
                const cachedData = JSON.parse(cacheRows[0].content);
                // Smart cache migration: If the cached data is from an older version (lacks 'overview'), force a re-fetch.
                if (cachedData.overview && cachedData.requirements) {
                    console.log(`[Cache Hit] Serving complete roadmap for ${cacheKey}`);
                    return res.json(cachedData);
                }
                console.log(`[Cache Upgrade] Old data found for ${cacheKey}, refreshing with AI...`);
            }
        } catch (cacheErr) {
            console.warn("Cache check failed:", cacheErr.message);
        }

        const prompt = `
You are an expert career counselor operating in Cambodia.
Generate a comprehensive career guide and roadmap for someone aiming to become a: ${careerTitle} in Cambodia.

CRITICAL INSTRUCTIONS:
1. Provide accurate data specifically tailored to the Cambodian market (salaries in USD, common local companies, local education requirements).
2. The output MUST be strictly valid JSON.
3. For "hero_image", use a high-quality Unsplash image URL related to the career.
4. For "top_companies", provide 6 companies and use high-quality logo URLs or names that I can map to icons.

SCHEMA:
{
    "career_title": "${careerTitle}",
    "subtitle": "Your roadmap to success in ${careerTitle}",
    "hero_image": "https://images.unsplash.com/photo-...",
    "overview": {
        "day_in_life": ["Task 1", "Task 2", "Task 3", "Task 4", "Task 5", "Task 6"],
        "career_progression": [
            { "role": "Junior Role", "description": "Short desc", "salary": "$400-$800" },
            { "role": "Mid-Level", "description": "Short desc", "salary": "$800-$1500" },
            { "role": "Senior", "description": "Short desc", "salary": "$1500-$2500" },
            { "role": "Lead/Manager", "description": "Short desc", "salary": "$2500-$4000" },
            { "role": "Director/Exec", "description": "Short desc", "salary": "$4000+" }
        ]
    },
    "requirements": {
        "education": "Details about degrees or bootcamps",
        "experience": "Experience range for entry level",
        "technical_skills": ["Skill 1", "Skill 2", "Skill 3", "Skill 4"],
        "soft_skills": ["Skill 1", "Skill 2", "Skill 3", "Skill 4"]
    },
    "resources": [
        { "name": "Resource 1", "type": "Course", "badge": "Free", "link": "https://..." },
        { "name": "Resource 2", "type": "Practice", "badge": "Paid", "link": "https://..." },
        { "name": "Resource 3", "type": "Book", "badge": "Paid", "link": "https://..." },
        { "name": "Resource 4", "type": "Course", "badge": "Free", "link": "https://..." }
    ],
    "top_companies": [
        { "name": "Company 1", "logo_url": "https://..." },
        { "name": "Company 2", "logo_url": "https://..." },
        { "name": "Company 3", "logo_url": "https://..." },
        { "name": "Company 4", "logo_url": "https://..." },
        { "name": "Company 5", "logo_url": "https://..." },
        { "name": "Company 6", "logo_url": "https://..." }
    ]
}
        `;

        const response = await axios.post(
            'https://openrouter.ai/api/v1/chat/completions',
            {
                model: 'openai/gpt-4o-mini',
                messages: [
                    { role: 'system', content: 'You are a career counseling JSON API. Always return raw JSON.' },
                    { role: 'user', content: prompt }
                ],
                temperature: 0.3,
                max_tokens: 1500,
            },
            {
                headers: {
                    'Authorization': `Bearer ${process.env.OPENROUTER_API_KEY}`,
                    'HTTP-Referer': 'http://localhost:3000',
                    'Content-Type': 'application/json'
                },
                timeout: 30000
            }
        );

        let content = response.data.choices[0].message.content;
        content = content.replace(/```json/g, '').replace(/```/g, '').trim();
        const roadmapData = JSON.parse(content);

        // 2. Save to Cache
        try {
            // MSSQL doesn't support REPLACE INTO, so we DELETE then INSERT
            await db.execute('DELETE FROM career_cache WHERE cache_key = ?', [cacheKey]);
            await db.execute('INSERT INTO career_cache (cache_key, content) VALUES (?, ?)', [cacheKey, JSON.stringify(roadmapData)]);
        } catch (saveErr) {
            console.warn("Failed to save roadmap to cache:", saveErr.message);
        }

        return res.json(roadmapData);

    } catch (error) {
        console.error("Roadmap Generation Error:", error.response?.data || error.message);
        res.status(500).json({ message: "Failed to generate AI roadmap." });
    }
};
