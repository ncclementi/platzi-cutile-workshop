#!/usr/bin/env bash

# Install Pixi
curl -fsSL https://pixi.sh/install.sh | bash
echo 'eval "$(pixi completion --shell bash)"' >> ${HOME}/.bashrc

# Add extra tools that might be useful for the exercises
# Need to use direct path to Pixi as sourcing ~/.bashrc causes interrupt
$HOME/.pixi/bin/pixi global install bat curl git gh nvim nvtop rattler-build pixi-browse tree

# Register a global "Python (Pixi)" Jupyter kernel for VS Code Remote.
curl -sL https://raw.githubusercontent.com/ncclementi/platzi-cutile-workshop/refs/heads/main/brev/setup_pixi_kernel.sh | bash

# Clone the workshop repository
git clone https://github.com/ncclementi/platzi-cutile-workshop.git ${HOME}/platzi-cutile-workshop

# Pre-install the pixi environment so the first notebook run doesn't pay
# the resolve/install cost interactively.
(cd ${HOME}/platzi-cutile-workshop && $HOME/.pixi/bin/pixi install)

# Pre-install the VS Code Python and Jupyter extension packs so they are
# available on first Remote-SSH connection. Extensions installed into
# ~/.vscode-server/extensions are shared across all VS Code server versions,
# so this works before the client ever installs its server.
if [ "$(uname -m)" = "aarch64" ]; then
    VSCODE_PLATFORM="server-linux-arm64"
else
    VSCODE_PLATFORM="server-linux-x64"
fi
# First entry of the commits API response is the latest stable build
VSCODE_COMMIT=$(curl -fsSL "https://update.code.visualstudio.com/api/commits/stable/${VSCODE_PLATFORM}" | cut -d '"' -f 2)
VSCODE_SERVER_TMP=$(mktemp -d)
curl -fsSL "https://update.code.visualstudio.com/commit:${VSCODE_COMMIT}/${VSCODE_PLATFORM}/stable" | tar -xz -C "${VSCODE_SERVER_TMP}"
# NODE_OPTIONS="--no-deprecation" to silence DEP0169 from VS Code
NODE_OPTIONS="--no-deprecation" "${VSCODE_SERVER_TMP}"/vscode-server-linux-*/bin/code-server \
    --install-extension ms-python.python \
    --install-extension ms-toolsai.jupyter
rm -rf "${VSCODE_SERVER_TMP}"
