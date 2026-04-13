# kBlog
kBlog 是轻量的静态网站生成器，让你立即开始记录自己的 idea。Demo: https://isncg.github.io/kblog/

## 主要特性
- **基于文件目录结构生成：** Markdown文件的文件目录组织方式决定它们的 url
- **签字风格的 meta：** 作者、日期等信息设计在 Markdown 文件结尾，不妨影响源 Markdown 的美观
- **可定制的 Markdown to HTML 生成器：** 生成器由 Lua 语言实现，易于自定义功能

## 快速上手
### Github Pages
1. fork 本仓库
2. 在仓库设置页打开 Pages 设置, 在 Build and deployment 中把 Source 设置为 Github Action
3. 添加一个新的 .md 后缀的 Markdown 文件, 编辑一些内容然后提交

### 本地生成
1. 准备 Lua 开发环境
    - Ubuntu、Debian 建议 Lua 版本 >= 5.4，Arch Linux 直接装默认的 Lua 5.5 即可。下面的命令以 apt 为例
    - 安装lua、luarocks
        - `sudo apt install lua5.4 liblua5.4-dev luarocks`
    - 安装 lua 库 luafilesystem、aspect
        - `luarocks install luafilesystem --lua-version 5.4`
        - `luarocks install aspect --lua-version 5.4`
2. clone 本仓库
3. 添加一个新的 .md 后缀的 Markdown 文件
4. 执行生成脚本
    1. `cd .src`
    2. `lua run.lua` 
    3. 浏览器访问 .build/index.html

## 开发状态
| 特性         | 状态 |
|--------------|-------|
| blog 页面生成 | ✅已实现 |
| GFM表格      | ✅已实现 |
| GFM代码块     | ✅已实现 |
| 目录边栏      | ❌待设计 |
| 目录页默认模板 | ❌仅基础功能，正式风格待设计 |


@author isncg
@date 2026-04-12
