# syntax=docker/dockerfile:1

FROM docker.io/library/docker:29.9.0-cli@sha256:1a4c7cb63513f349bdad01fcc6e0f3f2f67d37b9da86f14dc0d4a0942eecda00 AS docker-cli
FROM docker.io/jdxcode/mise:2026.10.8@sha256:b720f506c21a6bf5f733a3b1cd04361617ac461a597e44f513aa3976dcd71e57 AS mise

FROM docker.io/library/node:24.21.0-trixie-slim@sha256:173f125896c3b47ddf056734c7ea789d04595a6a08769a8f78e0df642781fb66

# renovate: datasource=npm depName=@open-mercato/cezar
ARG CEZAR_VERSION=0.15.0
# renovate: datasource=npm depName=@anthropic-ai/claude-code
ARG CLAUDE_CODE_VERSION=2.1.296
# renovate: datasource=npm depName=@openai/codex
ARG CODEX_VERSION=0.162.1
# renovate: datasource=npm depName=mongosh
ARG MONGOSH_VERSION=2.13.0

ENV LANG=C.UTF-8 \
    TZ=Europe/Warsaw \
    DISABLE_AUTOUPDATER=1 \
    MISE_SYSTEM_DATA_DIR=/usr/local/share/mise

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        bzip2 build-essential ca-certificates curl default-mysql-client dnsutils \
        fd-find file git git-lfs gnupg iputils-ping jq less make netcat-openbsd \
        openssh-client pkg-config postgresql-client procps python3 redis-tools \
        ripgrep rsync sqlite3 tini tzdata unzip xz-utils zip \
    && rm -rf /var/lib/apt/lists/* \
    && ln -s /usr/bin/fdfind /usr/local/bin/fd

COPY --from=docker-cli /usr/local/bin/docker /usr/local/bin/docker
COPY --from=docker-cli /usr/local/libexec/docker/cli-plugins/ /usr/local/libexec/docker/cli-plugins/

RUN npm install --global --no-fund --no-audit \
        "@open-mercato/cezar@${CEZAR_VERSION}" \
        "@anthropic-ai/claude-code@${CLAUDE_CODE_VERSION}" \
        "@openai/codex@${CODEX_VERSION}" \
        "mongosh@${MONGOSH_VERSION}" \
    && npm cache clean --force

COPY --from=mise /usr/local/bin/mise /usr/local/bin/mise

COPY mise.toml /etc/mise/config.toml
# The token lifts mise's GitHub API rate limit; it is not stored in the image.
RUN --mount=type=secret,id=github_token,env=GITHUB_TOKEN \
    MISE_DATA_DIR="${MISE_SYSTEM_DATA_DIR}" MISE_CACHE_DIR=/tmp/mise-cache mise install \
    && MISE_DATA_DIR="${MISE_SYSTEM_DATA_DIR}" mise reshim \
    && rm -rf /tmp/mise-cache

# The base image's `node` user owns uid/gid 1000; rename it so HOME is /home/cezar.
RUN usermod --login cezar --home /home/cezar --move-home node \
    && groupmod --new-name cezar node

COPY --chmod=0755 entrypoint.sh /usr/local/bin/cezar-entrypoint
COPY --chmod=0755 git-credential-env /usr/local/bin/git-credential-env

# /home/cezar holds config and logins; /home/cezar/work holds checkouts and caches.
ENV HOME=/home/cezar \
    CEZ_PROJECTS_DIR=/home/cezar/work/projects \
    CEZ_BROWSE_ROOT=/home/cezar/work \
    XDG_CACHE_HOME=/home/cezar/work/.cache \
    XDG_DATA_HOME=/home/cezar/work/.local/share \
    MISE_DATA_DIR=/home/cezar/work/.local/share/mise \
    GOPATH=/home/cezar/work/go \
    NPM_CONFIG_CACHE=/home/cezar/work/.cache/npm \
    NPM_CONFIG_PREFIX=/home/cezar/work/.npm-global \
    PATH=/home/cezar/work/.local/share/mise/shims:/usr/local/share/mise/shims:/home/cezar/work/go/bin:/home/cezar/work/.npm-global/bin:/usr/local/bin:/usr/bin:/bin

USER 1000:1000
WORKDIR /home/cezar
EXPOSE 4321

ENTRYPOINT ["/usr/bin/tini", "--", "/usr/local/bin/cezar-entrypoint"]
