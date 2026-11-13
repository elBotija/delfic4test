FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive \
    DISPLAY=:0 \
    RESOLUTION=1280x800x16 \
    LANG=C.UTF-8

# Instalar dependencias: Free Pascal, Lazarus, MariaDB client, X11 virtual, Fluxbox, x11vnc y noVNC
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    fpc \
    fp-compiler \
    fp-units-base \
    fp-units-db \
    fp-units-fcl \
    fp-units-gfx \
    fp-units-gtk2 \
    fp-units-misc \
    lazarus \
    lcl \
    lcl-gtk2 \
    lcl-utils \
    libmysqlclient21 \
    libmariadb3 \
    libmariadb-dev \
    mariadb-client \
    xvfb \
    fluxbox \
    x11vnc \
    novnc \
    websockify \
    supervisor \
    netcat-openbsd \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Configurar compatibilidad de libreria cliente MySQL 8.0 para Free Pascal
RUN ln -sf /usr/lib/*-linux-gnu/libmysqlclient.so.21 /usr/lib/libmysqlclient.so.21 2>/dev/null || true && \
    ln -sf /usr/lib/*-linux-gnu/libmysqlclient.so.21 /usr/lib/libmysqlclient.so 2>/dev/null || true

# Redirigir la raiz de noVNC para abrir vnc.html automaticamente
RUN ln -sf /usr/share/novnc/vnc.html /usr/share/novnc/index.html

WORKDIR /app

# Copiar codigo fuente y configuraciones
COPY src/ /app/src/
COPY docker/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY docker/entrypoint.sh /app/docker/entrypoint.sh

RUN chmod +x /app/docker/entrypoint.sh

# Precompilar el proyecto Lazarus / Delphi
RUN cd /app/src && lazbuild --build-all ColegioLegacy.lpr || true

EXPOSE 8080 5900

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
