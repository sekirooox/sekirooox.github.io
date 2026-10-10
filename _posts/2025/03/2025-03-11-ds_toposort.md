---
title: "图论·拓扑排序"
author: MayL
date: 2025-03-11
categories: ["算法与数据结构", "图论"]
tags: ["图论", "拓扑排序", "算法", "学习笔记"]
render_with_liquid: false
math: true
description: "本文整理“图论·拓扑排序”的核心思路、典型问题与实现要点，便于刷题复习和后续查阅。"
---

# 拓扑排序
## 用法：用于符合事件先后的排序结果 & 检查DAG中是否有环
+ 适用于有限无环图DAG
+ 获得事件的先后排序结果：拓扑序列中，XYZ意味着：**X的出现顺序先于Y和Z**
+ 检查**有向图是否连通/有环**：如果有环，则**拓扑排序算法失效**，**拓扑序列长度一定小于节点数**。
## 核心操作
+ 统计度数，对于度为0的点作为起始点，添加度为0的点作为遍历
+ 如何验证有环？注意不建议直接模拟，如果出现环这起始点的度一定不为0，肯定会少遍历一些点！这样遍历得到的点和图中的点数量不一致
+ 使用BFS作为搜索媒介

### 使用`vector<list<int>>`的实现
```cpp
#include<bits/stdc++.h>
#define MAX_VALUE 10009
using ll = long long;
using namespace std;
int n, m, s, t;
vector<list<int>>graph(100006,list<int>());
vector<int>indegrees(100006, 0);
vector<int>res;
void solve() {
	cin >> n >> m;
	while (m--) {
		cin >> s >> t;
		graph[s].push_back(t);
		indegrees[t]++;
	}
	queue<int>q;
	for (int i = 0; i <= n-1; i++) {
		if (!indegrees[i]) {
			q.push(i);
		}
	}
	while (!q.empty()) {
		int cur = q.front();
		q.pop();
		res.push_back(cur);

		for (auto item : graph[cur]) {
			if (--indegrees[item]==0) {
				q.push(item);
			}

		}
	}
	if (res.size() == n) {
		for (int i = 0; i < n - 1; i++) cout << res[i] << " ";
		cout << res[n - 1];
	}
	else cout << -1 << endl;

}
signed main() {
	std::ios::sync_with_stdio(false);
	std::cin.tie(0);
	std::cout.tie(0);
	solve();
}
```

### 链表前向星实现
+ `res`数组用于**记录拓扑序列**。
```cpp
void bfs() {
	for (int i = 1; i <= n; i++) {
		if (!d[i]) {
			q.push(i);
		}
	}
	while (q.size()) {
		int cur = q.front();
		reslen++;
		res[reslen] = cur;
		q.pop();
		for (int i = h[cur]; i != -1; i = nxt[i]) {
			int node = v[i];
			d[node]--;
			if (!d[node]) {
				q.push(node);
			}
		}
	}
	if (reslen != n)cout << -1;
	else {
		for (int i = 1; i <= n; i++) {
			cout << res[i] << " ";
		}
	}
}
```

---
<br><br><br><br><br><br><br><br>
# 例题
+ P4017 最大食物链计数：拓扑排序，**时间复杂度：$O(n+e)$**，DFS理论上也可以使用，但是只能过前两个用例。
```cpp
int n, m,a,b,ans=0;
vector<int>indegrees(5009, 0);
vector<list<int>>graph(5009, list<int>());
vector<int>producers;
vector<int>res(5009, 0);
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
			res[i] = 1;//1条食物链
		}
	}
	queue<int>q;
	for (auto producer : producers) {
		q.push(producer);
	}

	while (!q.empty()) {
		int cur = q.front();
		q.pop();
		//cout << "cur:" << cur << endl;
		if (!graph[cur].size()) {
			ans = (ans + res[cur]) % mod;
		}
		for (auto item : graph[cur]) {
			if (!--indegrees[item]) {
				q.push(item);
			}
			res[item] = (res[item] + res[cur])% mod;
			//cout << "item:" << item << " res[item]:" << res[item] << endl;

		}
		//for (int i = 1; i <= n; i++) {
		//	cout << res[i] << " ";
		//}
		//cout << endl;
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

