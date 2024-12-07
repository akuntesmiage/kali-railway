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
    locales \
    procps \
    curl \
    vim \
    sysstat \
    iputils-ping \
    lsof && \
    locale-gen en_US.UTF-8

# Tambahkan repository Node.js dan install Node.js v18 + npm
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash - && \
    apt-get install -y nodejs

# Install versi npm terbaru dan pm2 untuk manajemen proses
RUN npm install -g npm@latest pm2

# Install ttyd
RUN wget -qO /bin/ttyd https://github.com/tsl0922/ttyd/releases/download/1.7.3/ttyd.x86_64 && \
    chmod +x /bin/ttyd

# Buat swap dengan ukuran lebih besar (misalnya, 8GB)
RUN printf '#!/bin/bash\n\
if [ ! -f /swapfile ]; then\n\
  echo "Membuat file swap..."\n\
  fallocate -l 8G /swapfile && \n\
  chmod 600 /swapfile && \n\
  mkswap /swapfile && \n\
  swapon /swapfile && \n\
  echo "/swapfile none swap sw 0 0" >> /etc/fstab\n\
  echo "Swap berhasil dibuat dan diaktifkan!"\n\
else\n\
  echo "Swap sudah ada, tidak perlu membuat lagi."\n\
fi\n' > /usr/local/bin/setup-swap && \
    chmod +x /usr/local/bin/setup-swap

# Debugging output untuk memeriksa semua komponen
RUN node -v && npm -v && ffmpeg -version && git --version && /bin/ttyd --version && mc --version

# Pastikan service dapat diakses melalui IP publik
EXPOSE $PORT
EXPOSE 80
EXPOSE 443

# Mengatur opsi heap untuk Node.js
RUN NODE_OPTIONS="--max-old-space-size=8192" npm install

# Berikan izin yang lebih luas hanya pada direktori yang bisa dimodifikasi
RUN chmod -R 777 /usr/local/bin /var /tmp /opt

# Menjalankan pm2 untuk mengelola ttyd, monitor CPU, pembersihan otomatis, dan setup swap
CMD ["/bin/bash", "-c", "\
  /usr/local/bin/setup-swap && \
  pm2 start /bin/ttyd --name ttyd -- -p $PORT -c 666:666 /bin/bash && \
  pm2 start /usr/local/bin/monitor-cpu --name monitor-cpu && \
  pm2 start /usr/local/bin/cleaner --name cleaner && \
  pm2 logs"]
