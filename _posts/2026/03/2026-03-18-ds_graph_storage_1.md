---
title: "图论·图的存储"
author: MayL
date: 2026-03-18
categories: ["算法与数据结构", "图论"]
tags: ["图论", "rag", "算法", "学习笔记"]
render_with_liquid: false
description: "本文整理“图论·图的存储（2026-03-18）”的核心思路、典型问题与实现要点，便于刷题复习和后续查阅。"
---

# 图论的存储
+ **邻接表**
+ 邻接矩阵(一般不用)

## 邻接表
### 结构体数组实现
+ 缺点：如果使用结构体的话，`node`结构体初始化很慢。
```cpp
// common one
vector<list<int>>g;
// another type
typedef struct node{
	int val;
	int dist;// 如果需要节点到某点的距离的话
}
vector<list<node>>g;
```
+ 插入操作

```cpp
q.push_back(item)
```

### 链表前向星
+ 邻接表定义：
+ h代表链表头指针，**指向node,nxt数组中的位置**
+ **node,nxt数组表示边的数组**，其中node表示边的终点结点，nxt表示该结点**在邻接表中的下一结点**
+ **node,nxt数组的大小等于边数**！
+ len代表**总共有多少边**。


```cpp
int h[100009], node[100009], nxt[100009], len = 0;
```
+ 插入操作
```cpp
void insert(int x,int y) {
	len++;
	node[len] = y;
	nxt[len] = h[x];
	h[x] = len;
}
```
+ 容易出错的操作：搜索时我们**假定得到的是节点编号**，但是我们nxt和h指向的是**边数组的存储位置**。

```cpp
for (int i = h[cur]; i != -1; i = nxt[i]) {
	int x = node[i];
}
```
