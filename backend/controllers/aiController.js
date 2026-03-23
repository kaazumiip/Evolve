const axios = require('axios');
const db = require('../config/db');

exports.getAIResponse = async (req, res) => {
    try {
        const { messages, max_tokens } = req.body;
        const userId = req.user.id; // From authMiddleware

        // Fetch User Interests
        const [interests] = await db.execute(`
            SELECT i.title FROM interests i
            JOIN user_interests ui ON i.id = ui.interest_id
            WHERE ui.user_id = ?
        `, [userId]);

        // Fetch User Sub-Interests
        const [subInterests] = await db.execute(`
            SELECT si.name FROM sub_interests si
            JOIN user_sub_interests usi ON si.id = usi.sub_interest_id
            WHERE usi.user_id = ?
        `, [userId]);

        const interestNames = interests.map(i => i.title);
        const subInterestNames = subInterests.map(si => si.name);

        const interestContext = interestNames.length > 0 
            ? `The user is interested in ${interestNames.join(', ')}${subInterestNames.length > 0 ? ` with focus on ${subInterestNames.join(', ')}` : ''}.`
            : "The user hasn't specified their interests yet.";

        const systemPrompt = `You are a helpful, empathetic, and insightful AI Mind Guide for the Evolve app. 
        Your goal is to guide students in self-discovery, mental wellness, and personal growth. 
        ${interestContext} 
        Always relate your advice back to their specific passions and career interests if known. 
        Keep responses supportive, student-centered, and inspiring.`;

        // OpenRouter API Call
        const response = await axios.post(
            "https://openrouter.ai/api/v1/chat/completions",
            {
                model: "google/gemini-2.0-flash-lite-001",
                messages: [
                    { role: "system", content: systemPrompt },
                    ...messages.map(m => ({
                        role: m.role === 'model' ? 'assistant' : m.role,
                        content: m.content
                    }))
                ],
                max_tokens: max_tokens || 500,
                temperature: 0.7,
            },
            {
                headers: {
                    "Authorization": `Bearer ${process.env.AI_CHAT_API_KEY}`,
                    "Content-Type": "application/json",
                    "HTTP-Referer": "https://evolve-app.com", // Optional, for OpenRouter analytics
                    "X-Title": "Evolve App", // Optional
                }
            }
        );

        // Transform OpenRouter response to match the expected format on frontend
        const result = {
            choices: [{
                message: {
                    content: response.data.choices[0].message.content
                }
            }]
        };

        res.json(result);
    } catch (err) {
        console.error('AI Error:', err.response?.data || err.message);
        res.status(500).json({ error: 'AI Connection Failed', details: err.message });
    }
};
