# 🚀 Talos Toolbx

A zero-latency, privileged debug environment for **Talos Linux** nodes, fully integrated with **Sidero Omni**.

Since Talos Linux is designed to be immutable, API-driven, and lacks a traditional SSH server or shell, debugging low-level hardware or network issues can be challenging. This tool acts as the ultimate "break-glass" SSH alternative. It leverages `kubectl debug` with the `sysadmin` profile to launch a fully loaded, privileged Alpine container directly on the host network, providing full access to the node's filesystem, processes, and devices.

## ✨ Features

- **Direct Hardware Access:** Mounts `/dev` and the node's root filesystem (under `/host`), allowing you to use `parted`, `lvm2`, and `wipefs` on physical disks.
- **Sidero Omni Integration:** Automatically authenticates with your Omni endpoint to fetch `talosconfig` and `kubeconfig` on the fly.
- **Pre-installed Tooling:** - *Network:* `tcpdump`, `tshark`, `nmap`, `socat`, `iperf3`, `mtr`, `iproute2`, `bind-tools`
  - *Storage:* `lvm2`, `e2fsprogs`, `xfsprogs`, `parted`, `drbd-utils`
  - *K8s/Talos:* `kubectl`, `talosctl`, `omnictl`, `helm`, `cri-tools`
  - *Utilities:* `jq`, `yq`, `vim`, `tmux`, `lsof`, `strace`
- **Gigachad UX:** Custom `.bashrc` with smart aliases, dynamic node-name prompt, and full auto-completion for `kubectl`, `talosctl`, and `omnictl`.

## 📦 Installation

Currently, the plugin can be installed locally by placing the executable script in your user's `$PATH`.

1. Clone the repository or download the script:
  
  ```
  git clone https://github.com/cappyt/talos-toolbx.git
  cd talos-toolbx
  ```
2. Make the script executable:
  
  ```
  chmod +x kubectl-talos_toolbx
  ```
3. Move it to your local binary path (ensure `~/.local/bin` is in your `$PATH`):
  
  ```
  mkdir -p ~/.local/bin
  cp kubectl-talos_toolbx ~/.local/bin/
  ```
4. Verify the installation:
  
  ```
  kubectl plugin list
  # You should see "kubectl-talos_toolbx" in the output
  ```

## ⚙️ Configuration (Sidero Omni)

The tool requires authentication with Sidero Omni to seamlessly generate your K8s and Talos credentials from inside the debug pod.

The first time you run the tool, it will generate a configuration template at `~/.config/talos-toolbx/config.env` and exit.

Open the file and fill in your details:

```
OMNI_ENDPOINT="https://<your-omni-account>.siderolabs.io"
OMNI_SERVICE_ACCOUNT_KEY="insert-your-sa-key-here"
OMNI_CLUSTER_NAME="your-cluster-name-on-omni"
```

*(You can generate a Service Account Key from the Omni Web UI -> Settings -> Service Accounts).*

## 🚀 Usage

To start a debug session, simply run the plugin and specify the target node:

```
kubectl talos-toolbx <node-name>
```

### Inside the Pod

Once you drop into the shell, you can instantly load your credentials using the built-in aliases:

- Run `load-talos` to authenticate `talosctl` via Omni and point it to the local node.
- Run `load-kube` to authenticate `kubectl` via Omni with cluster-admin privileges.

### Examples

Check the physical disks of the node:

```
lsblk
parted /dev/sda print
```

Interact with the local container runtime (containerd):

```
crictl ps
crictl logs <container-id>
```

Check the node's Talos configuration and logs:

```
load-talos
t dmesg
t logs kubelet
```