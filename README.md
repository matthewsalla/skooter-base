Here's a simple and clear `README.md` you can place in the root of your `skooter-base` repo:

---

```markdown
# 🛠️ Skooter Base Repo

This repository contains the **shared base infrastructure and Kubernetes tooling** for use across multiple thin repositories. It is designed to be consumed as a **Git submodule** and includes:

- 🐳 Terraform provisioning scripts  
- ☸️ Kubernetes deployment helpers  
- 💾 Longhorn automation utilities  
- 🧩 Modular Helm-based app install scripts

The goal is to **centralize reusable logic**, while thin repos (e.g., `example-infra`, `msi-laptop-infra`) handle environment-specific overrides like `values.yaml`, secrets, domain names, and organizational logic.

---

## 📦 Submodule Setup

To add the `skooter-base` repo as a submodule:

```bash
git submodule add git@github.com:matthewsalla/skooter-base.git base
git submodule update --init --recursive
git add .gitmodules base
```

> 🔁 Always use `--recursive` to ensure any nested submodules are also pulled.

---

## 📥 Pulling Base Updates

When changes are made to `skooter-base` (such as improvements to Terraform or deployment scripts), you can pull in updates from your thin repo by running:

```bash
git submodule update --remote base
```

---

## 🚀 Cloning Thin Repos with Base Included

If you're cloning a thin repo (like `example-infra` or `msi-laptop-infra`), you **must use the recursive flag** to pull the base submodule:

```bash
# ✅ Correct
git clone --recursive https://github.com/yourusername/example-infra.git

# 🛑 If you forget:
git submodule update --init --recursive
```

---

## 🧠 Pro Tips

- Store thin repo-specific configuration (like `.env`, `terraform.tfvars`, and sealed secrets) **in the thin repo**, not here.
- Scripts in `skooter-base` will expect a `THIN_ROOT` environment variable when called from the thin repo. This allows them to find `.env` and secrets reliably across repo boundaries.
- You can safely call scripts like `longhorn-automation.sh` manually, or have them orchestrated by thin repo deploy flows.

---

Happy Kuberneting! 🚀
