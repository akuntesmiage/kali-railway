FROM kalilinux/kali-rolling

# Update dan install dependencies
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get -y install wget curl unzip build-essential

# Install ttyd (terminal berbasis web)
RUN wget -qO /bin/ttyd https://github.com/tsl0922/ttyd/releases/download/1.7.3/ttyd.x86_64 && \
    chmod +x /bin/ttyd

# Install file browser (untuk upload, download, dan edit file)
RUN curl -fsSL https://github.com/filebrowser/filebrowser/releases/download/v2.23.0/linux-amd64-filebrowser.tar.gz | tar -xz && \
    mv filebrowser /usr/local/bin/

# Expose port untuk ttyd (terminal) dan filebrowser (file manager)
EXPOSE 8080 8081

# Menjalankan ttyd dan filebrowser secara paralel
CMD ["/bin/bash", "-c", "/usr/local/bin/filebrowser --port 8081 --username 666 --password 666 & /bin/ttyd -p 8080 -c 666:666 /bin/bash"]
