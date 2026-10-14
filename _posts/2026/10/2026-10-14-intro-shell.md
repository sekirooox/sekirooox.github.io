---
title: "Shell 入门"
date: 2026-10-14 00:00:00 +0800
description: Shell、命令行工具、脚本、作业控制与远程连接基础
categories: ["计算机基础"]
tags: ["Shell", "Bash", "命令行", "SSH", "tmux"]
render_with_liquid: false
pin: false
---

# Shell 入门

Shell 是连接用户与操作系统的命令解释器，终端模拟器则提供与 Shell 交互的界面。本文以 Bash 为主，介绍常用命令、管道与重定向、脚本语法、作业控制、SSH 和 tmux。

## 打开终端

常见系统可通过以下方式打开终端：

- Linux：按 `Ctrl+Alt+T`，或在应用菜单中搜索“终端（Terminal）”；
- Windows：按 `Win+R`，输入 `cmd` 或 `powershell`，也可以从开始菜单打开“终端”或“命令提示符”；若要练习本文的 Bash 命令，建议使用 WSL；
- macOS：按 `Command+Space` 打开聚焦搜索，输入“终端”，或前往“应用程序 → 实用工具 → 终端”。

Linux 和 macOS 的默认 Shell 因系统而异，常见选择包括 Bash 和 Zsh。Windows 常用 PowerShell 或命令提示符；也可以通过 WSL 使用 Linux Shell。

## 提示符与路径

Shell 提示符通常包含用户名、主机名和当前目录，例如：

```console
missing:~$
```

其中，`~` 表示<span style="color:red">当前用户的主目录</span>；在 Linux 上通常是 `/home/用户名`。<span style="color:red">普通用户</span>的提示符常以 `$` 结尾，<span style="color:red">root 用户</span>则常以 `#` 结尾，但这只是提示符惯例，不能作为权限判断的唯一依据。

命令中的相对路径以当前工作目录为基准；省略操作数时的行为则由命令自身决定。可以使用 `pwd` 查看当前目录，也可以输出环境变量 `PWD`：

```bash
pwd
echo "$PWD"
```

每个目录还包含两个特殊路径：`.` 表示当前目录，`..` 表示父目录。以下命令会分别列出当前目录和父目录的内容：

```bash
ls .
ls ..
```

## 查询帮助与定位命令

`man` 是 manual 的缩写，用于查看命令手册。例如，`man date` 会说明 `date` 的用途和参数。多数命令也支持 `--help`，可快速查看简要帮助：

```bash
man date
date --help
```

Shell 会按自身规则解析命令名，可能匹配别名、函数、内建命令或外部程序；查找外部程序时，通常会按顺序搜索 `PATH` 环境变量列出的目录。可以使用以下命令查看搜索路径和解析结果：

```bash
echo "$PATH"
command -v date
type echo
```

`command -v` 适合在脚本中判断命令是否存在；`type` 还能说明目标是外部程序、Shell 内建命令还是别名。

## 文件与文本处理

### 常用命令

以下命令是处理文本文件的基础工具：

| 命令 | 作用 |
| --- | --- |
| `cat hello.txt` | 输出文件的全部内容 |
| `sort hello.txt` | 按行排序后输出 |
| `uniq hello.txt` | 合并连续重复的行，通常与 `sort` 配合 |
| `head hello.txt` | 输出文件开头的若干行 |
| `tail hello.txt` | 输出文件末尾的若干行 |

`grep` 用于**筛选匹配指定模式**的行，其中模式通常是<span style="color:red">正则表达式</span>：

```bash
grep 'pattern' hello.txt
grep -r 'pattern' .
```

第一条命令搜索单个文件，第二条命令从当前目录开始递归搜索。若不提供文件或目录，`grep` 会读取标准输入，而不是自动搜索当前目录。

### 使用 find 查找文件

`find` 会递归遍历目录，并根据名称、类型、大小或修改时间等条件筛选文件。例如：

```bash
find ~/Downloads -type f -name '*.zip' -mtime +30
```

