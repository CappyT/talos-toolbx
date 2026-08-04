FROM alpine

WORKDIR /root

RUN apk update && apk add --no-cache \
    bash-completion curl wget lvm2 util-linux jq yq drbd-utils tcpdump nano cri-tools bash tshark \
    bind-tools iproute2 nmap nmap-ncat socat iperf3 mtr \
    e2fsprogs xfsprogs parted nvme-cli \
    openssl vim tmux lsof strace git fzf unzip aws-cli coreutils

RUN curl -sL https://talos.dev/install | sh \
    && curl -sL "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" -o /usr/local/bin/kubectl \
    && chmod +x /usr/local/bin/kubectl \
    && curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash \
    && OMNI_VERSION=$(basename $(curl -Ls -o /dev/null -w %{url_effective} https://github.com/siderolabs/omni/releases/latest)) \
    && curl -sL "https://github.com/siderolabs/omni/releases/download/${OMNI_VERSION}/omnictl-linux-amd64" -o /usr/local/bin/omnictl \
    && chmod +x /usr/local/bin/omnictl \
    && K9S_VERSION=$(basename $(curl -Ls -o /dev/null -w %{url_effective} https://github.com/derailed/k9s/releases/latest)) \
    && curl -sL "https://github.com/derailed/k9s/releases/download/${K9S_VERSION}/k9s_Linux_amd64.tar.gz" | tar xz -C /usr/local/bin k9s \
    && curl -sL https://raw.githubusercontent.com/ahmetb/kubectx/master/kubens -o /usr/local/bin/kubens \
    && curl -sL https://raw.githubusercontent.com/ahmetb/kubectx/master/kubectx -o /usr/local/bin/kubectx \
    && chmod +x /usr/local/bin/kubens /usr/local/bin/kubectx \
    && KUBELOGIN_VERSION=$(basename $(curl -Ls -o /dev/null -w %{url_effective} https://github.com/int128/kubelogin/releases/latest)) \
    && curl -sL "https://github.com/int128/kubelogin/releases/download/${KUBELOGIN_VERSION}/kubelogin_linux_amd64.zip" -o kubelogin.zip \
    && unzip kubelogin.zip kubelogin \
    && mv kubelogin /usr/local/bin/kubectl-oidc_login \
    && rm kubelogin.zip

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