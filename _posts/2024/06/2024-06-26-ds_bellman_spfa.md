---
title: "图论·单源最短路径·Bellman_ford + SPFA"
author: MayL
date: 2024-06-26
categories: ["算法与数据结构", "图论"]
tags: ["图论", "bellman-ford", "spfa", "算法"]
render_with_liquid: false
math: true
description: "本文整理“图论·单源最短路径·Bellman_ford +…”的核心思路、典型问题与实现要点，便于刷题复习和后续查阅。"
---

[无负权回路例题](https://kamacoder.com/problempage.php?pid=1152)
[带负权回路例题](https://kamacoder.com/problempage.php?pid=1153)
# Bellman_ford算法：$O(nm)$
+ ### 单源最短路径
+ ### 存在负权值边
+ ### 检测负权回路：如果第n次dist数组还有变化，说明出现了负权回路
## 核心操作
+ 松弛：对每条边与源点的距离重新计算
```cpp
if (dist[item.v1] != INT_MAX && dist[item.v1] + item.w < dist[item.v2]) {
			dist[item.v2] = dist[item.v1] + item.w;//dist[item.v1]未更新时应该跳过
}
```
# 个人理解
+ # 第k层迭代就是计算路径长度为k的最短路径。
+ # 因为最短路径长度一定为n-1条边，所以只需要迭代n-1次。
## 例如：
+ 第一层只有dist[0]有效，所以只能计算**路径长度为1的最短路径**。
+ 第二次多了与0直接相连的路径，在通过松弛操作，路径长度至少为2，这一次迭代就是考虑**路径长度为2的最短路径**。

## 问题
+ **提前更新的问题**：`dist[item.v2] = dist[item.v1] + item.w`，item.v2在本轮被更新，如果还有别的边连接，则**可能造成路径长度不符合迭代次数的问题**。详见：[96. 城市间货物运输 III](https://kamacoder.com/problempage.php?pid=1154)
+ **解决方法**：备份一个数组`dist_copy`，使用`dist_copy[item.v1]`的数据，**确保来自上一次迭代**且未被更新。
+ **未被限制路径长度不需要考虑这个问题**
## 个人代码

```cpp
using namespace std;
using ll = long long;
int n, m, s, t, v;
struct Edge {
	int v1, v2, w;
};
void solve() {
	cin >> n >> m;
	vector<Edge>edges;
	vector<int>dist(n + 1, INT_MAX); dist[1] = 0;
	while (m--) {
		cin >> s >> t >> v;
		edges.push_back({ s,t,v });
	}
	for (int i = 1; i < n; i++) {
		for (auto item : edges) {
			if (dist[item.v1] != INT_MAX && dist[item.v1] + item.w < dist[item.v2]) {
				dist[item.v2] = dist[item.v1] + item.w;//dist[item.v1]未更新时应该跳过
			}
		}
	}
	if (dist[n] == INT_MAX) {
		cout << "unconnected";
	}
	else {
		cout << dist[n];
	}
}
int main() {
	std::ios::sync_with_stdio(false);
	std::cin.tie(0); std::cout.tie(0);
	solve();
	return 0;
}
```
## 判断负权回路
输出结果前多加上一层循环,改掉判断逻辑即可
```cpp
for (auto item : edges) {
	if (dist[item.v1] != INT_MAX && dist[item.v1] + item.w < dist[item.v2]) {
		cout << "circle";
		return;//return不可以省略
	}
}
```

## 注意事项
+ `dist[item.v1] != INT_MAX`**不可以省略**
+ `vector<Edge>edges;`存储方式既不是邻接矩阵也不是邻接表
---
# 优化版SPFA：$O(KM)-O(NM)$
## 改进思路
+ 检查并松弛所有的边是没必要的，**只有少数结点的dist数组得到了更新**。
+ 使用更新后的dist数组来更新其他数组才是有效的操作。
+ **使用队列存储更新后的结点**，然后**取出来更新其他边**。
---
+ **不再适用于路径长为k**
## 个人代码

```cpp
using namespace std;
using ll = long long;
int n, m, s, t, v;
struct Edge {
	int vex, weight;
};
void solve() {
	cin >> n >> m;
	vector<int>dist(n + 1, INT_MAX); dist[1] = 0;
	vector<list<Edge>>grid(n + 1, list<Edge>());
	queue<Edge>q;
	while (m--) {
		cin >> s >> t >> v;
		grid[s].push_back({ t,v});
	}
	q.push({ 1,0 });
	while (!q.empty()) {
		Edge cur = q.front();
		q.pop();
		for (auto item : grid[cur.vex]) {
			if (dist[cur.vex] + item.weight < dist[item.vex]) {
				dist[item.vex] = dist[cur.vex] + item.weight;
				q.push(item);
			}
		}
	}
	if (dist[n] == INT_MAX) {
		cout << "unconnected";
	}
	else {
		cout << dist[n];
	}
}
int main() {
	std::ios::sync_with_stdio(false);
	std::cin.tie(0); std::cout.tie(0);
	solve();
	return 0;
}
```
## 判断负权回路
**只要一个顶点被加入到队列的次数>=n，一定出现了负权回路**
+ 定义计数数组
```cpp
vector<int>count(n + 1, 0);
```
+ 初始化队列
```cpp
q.push({ 1,0 }); count[1]++;
```
+ 队列操作逻辑更新
```cpp
while (!q.empty()) {
	Edge cur = q.front();
	q.pop();
	if (count[cur.vex] >= n) {//判断加入队列的次数
		cout << "circle";
		return;
	}
	for (auto item : edges[cur.vex]) {
		if (dist[cur.vex] + item.weight < dist[item.vex]) {
			dist[item.vex] = dist[cur.vex] + item.weight;
			q.push(item);
			count[item.vex]++;
		}
	}
}
```

---
# 时间复杂度
+ 朴素版Bellman_ford算法：O(NM)，N是顶点数，M是边数
+ SPFA算法:O(KN)，N是顶点数，K是个不定值，取决于总共加入多少条边到队列中去
	+ 进出队列的时间不计			


---
[本文参考于代码随想录](https://www.programmercarl.com/kamacoder/0094.%E5%9F%8E%E5%B8%82%E9%97%B4%E8%B4%A7%E7%89%A9%E8%BF%90%E8%BE%93I.html#%E6%80%9D%E8%B7%AF)