该命令查找 `~/Downloads` 中修改时间超过 30 天的 ZIP 文件。

```bash
find ~ -type f -size +100M -exec ls -lh {} \;
```

该命令查找主目录中大于 100 MiB 的文件，并将每个匹配路径放到 `{}` 的位置。`;` 用于结束 `-exec` 后的命令，其中<span style="color:red">反斜杠用于避免分号</span>被当前 Shell 提前解释。

```bash
find . -type f -name '*.py' -exec grep -l 'TODO' {} +
```

该命令查找包含 `TODO` 的 Python 文件。结尾的 `+` 会尽可能将多个路径一次传给 `grep`，通常比逐个文件执行更高效。

### 使用 awk 处理结构化文本

`awk` 适合按记录和字段处理文本。默认情况下，它将每一行视为一条记录，并用空白字符分隔字段：

```bash
awk '{print $2}' hello.txt
awk -F, '{print $2}' hello.csv
```

第一条命令输出每行的第二个空白分隔字段；第二条命令通过 `-F,` 指定逗号为分隔符。

简单 CSV 可以这样处理，但带引号、换行或转义的完整 CSV 格式更适合使用专用解析器。

<span style="color:red">XLSX 通常是包含 XML 与其他资源的 ZIP 容器</span>，不应直接交给 `awk` 解析。

`sed` 更适合按规则修改文本流，`awk` 则擅长字段提取、过滤与统计。两者都有各自的表达式语言。

## 标准流、管道与重定向

命令行程序通常使用三个标准流：

| 文件描述符 | 名称 | 默认连接 |
| --- | --- | --- |
| `0` | 标准输入 `stdin` | 键盘或上游管道 |
| `1` | 标准输出 `stdout` | 终端或下游管道 |
| `2` | 标准错误 `stderr` | 终端 |

管道符 `|` 会把前一个程序的标准输出连接到后一个程序的标准输入：

```bash
sort hello.txt | uniq | head
```

管道传递的是字节流，不会把文本自动转换成命令行参数。例如，`ls` 通常不从标准输入读取文件名；需要将输入转换为参数时，应根据数据格式选择 `xargs`、循环或程序原生的批处理选项，并妥善处理空格与换行。

重定向可以改变标准流的去向：

```bash
command > output.txt       # 将 stdout 覆盖写入文件
command >> output.txt      # 将 stdout 追加到文件
command < input.txt        # 从文件读取 stdin
command 2> error.txt       # 将 stderr 写入文件
command > all.txt 2>&1     # 将 stdout 和 stderr 写入同一文件
```

例如，下面的命令只把错误信息保存到文件：

```console
$ ls footbar 2> redirect.txt
$ cat redirect.txt
ls: cannot access 'footbar': No such file or directory
```

## 条件、循环与退出状态

### 退出状态

> 在 Bash 中，<span style="color:red">退出状态为 0 表示成功；非 0 可表示失败、条件不成立或程序定义的其他状态</span>。在条件语境中，0 被视为真，非 0 被视为假。

命令执行后会返回一个整数退出状态，`$?` 保存上一条命令的退出状态：

```bash
mkdir -p test
echo "$?"
```

### 短路执行

`&&` 和 `||` 根据退出状态进行短路执行：

```bash
[ -d test ] || mkdir -p test
make && ./app
```

第一条命令仅在 `test` 不是目录时创建它；第二条命令仅在 `make` 成功后运行程序。

### 条件语句

`if` 直接根据命令的退出状态判断条件：

```bash
if [ -f "$file" ]; then
    echo "$file 是一个文件"
else
    echo "$file 不是一个文件"
fi
```

#### test 命令的另一种形式

`[` 实际上是 `test` 命令的**另一种形式**，结尾的 `]` 也是它的参数，**因此两侧都需要空格**。

Bash 还提供 `[[ ... ]]` 条件表达式，能减少单词拆分和通配符展开带来的意外；但它不是 POSIX `sh` 语法。

### 循环

`while` 会在条件命令持续成功时重复执行循环体：

