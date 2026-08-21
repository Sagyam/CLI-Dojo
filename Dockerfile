# YetiLink CLI Dojo — Dockerfile
FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive \
    TZ=UTC \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    LESS="-R -F -X" \
    PAGER=less

# 1. Unminimize Ubuntu to restore real manpages & documentation
RUN yes | unminimize

# 2. Install base system, compilers, core CLI utilities, and runtime dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    # Documentation
    man-db manpages manpages-dev cron \
    # Core & Teaching Utilities
    coreutils findutils grep sed gawk less file tree psmisc procps lsof util-linux bsdmainutils \
    # Archive Tools
    tar gzip bzip2 xz-utils zstd zip unzip rsync \
    # Network Tools
    curl wget iproute2 dnsutils iputils-ping netcat-openbsd openssh-client \
    # Scripting & Data
    jq python3 \
    # Shells & Modern Terminal Utilities
    zsh zsh-autosuggestions zsh-syntax-highlighting fzf bat ripgrep fd-find htop ncdu neovim tmux git sudo gosu shellcheck ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# 3. Install Starship prompt (pinned binary install)
RUN curl -sS https://starship.rs/install.sh | sh -s -- -y --version v1.22.1

# 4. Install mdcat (terminal markdown renderer) and configure bat
RUN ARCH="$(dpkg --print-architecture)" && \
    if [ "$ARCH" = "amd64" ]; then \
        curl -fsSL "https://github.com/swsnr/mdcat/releases/download/mdcat-2.7.1/mdcat-2.7.1-x86_64-unknown-linux-gnu.tar.gz" -o /tmp/mdcat.tar.gz && \
        tar -xzf /tmp/mdcat.tar.gz -C /tmp && \
        mv /tmp/mdcat-2.7.1-x86_64-unknown-linux-gnu/mdcat /usr/local/bin/mdcat && \
        chmod +x /usr/local/bin/mdcat && \
        rm -rf /tmp/mdcat*; \
    fi && \
    ln -sf /usr/bin/batcat /usr/local/bin/bat

# 5. Install BATS (core, support, assert, file) pinned in /opt/bats/
RUN mkdir -p /opt/bats && \
    git clone --depth 1 --branch v1.11.1 https://github.com/bats-core/bats-core.git /opt/bats/bats-core && \
    /opt/bats/bats-core/install.sh /usr/local && \
    git clone --depth 1 --branch v0.3.0 https://github.com/bats-core/bats-support.git /opt/bats/bats-support && \
    git clone --depth 1 --branch v2.1.0 https://github.com/bats-core/bats-assert.git /opt/bats/bats-assert && \
    git clone --depth 1 --branch v0.4.0 https://github.com/bats-core/bats-file.git /opt/bats/bats-file

# 6. User and group configuration
RUN touch /var/mail/ubuntu && (userdel -r ubuntu 2>/dev/null || true) && \
    groupadd -g 1000 student && \
    useradd -m -u 1000 -g 1000 -s /usr/bin/zsh student && \
    groupadd ops && \
    groupadd billing && \
    usermod -aG ops,billing student

# 7. Configure sudoers for student (strictly whitelisted dojo-setup and dojo-grade)
RUN echo "student ALL=(root) NOPASSWD: /opt/dojo/bin/dojo-setup, /opt/dojo/bin/dojo-grade" > /etc/sudoers.d/dojo && \
    chmod 0440 /etc/sudoers.d/dojo

# 8. Setup /etc/skel-dojo configuration templates
RUN mkdir -p /etc/skel-dojo/.config/nvim /etc/skel-dojo/bin
COPY config/zshrc /etc/skel-dojo/.zshrc
COPY config/starship.toml /etc/skel-dojo/.config/starship.toml
COPY config/nvim/init.lua /etc/skel-dojo/.config/nvim/init.lua
COPY config/motd.txt /etc/skel-dojo/.config/motd.txt

# 9. Install Dojo CLI and exercises to /opt/dojo
RUN mkdir -p /opt/dojo/bin /opt/dojo/lib /opt/dojo/exercises /opt/dojo/state /opt/dojo/config /opt/dojo/ci
COPY dojo/ /opt/dojo/
COPY ci/ /opt/dojo/ci/
COPY config/motd.txt /opt/dojo/config/motd.txt
COPY CHEATSHEET.md /opt/dojo/CHEATSHEET.md

RUN chmod +x /opt/dojo/bin/* /opt/dojo/ci/* && \
    ln -sf /opt/dojo/bin/dojo /usr/local/bin/dojo && \
    chown -R root:root /opt/dojo && \
    chmod 755 /opt/dojo && \
    chmod 700 /opt/dojo/state && \
    find /opt/dojo/exercises -type d -name "meta" -exec chmod 700 {} + 2>/dev/null || true

# 10. Install Entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

WORKDIR /home/student
ENTRYPOINT ["/entrypoint.sh"]
