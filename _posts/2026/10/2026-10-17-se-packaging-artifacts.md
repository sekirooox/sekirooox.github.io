---
title: "软件工程·构建产物、打包与发布"
date: 2026-10-17 00:00:00 +0800
description: 梳理 Python 打包、版本管理、容器化、服务编排与软件发布的核心概念和常用流程。
categories: [计算机系统与开发, 软件工程]
tags: [软件工程, python, uv, docker, 版本管理, 软件发布]
pin: false
math: false
mermaid: false
---

## 构建产物与 Python 打包

源代码（Source Code）是开发者编写的程序；打包与构建（Packaging / Building）负责把源代码整理为可安装、可分发的形式；构建产物（Artifact）则是构建结束后生成的文件，例如 Python Wheel、源码分发包或容器镜像。

### 打包、构建与分发的关系

以 Python 项目为例，开发者可以使用 `uv build` 将源代码构建为分发文件，再把这些产物发布到包索引。其他用户安装产物后，即可在自己的环境中复用软件，而不必复制原始工作目录。

<figure><img src="/assets/img/posts/se-packaging-artifacts/ruan-jian-jiao-fu-gou-jian-chan-wu-liu-cheng.png" alt="软件交付" width="760"><figcaption><p>构建产物分发流程</p></figcaption></figure>

### 从模块复用到分发包

在同一工作目录中，可以直接导入另一个文件中的函数。例如，`greeting.py` 定义如下函数：

```python
def greet(name):
    return f"Hello, {name}!"


def main():
    print(greet("World"))
```

同目录下的程序可以直接导入并调用：

```python
from greeting import greet

print(greet("Alice"))
```

如果代码需要跨目录、跨项目或提供给其他用户使用，仅依赖工作目录就不够了。此时应把模块组织成可安装的分发包，并通过构建产物完成交付。

### `pyproject.toml`：项目构建配置

`pyproject.toml` 用于声明项目元数据、依赖、命令行入口和构建后端。下面的示例定义了名为 `greeting` 的项目，并使用 Setuptools 构建：

```toml
[project]
name = "greeting"
version = "0.1.0"
description = "A simple greeting library"
dependencies = []

[project.scripts]
greet = "greeting:main"

[build-system]
requires = ["setuptools>=61.0"]
build-backend = "setuptools.build_meta"
```

其中，`[project]` 描述项目本身，`[project.scripts]` 声明安装后生成的命令行入口，`[build-system]` 则告诉构建工具需要使用哪个后端完成打包。

### `uv`：环境与项目管理工具

`uv` 不是虚拟环境本身，而是一个由 Astral 开发的 Python 工具链。它可以创建和管理 Python 环境，也能维护依赖、运行命令、构建产物和发布分发文件。

| `uv` 命令 | 作用 | 类似的传统工具 |
| --- | --- | --- |
| `uv python install` | 安装 Python 解释器 | `pyenv` |
| `uv venv` | 创建虚拟环境 | `venv`、`virtualenv` |
| `uv pip install` | 安装 Python 包 | `pip` |
| `uv add` | 添加并记录项目依赖 | `pip` 与手动维护依赖声明 |
| `uv sync` | 根据项目配置同步依赖与环境 | `pip-tools` 等 |
| `uv run` | 在项目环境中运行命令 | 激活虚拟环境后运行 |
| `uv build` | 构建 Wheel 和源码分发包 | `python -m build` |
| `uv publish` | 发布分发文件 | `twine` |

<figure><img src="/assets/img/posts/se-packaging-artifacts/ruan-jian-jiao-fu-uv-gong-ju-lian-zhi-ze.png" alt="软件交付" width="760"><figcaption><p>uv 工具链职责</p></figcaption></figure>

环境管理解决“开发者如何运行项目”，软件构建与分发解决“其他用户如何安装项目”。两套流程都可以使用 `uv`，但目标并不相同。

### 使用 `uv build` 构建项目

执行构建前，项目需要在 `pyproject.toml` 中声明构建系统：