```bash
while command1; do
    command2
    command3
done
```

`for` 用于依次处理一组值：

```bash
for name in a b c d; do
    echo "$name"
done
```

### 命令替换

命令替换 `$(...)` 可以把命令输出嵌入另一条命令：

```bash
for i in $(seq 1 10); do
    echo "$i"
done
```

旧式反引号也能完成命令替换，但不利于嵌套和阅读，应优先使用 `$(...)`。处理文件名时不要解析 `ls` 的输出；应优先使用 glob、`find -print0` 或其他能保留文件名边界的方式。

## 编写 Bash 脚本

较长的命令应保存为 `.sh` 文件。下面的脚本会反复运行测试，直到测试失败，并保留最后一次输出：

```bash
#!/usr/bin/env bash
set -uo pipefail

logfile="test_runs_$(date +%s).log"
run=1

while cargo test my_test >"$logfile" 2>&1; do
    echo "Run $run passed"
    ((run += 1))
done

echo "Test failed on run $run"
echo "Last 20 lines of output:"
tail -n 20 "$logfile"
echo "Full log: $logfile"
```

### 指定解释器

第一行是 shebang。直接执行脚本时，操作系统会读取它并启动<span style="color:red">指定解释器</span>；这里通过 `env` 在 `PATH` 中查找 `bash`。shebang 不限于 Shell，也可以指向 Python、Perl、Node.js 等解释器。

`set -uo pipefail` 中各选项的作用如下：

- `-u`：使用未定义变量时立即报错；
- `-o pipefail`：管道中任一命令失败时，整个管道返回失败状态。

常见的 `-e` 会在未被条件语境处理的命令失败时退出，但存在不少边界规则，不能简单理解为“任何失败都立即退出”。脚本仍应显式处理预期失败和清理逻辑。

## Glob 与大括号扩展

Glob 是 Shell 用于匹配路径名的模式语法，不等同于正则表达式：

| 模式 | 含义 |
| --- | --- |
| `*` | 匹配同一路径段中的任意字符序列，默认不匹配路径段开头的 `.` |
| `?` | 匹配任意单个字符 |
| `[abc]` | 匹配集合中的一个字符 |
| `[a-z]` | 匹配指定范围中的一个字符 |
| `[!abc]` | 匹配不在集合中的一个字符 |

Shell **会先展开 glob**，再启动目标程序。例如，`ls *.txt` 可能被展开为 `ls a.txt b.txt`。若没有匹配项，不同 Shell 或选项的行为可能不同。

字符类只约束一个字符。例如，`[!hello].txt` 并不表示“排除 `hello.txt`”，而是匹配文件名主体仅有一个字符、且该字符不是 `h`、`e`、`l` 或 `o` 的路径。

### 将 Glob 匹配应用于命令

大括号扩展是纯文本生成，不检查文件是否存在：

```bash
touch folder/{a,b,c}.py
# 展开为：touch folder/a.py folder/b.py folder/c.py

cp /path/to/project/{setup,build,deploy}.sh /newpath
# 展开为三个脚本路径

printf '%s\n' *.{py,sh}
# 输出匹配的 Python 和 Shell 文件
```

大括号扩展通常早于路径名展开发生。它与 glob 可以组合，但两者的语义不同。

## 参数、变量与命令替换

### 命令参数

程序接收的是字符串参数列表。例如：

```bash
ls -l folder/
```

这相当于运行 `ls`，并传入 `-l` 与 `folder/` 两个参数。选项通常以 `-` 或 `--` 开头，但具体规则由程序自行定义。短选项有时可以合并，例如 `ls -l -a` 与 `ls -la`；不能据此假设所有程序的选项都能合并或任意换序。

许多命令可以接收多个同类参数：

```bash
mkdir src docs
```

### 位置参数

在 Shell 脚本中，常用<span style="color:red">位置参数</span>包括：

| 写法 | 含义 |
| --- | --- |
| `$0` | 脚本或命令名称 |
| `$1` 至 `$9` | 前九个位置参数 |
| `${10}`、`${11}` | 第十个、第十一个位置参数，后续依次类推 |
| `$#` | 参数个数 |
| `"$@"` | 保留边界的全部参数 |

