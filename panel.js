const express = require('express');
const fileUpload = require('express-fileupload');
const { exec } = require('child_process');
const path = require('path');

const app = express();
const port = 8080;

// Middleware untuk file upload
app.use(fileUpload());
app.use(express.static('public'));

// Tombol Start
let botProcess = null;

// Halaman utama
app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

// Upload file bot
app.post('/upload', (req, res) => {
    if (!req.files || !req.files.botFile) {
        return res.status(400).send('No files were uploaded.');
    }

    const botFile = req.files.botFile;
    const uploadPath = path.join(__dirname, 'bot', botFile.name);

    botFile.mv(uploadPath, (err) => {
        if (err) return res.status(500).send(err);
        res.send('File uploaded successfully!');
    });
});

// Start bot
app.post('/start', (req, res) => {
    if (botProcess) {
        return res.status(400).send('Bot is already running!');
    }

    botProcess = exec('node bot/index.js', { cwd: path.join(__dirname, 'bot') });

    botProcess.stdout.on('data', (data) => console.log(data));
    botProcess.stderr.on('data', (data) => console.error(data));
    botProcess.on('close', () => botProcess = null);

    res.send('Bot started successfully!');
});

// Stop bot
app.post('/stop', (req, res) => {
    if (!botProcess) {
        return res.status(400).send('No bot is running!');
    }

    botProcess.kill();
    botProcess = null;
    res.send('Bot stopped successfully!');
});

// Start server
app.listen(port, () => {
    console.log(`Panel is running on http://localhost:${port}`);
});
