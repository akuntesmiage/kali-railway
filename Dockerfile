# Gunakan Ubuntu sebagai base image
FROM ubuntu:latest

# Set variabel environment
ENV DEBIAN_FRONTEND=noninteractive \
    LC_ALL=C.UTF-8 \
    LANG=C.UTF-8

# Update sistem dan install dependensi dasar
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
    nano \
    unzip \
    bc \
    locales && \
    locale-gen en_US.UTF-8

# Tambahkan repository Node.js dan install Node.js v18 + npm
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash - && \
    apt-get install -y nodejs

# Install versi npm terbaru
RUN npm install -g npm@latest

# Buat folder untuk aplikasi
WORKDIR /app

# Salin semua file panel server dan script tambahan
COPY . /app

# Pastikan folder bot kosong saat deploy
RUN rm -rf /app/bot/* && mkdir -p /app/bot

# Install dependencies untuk panel web dengan solusi masalah
RUN npm cache clean --force && \
    NODE_OPTIONS="--max-old-space-size=8192" npm install --legacy-peer-deps --verbose

# Debugging output untuk memeriksa semua komponen
RUN node -v && npm -v && ffmpeg -version

# Expose port untuk server panel
EXPOSE 8080

# Jalankan aplikasi panel
CMD ["node", "panel.js"]
