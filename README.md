# KernelSU/Apatch/Magisk WebUI Module Template

This is a template for creating KernelSU/Apatch/Magisk modules with WebUI. It includes a basic structure and a build script

## How to use template

1. Fork this template
2. Modify `module.prop` with your module details.
   1. Set your repo url in `updateJson`
3. Develop you own module, lol
4. Edit `CHANGELOG.md`
5. Build the module using `nix build`
   1. or just use GitHub Actions (`nix run nixpkgs#act -- -j build -P ubuntu-latest=ghcr.io/catthehacker/ubuntu:act-24.04 --artifact-server-path ./artifacts` (choose Medium size image))
6. Remove "How to use template" section from `README.md`

### Module Structure

- docs
  - [KernelSU](https://kernelsu.org/guide/module.html)
  - [Apatch](https://apatch.dev/apm-guide.html)
  - [Magisk](https://topjohnwu.github.io/Magisk/guides.html)
- `module.prop`: Module metadata
- `CHANGELOG.md`: Module changelog
- `banner.{png,webp}`: Banner which will be shown in module managers
  - [works in KSU-Next](https://github.com/KernelSU-Next/KernelSU-Next/blob/be141d05d03f37f67ae1505dbbe56cadbfcad130/manager/app/src/main/java/com/rifsxd/ksunext/ui/viewmodel/ModuleViewModel.kt#L48) and other new managers
  - you could place it inside `webroot/` to use as WebUI media
- `update.json`: Will be generated from `module.prop`
- `META-INF/` [From magisk docs](https://topjohnwu.github.io/Magisk/guides.html#magisk-module-installer)

### Development with Nix

Use `nix develop` (or better, use `direnv`) to enter a development shell with necessary tools installed:

- "hotreload webroot/index.html" to watch for changes
- "sync_file webroot/styles.css" to push manually

### Development inside Waydroid

TODO: link/mount guide `~/.local/share/waydroid/data/adb/modules/ksu-webui-module-template`

## Install

- Download zip from **[latest release](./releases/latest)**
- Flash via your module manager of choice
