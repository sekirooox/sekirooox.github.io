---
title: "计算机基础·cs336-编码基础和分词"
author: MayL
date: 2026-02-01
categories: ["大语言模型与强化学习", "大语言模型"]
tags: ["人工智能", "学习笔记"]
render_with_liquid: false
description: "本文围绕“计算机基础·cs336-编码基础和分词”梳理核心概念、算法思路与实践要点，便于系统学习和后续查阅。"
---

@[toc]
# python基础
## DefaultDict和Counter
+ DefaultDict：继承自python字典，主要区别是可以用`DefaultDict(int)`**指定默认值**(当为int时，返回0)，例如`DefaultDict(list)`可以**直接往键里面append元素**
+ Counter：继承自python字典，接受可以迭代的对象(list,dict)作为输入，输出返回一个字典，**得到当前元素的出现次数统计**。`Counter([1,2,3])={1:1,2:1,3:1}`
常见操作：`update`和`substract`增加或者减少元素的统计次数(接受list/dict作为参数)
## string.encode/decoder('utf-8')
+ 将字符串转为对应**utf-8编码**(字节的形式)

```python
string = 'hello'
for byte in string.encode('utf-8'):# b'hello'
    print(byte)
104 101 108 108 111
```
## bytes()函数：整数转字节序列

```python
bytes([104, 101, 108, 108, 111])
b'hello'
```
---
<br><br><br><br><br><br>
# 编码基础
## 字符转数字
### ASCII
用一个字节**0~255**来表示一个英文字符，不支持中文。
### Unicode
标识大多数字符，被标识的字符成为**码点**


## 数字转存储(字节)
### UTF-8,UTF-16,UTF-32
+ 字节表示方法：`b'\x00'`
+ 8，16，32指的是**位数(bit)**。
+ UTF-8指的是使用**最少一字节来存储字符**(实际是**动态存储**，例如英文字母‘a'对应一个字节，中文字符“好”对应3个字节)
+ UTF-32指的是使用4字节来存储任意字符，如果**字符不需要4个字节，则填充至4个字节**。
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/85347824a1c74ad1b77d4304bda51975.png){: referrerpolicy="no-referrer" }
### UTF-8编码原理(了解即可)
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/2b3ca08f5fdb4369ba199c7aec10b703.png){: referrerpolicy="no-referrer" }
### 实现
---
<br><br><br><br><br><br>

# BPE算法
## 预分词技术
+ 简单来说就是隔离每一个词，确保每一个词的语义完整，**避免BPE算法统计跨语义的次数**。


![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/1512c1ffc20a4684bc916684dba091ea.png){: referrerpolicy="no-referrer" }
  ---
<br><br><br><br><br><br>




