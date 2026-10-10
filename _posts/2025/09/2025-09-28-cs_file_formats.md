---
title: "计算机基础·常见文件格式处理"
author: MayL
date: 2025-09-28
categories: ["计算机系统与开发", "开发工具"]
tags: ["开发工具", "计算机基础", "开发笔记"]
render_with_liquid: false
description: "本文整理“计算机基础·常见文件格式处理”的核心知识、常用方法与实践注意事项，便于学习复习和开发查阅。"
---

# 基本文件处理
>python 中 文件处理的基本逻辑
+ 建议与with配合使用，实现文件自动关闭。
+ `f`是文件句柄，理解为**对文件引用**，操作系统中**用于标识和访问已打开文件的关键数据结构**。常见命令`f.read()/readline()/readlines()`都是通过句柄对文件进行一些操作，返回python的数据结构。
+ 由于`f`引用文件本身，所以是一个**可迭代对象**，可以用`for`循环代替`readline/readlines`命令
+ 但是直接打印`f`不会有任何效果(返回python的IO类型)。
```python
with open(file_path, 'r', encoding="utf-8") as f:
    data = [json.loads(line) for line in f]
```

# json
+ json格式可以简单理解为python的dict+list结构
+ list为主加载要使用`load`，dict格式要使用`loads()`
+ 常见命令包含`json.loads()`和`json.dumps()`，**对象是文件句柄f和python字典**。
## 示例1
+ 列表格式的json文件
```python
[
  {"id": 1, "name": "Alice", "score": 95},
  {"id": 2, "name": "Bob", "score": 88},
  {"id": 3, "name": "Charlie", "score": 92}
]

```

```python
with open("students.json", "r", encoding="utf-8") as f:
    students = json.load(f)

for stu in students:
    print(stu["name"], stu["score"])

```

## 示例2
+ 字典格式的json文件：`s = '{"name": "Alice", "age": 23, "is_student": false}'`，注意是一个**字典类型的字符串**
```python
import json

s = '{"name": "Alice", "age": 23, "is_student": false}'
data = json.loads(s)
print(data)        # {'name': 'Alice', 'age': 23, 'is_student': False}
print(type(data))  # dict

```
# jsonl
+ 并没有显示的`[]`，其中每一行都是一个**标准的字典类型的字符串 / json文件内容**。

不是jsonl格式：
```python
[
  {"id": 1, "name": "Alice", "score": 95},
  {"id": 2, "name": "Bob", "score": 88},
  {"id": 3, "name": "Charlie", "score": 92}
]
```
jsonl格式：

```python
{"scenario": "post_summarization", "prompt": ....
{"scenario": "post_summarization", "prompt": ....
```

+ 正确的读取方式，**通过句柄遍历文件每一行**，然后调用`json.loads()`读取就行！

```python
with open(file_path, 'r', encoding="utf-8") as f:
    data = [json.loads(line) for line in f]
```

等价于调用`f.readlines()`：

```python
with open(file_path, 'r', encoding="utf-8") as f:
    data=[]
    for line in f.readlines():
        data.append(json.loads(line))
```

