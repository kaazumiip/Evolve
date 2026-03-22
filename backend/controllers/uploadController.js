const cloudinary = require('cloudinary').v2;
require('dotenv').config();

cloudinary.config({
    cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
    api_key: process.env.CLOUDINARY_API_KEY,
    api_secret: process.env.CLOUDINARY_API_SECRET
});

exports.uploadMedia = async (req, res) => {
    if (!req.file) {
        return res.status(400).json({ msg: 'No file uploaded' });
    }

    try {
        // Determine resource_type for Cloudinary
        // Use 'auto' to let Cloudinary decide, but we still hint for our logic
        const resourceType = 'auto';

        // Upload to Cloudinary using buffer
        const uploadResult = await new Promise((resolve, reject) => {
            const uploadStream = cloudinary.uploader.upload_stream(
                {
                    folder: 'evolve_media',
                    resource_type: resourceType
                },
                (error, result) => {
                    if (error) reject(error);
                    else resolve(result);
                }
            );
            uploadStream.end(req.file.buffer);
        });

        res.json({
            url: uploadResult.secure_url,
            resource_type: uploadResult.resource_type
        });
    } catch (err) {
        console.error('Cloudinary Upload Error:', err.message);
        res.status(500).send('Server Error');
    }
};
