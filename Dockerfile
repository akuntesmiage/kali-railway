FROM kalilinux/kali-rolling

# Update dan install dependencies
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y wget curl unzip build-essential

# Install ttyd (terminal berbasis web)
RUN wget -qO /bin/ttyd https://github.com/tsl0922/ttyd/releases/download/1.7.3/ttyd.x86_64 && \
    chmod +x /bin/ttyd

# Install filebrowser (file manager berbasis web)
RUN curl -fsSL https://github.com/filebrowser/filebrowser/releases/download/v2.23.0/linux-amd64-filebrowser.tar.gz | tar -xz && \
    mv filebrowser /usr/local/bin/

# Install Caddy (reverse proxy)
RUN apt-get install -y debian-keyring debian-archive-keyring apt-transport-https && \
    curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | tee /etc/apt/sources.list.d/caddy-stable.list && \
    apt-get update && apt-get install -y caddy

# Konfigurasi Caddy untuk menggabungkan port
RUN echo "localhost:8080 {\n reverse_proxy /terminal localhost:8080\n reverse_proxy /filebrowser localhost:8081\n}" > /etc/caddy/Caddyfile

# Expose port 8080 untuk Railway
EXPOSE 8080

# Menjalankan ttyd, filebrowser, dan caddy
CMD ["/bin/bash", "-c", "/usr/local/bin/filebrowser --port 8081 --username 666 --password 666 & /bin/ttyd -p 8080 -c 666:666 /bin/bash & caddy run --config /etc/caddy/Caddyfile"]
