FROM alpine

WORKDIR /root

RUN apk update && apk add --no-cache \
    bash-completion curl wget lvm2 util-linux jq yq drbd-utils tcpdump nano cri-tools bash tshark \
    bind-tools iproute2 nmap nmap-ncat socat iperf3 mtr \
    e2fsprogs xfsprogs parted \
    openssl vim tmux lsof strace git

RUN curl -sL https://talos.dev/install | sh \
    && curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" \
    && install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl \
    && curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash \
    && OMNI_VERSION=$(basename $(curl -Ls -o /dev/null -w %{url_effective} https://github.com/siderolabs/omni/releases/latest)) \
    && curl -sL "https://github.com/siderolabs/omni/releases/download/${OMNI_VERSION}/omnictl-linux-amd64" -o /usr/local/bin/omnictl \
    && chmod +x /usr/local/bin/omnictl

RUN echo "runtime-endpoint: unix:///host/run/containerd/containerd.sock" > /etc/crictl.yaml && \
    echo "image-endpoint: unix:///host/run/containerd/containerd.sock" >> /etc/crictl.yaml && \
    mkdir -p /var/log && \
    ln -s /host/var/log/pods /var/log/pods && \
    ln -s /host/var/log/containers /var/log/containers

COPY bashrc /root/.bashrc

ENV IMAGE_SERVICE_ENDPOINT=unix:///host/run/containerd/containerd.sock  
ENV CONTAINER_RUNTIME_ENDPOINT=unix:///host/run/containerd/containerd.sock

ENTRYPOINT [ "/bin/bash" ]