下面的脚本要求恰好传入一个文件路径：

```bash
#!/usr/bin/env bash

if [ "$#" -ne 1 ]; then
    echo "用法：$0 <文件路径>" >&2
    exit 1
fi

file=$1
if [ -f "$file" ]; then
    echo "$file 是一个文件"
else
    echo "$file 不是一个文件"
fi
```

引用变量时通常应写成 `"$file"`，避免空格、通配符和空值引发单词拆分或路径名展开。

### Shell 变量

Bash 的普通标量通常<span style="color:red">按字符串保存</span>；此外还支持整数属性、索引数组和关联数组。**赋值符两侧不能有空格**：

```bash
foo=bar
echo "$foo"
```

### 单引号与双引号

**单引号中的内容按字面值处理**，不展开变量或命令替换；**双引号则会进行变量和命令替换**：

```bash
echo '$foo'   # 输出 $foo
echo "$foo"   # 输出 bar
```

命令替换会把命令的标准输出放入当前位置，并移除末尾连续换行：

```bash
today=$(date +%Y-%m-%d)
echo "$today"
```

### 环境变量

普通 Shell 变量不会自动传给子进程。可以只为单条命令设置环境变量：

```bash
TZ=Asia/Tokyo date
echo "${TZ-}"
```

第一条命令不会修改当前 Shell 中原有的 `TZ`；第二条命令显示原值，若此前未设置则为空。

也可以使用 `export` 将变量加入当前 Shell 后续启动的子进程环境：

```bash
export DEBUG=1
bash -c 'echo "$DEBUG"'
unset DEBUG
```

## curl 与 /dev/null

### curl 常用选项

`curl` 用于发送网络请求，也可**下载或上传**数据：

```bash
curl URL
curl -O URL
curl -o name URL
curl -L URL
curl -I URL
curl -i URL
curl -s -o /dev/null -w '%{http_code}\n' URL
curl -H 'K: V' URL
curl -d 'a=1&b=2' URL
curl -H 'Content-Type: application/json' -d '{"a":1}' URL
curl -F 'file=@x.jpg' URL
curl --user user URL
curl -v URL
```

`--user user` 会交互式询问密码，避免把明文密码直接写进命令历史；`-v` 的调试输出可能包含认证信息或 Cookie，分享日志前应先检查并脱敏。

常用下载选项包括：

| 选项 | 作用 |
| --- | --- |
| `-L` | 跟随 HTTP 重定向 |
| `-O` | 使用远程文件名保存 |
| `-o FILE` | 保存为指定文件 |
| `-#` | 显示简洁进度条 |
| `-s` | 静默输出 |
| `-C -` | 尝试从中断位置继续下载 |
| `--retry 3` | 失败后最多重试三次 |
| `--max-time 300` | 将整次传输限制为 300 秒 |

### /dev/null

`/dev/null` 是 Unix 类系统提供的特殊字符设备。<span style="color:red">写入其中的数据会被丢弃</span>，读取时则立即得到<span style="color:red">文件结束标记</span>：

```bash
ls -l /dev/null
command > /dev/null 2>&1
```

第二条命令同时丢弃标准输出和标准错误。使用它会隐藏诊断信息，因此只应在明确不需要输出时使用。

## 信号与作业控制

### 常见信号

信号用于通知进程发生了某个事件。进程可以捕获、忽略或暂时阻塞部分信号，但 `SIGKILL` 和 `SIGSTOP` 无法被捕获或忽略。

