# SPDX-FileCopyrightText: © 2025 Nfrastack <code@nfrastack.com>
#
# SPDX-License-Identifier: MIT

ARG \
    BASE_IMAGE

FROM ${BASE_IMAGE}

LABEL \
        org.opencontainers.image.title="Loki" \
        org.opencontainers.image.description="Log aggregator and shipper" \
        org.opencontainers.image.url="https://hub.docker.com/r/nfrastack/loki" \
        org.opencontainers.image.documentation="https://github.com/nfrastack/container-loki/blob/main/README.md" \
        org.opencontainers.image.source="https://github.com/nfrastack/container-loki.git" \
        org.opencontainers.image.authors="Nfrastack <code@nfrastack.com>" \
        org.opencontainers.image.vendor="Nfrastack <https://www.nfrastack.com>" \
        org.opencontainers.image.licenses="MIT"

ARG \
    LOKI_VERSION="v3.5.5" \
    LOKI_REPO_URL="https://github.com/grafana/loki"

COPY CHANGELOG.md /usr/src/container/CHANGELOG.md
COPY LICENSE /usr/src/container/LICENSE
COPY README.md /usr/src/container/README.md

ENV \
    NGINX_SITE_ENABLED=loki \
    NGINX_CLIENT_BODY_BUFFER_SIZE=2M \
    NGINX_ENABLE_CREATE_SAMPLE_HTML=FALSE \
    NGINX_WORKER_PROCESSES=1 \
    CONTAINER_ENABLE_SCHEDULING=TRUE \
    IMAGE_NAME="nfrastack/loki" \
    IMAGE_REPO_URL="https://github.com/nfrastack/container-loki/"

RUN echo "" && \
    LOKI_BUILD_DEPS_ALPINE=" \
                                git \
                                go \
                           " \
                           && \
    source /container/base/functions/container/build && \
    container_build_log image && \
    package update && \
    package upgrade && \
    package install \
                        LOKI_BUILD_DEPS \
                    && \
    \
    clone_git_repo "${LOKI_REPO_URL}" ${LOKI_VERSION} && \
    go build -ldflags='-s -w' -o /usr/local/bin/logcli ./cmd/logcli  && \
    go build -ldflags='-s -w' -o /usr/local/bin/loki ./cmd/loki  && \
    go build -ldflags='-s -w' -o /usr/local/bin/loki-canary ./cmd/loki-canary  && \
    \
    package remove \
                    LOKI_BUILD_DEPS \
                    && \
    package cleanup

COPY rootfs /