```toml
[build-system]
requires = ["setuptools>=61.0"]
build-backend = "setuptools.build_meta"
```

随后运行：

```bash
uv build
```

这里，`pyproject.toml` 提供项目配置，Setuptools 按配置执行构建，`uv build` 则负责发起并管理构建流程。生成的文件通常位于 `dist/` 目录。

Wheel 是 Python 标准的构建分发格式，扩展名为 `.whl`。它常被称为二进制分发包，但不一定包含机器码；纯 Python 项目的 Wheel 可以只包含 `.py` 文件和元数据。例如：

```text
greeting-0.1.0-py3-none-any.whl
```

### 发布到 PyPI

如果希望用户直接执行以下命令，而不必先取得本地 Wheel 文件，就需要把构建产物发布到包索引：

```bash
pip install greeting
```

PyPI（Python Package Index）是最常用的公共 Python 包索引。用户发起安装后，`pip` 会查询包名和版本，选择兼容的分发文件，下载依赖并安装到目标 Python 环境。

<figure><img src="/assets/img/posts/se-packaging-artifacts/ruan-jian-jiao-fu-pypi-an-zhuang-liu-cheng.png" alt="软件交付" width="760"><figcaption><p>PyPI 安装流程</p></figcaption></figure>

构建完成后，可以使用 `uv publish` 上传 `dist/` 中的分发文件：

```bash
uv publish
```

发布操作需要配置 PyPI 认证。API Token 应通过安全的凭据配置或环境变量提供，不能写入 `pyproject.toml`，也不能提交到 Git 仓库。

<figure><img src="/assets/img/posts/se-packaging-artifacts/ruan-jian-jiao-fu-uv-fa-bu-ming-ling.png" alt="软件交付" width="760"><figcaption><p>uv 发布命令与凭据安全</p></figcaption></figure>

发布后应在全新的虚拟环境中安装并导入包，确认分发文件没有依赖本地未声明的文件。下面假设发布时把分发名改为 `mayl-greeting-demo`，但它提供的导入包仍名为 `greeting`：

```bash
python -m pip install mayl-greeting-demo
python -c "import greeting"
```

<figure><img src="/assets/img/posts/se-packaging-artifacts/ruan-jian-jiao-fu-xu-ni-huan-jing-an-zhuang-yan-zheng.png" alt="软件交付" width="760"><figcaption><p>在新虚拟环境中验证安装</p></figcaption></figure>

### 模块、导入包与分发包

模块是单个 Python 文件，例如 `greeting.py`；导入包是包含多个模块的目录，例如 `greeting/`；分发包则是用于发布和安装的软件单元，例如 `greeting-0.1.0-py3-none-any.whl`。分发名称、导入包名称和仓库名称可以不同，需要通过项目配置建立对应关系。

| 概念 | 模块 | 导入包 | 分发包 |
| --- | --- | --- | --- |
| 示例 | `greeting.py` | `greeting/` | `greeting-0.1.0-py3-none-any.whl` |
| 用途 | 组织一组 Python 定义 | 组织多个模块 | 发布和安装软件 |
| 常见使用方式 | `import greeting` | `import greeting.utils` | `pip install greeting` |

## 软件发布与版本管理

版本号用于标识软件发布状态，并向用户传递兼容性或发布时间等信息。常见方案包括语义化版本和日历化版本。

### 语义化版本

语义化版本（Semantic Versioning，SemVer）通常采用 `MAJOR.MINOR.PATCH` 结构，例如 `2.3.5`。

<figure><img src="/assets/img/posts/se-packaging-artifacts/ruan-jian-jiao-fu-yu-yi-hua-ban-ben-jie-gou.png" alt="软件交付" width="760"><figcaption><p>语义化版本结构</p></figcaption></figure>

`MAJOR` 表示不兼容的公开 API 变更；`MINOR` 表示保持向后兼容的新功能；`PATCH` 表示保持向后兼容的问题修复。版本级别由公开接口的兼容性决定，而不是由代码修改量决定。