| 信号 | 常见编号 | 常见用途 | 特点 |
| --- | ---: | --- | --- |
| `SIGHUP` | `1` | 终端断开或请求重新加载 | 可捕获 |
| `SIGINT` | `2` | `Ctrl+C` 中断 | 可捕获 |
| `SIGQUIT` | `3` | `Ctrl+\` 退出 | 默认终止并生成 core dump |
| `SIGKILL` | `9` | 强制终止 | 不可捕获、不可忽略 |
| `SIGTERM` | `15` | 请求进程正常退出 | `kill` 的默认信号 |
| `SIGSTOP` | 因系统而异 | 强制暂停 | 不可捕获、不可忽略 |
| `SIGTSTP` | 因系统而异 | `Ctrl+Z` 交互式暂停 | 可捕获 |
| `SIGCONT` | 因系统而异 | 恢复暂停的进程 | 可捕获 |

信号编号可能因系统和架构而异，脚本中应优先使用名称：

```bash
kill -TERM <PID>
kill -INT <PID>
kill -KILL <PID>
kill -l
pgrep sleep
pkill -TERM sleep
```

`SIGTERM` 可被进程捕获，因此程序若安装了相应处理器，就有机会在退出前清理；`SIGKILL` 无法被捕获，会立即终止进程，可能留下临时文件、未刷新的数据或独立运行的子进程。

### 前台、后台与作业

交互式 Shell 开启作业控制后，终端会将 `Ctrl+C`、`Ctrl+Z` 等按键转换为信号并发送给前台进程组。常用命令如下：

```bash
sleep 1000 &   # 在后台启动
jobs           # 查看当前 Shell 的作业
fg %1          # 将作业 1 调到前台
bg %1          # 让暂停的作业 1 在后台继续
kill %1        # 向作业 1 发送信号
echo "$!"      # 最近一个后台进程的 PID
```

作业编号由当前 Shell 管理，退出 Shell 后不能在新 Shell 中直接使用原来的 `%1`。

### SIGHUP

`SIGHUP` 中的 HUP 是 hangup 的缩写，最初表示终端连接断开。终端关闭或会话断开时，控制终端或交互式 Shell 可能向相关进程或作业发送 `SIGHUP`；具体范围取决于 Shell、作业状态和启动方式，并非无条件发送给系统中的所有进程。

> <span style="color:red">作业由创建它的 Shell 管理</span>。退出该 Shell 后，新 Shell 不能继续使用原来的作业编号，但仍可通过进程 PID 查找和管理尚未退出的进程。

### nohup 与 SIGHUP

`nohup` 会让目标命令忽略 `SIGHUP`：

```bash
nohup command > command.log 2>&1 &
```

它能降低终端断开导致命令退出的风险，<span style="color:red">但不提供会话管理</span>。

命令仍可能因其他信号、系统重启或自身错误而终止；需要重新连接并管理会话时，tmux 通常更方便。

## SSH 远程连接

SSH（Secure Shell）用于安全登录远程主机：

```bash
ssh alice@server.example.com
```

也可以直接在远程主机执行命令：

```bash
# ls 在远程执行，wc 在本地执行
ssh alice@server.example.com ls | wc -l

# ls 与 wc 都在远程执行
ssh alice@server.example.com 'ls | wc -l'
```

引号决定管道由本地 Shell 还是远程 Shell 解释。

### 密钥认证

SSH 支持密码和密钥认证，两者都受到 SSH 加密通道保护。密钥认证无需向服务器发送账户密码，便于自动化，也能降低密码猜测与重复使用带来的风险。可以生成 Ed25519 密钥对：

```bash
ssh-keygen -a 100 -t ed25519 -f ~/.ssh/id_ed25519
```

私钥 `~/.ssh/id_ed25519` 相当于登录凭证，必须妥善保管；公钥文件则以 `.pub` 结尾。可使用以下命令复制公钥：

```bash
ssh-copy-id -i ~/.ssh/id_ed25519.pub alice@remote
```

若系统没有 `ssh-copy-id`，可以在确认远程目录和权限正确后手动追加：

```bash
cat ~/.ssh/id_ed25519.pub | ssh alice@remote 'umask 077; mkdir -p ~/.ssh; cat >> ~/.ssh/authorized_keys'
```

### 传输文件

`scp` 可直接复制文件，`rsync` 则支持增量传输、权限控制和断点续传：

```bash
scp path/to/local_file alice@remote:path/to/remote_file
rsync -av --partial path/to/local_file alice@remote:path/to/remote_file
```

### SSH 客户端配置

可以在 `~/.ssh/config` 中声明主机别名和默认参数：

```text
Host vm
    User alice
    HostName 172.16.174.141
    Port 2222
    IdentityFile ~/.ssh/id_ed25519

