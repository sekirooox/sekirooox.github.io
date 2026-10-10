---
title: "洛谷·扫雷游戏"
author: MayL
date: 2024-06-11
categories: ["算法与数据结构", "算法题解"]
tags: ["算法题解", "算法", "学习笔记"]
render_with_liquid: false
math: true
description: "本文整理“洛谷·扫雷游戏”的核心思路、典型问题与实现要点，便于刷题复习和后续查阅。"
---

[原题地址](https://www.luogu.com.cn/problem/P2670)
# [NOIP2015 普及组] 扫雷游戏

## 题目背景

NOIP2015 普及组 T2

## 题目描述

扫雷游戏是一款十分经典的单机小游戏。在 $n$ 行 $m$ 列的雷区中有一些格子含有地雷（称之为地雷格），其他格子不含地雷（称之为非地雷格）。玩家翻开一个非地雷格时，该格将会出现一个数字——提示周围格子中有多少个是地雷格。游戏的目标是在不翻出任何地雷格的条件下，找出所有的非地雷格。

现在给出 $n$ 行 $m$ 列的雷区中的地雷分布，要求计算出每个非地雷格周围的地雷格数。

注：一个格子的周围格子包括其上、下、左、右、左上、右上、左下、右下八个方向上与之直接相邻的格子。

## 输入格式

第一行是用一个空格隔开的两个整数 $n$ 和 $m$，分别表示雷区的行数和列数。

接下来 $n$ 行，每行 $m$ 个字符，描述了雷区中的地雷分布情况。字符 $\texttt{*}$ 表示相应格子是地雷格，字符 $\texttt{?}$ 表示相应格子是非地雷格。相邻字符之间无分隔符。

## 输出格式

输出文件包含 $n$ 行，每行 $m$ 个字符，描述整个雷区。用 $\texttt{*}$ 表示地雷格，用周围的地雷个数表示非地雷格。相邻字符之间无分隔符。

## 样例 #1

### 样例输入 #1

```
3 3
*??
???
?*?
```

### 样例输出 #1

```
*10
221
1*1
```

## 样例 #2

### 样例输入 #2

```
2 3
?*?
*??
```

### 样例输出 #2

```
2*1
*21
```

## 提示

对于 $100\%$的数据，$1≤n≤100, 1≤m≤100$。


```cpp
#include<bits/stdc++.h>
using namespace std;
int n,m;
int dir[8][2] = { 1,0,1,1,0,1,-1,1,-1,0,-1,-1,0,-1,1,-1 };
int ans;
void solve() {
	cin >> n >> m;
	vector<string>vec(n, string(m,'*'));
	vector<string>area(n, string(m, '*'));
	for (int i = 0; i < n; i++) {
		for (int j = 0; j < m; j++) {
			cin >> vec[i][j];
		}
	}
	for (int i = 0; i < n; i++) {
		for (int j = 0; j < m; j++) {
			if (vec[i][j] == '*') {
				continue;
			}
			ans = 0;
			for (int k = 0; k < 8; k++) {
				int x = i + dir[k][0];
				int y = j + dir[k][1];
				if (x < 0 || y < 0 || x >= n || y >= m) {
					continue;
				}
				if (vec[x][y] == '*') {
					ans++;
				}
			}
			area[i][j] = ans + '0';
		}
		
	}
	for (int i = 0; i < n; i++) {
		for (int j = 0; j < m; j++) {
			cout << area[i][j];
		}
		cout << endl;
	}
}
int main(){
	std::ios::sync_with_stdio(false);
	std::cin.tie(0); std:cout.tie(0);
	solve();
}
```
+ 要注意的点是**先读取n,m**再初始化vector,**还有下标别越界**
