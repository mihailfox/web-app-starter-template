FROM mcr.microsoft.com/devcontainers/typescript-node:24-bookworm

ENV DEBIAN_FRONTEND=noninteractive \
    COREPACK_ENABLE_DOWNLOAD_PROMPT=0

RUN --mount=type=cache,sharing=locked,target=/var/cache/apt \
    --mount=type=cache,sharing=locked,target=/var/lib/apt \
    apt-get update \
    && apt-get install -y --no-install-recommends \
      adwaita-icon-theme \
      at-spi2-common \
      dbus \
      dbus-bin \
      dbus-daemon \
      dbus-session-bus-common \
      dbus-system-bus-common \
      dbus-user-session \
      dconf-gsettings-backend \
      dconf-service \
      dmsetup \
      fonts-freefont-ttf \
      fonts-ipafont-gothic \
      fonts-liberation \
      fonts-noto-color-emoji \
      fonts-tlwg-loma-otf \
      fonts-unifont \
      fonts-wqy-zenhei \
      gtk-update-icon-cache \
      libapparmor1 \
      libargon2-1 \
      libasound2 \
      libasound2-data \
      libatk-bridge2.0-0 \
      libatk1.0-0 \
      libatspi2.0-0 \
      libavahi-client3 \
      libavahi-common-data \
      libavahi-common3 \
      libcairo-gobject2 \
      libcolord2 \
      libcryptsetup12 \
      libcups2 \
      libdbus-1-3 \
      libdbus-glib-1-2 \
      libdconf1 \
      libdevmapper1.02.1 \
      libdrm-amdgpu1 \
      libdrm-common \
      libdrm-intel1 \
      libdrm-nouveau2 \
      libdrm-radeon1 \
      libdrm2 \
      libepoxy0 \
      libfdisk1 \
      libfontenc1 \
      libgdk-pixbuf-2.0-0 \
      libgdk-pixbuf2.0-common \
      libgl1 \
      libgl1-mesa-dri \
      libglapi-mesa \
      libglvnd0 \
      libglx-mesa0 \
      libglx0 \
      libgtk-3-0 \
      libgtk-3-common \
      libice6 \
      libip4tc2 \
      libjson-c5 \
      libkmod2 \
      libllvm15 \
      libpam-systemd \
      libpciaccess0 \
      libsensors-config \
      libsensors5 \
      libsm6 \
      libsystemd-shared \
      libwayland-client0 \
      libwayland-cursor0 \
      libwayland-egl1 \
      libx11-xcb1 \
      libxaw7 \
      libxcb-dri2-0 \
      libxcb-dri3-0 \
      libxcb-glx0 \
      libxcb-present0 \
      libxcb-randr0 \
      libxcb-sync1 \
      libxcb-xfixes0 \
      libxcomposite1 \
      libxcursor1 \
      libxdamage1 \
      libxfixes3 \
      libxfont2 \
      libxinerama1 \
      libxkbcommon0 \
      libxkbfile1 \
      libxmu6 \
      libxpm4 \
      libxrandr2 \
      libxshmfence1 \
      libxt6 \
      libxtst6 \
      libxxf86vm1 \
      libz3-4 \
      systemd \
      systemd-sysv \
      x11-common \
      x11-xkb-utils \
      xfonts-encodings \
      xfonts-scalable \
      xfonts-utils \
      xkb-data \
      xserver-common \
      xvfb \
      iputils-ping \
      netcat-openbsd \
      bash-completion \
      ca-certificates \
      curl \
      git-lfs \
      jq \
      unzip \
      zip \
    && rm -rf /var/lib/apt/lists/*

RUN npm install --location=global npm@latest \
    && corepack enable \
    && mkdir -p /home/node/.cache/ms-playwright /home/node/.local/bin \
    && chown -R node:node /home/node/.cache /home/node/.local
