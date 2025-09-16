# TextMate 编译构建指南

本指南详细说明如何编译和调试TextMate，包括Universal Binary支持。

## 快速开始

### 1. 环境准备

```bash
# 安装依赖
brew install boost capnp google-sparsehash multimarkdown ninja ragel

# 克隆项目（包含子模块）
git clone --recursive https://github.com/textmate/textmate.git
cd textmate

# 初始化配置
./configure
```

### 2. 开发构建（推荐）

快速单架构构建，适合开发调试：

```bash
# 使用构建脚本
./build-dev.sh

# 或手动构建
bin/rave -cdebug -tTextMate
ninja TextMate
```

**输出位置**: `dist/debug/Applications/TextMate/TextMate.app`

### 3. Universal Binary 构建

同时支持 Apple Silicon (arm64) 和 Intel (x86_64) 的通用二进制文件：

```bash
# 自动构建Universal Binary
./build-universal.sh
```

**输出位置**: `build_universal/Applications/TextMate/TextMate.app`

## 构建配置详解

### 基础配置

项目使用自定义的 Rave 构建系统配置：

- `default.rave` - 默认构建配置
- `local.rave` - 本地自定义配置
- `universal.rave` - Universal Binary 配置模板

### 构建模式

#### Debug 模式
- 单架构 (arm64) 快速构建
- 包含调试信息和Address Sanitizer
- 适合开发和调试

#### Release 模式
- 优化构建 (-Os, LTO)
- 去除调试信息
- 支持多架构

### 架构支持

#### 单架构构建
```bash
# arm64 (Apple Silicon)
add FLAGS    "-arch arm64"
add LN_FLAGS "-arch arm64"

# x86_64 (Intel)
add FLAGS    "-arch x86_64"
add LN_FLAGS "-arch x86_64"
```

#### Universal Binary
使用 `lipo` 工具合并不同架构的二进制文件。

## 常用命令

### 基本构建命令

```bash
# 配置环境
./configure

# 构建TextMate (release)
ninja TextMate

# 构建并运行
ninja TextMate/run

# 构建调试版本
bin/rave -cdebug -tTextMate
ninja TextMate

# 清理构建
ninja -t clean
# 或强制清理
rm -rf dist/ ~/build/TextMate
```

### 测试和验证

```bash
# 检查二进制架构
file dist/release/Applications/TextMate/TextMate.app/Contents/MacOS/TextMate
lipo -info dist/release/Applications/TextMate/TextMate.app/Contents/MacOS/TextMate

# 检查代码签名
codesign -dv dist/release/Applications/TextMate/TextMate.app

# 运行应用
open dist/release/Applications/TextMate/TextMate.app
```

## 开发调试

### 在TextMate中开发

1. 安装 Ninja bundle: _Preferences_ → _Bundles_
2. 设置PATH变量包含 `/usr/local/bin` 或 `/opt/homebrew/bin`
3. 按 ⌘B 构建项目
4. 默认目标 `TextMate/run` 会重启TextMate

### 调试配置

TextMate支持通过 `.tm_properties` 文件自动检测构建目标：

- 测试文件会构建对应的测试目标
- 应用文件会构建对应的应用目标

### 常见问题

#### 依赖缺失
```bash
# 检查依赖
which capnp ninja ragel multimarkdown

# 重新安装
brew reinstall boost capnp google-sparsehash multimarkdown ninja ragel
```

#### 子模块问题
```bash
# 更新子模块
git submodule update --init --recursive
```

#### 构建失败
```bash
# 清理后重新构建
rm -rf dist/
./configure
ninja TextMate
```

## 文件结构

```
ben-textmate/
├── Applications/           # 应用程序目标
│   ├── TextMate/          # 主应用
│   ├── mate/              # 命令行工具
│   └── ...
├── Frameworks/            # 核心框架
│   ├── buffer/            # 文本缓冲区
│   ├── editor/            # 编辑器功能
│   ├── OakTextView/       # 主视图
│   └── ...
├── dist/                  # 构建输出目录
│   ├── debug/             # 调试构建
│   └── release/           # 发布构建
├── build-dev.sh          # 开发构建脚本
├── build-universal.sh    # Universal Binary构建脚本
├── local.rave           # 本地构建配置
└── universal.rave       # Universal配置模板
```

## 性能优化

### 构建性能
- 使用 `build-dev.sh` 进行快速迭代
- Debug模式仅构建单架构
- 利用ninja的并行构建能力

### 运行时性能
- Release版本启用了LTO和死代码消除
- Universal Binary确保在所有Mac上的最佳性能

## 贡献指南

1. 使用 `build-dev.sh` 进行开发
2. 确保代码通过所有警告检查
3. 在提交前进行Universal构建验证
4. 遵循现有代码风格和架构模式

---

通过这个指南，你应该能够成功编译和调试TextMate。如有问题，请检查依赖安装和子模块状态。