FROM i386/debian:stable-slim

# Install prerequisites
RUN apt-get update \
    && DEBIAN_FRONTEND="noninteractive" apt-get install -y --no-install-recommends \
        procps \
        gnupg \
        gpg-agent \
        xvfb \
        xauth \
        inotify-tools \
        wine \
        python3-minimal \
    && rm -rf /var/lib/apt/lists/*

# Setup wine prefix to /.wine
ENV WINEPREFIX /wine_configs/default
# Setup architecture as win32
ENV WINEARCH win32

RUN mkdir -p /wine_configs/default

# Run setup the first time
RUN wine wineboot --init > /dev/null 2>&1
# Copy over our wine config to ensure PoissonSuperfish is on the path for Wine
COPY wine_cfg /wine_configs/default

# Copy the code over and extract
COPY superfish.tar.gz /
RUN tar -xzf superfish.tar.gz; rm -rf superfish.tar.gz

# Create unix alias for wine commands for superfish
RUN /bin/bash -c 'for app in $(ls /PoissonSuperfish/*.EXE); \
do \
NAME=`basename ${app,,} | sed s/".exe"//`; \
CMD="fish_wrapper $app"; \
echo "#!/bin/bash" > /usr/bin/$NAME; \
echo "$CMD  \"\$@\"" >> /usr/bin/$NAME; \
chmod +x /usr/bin/$NAME; \
done'

RUN chmod 777 -R /wine_configs

COPY fish_wrapper /usr/bin/fish_wrapper
RUN chmod a+x /usr/bin/fish_wrapper

COPY fish_startup /usr/bin/fish_startup
RUN chmod a+x /usr/bin/fish_startup

COPY fish_command /usr/bin/fish_command
RUN chmod a+x /usr/bin/fish_command

COPY xvfb-run /usr/bin/xvfb-run
RUN chmod a+x /usr/bin/xvfb-run

COPY watcher /usr/bin/watcher
RUN chmod a+x /usr/bin/watcher

# Enable screen scaling for Interactive Fish runs
ENV SCALED_FISH=1

WORKDIR /data