#### PATCH：修复兼容性问题

例如，从 `1.2.3` 升级到 `1.2.4`，适合表示不改变公开接口的缺陷修复：

```python
def divide(a, b):
    return a / b
```

如果新版本只修复某个边界输入的错误，并保持原有调用方式可用，就应增加 `PATCH`。

#### MINOR：增加兼容的新功能

例如，从 `1.2.3` 升级到 `1.3.0`。原有函数继续可用，同时新增功能：

```python
def add(a, b):
    return a + b


def multiply(a, b):
    return a * b
```

这种更新扩展了公开 API，但没有破坏旧调用方式，因此增加 `MINOR`。

#### MAJOR：引入不兼容变更

例如，从 `1.2.3` 升级到 `2.0.0`。若接口从 `add(1, 2)` 改为 `add([1, 2])`，原有调用将失效，应增加 `MAJOR`。

对于 `0.y.z` 的初始开发版本，SemVer 不承诺与 `1.0.0` 之后相同的兼容性语义。使用此类依赖时，应阅读项目自己的版本策略，不能仅凭次版本号判断兼容性。

### 版本约束

依赖声明可以精确固定版本，也可以给出允许解析的版本范围。约束越严格，环境越容易复现，但也越难自动获得兼容更新。

<figure><img src="/assets/img/posts/se-packaging-artifacts/ruan-jian-jiao-fu-chang-yong-ban-ben-yue-shu.png" alt="软件交付" width="760"><figcaption><p>常用版本约束</p></figcaption></figure>

| 写法 | 含义 | 示例结果 |
| --- | --- | --- |
| `==2.32.3` | 精确匹配 | 仅允许 `2.32.3` |
| `>=8.0` | 设置最低版本 | 允许 `8.0` 及更高版本 |
| `>=1.24,<2.0` | 设置闭开范围 | 允许 `1.24` 至 `2.0` 之前的版本 |
| `~=2.1.0` | PEP 440 兼容发布约束 | 允许 `>=2.1.0,<2.2.0` |

`~=` 并不等同于对所有项目都“只允许 PATCH 更新”。它会根据给出的发布段确定兼容范围：`~=2.1.0` 等价于 `>=2.1.0,<2.2.0`，而 `~=2.1` 的上界则不同。编写约束时应明确需要锁定到哪一级。

<figure><img src="/assets/img/posts/se-packaging-artifacts/ruan-jian-jiao-fu-jian-rong-ban-ben-yue-shu-shi-li.png" alt="软件交付" width="760"><figcaption><p>兼容版本约束示例</p></figcaption></figure>

### 日历化版本

日历化版本（Calendar Versioning，CalVer）以发布时间构造版本号，例如 Ubuntu 的 `24.04` 表示 2024 年 4 月发布。它便于识别版本年代，但版本号本身通常不直接表达 API 兼容性。

<figure><img src="/assets/img/posts/se-packaging-artifacts/ruan-jian-jiao-fu-ri-li-ban-ben-shi-li.png" alt="软件交付" width="760"><figcaption><p>日历化版本示例</p></figcaption></figure>

### 语义化版本与日历化版本

| 对比项 | SemVer | CalVer |
| --- | --- | --- |
| 示例 | `2.3.1` | `24.04` |
| 版本依据 | API 兼容性与变更类型 | 发布时间 |
| 主要优点 | 传递兼容性预期 | 容易识别版本年代 |
| 主要局限 | 依赖维护者正确判断兼容性 | 版本号不直接表示兼容性 |

<figure><img src="/assets/img/posts/se-packaging-artifacts/ruan-jian-jiao-fu-ban-ben-ti-xi-dui-bi.png" alt="软件交付" width="760"><figcaption><p>语义化版本与日历化版本对比</p></figcaption></figure>

## 虚拟机与容器

Python 分发包主要管理 Python 代码和 Python 依赖，但程序还可能依赖操作系统共享库、编译器、驱动和系统工具。此时，应用依赖已经超出 Python 包管理器的职责边界。

