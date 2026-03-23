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

        // Direct Gemini API Call (using axios for simplicity)
        const response = await axios.post(
            `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=${process.env.AI_CHAT_API_KEY}`,
            {
                contents: [
                    { role: "user", parts: [{ text: `SYSTEM INSTRUCTION: ${systemPrompt}` }] },
                    ...messages.map(m => ({
                        role: m.role === 'assistant' ? 'model' : 'user',
                        parts: [{ text: m.content }]
                    }))
                ],
                generationConfig: {
                    maxOutputTokens: max_tokens || 500,
                    temperature: 0.7,
                }
            }
        );

        // Transform Gemini response to match the expected format on frontend
        const result = {
            choices: [{
                message: {
                    content: response.data.candidates[0].content.parts[0].text
                }
            }]
        };

        res.json(result);
    } catch (err) {
        console.error('AI Error:', err.response?.data || err.message);
        res.status(500).json({ error: 'AI Connection Failed', details: err.message });
    }
};
