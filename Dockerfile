FROM alpine:3.22

ARG ANSIBLE_VERSION="13.5.0"
ARG GOVC_VERSION="v0.53.0"
ARG PACKER_VERSION="1.15.1"
ARG TERRAFORM_VERSION="1.14.8"
ARG OPENTOFU_VERSION="v1.11.6"
ARG KUBECTL_VERSION="v1.35.4"
ARG HELM_VERSION="v4.1.4"
ARG K3SUP_VERSION="0.13.12"

ENV PYTHONDONTWRITEBYTECODE=True
ENV PATH="$PATH:/root/.local/bin"
ENV TZ=UTC

RUN apk add --no-cache \
    atop \
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
    perf \
    pipx \
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
    vim \
    wget

RUN pip install --break-system-packages hvac python-hcl2

RUN pipx ensurepath \
    && pipx install --include-deps ansible==${ANSIBLE_VERSION} \
    && pipx inject ansible hvac

RUN curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 \
    | bash -s -- -v ${HELM_VERSION}

RUN curl -L https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl \
    -o /usr/local/bin/kubectl \
    && chmod +x /usr/local/bin/kubectl

RUN curl -L -o - https://github.com/vmware/govmomi/releases/download/${GOVC_VERSION}/govc_$(uname -s)_$(uname -m).tar.gz \
    | tar -C /usr/local/bin -xvzf - govc

RUN curl -LO https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
    && curl -LO https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip \
    && unzip -o '*.zip' -d /usr/local/bin \
    && rm *.zip \
    && chmod +x /usr/local/bin/*

RUN OPENTOFU_VERSION_STRIPPED=$(echo ${OPENTOFU_VERSION} | sed 's/^v//') \
    && curl -LO https://github.com/opentofu/opentofu/releases/download/${OPENTOFU_VERSION}/tofu_${OPENTOFU_VERSION_STRIPPED}_linux_amd64.zip \
    && unzip tofu_${OPENTOFU_VERSION_STRIPPED}_linux_amd64.zip -d /usr/local/bin \
    && rm tofu_${OPENTOFU_VERSION_STRIPPED}_linux_amd64.zip \
    && chmod +x /usr/local/bin/tofu

RUN curl -sSL https://github.com/alexellis/k3sup/releases/download/${K3SUP_VERSION}/k3sup > k3sup \
    && chmod +x k3sup \
    && mv k3sup /usr/bin/k3sup

ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["/bin/bash"]