### 容器与系统级依赖

<figure><img src="/assets/img/posts/se-packaging-artifacts/ruan-jian-jiao-fu-python-bao-yi-lai-bian-jie.png" alt="软件交付" width="760"><figcaption><p>Python 包依赖边界</p></figcaption></figure>

例如，一个 Python 程序可能依赖 PostgreSQL 客户端开发库。在 Ubuntu 中可以安装：

```bash
sudo apt-get install libpq-dev
```

即使项目已经构建为 Wheel，另一台 Linux 主机安装后仍可能因缺少对应共享库而无法运行。Docker 的主要用途之一，就是把应用、用户态运行环境和所需的<span style="color:red">系统级依赖</span>共同组织为可重复构建的镜像。

容器不等同于虚拟机。虚拟机通常包含完整客体操作系统；容器共享宿主机内核，通过隔离机制提供独立的进程、文件系统和网络视图，因此启动更快、资源开销通常也更低。

### Docker Image 与 Container

Docker Image 是构建完成的只读模板，也是可保存和分发的 Artifact；Container 则是根据 Image 创建的运行实例，通常还拥有独立的可写层。同一个镜像可以创建多个容器，每个容器维护自己的运行状态。

<figure><img src="/assets/img/posts/se-packaging-artifacts/ruan-jian-jiao-fu-jing-xiang-yu-rong-qi-guan-xi.png" alt="软件交付" width="760"><figcaption><p>镜像与容器的关系</p></figcaption></figure>

常见操作如下：

```bash
# 下载镜像
docker pull python:3.12

# 使用镜像创建并运行容器
docker run -it python:3.12 python

# 查看正在运行的容器
docker ps
```

`docker run -it python:3.12 python` 可以拆解为：

| 部分 | 含义 |
| --- | --- |
| `docker run` | 创建并启动容器 |
| `-i` | 保持标准输入连接 |
| `-t` | 分配伪终端 |
| `python:3.12` | 使用指定的 Docker 镜像 |
| `python` | 容器启动后执行的命令 |

执行后会进入容器内的 Python 交互环境：

```python
>>> print("Hello from inside a container!")
Hello from inside a container!
```

这里的 Python 运行在容器内部，宿主机不需要直接安装 Python 3.12。退出解释器后，如果容器中没有其他前台进程，容器也会停止。

### `Dockerfile`：镜像构建配置

`pyproject.toml` 描述 Python 项目的构建方式，`Dockerfile` 则描述容器镜像的构建步骤。例如：

```dockerfile
FROM python:3.12

RUN apt-get update
RUN apt-get install -y gcc libpq-dev

RUN pip install numpy pandas

COPY . /app
WORKDIR /app

RUN pip install .
```

| 指令 | 作用 |
| --- | --- |
| `FROM python:3.12` | 基于包含 Python 3.12 的镜像构建 |
| `RUN apt-get update` | 更新系统软件包索引 |
| `RUN apt-get install -y gcc libpq-dev` | 安装编译器和 PostgreSQL 开发库 |
| `RUN pip install numpy pandas` | 安装 Python 依赖 |
| `COPY . /app` | 将构建上下文中的项目复制到镜像 |
| `WORKDIR /app` | 设置后续指令的工作目录 |
| `RUN pip install .` | 安装当前 Python 项目 |

构建并运行镜像：

```bash
docker build -t myapp:1.0 .
docker run --rm myapp:1.0
```

如果镜像没有配置合适的 `CMD` 或 `ENTRYPOINT`，运行时还需要在 `docker run` 后显式提供命令。`Dockerfile` 是构建配置，不是构建产物；根据它生成的 Docker Image 才是 Artifact。

### 镜像层与构建缓存

Docker Image 由多个有序的 Layer 构成。以下 `Dockerfile` 会依次形成基础镜像、依赖安装和源代码复制等层：

```dockerfile
FROM python:3.12-slim

RUN pip install numpy
RUN pip install pandas

COPY . /app
```

