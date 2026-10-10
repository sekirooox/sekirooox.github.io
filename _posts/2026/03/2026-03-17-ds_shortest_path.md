---
title: "图论·最短路径问题"
author: MayL
date: 2026-03-17
categories: ["算法与数据结构", "图论"]
tags: ["图论", "算法", "学习笔记"]
render_with_liquid: false
math: true
description: "本文整理“图论·最短路径问题”的核心思路、典型问题与实现要点，便于刷题复习和后续查阅。"
---


@[toc]
# 最短路径问题的定义：搜索，单源和多源
+ 搜索中的最短路
+ 单源最短路问题
+ 多源最短路问题

# 搜索问题
参考：[图论·搜索最短路径](https://blog.csdn.net/2301_80132162/article/details/140008965)
+ BFS：权值为1情况下的最短路径
+ A*：权值不为1的情况下的最短路径，启发式算法

## 应用
### 最短路径的路径总数
+ P1144 最短路计数
+ 有点类似边带权，深入理解dj算法。

# 单源最短路径
参考：[图论·单源最短路径·Bellman_ford算法](https://blog.csdn.net/2301_80132162/article/details/139981461)
## Dijsktra算法
+ 三部曲：**贪心选点**，**加入集合**，**更新距离**
### 例题
+ [849. Dijkstra求最短路 I](https://www.acwing.com/activity/content/problem/content/919/)
+ [850. Dijkstra求最短路 II](https://www.acwing.com/problem/content/description/852/)
### 朴素实现：$O(n^2)$
```cpp
int n, m, g[509][509], visited[509], dist[509];
int dj() {
	dist[1] = 0;
	for (int i = 1; i <= n; i++) {
		int idx = -1, temp = MAX_VALUE;
		for (int j = 1; j <= n; j++) {
			if (!visited[j] && dist[j] < temp) {
				temp = dist[j];
				idx = j;
			}
		}
		if (idx == -1)break;
		visited[idx] = 1;
		for (int j = 1; j <= n; j++) {
			if (!visited[j] && g[idx][j] != MAX_VALUE) {
				dist[j] = min(dist[j], dist[idx] + g[idx][j]);
			}
		}
	}
	return dist[n] == MAX_VALUE ? -1 : dist[n];
}
```
### 堆优化版本：$O(mlogn)$
+ 朴素实现的问题：每次都需要**手动遍历寻找dist[i]最小的节点加入数组**，每一次都要遍历邻接矩阵中所有终点的边(**存在无效遍历**)。
+ **使用堆来获得dist[i]的数组**，使用**邻接表来优化邻接矩阵的存储**(减少无效边的遍历)。
+ 堆中存储当前加入节点和**离起点的距离**。

#### 典型实现错误：每次放入堆时就更新visited数组
+ **这样堆就没有用了**，每次选择的是BFS遍历得到的结点。
```cpp
if(!visited[cur.first]){
	q.push(...);
	visited[cur.first]=1;
}
```
#### 有问题的写法：
+ 允许其他结点更新，但是这些结点的**dist值永远为最优值**。
+ 而且始终加入一些不可能最优的结点，**导致累赘(虽然不会错误)**。
```cpp
for (auto item : g[cur.first]) {
	if (f[item.first] <= mid) {
		dist[item.first] = min(dist[item.first],
			dist[cur.first] + item.second
			);
		q.push({ item.first,dist[item.first] });
	}
}
```


#### 时间复杂度分析
时间复杂度分析：更新邻接矩阵所有边，时间复杂度为$O(m)$，然后不需要遍历所有节点，通过堆来加入节点，堆中元素至多为m个(将所有相邻边的节点加入)，因此取出和插入操作复杂度为$O(logm)=O(logn)$，因此总共复杂度为$O(mlogn)$
#### 链表前向星
+ 额外定义w数组，**w[i]表示存储与i位置的节点(**存储于i != 节点i)的**边权值**。

```cpp
int n, m;
int h[150009],node[150009],w[150009],nxt[150009], len = 0,dist[150009],visited[150009];
class cmp {
public:
	bool operator()(const pair<int,int> &a ,const pair<int,int>&b) {
		return a.second > b.second;
	}
};
priority_queue<pair<int,int>, vector<pair<int,int>>, cmp>q;
void insert(int x, int y, int z) {
	len++;
	node[len] = y;
	w[len] = z;
	nxt[len] = h[x];
	h[x] = len;
}
int dj() {
	dist[1] = 0;
	q.push(make_pair(1,0));
	while (q.size()) {
		pair<int,int> cur = q.top();
		q.pop();
		if (visited[cur.first])continue;
		visited[cur.first] = 1;
		for (int i = h[cur.first]; i != -1; i = nxt[i]) {
			int v = node[i];// node's number
			int weight = w[i];
			if (!visited[v]&& dist[cur.first] + weight <dist[v]) {
				dist[v] = dist[cur.first] + weight;
				q.push(make_pair(v, dist[v]));
			}
		}
	}
	return dist[n] == MAX_VALUE ? -1 : dist[n];

}
```
#### STL链表实现
```cpp
int n, m;
vector<list<pair<int,int>>>g(1500009);
vector<int>visited(1500009, 0);
vector<int>dist(1500009, MAX_VALUE);
class cmp {
public:
	bool operator()(const pair<int,int>&a, const pair<int,int>&b) {
		return a.second > b.second;//small top heap
	}
};
priority_queue<pair<int, int>, vector<pair<int, int>>, cmp>q;
int dj() {
	dist[1] = 0;
	q.push({ 1,0 });// node, dist
	while (q.size()) {
		auto cur = q.top();
		q.pop();
		if (visited[cur.first]) {
			continue;
		}
		visited[cur.first] = 1;

		for (auto item : g[cur.first]) {
			if (!visited[item.first]&&
				dist[cur.first] + item.second < dist[item.first]
				) {
				dist[item.first] = dist[cur.first] + item.second;
				q.push({ item.first,dist[item.first] });
			}
		}
	}

	return dist[n] == MAX_VALUE ? -1:dist[n];
}
```

#### 失效情况：边权值为负数
简要证明思路和理解如下：
+ 贪心假设：加入到当前集合中的节点都是离起点的距离最短。
+ 情况分析：假设有一个边的权值为负数，但是**它还没有被加入到当前集合中**(例如，**离当前集合中所有点在图上的"距离"相对较远**)。
+ 失效案例：**假设该边的权值为-无穷**，加入到当前集合中可以**使得当前集合中所有点到出发点的距离更新为负无穷**，贪心假设不成立(**这说明当前集合中所有点到出发点的距离不一定最短**)，矛盾！

## Bellman_ford算法
参考：[图论·单源最短路径·Bellman_ford算法](https://blog.csdn.net/2301_80132162/article/details/139981461)
+ 松弛操作：`dist[j]=dist[i]+graph[i][j]`
+ 相当于动态规划，**dist[j]的距离减少**，但是**到dist[j]的路径长度增加1**，引入中间节点减少距离。
### 用法：负权重图的最短路问题 和 负环路
+ 可以用于负权重图的单源最短路
+ 可以用于**检测是否存在负环路**：如果第n+1次更新有效的话，那么**图中一定存在负环路**。
### 例题
+ [853. 有边数限制的最短路](https://www.acwing.com/problem/content/855/)：有边数限制的含负权重图==只能使用BF算法
+ [图论·单源最短路径·Bellman_ford算法](https://www.acwing.com/problem/content/description/854/)：检测是否存在负回路。

### 朴素实现：$O(nm)$
+ 遍历每一个边进行松弛即可
+ 为了控制最短距离中路径的长度，需要定义一个二维数组，**确保使用的是之前的数据**。
+ 注意`dist[i][j]`**表示起点1**到点i**长度<=j**的路径所需要的最短距离。
```cpp
int n, m, k;
typedef struct node {
	int x, y, z;
};
node edges[10009];
int dist[509][509];
void bf() {
	for (int i = 0; i <= k; i++)dist[1][i] = 0;
	for (int i = 1; i <= k; i++) {
		for (int j = 1; j <= m; j++) {
			int x = edges[j].x, y = edges[j].y, z = edges[j].z;
// 避免路径长度超过限制:例如 i=1时, x,y y,z 按顺序加入, 此时dist[z]的长度最短,但是不符合dp数组的定义(路径长度超过1). 
			dist[y][i] = min(dist[y][i], dist[x][i - 1] + z);
		}

	}
	if (dist[n][k] > (MAX_VALUE / 2))cout << "impossible";
	else cout << dist[n][k];
}
void solve() {
	cin >> n >> m >> k;
	memset(dist, 0x3F, sizeof dist);
	for (int i = 1; i <= m; i++) {
		int a, b, c;
		cin >> a >> b >> c;
		edges[i] = { a,b,c };
	}
	bf();
}
```
### SPFA：$O(m)-O(nm)$
+ 优化思路：动态规划的更新方法中存在一些无效操作：**例如如果dist[x][i-1]在第i-1轮中没有更新，那么这一步更新操作可以省略**。
+ 我们可以**只记录更新过后的节点**，将其加入到队列中，确保**所有的更新操作都是高效的**。
+ 注意：队列中的元素表示**待处理的节点**。如果处理之前又被更新，既要**避免重复加入**，又要**确保及时更新**。

```cpp
int n, m;
vector < list<pair<int, int>>>g(100009);// node, weight
queue<int>q;
int visited[100009],dist[100009];
void spfa() {
	dist[1] = 0;
	q.push(1);
	while (q.size()) {
		int cur = q.front();
		q.pop();
		// 允许重复更新
		visited[cur] = 0;
		for (auto item : g[cur]) {
			if (dist[cur] + item.second < dist[item.first]) {
				// 更新当前节点
				dist[item.first] = dist[cur] + item.second;
				// 更新队列中存在当前节点, 不需要重复更新. 
				if (!visited[item.first]) {
					q.push(item.first);
				}
			}
		}
	}
	if (dist[n] > (MAX_VALUE / 2)) {
		cout << "impossible";
	}
	else cout << dist[n];
}
```
#### SPFA的应用：检测负权回路
+ 使用cnt数组，`cnt[i]`表示从起点到i节点最短路径的长度，如果该长度大于等于结点数n，则说明肯定出现负环（**有负数回路才会导致一直加入节点**）。
![负回路无限循环的原理](https://i-blog.csdnimg.cn/direct/a173afba464e41faa7af5ae7ffc8d53b.png){: referrerpolicy="no-referrer" }
+ 问题：图不一定联通
+ 解决方案：加入虚拟源节点，假设源节点为0，令其与所有边的节点边权重为0，运行SPFA算法即可。

```cpp
for(int i=1;i<=n;i++){
	g[0].push_back({i,0});
}
dist[0]=0;
q.push(0);
visited[0]=1;
//等价于：这个会快一点。
for (int i = 1; i <= n; i++) {
		q.push(i);
		visited[i] = 1;
	}
```

```cpp
int n, m;
vector<list<pair<int, int>>>g(2009);
vector<int>dist(2009, MAX_VALUE);
vector<int>cnt(2009, 0);
vector<int>visited(2009, 0);
void bf() {
	queue<int>q;
	for (int i = 1; i <= n; i++) {
		q.push(i);
		visited[i] = 1;
	}
	while (q.size()) {
		int cur = q.front();
		q.pop();
		visited[cur] = 0;
		for (auto item : g[cur]) {
			if (dist[cur] + item.second < dist[item.first]) {
				dist[item.first] = dist[cur] + item.second;
				cnt[item.first] = cnt[cur] + 1;
				if (cnt[item.first]>=n) {
					cout << "Yes";
					return;
				}
				if (!visited[item.first]) {
					visited[item.first] = 1;
					q.push(item.first);
				}
			}
		}
	}
	cout << "No";
}
```

#### SPFA不适用于负权数回路的图


# 多源最短路径
## Johoson算法：$O(nmlogn)$
+ 循环n次dj算法。
## Floyd算法：$O(n^3)$

参考：[图论·多源最短路径Floyd&dijsktra](https://blog.csdn.net/2301_80132162/article/details/139984637?ops_request_misc=%257B%2522request%255Fid%2522%253A%25223b222656925a45171cfd68ee75f05672%2522%252C%2522scm%2522%253A%252220140713.130102334.pc%255Fblog.%2522%257D&request_id=3b222656925a45171cfd68ee75f05672&biz_id=0&utm_medium=distribute.pc_search_result.none-task-blog-2~blog~first_rank_ecpm_v1~rank_v31_ecpm-1-139984637-null-null.nonecase&utm_term=Floyd&spm=1018.2226.3001.4450)

### 例题
+ [AcWing 854. Floyd求最短路
](https://www.acwing.com/problem/content/856/)
### 实现

+ 子问题：d[i][j]表示i到j的最短路径，于i-k,k-j的最短路径有关
+ 进行状态压缩，**删去d[i][j][k]中k这一维度**。



```cpp
void solve() {
	cin >> n >> m >> k;
	memset(g, 0x3f, sizeof g);
	for (int i = 1; i <= n; i++)g[i][i] = 0;
	while (m--) {
		int x, y, z;
		cin >> x >> y >> z;
		g[x][y] = min(g[x][y], z);
	}
	for (int k = 1; k <= n; k++) {
		for (int i = 1; i <= n; i++) {
			for (int j = 1; j <= n; j++) {
				g[i][j] = min(g[i][j], g[i][k] + g[k][j]);
			}
		}
	}

	while (k--) {
		int x, y;
		cin >> x >> y;
		if (g[x][y] > (MAX_VALUE / 2)) {
			cout << "impossible" << endl;
		}
		else cout << g[x][y] << endl;
	}
}
```

