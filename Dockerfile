FROM alpine:3.24

# renovate: datasource=github-releases depName=siderolabs/talos
ARG TALOSCTL_VERSION=v1.14.0
# renovate: datasource=github-releases depName=kubernetes/kubernetes
ARG KUBECTL_VERSION=v1.37.0
# renovate: datasource=github-releases depName=helm/helm
ARG HELM_VERSION=v4.2.4
# renovate: datasource=github-releases depName=siderolabs/omni
ARG OMNICTL_VERSION=v1.11.0
# renovate: datasource=github-releases depName=derailed/k9s
ARG K9S_VERSION=v0.51.0
# renovate: datasource=github-releases depName=ahmetb/kubectx
ARG KUBECTX_VERSION=v0.11.0
# renovate: datasource=github-releases depName=int128/kubelogin
ARG KUBELOGIN_VERSION=v1.36.4

# Provided by buildkit, the default keeps classic `docker build` working
ARG TARGETARCH=amd64

WORKDIR /root

RUN apk add --no-cache \
    bash-completion curl wget lvm2 util-linux jq yq drbd-utils tcpdump nano cri-tools bash tshark \
    bind-tools iproute2 nmap nmap-ncat socat iperf3 mtr \
    e2fsprogs xfsprogs parted nvme-cli \
    openssl vim tmux lsof strace git fzf unzip aws-cli coreutils

RUN curl -fsSL "https://github.com/siderolabs/talos/releases/download/${TALOSCTL_VERSION}/talosctl-linux-${TARGETARCH}" -o /usr/local/bin/talosctl \
    && curl -fsSL "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/${TARGETARCH}/kubectl" -o /usr/local/bin/kubectl \
    && curl -fsSL "https://github.com/siderolabs/omni/releases/download/${OMNICTL_VERSION}/omnictl-linux-${TARGETARCH}" -o /usr/local/bin/omnictl \
    && curl -fsSL "https://raw.githubusercontent.com/ahmetb/kubectx/${KUBECTX_VERSION}/kubectx" -o /usr/local/bin/kubectx \
    && curl -fsSL "https://raw.githubusercontent.com/ahmetb/kubectx/${KUBECTX_VERSION}/kubens" -o /usr/local/bin/kubens \
    && curl -fsSL "https://get.helm.sh/helm-${HELM_VERSION}-linux-${TARGETARCH}.tar.gz" | tar xz -C /tmp \
    && mv "/tmp/linux-${TARGETARCH}/helm" /usr/local/bin/helm \
    && curl -fsSL "https://github.com/derailed/k9s/releases/download/${K9S_VERSION}/k9s_Linux_${TARGETARCH}.tar.gz" | tar xz -C /usr/local/bin k9s \
    && curl -fsSL "https://github.com/int128/kubelogin/releases/download/${KUBELOGIN_VERSION}/kubelogin_linux_${TARGETARCH}.zip" -o /tmp/kubelogin.zip \
    && unzip -o /tmp/kubelogin.zip kubelogin -d /tmp \
    && mv /tmp/kubelogin /usr/local/bin/kubectl-oidc_login \
    && chmod +x /usr/local/bin/talosctl /usr/local/bin/kubectl /usr/local/bin/omnictl \
        /usr/local/bin/kubectx /usr/local/bin/kubens /usr/local/bin/helm \
        /usr/local/bin/k9s /usr/local/bin/kubectl-oidc_login \
    && rm -rf /tmp/kubelogin.zip "/tmp/linux-${TARGETARCH}"

# Fix for crictl logs and configuration warnings
RUN echo "runtime-endpoint: unix:///host/run/containerd/containerd.sock" > /etc/crictl.yaml && \
    echo "image-endpoint: unix:///host/run/containerd/containerd.sock" >> /etc/crictl.yaml && \
    mkdir -p /var/log && \
    ln -s /host/var/log/pods /var/log/pods && \
    ln -s /host/var/log/containers /var/log/containers

COPY bashrc /root/.bashrc

ENV IMAGE_SERVICE_ENDPOINT=unix:///host/run/containerd/containerd.sock
ENV CONTAINER_RUNTIME_ENDPOINT=unix:///host/run/containerd/containerd.sock

ENTRYPOINT [ "/bin/bash" ]
