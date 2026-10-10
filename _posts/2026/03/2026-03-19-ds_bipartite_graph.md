---
title: "图论·二分图"
author: MayL
date: 2026-03-19
categories: ["算法与数据结构", "图论"]
tags: ["图论", "二分查找", "算法", "学习笔记"]
render_with_liquid: false
math: true
description: "本文整理“图论·二分图”的核心思路、典型问题与实现要点，便于刷题复习和后续查阅。"
---

@[toc]
# 二分图的定义
## 形式化定义

一个**二分图**（又称**二部图**，Bipartite Graph）是一个三元组 $G = (U, V, E)$，其中：

- $U$ 和 $V$ 是两个**非空**且**互不相交**的顶点集合，即 $U \cap V = \emptyset$
- $E$ 是边的集合
- **任意一条边 $e \in E$ 都连接 $U$ 中的一个顶点和 $V$ 中的一个顶点**

## 等价定义

### 染色定义：二分图判定法
图 $G$ 是二分图，当且仅当它可以用 **2种颜色** 对顶点进行染色，使得任意一条边的两个端点颜色不同。

用数学语言表达：存在一个函数 $c: V \rightarrow \{0, 1\}$，使得对于任意边 $(u, v) \in E$，都有 $c(u) \neq c(v)$。

### 奇环定义：由染色定义衍生而来
图 $G$ 是二分图，当且仅当它**不包含奇环**（奇数长度的环）。
即：对于任意整数 $k$，$G$ 中不存在长度为 $2k + 1$ 的环。

### 特例：自环、重边和孤立点
- **自环（self-loop）是不允许存在的**（因为自环的两个端点在同一个集合中）
-  重边不影响二分图存在
- 孤立点可以属于任意一个集合，不影响二分性

## 完全二分图

一种特殊的二分图称为**完全二分图**，记作 $K_{m, n}$，其中：

- $\lvert U\rvert = m$，$\lvert V\rvert = n$
- $U$ 中的**每个顶点都与 $V$ 中的所有顶点相连**
- 边数 $\lvert E\rvert = m \times n$



![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/c718bac6af6a4119a199ef06e5c7cc6a.png){: referrerpolicy="no-referrer" }

<br><br><br><br>

# 二分图的应用
## 染色法判定二分图：能否分为不冲突的两组？
### 例题
+ [860. 染色法判定二分图](https://www.acwing.com/problem/content/description/862/)
### 实现
+ 定义一个colors数组记录颜色，对于visited过的节点判断颜色即可。
```cpp
int n, m;
vector<list<int>>g(150009);
vector<int>visited(150009, 0);
vector<int>colors(150009, 0);
bool dfs(int x) {
	for (auto item : g[x]) {
		if (!visited[item]) {
			visited[item] = 1;
			colors[item] = !colors[x];
			if (!dfs(item)) {
				return false;
			}
		}
		else {
			if (colors[item] == colors[x]) {
				return false;
			}
		}
	}
	return true;
}
void solve() {
	cin >> n >> m;
	for (int i = 1; i <= m; i++) {
		int u, v;
		cin >> u >> v;
		g[u].push_back(v);
		g[v].push_back(u);
	}
	for (int i = 1; i <= n; i++) {
		if (!visited[i]) {
			visited[i] = 1;
			colors[i] = 1;
			if (!dfs(i)) {
				cout << "No";
				return;
			}
		}
	}
	cout << "Yes";
}
```
## 二分图的匹配：寻找一一配对，且配对数最大？
给定一个二分图 $G = (U, V, E)$，图 $G$ 的一个匹配（matching）$M$ 是边集 $E$ 的一个子集，即 $M \subseteq E$，满足：**$M$ 中的任意两条边都没有公共顶点**。
### 匈牙利算法


### 例题
+ [861. 二分图的最大匹配](https://www.acwing.com/problem/content/description/863/)：
### 实现

+ 遍历每一个节点每一条边，尝试为每一个节点找一个匹配节点，如果当前匹配节点已经被之前的节点匹配了，就可以**尝试为之前的节点再找一个新的匹配节点**
+ 注意：**visited数组不是全局的，当前节点和之前节点共用**
```cpp
int n1, n2, m, ans;
vector<list<int>>g(509);
int visited[509];// 防止重边u-v
int fa[509];
bool find(int x) {
	for (auto item : g[x]) {
		if (!visited[item]) {
			visited[item] = 1;
			if (fa[item]) {
				if (find(fa[item])) {
					fa[item] = x;
					return true;
				}
			}
			else {
				fa[item] = x;
				return true;
			}
		}
	}
	return false;
}
void solve() {
	cin >> n1 >> n2 >> m;
	for (int i = 1; i <= m; i++) {
		int u, v;
		cin >> u >> v;
		g[u].push_back(v);
	}
	for (int i = 1; i <= n1; i++) {
		memset(visited, 0, sizeof visited);
		if (find(i)) {
			ans++;
		}
	}
	cout << ans;
}
```
