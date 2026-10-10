---
title: "数据结构·链表，树的数组表示"
author: MayL
date: 2026-02-14
categories: ["算法与数据结构", "数据结构"]
tags: ["数据结构", "算法", "学习笔记"]
render_with_liquid: false
description: "本文整理“数据结构·链表，树的数组表示”的核心思路、典型问题与实现要点，便于刷题复习和后续查阅。"
---


@[toc]
# 数组表示树类型结构(树，链表等)
## 总结
+ 在数组中**用0表示头指针，1表示尾部指针(双链表)**，使用`len`下一个插入的节点下标。
+ 定义`val`表示节点取值，`nxt`或`l`和`r`表示链表指向。
+ -1表示空节点
# 单链表
+ **nxt数组必须初始化为全-1**
+ 使用**0表示头指针**，新节点的下标从1开始。
+ add指的是在**k结点之后插入新节点**，remove指的是移除第k个节点下一个节点(**单链表不支持删除当前节点**)。
+ **节点k并非第k个位置的节点，而是添加时的顺序**，
## 纯数组实现 
```cpp
int m, val[100009], nxt[100009] = {-1}, len;
void init() {
	nxt[0] = -1;
	len = 1;
}
void add(int k, int x) {
	val[len] = x;
	nxt[len] = nxt[k];
	nxt[k] = len;
	len++;
}
void remove(int k) {//remove next item
	nxt[k] = nxt[nxt[k]];
}
void printout() {
	int cur = nxt[0];
	while (cur != -1) {
		cout << val[cur] << " ";
		cur = nxt[cur];
	}
}
```
## 结构体实现 (使用`new`操作导致速度较慢)

```cpp
typedef struct node {
	int val, nxt = -1;
};
class link {
public:
	node link[100009];
	int len = 0;
	void insert(int x) {
		len++;
		link[len].val = x;
		link[len].nxt = link[0].nxt;
		link[0].nxt = len;
	}
	void remove(int k) {
		link[k].nxt = link[link[k].nxt].nxt;
	}
	void insert_k(int k, int x) {
		len++;
		link[len].val = x;
		link[len].nxt = link[k].nxt;
		link[k].nxt = len;
	}
	void printout() {
		int cur = link[0].nxt;
		while (cur != -1) {
			cout << link[cur].val << " ";
			cur = link[cur].nxt;
		}
	}
};
```

## 例题
+ [AcWing 826. 单链表](https://www.acwing.com/activity/content/problem/content/863/)

# 双链表
+ **l和r数组必须初始化为全-1**
+ 使用0表示头指针，1表示尾指针，**新节点的下标从2开始**。
+ add指的是在**k结点之后插入新节点**，remove指的是移除第k个节点(**双链表支持删除当前节点**)。
+ **节点k并非第k个位置的节点，而是添加时的顺序**。例如，删除第k个节点指的是下标为k+1个节点。
## 纯数组实现

```cpp
int m, l[100009] = {-1}, r[100009] = { -1 }, val[100009],len;
void init() {
	l[1] = 0;
	r[0] = 1;
	len = 2;
}
void add(int k, int x) {
	val[len] = x;
	l[len] = k;
	r[len] = r[k];
	l[r[k]] = len;
	r[k] = len;
	len++;
}
void remove(int k) {
	r[l[k]] = r[k];
	l[r[k]] = l[k];
}
void printout() {
	int cur = r[0];
	while (cur != 1) {
		cout << val[cur] << " ";
		cur = r[cur];
	}
}
```
## 结构体实现 (速度较慢)

```cpp
typedef struct node {
	int val, l=-1, r=-1;
};
class doublelink {
public:
	node link[100010];//head:0,tail:100005
	int head = 0, tail = 100005;
	int len=0;
	doublelink() {
		link[head].r = tail;
		link[tail].l = head;
	}

	void insert_right(int x) {
		len++;
		link[len].val = x;
		link[len].r = link[head].r;
		link[len].l = head;
		//right
		link[link[head].r].l = len;
		link[head].r = len;
	}
	void remove(int k) {
		link[link[k].l].r = link[k].r;
		link[link[k].r].l = link[k].l;

	}
	void insert_right_k(int k, int x) {//insert_right_k
		len++;
		link[len].val = x;
		link[len].r = link[k].r;
		link[len].l = k;
		link[link[k].r].l = len;
		link[k].r = len;
	}
	void printout() {
		int cur = link[head].r;
		while (cur != tail) {
			cout << link[cur].val<<" ";
			cur = link[cur].r;
		}
	}
};
```

## 例题
+ [AcWing 827. 双链表](https://www.acwing.com/activity/content/problem/content/864/)

# 字典树
## 例题
+ [835. Trie字符串统计](https://www.acwing.com/problem/content/837/)
## 结构体实现
```cpp
typedef struct node {
	char c;
	int child[130] = { 0 };
	int cnt = 0;
};
int len = 0;
node trie[100009];
void build(string s) {
	int cur = 0;
	for (int i = 0; i < s.size(); i++) {
		if (!trie[cur].child[s[i]]) {
			len++;
			trie[cur].child[s[i]] = len;

			node x;
			x.c = s[i];
			if (i == s.size() - 1)x.cnt++;

			trie[len] = x;
			cur = len;
		}
		else {
			cur = trie[cur].child[s[i]];
			if (i == s.size() - 1) {
				trie[cur].cnt++;
			}
		}
	}
}
void query(string s) {
	int cur = 0;
	for (int i = 0; i < s.size(); i++) {
		if (trie[cur].child[s[i]]) {
			cur = trie[cur].child[s[i]];
			if (i == s.size() - 1)cout << trie[cur].cnt << endl;
		}
		else {
			cout << 0<<endl;
			return;
		}
	}
}
```

