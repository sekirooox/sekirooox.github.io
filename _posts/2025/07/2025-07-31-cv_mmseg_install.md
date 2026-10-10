---
title: "环境配置·mmsegmentation和mmcv的安装"
author: MayL
date: 2025-07-31
categories: ["深度学习与计算机视觉", "计算机视觉"]
tags: ["计算机视觉", "语义分割", "深度学习", "学习笔记"]
render_with_liquid: false
description: "本文整理“环境配置·mmsegmentation和mmc…”涉及的模型原理、关键方法与实践要点，便于理解和复习相关技术。"
---

## 安装pytorch
 `-c`的意思是channel，这里的`-c pytorch`是**pytorch官网安装路径**，**非常慢，不推荐！**
```python
conda install pytorch==1.10.1 torchvision==0.11.2 torchaudio=0.10.1 cudatoolkit=10.2 -c pytorch
```
建议结合以下步骤安装pytorch，实测速度非常快！
**首先加入清华源**，可以参考别的地方的源，快就行了！
```python
conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/free/
conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/main/
conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud//pytorch/
conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/conda-forge/
conda config --set show_channel_urls yes
```
删去`-c pytorch`后缀！使用默认命令安装
```python
conda install pytorch==1.10.1 torchvision==0.11.2 torchaudio=0.10.1 cudatoolkit=10.2
```
## mmsegmentation的安装
直接安装即可

```python
pip install mmsegmentation==0.24.0
```

## mmcv-full的安装
**windows系统正常安装mmcv-full一般都会报错**！大概意思是缺少cl.exe编译器，这是一个C++和python混合编译的库，所以需要C++编译器。

```python
Could not build wheels for mmcv-full, which is required to install pyproject.toml-based projects
```

