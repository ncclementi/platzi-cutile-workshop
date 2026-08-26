# Setup: Running the notebooks on an NVIDIA Brev GPU instance

This workshop uses [Pixi](https://pixi.sh/) to reproducibly manage the CUDA/cuTile
Python environment, and [NVIDIA Brev](https://brev.nvidia.com/) to provision a
GPU-backed VM to run it on. This avoids relying on a hosted "Launchable" —
you provision and own the instance yourself.

## Prerequisites

- [Pixi](https://pixi.sh/) installed locally (used only to install the `brev` CLI).
- A GitHub account, with this repository accessible (public, or you're logged
  in via `gh`/SSH if private).
- An [NVIDIA Brev](https://login.brev.nvidia.com/signin) account.

## 1. Install the Brev CLI

```bash
pixi global install brev
brev --help
```

> **Windows:** Brev requires WSL, virtualization enabled in BIOS, and Ubuntu
> 20.04 from the Microsoft Store.

## 2. Authenticate with Brev

```bash
brev login
```

You'll be asked to confirm your email, then complete authentication in the browser.

## 3. Set your Brev organization

```bash
brev org set <your-org-name>
```

## 4. Create the instance

Download the startup script from this repo and launch a GPU instance with it:

```bash
curl -sLO https://raw.githubusercontent.com/ncclementi/platzi-cutile-workshop/refs/heads/main/brev/setup_brev.sh
brev create $(whoami)-cutile-workshop --type g6.xlarge --startup-script @./setup_brev.sh
```

`g6.xlarge` gives you 1x NVIDIA L4 GPU (22.35 GiB VRAM), 16 GiB RAM, 4 CPUs (AWS-based).

The [`brev/setup_brev.sh`](brev/setup_brev.sh) script, run automatically on
first boot, will:

- Install Pixi and some useful CLI tools (`bat`, `git`, `gh`, `nvim`, `nvtop`, `tree`, ...).
- Register a global `Python (Pixi)` Jupyter kernel (via
  [`brev/setup_pixi_kernel.sh`](brev/setup_pixi_kernel.sh)) that resolves to
  whichever Pixi project a notebook lives in.
- Clone this repository to `~/platzi-cutile-workshop`.
- Pre-install the Pixi environment (`pixi.toml` at the repo root) so the
  CUDA/cuTile dependencies are ready before you open a notebook.
- Pre-install the VS Code Python and Jupyter extensions for Remote-SSH.

Instance startup can take several minutes even after the CLI returns, since
the startup script keeps running in the background.

## 5. Connect to the instance

**Via VS Code:**

```bash
brev open $(whoami)-cutile-workshop code
```

**Via SSH:**

```bash
brev shell $(whoami)-cutile-workshop
```

## 6. Run the notebooks

See [Interacting with the notebooks on Brev](#interacting-with-the-notebooks-on-brev) below.

## 7. Clean up

When you're done, delete the instance to avoid ongoing charges:

```bash
brev delete $(whoami)-cutile-workshop
```

---

## Interacting with the notebooks on Brev

### Option A: VS Code

1. Connect with `brev open $(whoami)-cutile-workshop code`.
2. Open a notebook under `notebooks/` (e.g.
   [`notebooks/01__cutile_python_intro__vector_add.ipynb`](notebooks/01__cutile_python_intro__vector_add.ipynb)).
3. Click **Select Kernel**, then **Install/Enable suggested extensions
   (Python + Jupyter)** if prompted.
4. Once installed, click **Select Kernel → Jupyter Kernel**, and choose
   **Python (Pixi)** — this is the kernel registered by
   `setup_pixi_kernel.sh`, and it automatically runs inside the `pixi.toml`
   environment for this repo.

### Option B: Brev's hosted Jupyter Lab

1. Go to <https://brev.nvidia.com/> and log in.
2. Click your running instance (`$(whoami)-cutile-workshop`).
3. Click **Open Notebook**.
4. Navigate to a notebook under `notebooks/`.
5. In the kernel selector (top-right), choose **Python (Pixi)** under
   "Start python Kernel".

Both paths run the notebook using the Pixi-managed environment defined in
[`pixi.toml`](pixi.toml), which installs `numpy`, `numba-cuda-mlir`, `cupy`,
`cutile-python`, `cuda-python`, `cuda-cccl`, and JupyterLab/Notebook for the
`linux-64` + CUDA 13 platform.
