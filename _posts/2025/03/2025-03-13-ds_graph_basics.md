---
title: "图论·基本应用"
author: MayL
date: 2025-03-13
categories: ["算法与数据结构", "图论"]
tags: ["图论", "算法", "学习笔记"]
render_with_liquid: false
math: true
description: "本文整理“图论·基本应用”的核心思路、典型问题与实现要点，便于刷题复习和后续查阅。"
---

# 图论的基本技巧总结(未完待续)


# P3916 图的遍历

## 题目描述

给出 $N$ 个点，$M$ 条边的有向图，对于每个点 $v$，求 $A(v)$ 表示从点 $v$ 出发，能到达的编号最大的点。

## 输入格式

第 $1$ 行 $2$ 个整数 $N,M$，表示点数和边数。

接下来 $M$ 行，每行 $2$ 个整数 $U_i,V_i$，表示边 $(U_i,V_i)$。点用 $1,2,\dots,N$ 编号。

## 输出格式

一行 $N$ 个整数 $A(1),A(2),\dots,A(N)$。

## 输入输出样例 #1

### 输入 #1

```
4 3
1 2
2 4
4 3
```

### 输出 #1

```
4 4 3 4
```

## 说明/提示

- 对于 $60\%$ 的数据，$1 \leq N,M \leq 10^3$。
- 对于 $100\%$ 的数据，$1 \leq N,M \leq 10^5$。

# 个人解法
+ ## 反向建边+BFS
```cpp
#include<bits/stdc++.h>
#define MAX_VALUE 10000009
using ll = long long;
using namespace std;
int n, m, x, y;
vector<list<int>>graph(100009, list<int>());
vector<int>visited(100009, 0);
vector<int>A(100009, 0);
void bfs(int start) {
	queue<int>q;
	q.push(start);
	visited[start] = 1;

	if (!A[start]) {
		A[start] = start;//没有比它编号大的
	}

	while (!q.empty()) {
		int cur = q.front();
		q.pop();
		for (auto item : graph[cur]) {
			if (!visited[item]) {
				q.push(item);
				visited[item] = 1;
				A[item] = start;
			}
		}
	}
}
void solve() {
	cin >> n >> m;
	while (m--) {
		cin >> x >> y;
		graph[y].push_back(x);//反向建图
	}
	for (int i = n; i >= 1; i--) {
		if (!visited[i]) {
			bfs(i);
		}
	}

	for (int i = 1; i <= n; i++) {
		cout << A[i] << " ";
	}
}



signed main() {
	std::ios::sync_with_stdio(false);
	std::cin.tie(0);
	std::cout.tie(0);
	solve();
}
```
# P1113 杂务

## 题目描述

John 的农场在给奶牛挤奶前有很多杂务要完成，每一项杂务都需要一定的时间来完成它。比如：他们要将奶牛集合起来，将他们赶进牛棚，为奶牛清洗乳房以及一些其它工作。尽早将所有杂务完成是必要的，因为这样才有更多时间挤出更多的牛奶。

当然，有些杂务必须在另一些杂务完成的情况下才能进行。比如：只有将奶牛赶进牛棚才能开始为它清洗乳房，还有在未给奶牛清洗乳房之前不能挤奶。我们把这些工作称为完成本项工作的准备工作。至少有一项杂务不要求有准备工作，这个可以最早着手完成的工作，标记为杂务 $1$。

John 有需要完成的 $n$ 个杂务的清单，并且这份清单是有一定顺序的，杂务 $k\ (k>1)$ 的准备工作只可能在杂务 $1$ 至 $k-1$ 中。

写一个程序依次读入每个杂务的工作说明。计算出所有杂务都被完成的最短时间。当然互相没有关系的杂务可以同时工作，并且，你可以假定 John 的农场有足够多的工人来同时完成任意多项任务。

## 输入格式

第1行：一个整数 $n\ (3 \le n \le 10{,}000)$，必须完成的杂务的数目；

第 $2$ 至 $n+1$ 行，每行有一些用空格隔开的整数，分别表示：

- 工作序号（保证在输入文件中是从 $1$ 到 $n$ 有序递增的）；
- 完成工作所需要的时间 $len\ (1 \le len \le 100)$；
- 一些必须完成的准备工作，总数不超过 $100$ 个，由一个数字 $0$ 结束。有些杂务没有需要准备的工作只描述一个单独的 $0$。

保证整个输入文件中不会出现多余的空格。

## 输出格式

一个整数，表示完成所有杂务所需的最短时间。

## 输入输出样例 #1

### 输入 #1

```
7
1 5 0
2 2 1 0
3 3 2 0
4 6 1 0
5 1 2 4 0
6 8 2 4 0
7 4 3 5 6 0
```

### 输出 #1

