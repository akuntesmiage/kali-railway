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

# Copy file panel server dan script tambahan
COPY . /app

# Install dependencies untuk panel web
RUN npm install

# Debugging output untuk memeriksa semua komponen
RUN node -v && npm -v && ffmpeg -version

# Expose port untuk server panel
EXPOSE 8080

# Jalankan aplikasi panel
CMD ["node", "panel.js"]
