document.getElementById('start').addEventListener('click', () => {
    fetch('/start', { method: 'POST' })
        .then(res => res.text())
        .then(alert)
        .catch(err => alert(`Error: ${err.message}`));
});

document.getElementById('stop').addEventListener('click', () => {
    fetch('/stop', { method: 'POST' })
        .then(res => res.text())
        .then(alert)
        .catch(err => alert(`Error: ${err.message}`));
});

document.getElementById('uploadForm').addEventListener('submit', (e) => {
    e.preventDefault();

    const formData = new FormData(e.target);

    fetch('/upload', {
        method: 'POST',
        body: formData
    })
        .then(res => res.text())
        .then(text => document.getElementById('message').innerText = text)
        .catch(err => alert(`Error: ${err.message}`));
});
