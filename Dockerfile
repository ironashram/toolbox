FROM ubuntu:noble

ARG ANSIBLE_VERSION="13.0.0"
ARG GOVC_VERSION="v0.52.0"
ARG PACKER_VERSION="1.14.3"
ARG TERRAFORM_VERSION="1.14.0"
ARG OPENTOFU_VERSION="v1.10.7"
ARG KUBECTL_VERSION="v1.34.2"
ARG HELM_VERSION="v4.0.1"
ARG K3SUP_VERSION="0.13.11"
ARG AWSCLI_VERSION="2.22.35"

ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONDONTWRITEBYTECODE=True
ENV PATH="$PATH:/root/.local/bin"
ENV TZ=UTC

RUN apt-get update && \
    apt-get install -y \
    atop \
    bash \
    bash-completion \
    conntrack \
    curl \
    dnsutils \
    dumb-init \
    git \
    htop \
    inetutils-ping \
    iproute2 \
    iptables \
    jq \
    linux-tools-common \
    make \
    ncat \
    net-tools \
    openssh-client \
    openssl \
    pipx \
    python3-hvac \
    python3-pip \
    python3-semver \
    s3cmd \
    strace \
    sudo \
    tcpdump \
    telnet \
    unzip \
    vim \
    wget

RUN pip install --break-system-packages python-hcl2

RUN pipx ensurepath \
    && pipx install --include-deps ansible==${ANSIBLE_VERSION} \
    && pipx inject ansible hvac

RUN curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 \
    | bash -s -- -v ${HELM_VERSION}

RUN curl -L https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl \
    -o /usr/local/bin/kubectl

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

RUN curl https://awscli.amazonaws.com/awscli-exe-linux-x86_64-${AWSCLI_VERSION}.zip -o awscliv2.zip \
    && unzip awscliv2.zip \
    && ./aws/install \
    && rm -rf aws awscliv2.zip

RUN curl -sSL https://github.com/alexellis/k3sup/releases/download/${K3SUP_VERSION}/k3sup > k3sup \
    && chmod +x k3sup \
    && mv k3sup /usr/bin/k3sup

RUN apt-get clean autoclean; \
    apt-get autoremove --yes; \
    rm -rf /var/lib/{apt,dpkg,cache,log}/

ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["/bin/bash"]
