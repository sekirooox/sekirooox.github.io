---
title: "图论·dijkstra+优化版"
author: MayL
date: 2024-06-19
categories: ["算法与数据结构", "图论"]
tags: ["图论", "dijkstra", "算法", "学习笔记"]
render_with_liquid: false
description: "本文整理“图论·dijkstra+优化版”的核心思路、典型问题与实现要点，便于刷题复习和后续查阅。"
---

[例题出处](https://kamacoder.com/problempage.php?pid=1047)
# 朴素版Dijkstra
## 适用
+ 单源最短路径
+ **没有负权值的边**
+ 稠密图:**顶点数<10e+5**
+ 时间复杂度O(n^2)
## 核心思想:贪心
+ 每一次选择**距离源点最近**的点，达成局部最优，最后达成全局最优，即终点距离源点最近
## 核心操作
+ **选点**：选择距离源点最近的点
+ **标记**：标记访问的点(visited数组)
+ **更新**：更新到源点的距离(minDist数组)
## 个人代码
特别注意的点：
+ cur**初始化为0/1**，不然导致越界(与Prim算法不一致)
+ grid数组和minDist数组初始化为INT_MAX，**grid数组存储的是有向图**
```cpp
using namespace std;
using ll = long long;
int n, m, s, e, v;
void solve() {
	cin >> n >> m;
	vector<vector<int>>grid(n + 1, vector<int>(n + 1, INT_MAX));
	vector<int>visited(n + 1, false);
	vector<int>minDist(n + 1, INT_MAX);
	minDist[1] = 0;//初始化，优先选源点加入
	while (m--) {
		cin >> s >> e >> v;
		grid[s][e] = v;
	}
	for (int i = 1; i <= n; i++) {
		int minVal = INT_MAX;
		int cur = 1;//int cur=-1;cur会越界!
		for (int j = 1; j <= n; j++) {
			if (!visited[j] && minDist[j] < minVal) {
				minVal = minDist[j];
				cur = j;
			 }
		}
		visited[cur] = true;
		for (int j = 1; j <= n; j++) {
			if (!visited[j] && grid[cur][j] != INT_MAX && grid[cur][j] + minDist[cur] < minDist[j]) {
				//1.结点未加入到集合	2.存在边	3.距离更小
				minDist[j] = grid[cur][j] + minDist[cur];
			}
		}
		/*cout << "select" << cur << endl;	//调试的代码
		for (int j = 1; j <= n; j++) {
			cout << minDist[j] << " ";
		}
		cout << endl;*/
	}
	if (minDist[n] != INT_MAX) {
		cout << minDist[n];
	}
	else {
		cout << -1;
	}
}
int main() {
	std::ios::sync_with_stdio(false);
	std::cin.tie(0); std::cout.tie(0);
	solve();
	return 0;
}
```
---
# 优化版dijsktra算法
## 适用：
+ 单源最短路径
+ 没有负权值的边
+ **稀疏图:顶点>=10e+5**
+ 时间复杂度:O(nlogn)
## 核心操作
+ 选边：使用小顶堆排序，**排序对象是与源点的距离**，确保每次都是选择最近的一条边(因为一个顶点的邻接表里可能重复添加多条边)
+ 标记：visited数组标记，防止重复添加
+ 添加边：遍历邻接矩阵，注意这条代码语句`q.push(Edge(item.vex,dist[item.vex]));`
## 个人代码
特别注意的点：
+ 仍然需要visited数组来避免多次遍历一个顶点的所在边
+ 邻接表存储的**不仅需要结点，还需要边的权值**
+ **堆存储的边的权值都是与源点的距离**
```cpp
using namespace std;
using ll = long long;
int n, m, s, e, v;
struct Edge {
	int vex;
	int weight;
	Edge(int v,int w):vex(v),weight(w) {

	}
};
class cmp {
public:
	bool operator()(Edge a,Edge b) {
		return a.weight > b.weight;
	}
};
void solve() {
	cin >> n >> m;
	vector<list<Edge>>grid(n + 1, list<Edge>());
	vector<bool>visited(n + 1, false);
	vector<int>dist(n + 1, INT_MAX);
	dist[1] = 0;
	priority_queue < Edge, vector<Edge>,cmp>q;
	while (m--) {
		cin >> s >> e >> v;
		grid[s].push_back(Edge(e,v));
	}
	q.push(Edge(1, 0));
	while (!q.empty()) {
		Edge cur= q.top();
		q.pop();
		if (visited[cur.vex]) {
			continue;
		}//防止重复更新

		visited[cur.vex] = true;

		for (auto item : grid[cur.vex]) {
			if (!visited[item.vex] && dist[cur.vex] + item.weight < dist[item.vex]) {
				dist[item.vex] = dist[cur.vex] + item.weight;
				q.push(Edge(item.vex,dist[item.vex]));//注意堆存储的是距离源点最近的边
				//写成item.vex,item.weight是错误的！！！
			}
		}
	}
	cout << (dist[n] == INT_MAX ? -1 : dist[n]);

}
int main() {
	std::ios::sync_with_stdio(false);
	std::cin.tie(0); std::cout.tie(0);
	solve();
	return 0;
}
```
[思路源自代码随想录](https://www.programmercarl.com/kamacoder/0047.%E5%8F%82%E4%BC%9Adijkstra%E5%A0%86.html#%E6%80%9D%E8%B7%AF)
# 存储模式小结
+ 对顶点操作用邻接矩阵
+ 对边操作用邻接多重表
---
# 第二次复习小结
## 朴素板易错点
+ cur数组的初始化
+ 邻接矩阵有效边问题，`grid[cur][j] != INT_MAX`忘写这段代码
## 优化板易错点
+ **小顶堆对边与源点距离进行排序，而不是简单的对边排序**
+ 结构体定义赘余
