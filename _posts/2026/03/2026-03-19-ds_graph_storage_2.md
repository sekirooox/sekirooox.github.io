---
title: "图论·图的存储"
author: MayL
date: 2026-03-19
categories: ["算法与数据结构", "图论"]
tags: ["图论", "rag", "算法", "学习笔记"]
render_with_liquid: false
description: "本文整理“图论·图的存储（2026-03-19）”的核心思路、典型问题与实现要点，便于刷题复习和后续查阅。"
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
+ h代表链表头指针，**指向v,nxt数组中的每一个节点**
+ v代表某一个**边终点节点**的具体值，nxt代表指向的边。**注意这两个数组其实都是代表边**，可能会出现1->3,2->3，**3号节点对应v和nxt中不同的位置的情况！**
+ **v和nxt的大小等于边数**！
+ len代表总共有多少边。

```cpp
int h[100009], v[100009], nxt[100009], len = 0;
```

+ 插入操作
```cpp
void insert(int x,int y) {
	len++;
	v[len] = y;
	nxt[len] = h[x];
	h[x] = len;
	d[y]++;
}
```
+ 容易出错的操作：搜索时我们**假定得到的是节点编号**，但是我们nxt和h指向的是**该节点的实际存储**位置。

```cpp
for (int i = h[cur]; i != -1; i = nxt[i]) {
	int node = v[i];
	d[node]--;
	if (!d[node]) {
		q.push(node);
	}
}
```