```text
Layer 4 · COPY . /app          项目源代码
Layer 3 · 安装 Pandas          可复用缓存
Layer 2 · 安装 NumPy           可复用缓存
Layer 1 · Python 基础镜像      可复用缓存
```

如果只修改项目代码，前面的构建输入没有变化，Docker 通常可以复用依赖安装层。因此，指令顺序会直接影响构建缓存效率。

下面的写法先复制全部代码，再安装依赖；任何源代码变化都可能使后续依赖层失效：

```dockerfile
COPY . /app
RUN pip install -r /app/requirements.txt
```

更常见的方式是先复制依赖清单并安装依赖，最后再复制源代码：

```dockerfile
COPY requirements.txt /app/
RUN pip install -r /app/requirements.txt

COPY . /app
```

### 容器产品的构建与发布

容器化项目通常先使用 `uv` 管理 Python 依赖，再通过 `Dockerfile` 构建镜像，将镜像推送到 Container Registry。服务器拉取指定镜像后，便可创建并启动容器。

<figure><img src="/assets/img/posts/se-packaging-artifacts/ruan-jian-jiao-fu-docker-gou-jian-fa-bu-liu-cheng.png" alt="软件交付" width="420"><figcaption><p>Docker 构建发布流程</p></figcaption></figure>

## 服务与编排

容器解决了单个运行环境的交付问题。当一个应用由 Web 服务、缓存和数据库等多个组件组成时，还需要统一描述它们的网络、存储、启动关系和运行策略。

### 为什么拆分为多个服务

不同组件的运行方式、依赖和生命周期可能不同。把 Web Service、Redis 和 PostgreSQL 放入独立容器，可以分别升级、扩缩容和恢复故障，也能减少依赖冲突。

<figure><img src="/assets/img/posts/se-packaging-artifacts/ruan-jian-jiao-fu-duo-rong-qi-fu-wu-jia-gou.png" alt="软件交付" width="760"><figcaption><p>多容器服务架构</p></figcaption></figure>

服务拆分并非越细越好。边界设计还需要考虑部署复杂度、网络延迟、数据一致性和团队维护能力。

### Docker Compose：管理多个容器

如果每个容器都手动执行 `docker run`，配置难以复用。Docker Compose 使用 YAML 文件描述整套应用：

```yaml
services:
  web:
    build: .
    ports:
      - "8080:8080"
    environment:
      - REDIS_URL=redis://cache:6379
    depends_on:
      - cache

  cache:
    image: redis:7-alpine
    volumes:
      - redis_data:/data

volumes:
  redis_data:
```

| 配置 | 作用 |
| --- | --- |
| `services` | 定义需要运行的服务 |
| `build: .` | 使用当前目录的 `Dockerfile` 构建 Web 镜像 |
| `image: redis:7-alpine` | 使用现成的 Redis 镜像 |
| `ports` | 将宿主机端口映射到容器端口 |
| `environment` | 设置环境变量 |
| `depends_on` | 声明服务启动顺序依赖 |
| `volumes` | 提供持久化存储 |

启动服务：

```bash
docker compose up -d
```

Compose 会创建项目网络并启动两个服务。`redis://cache:6379` 中的 `cache` 是 Compose 服务名，Docker 内部 DNS 会把它解析为对应容器的网络地址，因此应用不需要写死容器 IP。

默认情况下，`depends_on` 只控制启动顺序，不保证 Redis 已经能够接收请求。需要等待服务真正就绪时，应配置 `healthcheck`，并让依赖方根据健康状态或重试策略启动。

### `systemd`：开机启动与主机级管理

在 Linux 服务器上，可以使用 `systemd` 管理 Compose 应用的启动与停止：

```ini
[Unit]
Description=My application stack
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=/opt/myapp
ExecStart=/usr/bin/docker compose up -d
ExecStop=/usr/bin/docker compose down

[Install]
WantedBy=multi-user.target
```

该配置以 `/opt/myapp` 为工作目录，并在服务启停时执行对应的 Compose 命令。管理员可以使用：

