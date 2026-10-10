---
title: "图论Day1·搜索"
author: MayL
date: 2025-03-09
categories: ["算法与数据结构", "图论"]
tags: ["图论", "算法", "学习笔记"]
render_with_liquid: false
description: "本文整理“图论Day1·搜索”的核心思路、典型问题与实现要点，便于刷题复习和后续查阅。"
---

# 98.所有可以到达的路径
[链接如下](https://kamacoder.com/problempage.php?pid=1170)
```cpp
#include "bits/stdc++.h"
#define MAX_VALUE 10000009
using ll = long long;
using namespace std;
int n, m, s, t,ans=0;
vector<list<int>>graph(109,list<int>());
vector<int>visited(109, false);
vector<int>temp;
void dfs(int start) {
	if (start == n) {
		for (int i = 0; i < temp.size(); i++) {
			if (i != temp.size() - 1) {
				cout << temp[i]<<" ";
			}
			else {
				cout << temp[i];
			}
		}
		cout << endl;
		ans++;
	}

	for (auto item : graph[start]) {
		if (!visited[item]) {
			visited[item] = true;
			temp.push_back(item);
			dfs(item);
			visited[item] = false;
			temp.pop_back();
		}
	}
}
void solve() {
	cin >> n >> m;
	while (m--) {
		cin >> s >> t;
		graph[s].push_back(t);
	}
	visited[1] = false;//防止有环遍历自身,这题不需要
	temp.push_back(1);
	dfs(1);
	if (ans == 0) {
		cout << -1;
	}

}
signed main() {
	std::ios::sync_with_stdio(false);
	std::cin.tie(0);
	std::cout.tie(0);
	solve();
}
```

# 99.岛屿数量
[链接如下](https://kamacoder.com/problempage.php?pid=1171)
+ 稍微**转化一下问题**，用BFS搜索后标记一下岛屿，这样就收集到了一个结果
+ DFS也可以解决，但是效率比较低。
```cpp
# include<bits/stdc++.h>
#define MAX_VALUE 10000009
using ll = long long;
using namespace std;
int n, m, ans = 0;
int dir[4][2] = { 1,0,0,1,-1,0,0,-1 };
vector<vector<int>>graph(59, vector<int>(59,0));
typedef struct point {
	int x, y;
	point(int a, int b) :x(a), y(b) {};
}point;
void bfs(int x, int y) {
	queue<point>q;
	q.push(point(x, y));
	graph[x][y] = 0;
	while (!q.empty()) {
		point cur = q.front();
		q.pop();
		for (int i = 0; i < 4; i++) {
			int next_x = cur.x + dir[i][0];
			int next_y = cur.y + dir[i][1];
			if (next_x >= 1 && next_x <= n && next_y >= 1 && next_y <= m
				&& graph[next_x][next_y]
				) {
				graph[next_x][next_y] = 0;
				q.push(point(next_x, next_y));
			}
		}
	}
	ans++;
}
void solve() {
	cin >> n >> m;
	for (int i = 1; i <= n; i++) {
		for (int j = 1; j <= m; j++) {
			cin >> graph[i][j];
		}
	}
	for (int i = 1; i <= n; i++) {
		for (int j = 1; j <= m; j++) {
			if (!graph[i][j]) {
				continue;
			}
			bfs(i, j);
		}
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
# 100.岛屿的最大面积
[连接如下](https://kamacoder.com/problempage.php?pid=1172)
```cpp
# include<bits/stdc++.h>
#define MAX_VALUE 10000009
using ll = long long;
using namespace std;
int n, m, ans = 0;
int dir[4][2] = { 1,0,0,1,-1,0,0,-1 };
vector<vector<int>>graph(59, vector<int>(59,0));
typedef struct point {
	int x, y;
	point(int a, int b) :x(a), y(b) {};
}point;
int bfs(int x, int y) {
	queue<point>q;
	q.push(point(x, y));
	graph[x][y] = 0;
	int s = 1;
	while (!q.empty()) {
		point cur = q.front();
		q.pop();
		for (int i = 0; i < 4; i++) {
			int next_x = cur.x + dir[i][0];
			int next_y = cur.y + dir[i][1];
			if (next_x >= 1 && next_x <= n && next_y >= 1 && next_y <= m
				&& graph[next_x][next_y]
				) {
				graph[next_x][next_y] = 0;
				q.push(point(next_x, next_y));
				s++;
			}
		}
	}
	return s;
}
void solve() {
	cin >> n >> m;
	for (int i = 1; i <= n; i++) {
		for (int j = 1; j <= m; j++) {
			cin >> graph[i][j];
		}
	}
	for (int i = 1; i <= n; i++) {
		for (int j = 1; j <= m; j++) {
			if (!graph[i][j]) {
				continue;
			}
			ans = max(ans, bfs(i, j));
		}
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
# 101.孤岛的总面积
[链接如下](https://kamacoder.com/problempage.php?pid=1173)
## 方法１:
+ 直接模拟遇到陆地，就**返回0作为有效面积**
```cpp
# include<bits/stdc++.h>
#define MAX_VALUE 10000009
using ll = long long;
using namespace std;
int n, m, ans = 0;
int dir[4][2] = { 1,0,0,1,-1,0,0,-1 };
vector<vector<int>>graph(59, vector<int>(59,0));
typedef struct point {
	int x, y;
	point(int a, int b) :x(a), y(b) {};
}point;
int bfs(int x, int y) {
	queue<point>q;
	q.push(point(x, y));
	graph[x][y] = 0;
	bool flag = true;
	int s = 1;
	while (!q.empty()) {
		point cur = q.front();
		q.pop();
		if (cur.x == 1 || cur.x == n || cur.y == 1 || cur.y == m) {
			flag = false;//not isolated island
		}
		for (int i = 0; i < 4; i++) {
			int next_x = cur.x + dir[i][0];
			int next_y = cur.y + dir[i][1];

			if (next_x >= 1 && next_x <= n && next_y >= 1 && next_y <= m
				&& graph[next_x][next_y]
				) {
				graph[next_x][next_y] = 0;
				q.push(point(next_x, next_y));
				s++;
			}
		}
	}
	
	return (flag?s:0);
}
void solve() {
	cin >> n >> m;
	for (int i = 1; i <= n; i++) {
		for (int j = 1; j <= m; j++) {
			cin >> graph[i][j];
		}
	}
	for (int i = 1; i <= n; i++) {
		for (int j = 1; j <= m; j++) {
			if (!graph[i][j]) {
				continue;
			}
			ans += bfs(i, j);
		}
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
## 方法２
+ 转化一下问题:**提前处理在陆地的岛屿**
```cpp
# include<bits/stdc++.h>
#define MAX_VALUE 10000009
using ll = long long;
using namespace std;
int n, m, ans = 0;
int dir[4][2] = { 1,0,0,1,-1,0,0,-1 };
vector<vector<int>>graph(59, vector<int>(59,0));
typedef struct point {
	int x, y;
	point(int a, int b) :x(a), y(b) {};
}point;
int bfs(int x, int y) {
	queue<point>q;
	q.push(point(x, y));
	graph[x][y] = 0;
	int s = 1;
	while (!q.empty()) {
		point cur = q.front();
		q.pop();
		for (int i = 0; i < 4; i++) {
			int next_x = cur.x + dir[i][0];
			int next_y = cur.y + dir[i][1];
			if (next_x >= 1 && next_x <= n && next_y >= 1 && next_y <= m
				&& graph[next_x][next_y]
				) {
				graph[next_x][next_y] = 0;
				q.push(point(next_x, next_y));
				s++;
			}
		}
	}
	
	return s;
}
void solve() {
	cin >> n >> m;
	for (int i = 1; i <= n; i++) {
		for (int j = 1; j <= m; j++) {
			cin >> graph[i][j];
		}
	}
	for (int i = 1; i <= n; i++) {
		if (graph[i][1]) {
			bfs(i, 1);
		}
		if (graph[i][m]) {
			bfs(i, m);
		}
	}
	for (int j = 1; j <= m; j++) {
		if (graph[1][j]) {
			bfs(1, j);
		}
		if (graph[n][j]) {
			bfs(n, j);
		}
	}

	for (int i = 1; i <= n; i++) {
		for (int j = 1; j <= m; j++) {
			if (!graph[i][j]) {
				continue;
			}
			ans += bfs(i, j);
		}
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
# 102.沉没孤岛
[链接如下](https://kamacoder.com/problempage.php?pid=1174)
## 方法1
+ 使用一个visited数组**备份**一下原来的graph

```cpp
# include<bits/stdc++.h>
#define MAX_VALUE 10000009
using ll = long long;
using namespace std;
int n, m, ans = 0;
int dir[4][2] = { 1,0,0,1,-1,0,0,-1 };
vector<vector<int>>graph(59, vector<int>(59,0));

typedef struct point {
	int x, y;
	point(int a, int b) :x(a), y(b) {};
}point;
void bfs(int x, int y,vector<vector<int>>&graph) {
	queue<point>q;
	q.push(point(x, y));
	graph[x][y] = 0;
	while (!q.empty()) {
		point cur = q.front();
		q.pop();
		for (int i = 0; i < 4; i++) {
			int next_x = cur.x + dir[i][0];
			int next_y = cur.y + dir[i][1];
			if (next_x >= 1 && next_x <= n && next_y >= 1 && next_y <= m
				&& graph[next_x][next_y]
				) {
				graph[next_x][next_y] = 0;
				q.push(point(next_x, next_y));
			}
		}
	}
	
}
void solve() {
	cin >> n >> m;
	for (int i = 1; i <= n; i++) {
		for (int j = 1; j <= m; j++) {
			cin >> graph[i][j];
		}
	}
	vector<vector<int>>visited(graph);//copy one 
	for (int i = 1; i <= n; i++) {
		if (graph[i][1]) {
			bfs(i, 1,visited);
		}
		if (graph[i][m]) {
			bfs(i, m,visited);
		}
	}
	for (int j = 1; j <= m; j++) {
		if (graph[1][j]) {
			bfs(1, j,visited);
		}
		if (graph[n][j]) {
			bfs(n, j, visited);
		}
	}

	for (int i = 1; i <= n; i++) {
		for (int j = 1; j <= m; j++) {
			if (!visited[i][j]) {
				continue;
			}
			bfs(i, j,graph);
		}
	}
	for (int i = 1; i <= n; i++) {
		for (int j = 1; j <= m; j++) {
			cout << graph[i][j] << " ";
		}
		cout << endl;
	}
}
signed main() {
	std::ios::sync_with_stdio(false);
	std::cin.tie(0);
	std::cout.tie(0);
	solve();
}
```
## 方法２
+ 特殊标记，最后还原一下就行。

```cpp
//略
```
# 103.水流问题
[链接如下](https://kamacoder.com/problempage.php?pid=1175)
+ 逆向思维:**将问题转换为从边界逆流到最高点**
+ 直接模拟问题有一点麻烦。
```cpp
# include<bits/stdc++.h>
#define MAX_VALUE 10000009
using ll = long long;
using namespace std;
int n, m;
int dir[4][2] = { 1,0,0,1,-1,0,0,-1 };
vector<vector<int>>graph(109, vector<int>(109,0));//from 0 to n-1,from 0 to m-1
vector<vector<int>>res1(109, vector<int>(109, 0));//record 
vector<vector<int>>res2(109, vector<int>(109, 0));
typedef struct point {
	int x, y;
	point(int a, int b) :x(a), y(b) {};
};
void bfs(int x,int y,vector<vector<int>>&res) {
	vector<vector<int>>visited(109, vector<int>(109, 0));
	queue<point>q;
	q.push(point(x, y));
	visited[x][y] = 1;
	res[x][y]++;

	while (!q.empty()) {
		point cur = q.front();
		q.pop();
		for (int i = 0; i < 4; i++) {
			int next_x = cur.x + dir[i][0];
			int next_y = cur.y + dir[i][1];
			if (next_x >= 0 && next_x <= n - 1 && next_y >= 0 && next_y <= m - 1
				&& !visited[next_x][next_y]
				&&graph[cur.x][cur.y]<=graph[next_x][next_y]
				) {
				q.push(point(next_x, next_y));

				visited[next_x][next_y]=1;
				res[next_x][next_y]++;
			}
		}
	}
}
void solve() {
	cin >> n >> m;
	for (int i = 0; i <n; i++) {
		for (int j = 0; j < m; j++) {
			cin >> graph[i][j];
		}
	}
	for (int i = 0; i < n; i++) {
		bfs(i, 0,res1);//left
		bfs(i, m - 1, res2);//right

	}
	for (int j = 0; j < m; j++) {//top
		bfs(0, j, res1);
		bfs(n - 1, j, res2);
	}


	for (int i = 0; i < n; i++) {
		for (int j = 0; j < m; j++) {
			if (res1[i][j] && res2[i][j]) {
				cout << i << " " << j << endl;
			}
		}
	}
	//cout << endl;
	//for (int i = 0; i < n; i++) {
	//	for (int j = 0; j < m; j++) {
	//		cout <<graph[i][j]<<" ";
	//	}
	//	cout << endl;
	//}

}
signed main() {
	std::ios::sync_with_stdio(false);
	std::cin.tie(0);
	std::cout.tie(0);
	solve();
}
```

# 104.最大岛屿
[链接如下](https://kamacoder.com/problempage.php?pid=1176)
+ **注意特判**
```cpp
# include<bits/stdc++.h>
#define MAX_VALUE 10000009
using ll = long long;
using namespace std;
int n, m,ans=0;
int dir[4][2] = { 1,0,0,1,-1,0,0,-1 };
vector<vector<int>>graph(109, vector<int>(109,0));//from 0 to n-1,from 0 to m-1
typedef struct point {
	int x, y;
	point(int a, int b) :x(a), y(b) {};
};
int bfs(int x,int y) {
	vector<vector<int>>visited(109, vector<int>(109, 0));
	queue<point>q;
	q.push(point(x, y));
	visited[x][y] = 1;
	int s = 1;
	while (!q.empty()) {
		point cur = q.front();
		q.pop();
		for (int i = 0; i < 4; i++) {
			int next_x = cur.x + dir[i][0];
			int next_y = cur.y + dir[i][1];
			if (next_x >= 1 && next_x <= n && next_y >= 1 && next_y <= m
				&& !visited[next_x][next_y]&&graph[next_x][next_y]
				) {
				q.push(point(next_x, next_y));
				visited[next_x][next_y]=1;
				s++;
			}
		}
	}
	return s;
}
void solve() {
	cin >> n >> m;
	for (int i = 1; i <= n; i++) {
		for (int j = 1; j <= m; j++) {
			cin >> graph[i][j];
		}
	}
	bool flag = true;//all 1
	for (int i = 1; i <= n; i++) {
		for (int j = 1; j <= m; j++) {
			if (!graph[i][j]) {
				ans = max(ans, bfs(i, j));
				flag = false;//ensure that there is a 0 in matrix
			}
		}
	}
	if (flag) {
		cout << m * n;
	}
	else {
		cout << (ans == 0 ? 1 : ans);
	}
	

}
signed main() {
	std::ios::sync_with_stdio(false);
	std::cin.tie(0);
	std::cout.tie(0);
	solve();
}
```

