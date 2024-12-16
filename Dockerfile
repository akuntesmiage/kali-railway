FROM kalilinux/kali-rolling

# Update dan install dependencies
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get -y install wget curl git unzip build-essential

# Install ttyd untuk terminal berbasis web
RUN wget -qO /bin/ttyd https://github.com/tsl0922/ttyd/releases/download/1.7.3/ttyd.x86_64 && \
    chmod +x /bin/ttyd

# Install code-server untuk editing file berbasis web
RUN curl -fsSL https://code-server.dev/install.sh | sh

# Konfigurasi code-server agar dapat diakses dengan username dan password
RUN mkdir -p /root/.config/code-server && \
    echo "bind-addr: 0.0.0.0:8080\n" > /root/.config/code-server/config.yaml && \
    echo "auth: password\n" >> /root/.config/code-server/config.yaml && \
    echo "password: 666\n" >> /root/.config/code-server/config.yaml && \
    echo "cert: false\n" >> /root/.config/code-server/config.yaml

# Membuka port untuk terminal (ttyd) dan code-server
EXPOSE $PORT
EXPOSE 8080

# Debugging
RUN echo "666:666" > /tmp/debug

# Menjalankan ttyd dan code-server secara paralel menggunakan skrip
CMD ["/bin/bash", "-c", "code-server & /bin/ttyd -p $PORT -c 666:666 /bin/bash"]
