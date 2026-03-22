const axios = require('axios');
const db = require('../config/db');

const scoutScholarships = async (req, res) => {
    try {
        const page = parseInt(req.query.page) || 1;
        const limit = parseInt(req.query.limit) || 10;
        const offset = (page - 1) * limit;
        const forceFetch = req.query.force === 'true';

        // 1. Check if we have ANY scholarships in DB at all to avoid unnecessary AI calls
        const [totalCountRows] = await db.query('SELECT COUNT(*) as total FROM scholarships WHERE expires_at > GETDATE() OR expires_at IS NULL');
        const totalInDb = totalCountRows[0]?.total || 0;

        // 1. Try DB Cache First (Unless Forced)
        if (!forceFetch && totalInDb > 0) {
            const mssqlQuery = `
                SELECT * FROM scholarships 
                WHERE expires_at > GETDATE() OR expires_at IS NULL
                ORDER BY created_at DESC 
                OFFSET ? ROWS FETCH NEXT ? ROWS ONLY
            `;
            const [results] = await db.execute(mssqlQuery, [offset, limit]);

            // If we have results, return them. 
            // If we don't have results for THIS specific page but we HAVE data in DB,
            // we return an empty array instead of triggering a $0.05 AI call!
            if (results && results.length > 0) {
                const formattedResults = results.map(row => ({
                    id: row.id,
                    title: row.title,
                    provider: row.provider,
                    amount: row.amount,
                    deadline: row.deadline,
                    applicantsCount: row.applicantsCount,
                    pacing: row.pacing,
                    color: row.color,
                    website: row.website,
                    description: row.description,
                    type: row.type,
                    eligibility: row.eligibility,
                    logo_url: row.logo_url,
                    requirements: row.requirements ? JSON.parse(row.requirements) : null,
                    processes: row.processes ? JSON.parse(row.processes) : null,
                    quickFacts: row.quickFacts ? JSON.parse(row.quickFacts) : null,
                    aboutProvider: row.aboutProvider,
                    providerDetails: row.providerDetails ? JSON.parse(row.providerDetails) : null,
                    checklist: row.checklist ? JSON.parse(row.checklist) : null
                }));
                return res.json(formattedResults);
            } else if (offset >= totalInDb) {
                // We reached the end of our current cache, returning empty to prevent automated AI spend
                return res.json([]);
            }
        }

        // 2. Fallback to AI Fetch
        const apiKey = process.env.OPENROUTER_API_KEY;
        if (!apiKey) {
            return res.status(500).json({ message: 'Scouting service not configured (API Key missing)' });
        }

        const prompt = `You are an expert academic advisor specialized in Cambodian education. 
Your task is to scout for scholarships available to Cambodian students.

Step 1: Identify the top 20 most prestigious universities in Cambodia. You MUST search for scholarships at these specific universities:
- Royal University of Phnom Penh (RUPP)
- Institute of Technology of Cambodia (ITC)
- National University of Management (NUM)
- Pannasastra University of Cambodia (PUC)
- University of Puthisastra (UP)
- American University of Phnom Penh (AUPP)
- Paragon International University
- Royal University of Law and Economics (RULE)
- CamEd Business School
- Norton University
- Limkokwing University of Creative Technology
- SETEC Institute
- Cambodia Academy of Digital Technology (CADT)
- National University of Cheasim Kamchaymear (NUCK)
Step 2: For each identified university, find any known internal or external undergraduate/graduate scholarship opportunities they are currently offering.
Step 3: Additionally, scout for major international scholarships eligible for Cambodians (e.g., Fulbright, Chevening, Australia Awards, ASEAN scholarships, MEXT, etc.).

CRITICAL INSTRUCTION: You MUST return a balanced 50/50 mix of BOTH National Cambodian scholarships AND major International scholarships. Find at least 15-20 different scholarships total.
CRITICAL INSTRUCTION 2: You MUST ONLY return scholarships that are CURRENTLY OPEN and AVAILABLE to apply for. Do not return past opportunities. If the exact deadline is unknown but the cycle is currently active, estimate "Open Now".
CRITICAL INSTRUCTION 3: ACCURACY IS PARAMOUNT. Do not hallucinate. All URLs, requirements, application processes, and deadlines MUST be factually correct. If you do not know the exact application process steps, DO NOT invent generic ones. Instead, provide a single step directing the user to read the website.

Return the results ONLY as a valid JSON array of objects.
Each object must have these exactly:
- title: (string) The name of the scholarship.
- provider: (string) The university name or international organization.
- amount: (string) Value or type (e.g., "$5000", "Full Tuition", "100% Scholarship").
- type: (string) Either "National" (Cambodian universities) or "International".
- eligibility: (string) Brief summary of who can apply.
- deadline: (string) Month/Day/Year or "Open".
- color: (string) A hex color code.
- website: (string) The exact REAL valid Deep Link URL where the user can apply (e.g. https://www.rupp.edu.kh/scholarships/apply). DO NOT just provide the root homepage. You MUST find the specific nested page for the scholarship. NEVER INVENT URLS.
- description: (string) A 1-2 sentence compelling summary of the scholarship's goal.
- applicantsCount: (string) Estimated number of applicants (e.g., "2150", "500+").
- pacing: (string) e.g., "Merit-based", "Need-based", "First-based".
- requirements: (array of objects) [{ name: "Academic Transcript", desc: "Required", icon: "check" }]. Provide ONLY factually accurate requirements.
- processes: (array of objects) [{ step: 1, title: "Online Application", desc: "Submit via website" }]. Provide ONLY factually accurate steps.
- quickFacts: (object) { established: "2018", totalAwarded: "$2.5M", recipients: "250", renewability: "Up to 4 years", location: "United States/Cambodia" }
- aboutProvider: (string) A short paragraph about the foundation/university.
- providerDetails: (object) { founded: "1980", location: "Phnom Penh", scholarshipsOffered: "15", budget: "$1M" }
- checklist: (array of strings) e.g., ["STEM Field", "Portfolio Required", "GPA 3.0+"]
- logoUrl: (string) Extract the root domain of the university for logo fetching (e.g. "rupp.edu.kh" or "stanford.edu").
`;

        const response = await axios.post('https://openrouter.ai/api/v1/chat/completions', {
            model: "openai/gpt-4o-mini", // Reliable, cost-effective model
            messages: [
                { role: "system", content: "You are an expert web scraper and json data extractor. You must return ONLY raw valid JSON." },
                { role: "user", content: "You MUST provide REAL, FACTUAL, and UP-TO-DATE information. If you have web search enabled, visit official Cambodian university websites directly to gather data. Do not hallucinate. " + prompt }
            ],
            max_tokens: 2000,
        }, {
            headers: {
                'Authorization': `Bearer ${apiKey}`,
                'HTTP-Referer': 'https://evolve-app.com',
                'X-Title': 'Evolve App',
                'Content-Type': 'application/json'
            }
        });

        let data = response.data.choices[0].message.content;

        const jsonMatch = data.match(/\[[\s\S]*\]/);
        if (jsonMatch) {
            data = jsonMatch[0];
        } else {
            const objMatch = data.match(/\{[\s\S]*\}/);
            if (objMatch) data = objMatch[0];
        }

        if (data.trim().startsWith('[') && !data.trim().endsWith(']')) {
            if (data.trim().endsWith('}')) {
                data += '\n]';
            } else {
                const lastCompleteBracket = data.lastIndexOf('}');
                if (lastCompleteBracket > 0) {
                    data = data.substring(0, lastCompleteBracket + 1) + '\n]';
                } else {
                    data += '\n]';
                }
            }
        }

        let parsedData;
        try {
            parsedData = JSON.parse(data);
            if (parsedData.scholarships) {
                parsedData = parsedData.scholarships;
            }
        } catch (e) {
            console.error('Failed to parse AI response:', e);
            return res.status(500).json({ message: 'Error processing scholarship data' });
        }

        // 2.5 Verify URLs concurrently to catch hallucinations
        const verifyUrl = async (url) => {
            try {
                if (!url || !url.startsWith('http')) return false;
                // Simulating a real browser to prevent 403 Forbidden blocks from strict university firewalls
                const response = await axios.get(url, {
                    timeout: 8000,
                    headers: {
                        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36'
                    },
                    validateStatus: function (status) {
                        // Accept any status code between 200 and 499 EXCEPT 404 (Not Found)
                        // This allows 403 Forbidden (Cloudflare/Bot protection) to pass as a "working" link
                        return status >= 200 && status < 500 && status !== 404;
                    }
                });
                return true;
            } catch (error) {
                // Network errors (ENOTFOUND, connection refused, or 8s timeout) are considered dead
                console.log(`[URL Verification Failed]: ${url} - Error: ${error.message}`);
                return false;
            }
        };

        const validData = [];
        await Promise.all(parsedData.map(async (item) => {
            if (item.website) {
                const isValid = await verifyUrl(item.website);
                if (!isValid) {
                    console.log(`[URL Verification] Dead link caught, substituting root domain: ${item.website}`);
                    try {
                        const fallbackUrl = new URL(item.website);
                        item.website = fallbackUrl.origin;
                    } catch (e) {
                        return; // Reject only if completely malformed
                    }
                }
                validData.push(item);
            }
        }));

        // 3. Save to DB Cache
        try {
            for (const item of validData) {
                // Determine expiration from deadline
                let expiresAt = "DATEADD(day, 30, GETDATE())";
                if (item.deadline && item.deadline.toLowerCase() !== "open" && item.deadline.toLowerCase() !== "open now") {
                    try {
                        const parsedDate = new Date(item.deadline);
                        if (!isNaN(parsedDate.getTime())) {
                            parsedDate.setDate(parsedDate.getDate() + 1); // Give a 1 day buffer
                            expiresAt = `'${parsedDate.toISOString().split('T')[0]} 23:59:59'`;
                        }
                    } catch (e) { }
                }

                // Check if already exists to avoid duplicates in cache
                const [existing] = await db.query('SELECT id FROM scholarships WHERE title = ? AND provider = ?', [item.title, item.provider]);
                if (existing && existing.length > 0) {
                    console.log(`[Cache Sync] Scholarship already exists: ${item.title}`);
                    continue;
                }

                const insertQuery = `
                    INSERT INTO scholarships (
                        title, provider, amount, deadline, applicantsCount, pacing, 
                        description, requirements, processes, quickFacts, 
                        aboutProvider, providerDetails, checklist, color, website, type, eligibility, logo_url, expires_at
                    ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ? , ${expiresAt})
                `;

                let cleanLogoUrl = null;
                if (item.logoUrl) {
                    try {
                        let rawDomain = item.logoUrl.replace(/^(?:https?:\/\/)?(?:www\.)?/i, "").split('/')[0];
                        cleanLogoUrl = `https://logo.clearbit.com/${rawDomain}`;
                    } catch (e) { }
                }

                await db.execute(insertQuery, [
                    item.title || '',
                    item.provider || '',
                    item.amount || '',
                    item.deadline || '',
                    item.applicantsCount || '',
                    item.pacing || '',
                    item.description || '',
                    item.requirements ? JSON.stringify(item.requirements) : null,
                    item.processes ? JSON.stringify(item.processes) : null,
                    item.quickFacts ? JSON.stringify(item.quickFacts) : null,
                    item.aboutProvider || '',
                    item.providerDetails ? JSON.stringify(item.providerDetails) : null,
                    item.checklist ? JSON.stringify(item.checklist) : null,
                    item.color || '',
                    item.website || '',
                    item.type || 'All',
                    item.eligibility || 'N/A',
                    cleanLogoUrl
                ]);
            }
        } catch (dbError) {
            console.error('Failed to save scholarships to db:', dbError);
        }

        // We only return a limited set to properly match pagination semantics on the first call
        // Even if the AI returned 20, we just return the first 10 (or whatever 'limit' is)
        return res.json(validData.slice(0, limit));
    } catch (error) {
        console.error('Scholarship scouting error:', error.response?.data || error.message);
        res.status(500).json({ message: 'Failed to scout scholarships', error: error.message });
    }
};

const logView = async (req, res) => {
    try {
        const { scholarshipId, title } = req.body;
        if (!req.user || !req.user.id) return res.status(401).json({ message: "Unauthorized" });

        await db.execute(
            'INSERT INTO activities (user_id, action_type, entity_title) VALUES (?, ?, ?)',
            [req.user.id, 'viewed_scholarship', title || `Scholarship #${scholarshipId}`]
        );
        res.json({ message: "View logged" });
    } catch (error) {
        console.error("Failed to log view:", error);
        res.status(500).json({ message: "Server error" });
    }
};

module.exports = {
    scoutScholarships,
    logView
};
