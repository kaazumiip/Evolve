const axios = require('axios');

exports.getAIResponse = async (req, res) => {
    try {
        const { messages, max_tokens } = req.body;
        
        const response = await axios.post('https://openrouter.ai/api/v1/chat/completions', {
            model: "google/gemini-2.0-flash-001",
            messages: messages,
            max_tokens: max_tokens || 500,
        }, {
            headers: {
                'Authorization': `Bearer ${process.env.AI_CHAT_API_KEY}`,
                'Content-Type': 'application/json',
                'HTTP-Referer': 'https://evolve-rv6a.onrender.com', // Required by OpenRouter
                'X-Title': 'Evolve App',
            }
        });

        res.json(response.data);
    } catch (err) {
        console.error('AI Error:', err.response?.data || err.message);
        res.status(500).json({ error: 'AI Connection Failed', details: err.message });
    }
};
