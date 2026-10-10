---
title: "图论·多源最短路径Floyd&dijsktra"
author: MayL
date: 2024-06-26
categories: ["算法与数据结构", "图论"]
tags: ["图论", "dijkstra", "floyd", "算法"]
render_with_liquid: false
description: "本文整理“图论·多源最短路径Floyd&dijsktra”的核心思路、典型问题与实现要点，便于刷题复习和后续查阅。"
---

[例题地址](https://kamacoder.com/problempage.php?pid=1155)
# 多源最短路径
+ **多个源点多个终点**
+ 可以使用Floyd算法直接求各源点到终点的最短距离，也可以直接多次使用dijsktra算法求单源点到终点的最短距离
# Floyd算法
## 使用条件
+ 多源最短路径
+ 权值正负皆可
## 核心思想：动态规划
+ **子问题**：
	+ 设(A,B)表示顶点A,B之间的距离，则有可能(A,B)=(A,C)+(C,B)，这说明AB之间的距离可以继续分解为AC,CB之间的距离问题，我们可以找到一个子问题，而这就体现了动态规划的思想
+ **定义dp数组**：
	+ 因为从存储上来讲，我们需要利用邻接矩阵，所以AB间的最短距离表示至少需要两个维度i和j，所以dp数组至少有两个维度。
	+ 又因为**从子问题的角度**，我们分解问题的出发点是找一个中间结点，比较AB的最短距离经过中间结点C会不会更短。所以定义一个新的维度k，其含义是**考虑下标从1开始到k结束的k个顶点**是否应该加入到路径中去。(这个定义有鲜明的dp特色,学过dp应该不难理解)
因此dp数组的定义如下`dp[i][j][k]`，表示考虑下标1~k的k个顶点的 **i到j的最短距离**
+ 递推公式：
  + 根据定义，不难想到，递推公式就是是否应该**将下标为k的结点是否值得加入到路径中去**
  + 不加入k结点：`dp[i][j][k - 1]` (言外之意就是i和j已经连通，加入k结点不值得)
  + 加入k结点：`dp[i][k][k - 1] + dp[k][j][k - 1]`
  + 完整公式：`dp[i][j][k] = min(dp[i][j][k - 1], dp[i][k][k - 1] + dp[k][j][k - 1]);`
+ 初始化：
  + 处理输入时，要考虑k这个维度应该怎么设置。一种简单的想法是，把k设置无关紧要或者无意义的数值(根据不同题目需要可能是INT_MAX/INT_MIN/0)，**这里设置为0** `dp[u][v][0] = w;`
+ 遍历顺序：
	+ 其实这个很简单，根据递推公式，`dp[i][j][k-1]`中k-1个维度的数据必须知道，否则会造成无意义的更新，所以k必须在外层循环
## 个人代码

```cpp
using namespace std;
using ll = long long;
int n, m, u, v, w,q,start,ed;
void solve() {
	cin >> n >> m;
	vector < vector<vector<int>>>dp(n + 1, vector<vector<int>>(n + 1, vector<int>(n + 1, 10009)));//dp数组
	while (m--) {
		cin >> u >> v >> w;
		dp[u][v][0] = w;
		dp[v][u][0] = w;
	}
	for (int k = 1; k <= n; k++) {
		for (int i = 1; i <= n; i++) {
			for (int j = 1; j <= n; j++) {
				dp[i][j][k] = min(dp[i][j][k - 1], dp[i][k][k - 1] + dp[k][j][k - 1]);
			}
		}
	}
	cin >> q;
	while (q--) {
		cin >> start >> ed;
		cout << (dp[start][ed][n] == 10009 ? -1 : dp[start][ed][n])<<endl;
	}
}
int main() {
	std::ios::sync_with_stdio(false);
	std::cin.tie(0); std::cout.tie(0);
	solve();
	return 0;
}
```
## 注意事项
+**dp数组不应该设置为最大值INT_MAX**，否则会相加溢出导致数据异常 
`vector < vector<vector<int>>>dp(n + 1, vector<vector<int>>(n + 1, vector<int>(n + 1, 10009)));`

## 空间优化版
+ 直接删去了k这一个维度，因为利用更新后的数据(第k层的)`dp[i][k] + dp[k][j]`更新自己同一层(第k层的)数据，也能得到正确结果

```cpp
#include<bits/stdc++.h>
using namespace std;
using ll = long long;
int n, m, u, v, w,q,start,ed;
void solve() {
	cin >> n >> m;
	vector < vector<int>>dp(n + 1,vector<int>(n+1,10009));//dp数组
	while (m--) {
		cin >> u >> v >> w;
		dp[u][v] = w;
		dp[v][u] = w;
	}
	for (int k = 1; k <= n; k++) {
		for (int i = 1; i <= n; i++) {
			for (int j = 1; j <= n; j++) {
				dp[i][j] = min(dp[i][j], dp[i][k] + dp[k][j]);
			}
		}
	}
	cin >> q;
	while (q--) {
		cin >> start >> ed;
		cout << (dp[start][ed] == 10009 ? -1 : dp[start][ed])<<endl;
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
# 多次使用dijsktra算法
## 核心思路
+ 将dijsktra定义为函数
+ 传入**dist数组的拷贝**(没有&引用)作参数,传入st,ed分别作为源点和终点，**在函数内初始化dist数组**
## 个人代码

```cpp
#include<bits/stdc++.h>
using namespace std;
using ll = long long;
int n, m, s, e, v,q,st,ed;//s=u,e=v,v=w;
void dijkstra(vector<vector<int>>&grid, vector<bool>visited, vector<int>dist,int st,int ed) {
//vector<bool>visited和vector<int>dist一定不能传入引用的形式！
    dist[st]=0;//一定要在这里初始化dist[st]
    for (int i = 1; i <= n - 1; i++) {
        int temp = INT_MAX;
        int cur = 0;
        for (int j = 1; j <= n; j++) {
            if (!visited[j] && dist[j] < temp) {
                temp = dist[j];
                cur = j;
            }
        }
        visited[cur] = true;
        for (int j = 1; j <= n; j++) {
            if (grid[cur][j] != INT_MAX && !visited[j] && dist[cur] + grid[cur][j] < dist[j]) {
                dist[j] = dist[cur] + grid[cur][j];
            }
        }
    }
    cout << (dist[ed] == INT_MAX ? -1 : dist[ed]) << endl;
}
void solve() {
    cin >> n >> m;
    vector<vector<int>>grid(n + 1, vector<int>(n + 1, INT_MAX));
    vector<bool>visited(n + 1, false);
    vector<int>dist(n + 1, INT_MAX);
    while (m--) {
        cin >> s >> e >> v;
        grid[s][e] = v;
        grid[e][s] = v;
    }
    cin >> q;
    while (q--) {
        cin >> st >> ed;
        dijkstra(grid, visited, dist,st,ed);
    }
    
}
int main() {
    std::ios::sync_with_stdio(false);
    std::cin.tie(0); std::cout.tie(0);
    solve();
    return 0;
}
```
[本文参考于代码随想录](https://www.programmercarl.com/kamacoder/0097.%E5%B0%8F%E6%98%8E%E9%80%9B%E5%85%AC%E5%9B%AD.html)
