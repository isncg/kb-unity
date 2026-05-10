# Arch Linux 开发环境

## 安装 Unity Editor

- 国外：`yay -S unityhub`
- 国内：去官网下载团结引擎hub tuanjiehub-amd64.deb

### 使用 debtap 安装团结 deb 包

- 安装 debtap: `sudo pacman -S debtap`
- 更新 debtap 数据库: `sudo debtap -u`
- 转换 deb 包: `sudo debtap tuanjiehub-amd64.deb`
- 转换过程中根据提示编辑 `.PKGINFO`，将 `gtk` 相关依赖改为 `gtk4`
- 安装：`sudo pacman -U tuanjiehub-1.4.1-1-x86_64.pkg.tar.zst`

## 安装 JetBrains Rider

- 安装 rider: `yay -S rider`
- 安装 toolbox，让 External Tools 能够检测到 rider: `yay -S jetbrains-toolbox`