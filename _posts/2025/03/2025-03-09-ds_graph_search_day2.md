---
title: "图论Day2·搜索"
author: MayL
date: 2025-03-09
categories: ["算法与数据结构", "图论"]
tags: ["图论", "算法", "学习笔记"]
render_with_liquid: false
description: "本文整理“图论Day2·搜索”的核心思路、典型问题与实现要点，便于刷题复习和后续查阅。"
---

# 110.字符串接龙
[链接如下](https://kamacoder.com/problempage.php?pid=1183)
+ 这道题难度不大，但是建图有一定技巧，需要用到**桶排序的思想**

```cpp
#include<bits/stdc++.h>
#define MAX_VALUE 10000009
using ll = long long;
using namespace std;
int n,ans=MAX_VALUE;
string a, b, c;
unordered_map<string, vector<string>>mp;
unordered_set<string>visited;
void bfs() {
	queue<pair<string,int>>q;
	q.push(pair<string,int>(a,1));
	visited.insert(a);
	while (!q.empty()) {
		pair<string,int> cur = q.front();
		q.pop();
		if (cur.first == b) {
			ans = min(ans, cur.second);
		}
		for (int i = 0; i < cur.first.size(); i++) {
			string temp(cur.first);
			temp[i] = '*';
			for (auto item : mp[temp]) {//*bc
				if (visited.find(item)!=visited.end()) {//找得到
					continue;
				}

				q.push(pair<string, int>(item, cur.second + 1));
				visited.insert(item);
			}
		}
	}
	cout << (ans == MAX_VALUE?0:ans);
}
void solve() {
	//special:重复
	cin >> n >> a >> b;
	for (int i = 0; i < a.size(); i++) {
		string temp(a);
		temp[i] = '*';
		mp[temp].push_back(a);
	}
	for (int i = 0; i < b.size(); i++) {
		string temp(b);
		temp[i] = '*';
		mp[temp].push_back(b);
	}
	while (n--) {
		cin >> c;
		for (int i = 0; i < c.size(); i++) {
			string temp(c);
			temp[i] = '*';
			mp[temp].push_back(c);
		}
	}
	bfs();
}
signed main() {
	std::ios::sync_with_stdio(false);
	std::cin.tie(0);
	std::cout.tie(0);
	solve();
}
```
# 105.有向图的完全可达性
[链接如下](https://kamacoder.com/problempage.php?pid=1177)
```cpp
# include<bits/stdc++.h>
#define MAX_VALUE 10000009
using ll = long long;
using namespace std;
int n, k, s, t;
vector<list<int>>graph(109, list<int>());
vector<int>visited(109, 0);
void bfs() {
	queue<int>q;
	q.push(1);
	visited[1] = 1;
	while (!q.empty()) {
		int cur = q.front();
		q.pop();
		for (auto item : graph[cur]) {
			if (!visited[item]) {
				visited[item] = 1;
				q.push(item);
			}
		}
	}
}
void solve() {
	cin >> n >> k;
	while (k--) {
		cin >> s >> t;
		graph[s].push_back(t);
	}
	bfs();
	for (int i = 1; i <= n; i++) {
		if (!visited[i]) {
			cout << -1;
			return;
		}
	}
	cout << 1;
}
signed main() {
	std::ios::sync_with_stdio(false);
	std::cin.tie(0);
	std::cout.tie(0);
	solve();
}
```
# 106. 岛屿的周长

```cpp
#include<bits/stdc++.h>
#define MAX_VALUE 10000009
using ll = long long;
using namespace std;
int n, m;
int dir[4][2] = { 1,0,0,1,-1,0,0,-1 };
vector<vector<int>>graph(59, vector<int>(59, 0));

typedef struct point {
	int x, y;
	point(int a, int b) :x(a), y(b) {};
}point;

int bfs(int x,int y) {
	queue<point>q;
	q.push(point(x, y));
	graph[x][y] = 2;//区分标记过的陆地和水域
	int res = 0;
	while (!q.empty()) {
		point cur = q.front();
		q.pop();
		for (int i = 0; i < 4; i++) {
			int next_x = cur.x + dir[i][0];
			int next_y = cur.y + dir[i][1];
			if (next_x >= 1 && next_x <= n && next_y >= 1 && next_y <= m) {
				if (graph[next_x][next_y]==1) {
					q.push(point(next_x, next_y));
					graph[next_x][next_y] = 2;
				}
				else if(graph[next_x][next_y]==0) {
					res++;
				}
			}
			else {
				res++;
			}
		}
	}
	return res;
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
			if (graph[i][j]) {
				cout<<bfs(i,j);
				return;
			}
		}
	}
}
signed main() {
	std::ios::sync_with_stdio(false);
	std::cin.tie(0);
	std::cout.tie(0);
	solve();
}
```

