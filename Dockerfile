FROM alpine:3.23

ARG ANSIBLE_CORE_VERSION="2.20.4"
ARG OPENTOFU_VERSION="v1.11.6"
ARG KUBECTL_VERSION="v1.35.4"
ARG HELM_VERSION="v4.1.4"

ENV PYTHONDONTWRITEBYTECODE=True
ENV PIP_NO_CACHE_DIR=1
ENV TZ=UTC

RUN apk add --no-cache \
    aws-cli \
    bash \
    bash-completion \
    bind-tools \
    ca-certificates \
    conntrack-tools \
    curl \
    dumb-init \
    git \
    htop \
    inetutils-telnet \
    iproute2 \
    iptables \
    iputils \
    jq \
    make \
    net-tools \
    nmap-ncat \
    openssh-client \
    openssl \
    py3-pip \
    py3-semver \
    python3 \
    rsync \
    s3cmd \
    strace \
    sudo \
    tcpdump \
    tzdata \
    unzip \
    wget

RUN pip install --break-system-packages \
        ansible-core==${ANSIBLE_CORE_VERSION} \
        hvac \
        python-hcl2 \
    && ansible-galaxy collection install -p /usr/share/ansible/collections \
        community.docker community.general community.hashi_vault \
    && rm -rf /root/.cache /root/.ansible/tmp

RUN curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 \
    | bash -s -- -v ${HELM_VERSION}

RUN curl -L https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl \
    -o /usr/local/bin/kubectl \
    && chmod +x /usr/local/bin/kubectl

RUN OPENTOFU_VERSION_STRIPPED=$(echo ${OPENTOFU_VERSION} | sed 's/^v//') \
    && curl -LO https://github.com/opentofu/opentofu/releases/download/${OPENTOFU_VERSION}/tofu_${OPENTOFU_VERSION_STRIPPED}_linux_amd64.zip \
    && unzip tofu_${OPENTOFU_VERSION_STRIPPED}_linux_amd64.zip -d /usr/local/bin \
    && rm tofu_${OPENTOFU_VERSION_STRIPPED}_linux_amd64.zip \
    && chmod +x /usr/local/bin/tofu


ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["/bin/bash"]