```
23
```
# 1解法：记忆化搜索+逆向
```cpp
#include<bits/stdc++.h>
#define MAX_VALUE 10000009
using ll = long long;
using namespace std;
int n,a,b,c;
vector<int>w(10009,0);
vector<int>visited(10009,0);
vector<int>mem(10009, 0);

vector<list<int>>graph(10009, list<int>());
int dfs(int start) {
	if (!graph[start].size()) {
		mem[start] = w[start];
		return mem[start];
	}
	if (mem[start]) {
		return mem[start];//记忆化搜索
	}
	int ans = INT_MIN;
	for (auto item : graph[start]) {
		if (!visited[item]) {
			visited[item] = 1;
			ans=max(dfs(item)+w[start],ans);
			visited[item] = 0;
		}
	}
	mem[start] = ans;
	return mem[start];
}
void solve() {
	cin >> n;
	for (int i = 1; i <= n; i++) {
		cin >> a >> b;
		w[a] = b;//权重
		while (true) {
			cin >> c;
			if (!c)break;
			graph[a].push_back(c);//c->a 反向a->c
		}
	}
	int ans = INT_MIN;
	for (int i = n; i >= 1; i--) {
		if (!mem[i]) {
			ans = max(ans, dfs(i));
			//cout << "i==" << i << " ans==" << ans << endl;
		}
		//else cout << "mem[" << i << "]" << endl;

	}
	//for (int i = 1; i <= n; i++) {
	//	cout << mem[i] << " ";
	//}
	cout << ans;

}



signed main() {
	std::ios::sync_with_stdio(false);
	std::cin.tie(0);
	std::cout.tie(0);
	solve();
}
```
# 解法2：拓扑排序+模拟
```cpp
#include<bits/stdc++.h>
#define MAX_VALUE 10000009
using ll = long long;
using namespace std;
int n,a,b,c;
vector<int>w(10009,0);
vector<int>indegrees(10009, 0);
vector<list<int>>graph(10009, list<int>());
vector<int>res(10009, 0);
void solve() {
	cin >> n;
	for (int i = 1; i <= n; i++) {
		cin >> a >> b;
		w[a] = b;//权重
		while (true) {
			cin >> c;
			if (!c)break;
			graph[c].push_back(a);//c->a 反向a->c
			indegrees[a]++;
		}
	}
	queue<int>q;
	for (int i = 1; i <= n; i++) {
		if (!indegrees[i])q.push(i);
	}
	while (!q.empty()) {
		int cur = q.front();
		q.pop();
		for (auto item : graph[cur]) {
			if (--indegrees[item] == 0) {
				q.push(item);
			}
			res[item] = max(res[item], w[cur]+res[cur]);
		}
	}
	int ans = INT_MIN;
	for (int i = 1; i <= n; i++) {
		ans = max(ans, res[i]+w[i]);
		//cout << res[i] << " ";
	}
	cout << ans;
}



signed main() {
	std::ios::sync_with_stdio(false);
	std::cin.tie(0);
	std::cout.tie(0);
	solve();
}
```
# P4017 最大食物链计数

## 题目背景

你知道食物链吗？Delia 生物考试的时候，数食物链条数的题目全都错了，因为她总是重复数了几条或漏掉了几条。于是她来就来求助你，然而你也不会啊！写一个程序来帮帮她吧。

## 题目描述

给你一个食物网，你要求出这个食物网中最大食物链的数量。

（这里的“最大食物链”，指的是**生物学意义上的食物链**，即**最左端是不会捕食其他生物的生产者，最右端是不会被其他生物捕食的消费者**。）

Delia 非常急，所以你只有 $1$ 秒的时间。

由于这个结果可能过大，你只需要输出总数模上 $80112002$ 的结果。

## 输入格式

第一行，两个正整数 $n、m$，表示生物种类 $n$ 和吃与被吃的关系数 $m$。

接下来 $m$ 行，每行两个正整数，表示被吃的生物A和吃A的生物B。

## 输出格式

一行一个整数，为最大食物链数量模上 $80112002$ 的结果。

## 输入输出样例 #1

### 输入 #1

```
5 7
1 2
1 3
2 3
3 5
2 5
4 5
3 4
```

### 输出 #1

```
5
```

## 说明/提示

各测试点满足以下约定：

 ![](https://i-blog.csdnimg.cn/img_convert/8a0130ac217c3c9681905b9c1d4f4fa7.png){: referrerpolicy="no-referrer" }

【补充说明】

数据中不会出现环，满足生物学的要求。（感谢 @AKEE ）

# 解法1：DFS(超时)

```cpp
#include "f.h"
#define MAX_VALUE 10000009
#define mod 80112002
using ll = long long;
using namespace std;
int n, m,a,b,ans=0;
vector<int>indegrees(5009, 0);
vector<list<int>>graph(5009, list<int>());
vector<int>producers;
void dfs(int start,vector<int>visited) {
	//cout << "current node:" << start << endl;
	if (!graph[start].size()) {
		ans=(ans+1)% mod;
		//cout << endl;
		return;
	}
	for (auto item : graph[start]) {
		if (!visited[item]) {
			visited[item] = 1;
			dfs(item,visited);
			visited[item] = 0;
		}
	}
}
void solve() {
	cin >> n >> m;
	while (m--) {
		cin >> a >> b;
		graph[a].push_back(b);
		indegrees[b]++;
	}
	for (int i = 1; i <= n; i++) {
		if (!indegrees[i]) {
			producers.push_back(i);
		}
	}
	for (auto producer : producers) {
		if (!graph[producer].size()) {// no consumer
			continue;
		}
		vector<int>visited(5009, 0);
		visited[producer] = 1;
		dfs(producer, visited);
	}
	cout << ans;
}
signed main() {
	std::ios::sync_with_stdio(false);
	std::cin.tie(0);
	std::cout.tie(0);
	solve();
}
```
