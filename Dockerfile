FROM alpine

RUN apk update && apk add --no-cache \
    bash-completion curl wget lvm2 util-linux jq yq drbd-utils tcpdump nano cri-tools bash tshark \
    bind-tools iproute2 nmap nmap-ncat socat iperf3 mtr \
    e2fsprogs xfsprogs parted \
    openssl vim tmux lsof strace git \
    && curl -sL https://talos.dev/install | sh \
    && curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" \
    && install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl \
    && curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash \
    && curl -sL https://github.com/siderolabs/omni/releases/download/v0.38.1/omnictl-linux-amd64 -o /usr/local/bin/omnictl \
    && chmod +x /usr/local/bin/omnictl

COPY bashrc /root/.bashrc

ENV IMAGE_SERVICE_ENDPOINT=unix:///host/run/containerd/containerd.sock  
ENV CONTAINER_RUNTIME_ENDPOINT=unix:///host/run/containerd/containerd.sock

ENTRYPOINT [ "/bin/bash" ]