```bash
sudo systemctl start myapp
sudo systemctl stop myapp
sudo systemctl status myapp
sudo systemctl enable myapp
```

`Type=oneshot` 配合 `RemainAfterExit=yes` 只记录启动操作已经完成，并不会持续监控容器内的进程。若容器异常退出后需要自动恢复，还应在 Compose 中设置适当的 `restart` 策略。

### Kubernetes：多主机容器编排

Docker Compose 适合单机上的多容器应用。需要跨多台服务器调度副本、滚动更新、服务发现、故障恢复和自动扩缩容时，可以使用 Kubernetes（K8s）。

| 能力 | Docker Compose | Kubernetes |
| --- | --- | --- |
| 管理多个容器 | 支持 | 支持 |
| 服务间网络通信 | 支持 | 支持 |
| 单机部署 | 很适合 | 可以，但通常更复杂 |
| 多主机集群调度 | 不擅长 | 原生支持 |
| 自动扩缩容 | 需要额外方案 | 原生支持相关机制 |
| 故障恢复与副本管理 | 基础能力 | 更完善 |
| 学习与运维成本 | 较低 | 较高 |

可以把三者概括为：Docker 构建和运行容器；Docker Compose 管理单机上的一组容器；Kubernetes 在集群中调度和管理容器化应用。个人项目或小型业务通常先从 Docker Compose 开始。

### API：服务之间的通信

Web、缓存和数据库运行在不同进程或容器中，需要通过明确的协议通信。常见方式包括 HTTP API、数据库协议和消息队列协议。

下面使用一个示意地址发送 HTTP 请求：

```python
import requests

response = requests.post(
    "https://api.example.com/chat",
    json={"message": "Hello"},
)
print(response.json())
```

```text
Python 程序
    ↓
发送 HTTP Request
    ↓
远程 API Server
    ↓
处理请求并返回 HTTP Response
    ↓
程序解析响应
```

API 允许不同程序按照约定的接口交互，而不需要了解彼此的内部实现。不过，并非所有服务都使用 REST API；例如 Redis 通常使用 RESP 协议。

## 软件发布与交付方式

软件构建完成后，可以把 Artifact 发布给用户下载安装，也可以把软件部署为在线服务。Publishing 强调交付可安装产物，Deployment 强调让应用持续运行并通过网络提供能力。

### 从源代码到发布或部署

源代码经过构建形成 Wheel、二进制文件或 Docker Image 等 Artifact。此后可以进入两条路径：一是发布到 PyPI、GitHub Releases 或 Registry，由用户下载或安装；二是部署到服务器或容器平台，由用户通过网络访问。

<figure><img src="/assets/img/posts/se-packaging-artifacts/ruan-jian-jiao-fu-ruan-jian-fa-bu-yu-bu-shu-liu-cheng.png" alt="软件交付" width="560"><figcaption><p>软件发布与部署流程</p></figcaption></figure>

### 六种常见发布方式

<figure><img src="/assets/img/posts/se-packaging-artifacts/ruan-jian-jiao-fu-liu-zhong-ruan-jian-fa-bu-fang-shi.png" alt="软件交付" width="760"><figcaption><p>六种常见软件发布方式</p></figcaption></figure>

| 发布方式 | 发布位置 | 用户如何使用 | 常见场景 |
| --- | --- | --- | --- |
| PyPI | Python 包索引 | `pip install` | Python 库、CLI 工具 |
| GitHub Releases | GitHub 发布页面 | 下载预编译文件 | 桌面软件、CLI 工具 |
| GitHub 源代码仓库 | Git Repository | `pip install git+...` | 开发版本、未发布的库 |
| Docker Registry | Docker Hub、GHCR | `docker pull`、`docker run` | Web 服务、后端应用 |
| 系统软件仓库 | Ubuntu APT、Homebrew | `apt install`、`brew install` | 系统工具、开发工具 |
| 在线服务 | 云服务器、托管平台 | 通过 URL 访问 | 网站、Web API、SaaS |

#### 发布到 PyPI

