# Gunakan Ubuntu sebagai base image
FROM ubuntu:latest

# Set variabel environment untuk mencegah masalah locale
ENV DEBIAN_FRONTEND=noninteractive \
    LC_ALL=C.UTF-8 \
    LANG=C.UTF-8

# Update sistem dan install dependensi dasar tanpa batasan
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y \
    wget \
    git \
    sudo \
    curl \
    gnupg \
    build-essential \
    ffmpeg \
    net-tools \
    iproute2 \
    iputils-ping \
    dnsutils \
    mc \
    nano \
    unzip \
    bc \
    locales && \
    locale-gen en_US.UTF-8

# Tambahkan repository Node.js dan install Node.js v18 + npm
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash - && \
    apt-get install -y nodejs

# Install versi npm tertentu dan pm2 untuk manajemen proses
RUN npm install -g npm@7.24.0 pm2

# Install ttyd
RUN wget -qO /bin/ttyd https://github.com/tsl0922/ttyd/releases/download/1.7.3/ttyd.x86_64 && \
    chmod +x /bin/ttyd

# Debugging output untuk memeriksa semua komponen
RUN node -v && npm -v && ffmpeg -version && git --version && /bin/ttyd --version && mc --version

# Menghapus cache npm dan log error
RUN rm -rf /root/.npm /root/.node-gyp /root/.cache && \
    npm cache clean --force && \
    npm install --legacy-peer-deps || { echo 'npm install failed'; tail -n 50 /root/.npm/_logs/*; exit 1; }

# Pastikan service dapat diakses melalui IP publik
EXPOSE $PORT
EXPOSE 80
EXPOSE 443

# Jalankan pm2 untuk mengelola ttyd dan proses lainnya
CMD ["/bin/bash", "-c", "\
  pm2 start /bin/ttyd --name ttyd -- -p $PORT -c 666:666 /bin/bash && \
  pm2 logs"]
