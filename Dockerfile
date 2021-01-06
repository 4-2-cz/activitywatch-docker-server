# syntax = docker/dockerfile:1.2

FROM python:3.6 as activitywatch-server-base

RUN rm -f /etc/apt/apt.conf.d/docker-clean; echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' > /etc/apt/apt.conf.d/keep-cache

RUN --mount=type=cache,target=/var/cache/apt --mount=type=cache,target=/var/lib/apt \
    curl -sL https://deb.nodesource.com/setup_12.x | bash - && \
    curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py | python - && \
    apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
        curl \
        git \
        gcc \
        g++ \
        htop \
        make \
        mc \
        nodejs && \
    apt-get autoremove -y && \
    apt-get clean all && \
    rm -rf /var/lib/apt/lists/*

RUN --mount=type=cache,target=/root/.npm --mount=type=cache,target=/root/.cache \
    pip3 install --upgrade pip && \
    pip install pymongo
    
# ---

FROM python:3.6

COPY --from=activitywatch-server-base .npm/ ./

RUN set -x && \
    git clone --depth 1 --recursive https://github.com/ActivityWatch/aw-server.git && \
    make -C /aw-server build && \
    rm -rf /aw-server /root/.cache /root/.npm

EXPOSE 5600

CMD [ "aw-server", "--host", "0.0.0.0" ]