网上的方法特别麻烦，最简单的解决方案是：**先安装mim工具，然后通过mim安装mmcv-full**
```python
pip install -U openmim
mim install "mmcv-full<2.0.0"
```
但是又出现了新的问题，**mmcv-full的版本不兼容！**
```python
AssertionError: MMCV==1.7.0 is used but incompatible. Please install mmcv>=2.0.0rc4, <2.2.0.
```
解决方案：**先更新mmsegmentations到1.0.0的版本**(这一步是为了确保二者兼容)，然后**不要尝试**直接安装`mmcv==2.0.0rc4`，而是尝试安装更高的版本`mim install mmcv==2.1.0`
```python
Looking in indexes: https://pypi.tuna.tsinghua.edu.cn/simple
Looking in links: https://download.openmmlab.com/mmcv/dist/cu102/torch1.10.0/index.html
Collecting mmcv==2.1.0
  Downloading https://download.openmmlab.com/mmcv/dist/cu102/torch1.10.0/mmcv-2.1.0-cp38-cp38-win_amd64.whl (26.6 MB)
     ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 26.6/26.6 MB 11.1 MB/s eta 0:00:00
Requirement already satisfied: addict in d:\anacoda\envs\mmseg\lib\site-packages (from mmcv==2.1.0) (2.4.0)
Requirement already satisfied: mmengine>=0.3.0 in d:\anacoda\envs\mmseg\lib\site-packages (from mmcv==2.1.0) (0.10.7)
Requirement already satisfied: numpy in d:\anacoda\envs\mmseg\lib\site-packages (from mmcv==2.1.0) (1.24.4)
Requirement already satisfied: packaging in d:\anacoda\envs\mmseg\lib\site-packages (from mmcv==2.1.0) (24.2)
Requirement already satisfied: Pillow in d:\anacoda\envs\mmseg\lib\site-packages (from mmcv==2.1.0) (9.4.0)
Requirement already satisfied: pyyaml in d:\anacoda\envs\mmseg\lib\site-packages (from mmcv==2.1.0) (6.0.2)
Requirement already satisfied: yapf in d:\anacoda\envs\mmseg\lib\site-packages (from mmcv==2.1.0) (0.43.0)
Requirement already satisfied: opencv-python>=3 in d:\anacoda\envs\mmseg\lib\site-packages (from mmcv==2.1.0) (4.12.0.88)  
Requirement already satisfied: regex in d:\anacoda\envs\mmseg\lib\site-packages (from mmcv==2.1.0) (2024.11.6)
Requirement already satisfied: matplotlib in d:\anacoda\envs\mmseg\lib\site-packages (from mmengine>=0.3.0->mmcv==2.1.0) (3.7.5)
Requirement already satisfied: rich in d:\anacoda\envs\mmseg\lib\site-packages (from mmengine>=0.3.0->mmcv==2.1.0) (13.4.2)Requirement already satisfied: termcolor in d:\anacoda\envs\mmseg\lib\site-packages (from mmengine>=0.3.0->mmcv==2.1.0) (2.4.0)
Requirement already satisfied: platformdirs>=3.5.1 in d:\anacoda\envs\mmseg\lib\site-packages (from yapf->mmcv==2.1.0) (4.3.6)
Requirement already satisfied: tomli>=2.0.1 in d:\anacoda\envs\mmseg\lib\site-packages (from yapf->mmcv==2.1.0) (2.2.1)    
Requirement already satisfied: contourpy>=1.0.1 in d:\anacoda\envs\mmseg\lib\site-packages (from matplotlib->mmengine>=0.3.0->mmcv==2.1.0) (1.1.1)
Requirement already satisfied: cycler>=0.10 in d:\anacoda\envs\mmseg\lib\site-packages (from matplotlib->mmengine>=0.3.0->mmcv==2.1.0) (0.12.1)
Requirement already satisfied: fonttools>=4.22.0 in d:\anacoda\envs\mmseg\lib\site-packages (from matplotlib->mmengine>=0.3.0->mmcv==2.1.0) (4.57.0)
Requirement already satisfied: kiwisolver>=1.0.1 in d:\anacoda\envs\mmseg\lib\site-packages (from matplotlib->mmengine>=0.3.0->mmcv==2.1.0) (1.4.7)
Requirement already satisfied: pyparsing>=2.3.1 in d:\anacoda\envs\mmseg\lib\site-packages (from matplotlib->mmengine>=0.3.0->mmcv==2.1.0) (3.1.4)
Requirement already satisfied: python-dateutil>=2.7 in d:\anacoda\envs\mmseg\lib\site-packages (from matplotlib->mmengine>=0.3.0->mmcv==2.1.0) (2.9.0.post0)
Requirement already satisfied: importlib-resources>=3.2.0 in d:\anacoda\envs\mmseg\lib\site-packages (from matplotlib->mmengine>=0.3.0->mmcv==2.1.0) (6.4.5)
Requirement already satisfied: markdown-it-py>=2.2.0 in d:\anacoda\envs\mmseg\lib\site-packages (from rich->mmengine>=0.3.0->mmcv==2.1.0) (3.0.0)
Requirement already satisfied: pygments<3.0.0,>=2.13.0 in d:\anacoda\envs\mmseg\lib\site-packages (from rich->mmengine>=0.3.0->mmcv==2.1.0) (2.19.2)
Requirement already satisfied: typing-extensions<5.0,>=4.0.0 in d:\anacoda\envs\mmseg\lib\site-packages (from rich->mmengine>=0.3.0->mmcv==2.1.0) (4.12.2)
Requirement already satisfied: zipp>=3.1.0 in d:\anacoda\envs\mmseg\lib\site-packages (from importlib-resources>=3.2.0->matplotlib->mmengine>=0.3.0->mmcv==2.1.0) (3.20.2)
Requirement already satisfied: mdurl~=0.1 in d:\anacoda\envs\mmseg\lib\site-packages (from markdown-it-py>=2.2.0->rich->mmengine>=0.3.0->mmcv==2.1.0) (0.1.2)
Requirement already satisfied: six>=1.5 in d:\anacoda\envs\mmseg\lib\site-packages (from python-dateutil>=2.7->matplotlib->mmengine>=0.3.0->mmcv==2.1.0) (1.17.0)
Installing collected packages: mmcv
  Attempting uninstall: mmcv
    Found existing installation: mmcv 2.0.0rc3
    Uninstalling mmcv-2.0.0rc3:
      Successfully uninstalled mmcv-2.0.0rc3
Successfully installed mmcv-2.1.0
```
实测：解决成功！


## curse_轮子

```python
https://github.com/zephyrproject-rtos/windows-curses
```

## torchvision的问题

```python
UserWarning: Failed to load image Python extension: 
Could not find module 'D:\anacoda\envs\zegclip\Lib\site-packages\torchvision\image.pyd' (or one of its dependencies). 
Try using the full path with constructor syntax.
```

# PIL库中DLL缺失
```python
ImportError: DLL load failed while importing _imaging: 找不到指定的模块。
```

```python
pip install pillow==6.2.1 -i https://pypi.tuna.tsinghua.edu.cn/simple/
```