Requests 是 Python HTTP 客户端库。开发者把分发包发布到 PyPI，用户可以直接按包名安装。

开发者构建并上传：

```bash
uv build
uv publish
```

用户安装并导入：

```bash
pip install requests
```

```python
import requests

response = requests.get("https://example.com")
print(response.status_code)
```

这种方式适合向其他 Python 开发者提供库或 Python 命令行工具。

#### 使用 GitHub Releases

`ripgrep` 是使用 Rust 编写的搜索工具。项目可以通过 GitHub Releases 为 Linux、macOS 和 Windows 提供预编译文件。

开发者先构建发布版本：

```bash
cargo build --release
```

随后创建版本标签和 Release，填写 Release Notes，并上传各平台的压缩包或可执行文件。用户下载并解压后即可运行：

```bash
rg "hello" .
```

这种方式适合命令行工具、桌面应用及其他可直接运行的编译程序，用户不必下载源代码或自行编译。

#### 从 GitHub 源代码安装

开发者可以把带有正确构建配置的源代码推送到 GitHub，而不预先上传 Wheel：

```bash
git push origin main
```

用户从仓库安装：

```bash
pip install git+https://github.com/psf/requests.git
```

也可以指定标签或其他 Git 引用：

```bash
pip install git+https://github.com/psf/requests.git@v2.32.3
```

`pip` 会获取仓库内容，再构建并安装 Python 包。这种方式适合测试尚未发布的新功能、安装特定分支或提交，以及分发内部项目。目标机器通常需要能够使用 Git 并访问对应仓库。

#### 发布到 Docker Registry

Redis 等服务提供容器镜像，用户无需手动安装程序及其用户态依赖，只需准备容器运行环境。

开发者构建、登录并推送镜像：

```bash
docker build -t myuser/myapp:1.0 .
docker login
docker push myuser/myapp:1.0
```

其中，`myuser` 必须替换为有权限的 Registry 命名空间。用户可以下载并启动 Redis：

```bash
docker pull redis:7-alpine

docker run -d \
  --name my-redis \
  -p 6379:6379 \
  redis:7-alpine
```

示例把 Redis 端口发布到宿主机。实际部署时需要配置访问控制，避免把数据库端口意外暴露到公网。

#### 发布到系统软件仓库

Git 可以通过 Ubuntu APT 或 macOS Homebrew 等系统包管理器安装。以 Ubuntu 为例，发布流程通常包括准备源代码、制作符合 Debian 规范的 `.deb` 包、接受仓库维护者审核与构建，以及发布软件包和索引元数据。进入官方仓库并不是简单上传任意 `.deb` 文件。

用户通过系统包管理器安装：

```bash
# Ubuntu
sudo apt update
sudo apt install git

# macOS
brew install git

# 验证
git --version
```

这种方式可以让软件融入操作系统的安装、更新和依赖管理机制。

#### 部署为在线服务

在线服务由开发者负责运行和维护，用户通过浏览器或 HTTP 客户端访问，不需要下载服务端代码。下面是一个 FastAPI 示例：

```python
from fastapi import FastAPI

app = FastAPI()


@app.get("/")
def home():
    return {"message": "Hello World"}
```

安装依赖并启动服务：

```bash
pip install fastapi uvicorn
uvicorn main:app --host 0.0.0.0 --port 8000
```

如果服务运行在云服务器上，还需要配置网络访问、域名、HTTPS、进程管理、日志与监控。用户可以通过示意地址访问：

```text
https://api.example.com/
```

示例响应：

```json
{
  "message": "Hello World"
}
```

`api.example.com` 只是示例域名，上述启动命令不会自动完成公网部署。

## 总结

软件交付是一条从源代码到可用服务的链路：项目配置描述如何构建，构建工具生成 Artifact，版本号表达发布状态，包索引或 Registry 负责分发，容器与编排工具则负责组织运行环境和服务。选择方案时，应先判断用户需要“安装软件”还是“访问服务”，再决定使用分发包、可执行文件、容器镜像或在线部署。
