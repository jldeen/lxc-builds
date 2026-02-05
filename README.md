# LXC/LXD/Incus Container Images

A collection of custom Ubuntu container images optimized for personal development environments on Incus. Each image is pre-configured with common development tools, SSH access, Docker, Git, and shell utilities.

## Overview

This repository contains distrobuilder YAML configurations to create container images tailored for different development workflows. All images are based on Ubuntu Noble (24.04) cloud variant and include:

- **SSH access** with GitHub SSH key import
- **Shell environment** (zsh with Oh My Zsh, Powerlevel10k theme, and plugins)
- **Docker & Docker Compose v2**
- **Git configuration** and GPG key support
- **AWS CLI v2**
- **systemd-networkd** for networking

## Available Images

### Development Environments

- **node** - Node.js development (NVM v0.40.1, Node 18+)
- **gatsby** - Static site generation (Gatsby CLI, Node 18)
- **go** - Go development (v1.22.5, Hugo, Node)
- **hugo** - Hugo static site generator (Hugo, Go, Node)
- **python** - Python development (Python 3, pip, venv, build tools)
- **rust** - Rust development (Rustup, Cargo)
- **terraform** - Infrastructure as Code (Terraform v1.7.4, Helm, kubectl, AWS CLI)

### Base Image

- **ubuntu** - Minimal Ubuntu Noble with base development tools

## Quick Start

### Prerequisites

- Incus installed and configured on your local machine
- `distrobuilder` installed (via snap: `snap install distrobuilder --classic`)
- Sudo access for building images

### Building Images

Build a single image:

```bash
make node      # Builds Node.js image
make go        # Builds Go image
make terraform # Builds Terraform/IaC image
```

Build all images:

```bash
make all
```

Build a specific VM variant:

```bash
make ecs-vm  # Builds ECS VM image
```

### Using Images

Once built, launch a container from an image:

```bash
# Launch interactive container
incus launch node my-node-dev

# Launch with shell
incus exec my-node-dev -- /bin/zsh

# Copy files into container
incus file push local-file.txt my-node-dev/home/jldeen/

# Stop and remove container
incus stop my-node-dev
incus delete my-node-dev
```

## Image Details

### Node

- **NVM** - v0.40.1 (Node version manager)
- **Node.js** - v18 LTS
- **Docker** - Latest
- **AWS CLI** - v2

### Go

- **Go** - v1.22.5
- **Hugo** - Latest (apt package)
- **NVM** - v0.40.1 (Node version manager)
- **Docker** - Latest

### Hugo

- **Hugo** - Latest (apt package)
- **Go** - v1.22.5
- **NVM** - v0.40.1 (Node version manager)
- **Docker** - Latest

### Python

- **Python** - 3.12 (system)
- **pip** - Latest
- **venv** - Built-in
- **build-essential** - For C extensions
- **Docker** - Latest

### Rust

- **Rust** - Latest (via Rustup)
- **Cargo** - Package manager
- **Docker** - Latest

### Terraform

- **Terraform** - v1.7.4
- **Helm** - Latest
- **kubectl** - Latest stable
- **AWS CLI** - v2
- **Docker** - Latest
- **jq** - JSON query tool

## Configuration

### Common to All Images

#### SSH Keys

SSH keys are imported from GitHub at container startup:
```bash
ssh-import-id gh:<your-github-username>
```

Modify the YAML files to change your GitHub username or customize key import.

#### Shell Configuration

Zsh configuration files are pulled from:
- `.zshrc` - [sources/conf/zsh](sources/conf/zsh) in this repo
- `.p10k.zsh` - Powerlevel10k theme config
- `.gitconfig` - Git configuration

#### GPG & SSH Keys

GPG and SSH private keys can be imported during provisioning if placed in:
- `sources/sshkeys/id_rsa` - Private SSH key
- `sources/sshkeys/id_rsa.pub` - Public SSH key
- `sources/sshkeys/keys.asc` - GPG key (ASCII-armored)
- `sources/sshkeys/pass` - GPG passphrase (for automated import)

**Note**: Store these securely and never commit them to version control.

#### Timezone

All images default to `America/Los_Angeles`. Edit the `post-packages` action in the YAML to change:

```yaml
- trigger: post-packages
  action: |-
    #!/bin/sh
    ln -s /usr/share/zoneinfo/YOUR_TIMEZONE /etc/localtime
```

## Architecture Support

- **amd64** (x86-64) - Primary
- **arm64** (ARM64/Apple Silicon) - Supported

The Makefile auto-detects architecture and uses the appropriate Ubuntu mirror.

## Troubleshooting

### Build Fails Due to Network

Network issues during SSH key import or tool downloads can fail the build. Options:

1. Retry the build (temporary network issue)
2. Pre-cache tools by storing them locally and modifying URLs in YAML
3. Remove problematic tools if not needed for your workflow

### SSH Keys Not Working

Ensure GitHub username is correct in the YAML and your SSH keys are available on GitHub: `https://github.com/<username>.keys`

### Docker Not Available in Container

After launching a container:

```bash
# Start Docker daemon
incus exec my-node-dev -- systemctl start docker

# Or enable for auto-start
incus exec my-node-dev -- systemctl enable docker
```

### Container Disk Space Full

Rebuild with fresh images. Use `incus image rm <image-name>` to remove old images and free space.

## Customization

### Modify an Existing Image

Edit the corresponding YAML file (e.g., `node.yaml`) and rebuild:

```bash
# Edit node.yaml to add new packages
vim node.yaml

# Rebuild
make node
```

### Create a New Custom Image

Copy an existing YAML (e.g., `node.yaml`) as a template:

```bash
cp node.yaml custom.yaml

# Edit custom.yaml with your configurations
vim custom.yaml

# Add to Makefile
echo "custom:" >> Makefile
echo "\tincus image rm custom || true" >> Makefile
echo "\tsudo distrobuilder build-incus ... --import-into-incus=\"custom\" custom.yaml" >> Makefile

# Build
make custom
```

## Version Updates

### Docker Compose

Update version in all YAML files by changing the download URL:

```bash
curl -L "https://github.com/docker/compose/releases/download/v2.x.x/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
```

Check latest release: https://github.com/docker/compose/releases

### NVM

Update NVM version in post-packages action:

```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/vX.X.X/install.sh | bash
```

Check latest release: https://github.com/nvm-sh/nvm/releases

### Go

Update Go version in YAML:

```yaml
gover=1.22.5  # Change to desired version
```

Check latest: https://golang.org/dl/

### Terraform

Update Terraform version in terraform.yaml:

```yaml
tfver=1.7.4  # Change to desired version
```

Check latest: https://releases.hashicorp.com/terraform/

## Notes

- All containers run as the `jldeen` user by default with passwordless sudo
- Images are optimized for personal development on local Incus servers
- Consider security implications before customizing for production use
- Containers inherit host system timezone and locale settings

## Maintenance

Update frequency recommendations:

- **Docker Compose** - Quarterly (new features, security)
- **Go/Node/Rust** - Semi-annually (major releases)
- **Terraform/Helm/kubectl** - Quarterly (rapid release cycle)
- **Base OS** - Annually (stick to Ubuntu LTS releases)

## License

These configurations are provided as-is for personal use. Modify and share as needed.

## References

- [Distrobuilder Documentation](https://github.com/lxc/distrobuilder)
- [LXC/LXD Project](https://linuxcontainers.org/)
- [Incus](https://linuxcontainers.org/incus/)
- [Ubuntu Release Schedule](https://wiki.ubuntu.com/Releases)
