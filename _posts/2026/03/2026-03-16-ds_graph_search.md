---
title: "图论·树或图的DFS和BFS搜索"
author: MayL
date: 2026-03-16
categories: ["算法与数据结构", "图论"]
tags: ["图论", "dfs", "bfs", "算法"]
render_with_liquid: false
description: "本文整理“图论·树或图的DFS和BFS搜索”的核心思路、典型问题与实现要点，便于刷题复习和后续查阅。"
---

# DFS
## 例题
+ [846. 树的重心](https://www.acwing.com/problem/content/description/848/)：可以使用**动态规划的思想进行优化**。

```cpp
int n,ans=INT_MAX;
int h[100009], v[200009], nxt[200009], len = 0, visited[100009];
// 返回当前节点的连通图数量
int dfs(int cur) {
	visited[cur] = 1;
	int res = 0, sum = 0;
	for (int i = h[cur]; i != -1; i = nxt[i]) {
		int node = v[i];
		if (!visited[node]) {
			int tmp = dfs(node);
			res = max(res, tmp);
			sum += tmp;
		}
	}
	res = max(res, n - sum - 1);
	ans = min(ans, res);
	//　根据动态规划的思想考虑当前节点的连通图节点数量。
	return sum + 1;
}
void insert(int x, int y) {
	len++;
	v[len] = y;
	nxt[len] = h[x];
	h[x] = len;
}
void solve() {
	cin >> n;
	memset(h, -1, sizeof h);
	for (int i = 1; i <= n - 1; i++) {
		int a, b;
		cin >> a >> b;
		insert(a, b);
		insert(b, a);
	}
	dfs(1);
	cout << ans;
}

```

# BFS
## 例题
+ [847. 图中点的层次](https://www.acwing.com/problem/content/849/)：注意h和v数组的含义就行。

```cpp
void bfs() {
	q.push(1);
	visited[1] = 1;
	while (q.size()) {
		int cur = q.front();
		if (cur == n) {
			cout << dist[cur];
			return;
		}
		q.pop();
		for (int i = h[cur]; i != -1; i = nxt[i]) {
			int node = v[i];
			if (!visited[node]) {
				visited[node] = 1;
				dist[node] = dist[cur] + 1;
				q.push(node);
			}
		}
	}
	cout << -1;
}
```

