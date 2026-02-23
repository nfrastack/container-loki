# SPDX-FileCopyrightText: © 2026 Nfrastack <code@nfrastack.com>
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
    LOKI_VERSION="v3.6.7" \
    LOKI_REPO_URL="https://github.com/grafana/loki"

COPY CHANGELOG.md /usr/src/container/CHANGELOG.md
COPY LICENSE /usr/src/container/LICENSE
COPY README.md /usr/src/container/README.md

ENV \
    IMAGE_NAME="nfrastack/loki" \
    IMAGE_REPO_URL="https://github.com/nfrastack/container-loki/"

RUN echo "" && \
    BUILD_ENV=" \
                10-nginx/ENABLE_NGINX=FALSE \
                10-nginx/NGINX_SITE_ENABLED=loki \
                10-nginx/NGINX_ENABLE_CREATE_SAMPLE_HTML=FALSE \
              " \
              && \
    LOKI_BUILD_DEPS_ALPINE=" \
                                git \
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
    package build go && \
    clone_git_repo "${LOKI_REPO_URL}" ${LOKI_VERSION} && \
    for package in logcli loki loki-canary ; do \
        go build -ldflags='-s -w' -o /usr/local/bin/${package} ./cmd/${package}; \
    done ; \
    \
    container_build_log add "Loki" "${LOKI_VERSION}" "${LOKI_REPO_URL}" && \
    sed -i "s|{{NGINX_CLIENT_BODY_BUFFER_SIZE}}|2M|g" /container/data/nginx/templates/server/http-client.template
    package remove \
                    LOKI_BUILD_DEPS \
                    && \
    package cleanup

COPY rootfs /