Host *.example.com
    User alice
```

保存后可直接运行 `ssh vm`。`scp`、`sftp` 和 `rsync` 等工具也能使用这些配置。

## tmux 终端复用

tmux 可以在一个终端中**管理多个持久会话、窗口和窗格**。会话可暂时分离，<span style="color:red">SSH 断开后重新连接服务器仍可继续使用</span>。

tmux 的默认前缀键是 `Ctrl+B`。例如，`Ctrl+B` 后再按 `d` 表示分离当前会话。

### 会话

```bash
tmux                     # 创建新会话
tmux new -s NAME         # 创建命名会话
tmux ls                  # 列出会话
tmux attach              # 附着到最近的会话
tmux attach -t NAME      # 附着到指定会话
```

常用会话快捷键：

| 快捷键 | 作用 |
| --- | --- |
| `Ctrl+B d` | 分离当前会话 |
| `Ctrl+B s` | 列出并切换会话 |

### 窗口

| 快捷键 | 作用 |
| --- | --- |
| `Ctrl+B c` | 创建窗口 |
| `Ctrl+B n` | 切换到下一个窗口 |
| `Ctrl+B p` | 切换到上一个窗口 |
| `Ctrl+B 0` 至 `Ctrl+B 9` | 切换到指定编号的窗口 |
| `Ctrl+B ,` | 重命名窗口 |
| `Ctrl+B w` | 列出窗口 |

### 窗格

| 快捷键 | 作用 |
| --- | --- |
| `Ctrl+B "` | 上下拆分窗格 |
| `Ctrl+B %` | 左右拆分窗格 |
| `Ctrl+B` 加方向键 | 切换窗格 |
| `Ctrl+B z` | 切换当前窗格的缩放状态 |
| `Ctrl+B [` | 进入复制与回看模式 |
| `Ctrl+B Space` | 切换窗格布局 |

## 配置文件与包管理器

Shell 和许多命令行工具通过 dotfiles 保存用户配置。常见文件包括：

| 工具 | 常见配置文件 |
| --- | --- |
| Bash | `~/.bashrc`、`~/.bash_profile` |
| Git | `~/.gitconfig` |
| Vim | `~/.vimrc`、`~/.vim/` |
| SSH | `~/.ssh/config` |
| tmux | `~/.tmux.conf` |

Bash 读取哪些文件取决于当前会话是否为登录式或交互式 Shell，因此修改配置前应先确认启动方式。

向 `PATH` 追加目录时，可以写成：

```bash
export PATH="$PATH:$HOME/.local/bin"
```

这样后续启动的子进程就能找到该目录中的程序。示例把目录追加到现有搜索路径末尾；若要提高其优先级，可以放在 `PATH` 前端。不要加入不可信或权限过宽的目录。

不同系统使用不同包管理器，例如 macOS 常用 Homebrew，Ubuntu 和 Debian 常用 APT，Fedora 常用 DNF，Arch Linux 常用 Pacman。

## Alias 别名

Alias 可为常用命令创建简写或添加默认选项：

```bash
alias ll='ls -lh'
alias gs='git status'
alias gc='git commit'
alias sl='ls'
alias mv='mv -i'
alias mkdir='mkdir -p'
alias df='df -h'
```

别名可以引用另一个别名，但层层组合会降低可读性，并可能造成意外行为：

```bash
alias la='ls -A'
alias lla='la -l'
```

可使用 `type` 或 `alias` 查看定义，使用 `unalias` 删除别名。命令名前加反斜杠通常可以绕过同名别名：

```bash
alias ll
type ll
\ls
unalias ll
```

别名主要适合交互式使用；可复用的复杂逻辑更适合写成 Shell 函数或独立脚本。
