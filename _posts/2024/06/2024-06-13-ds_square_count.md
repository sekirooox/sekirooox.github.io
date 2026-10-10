---
title: "洛谷·统计方形-组合数学"
author: MayL
date: 2024-06-13
categories: ["算法与数据结构", "算法题解"]
tags: ["算法题解", "算法", "学习笔记"]
render_with_liquid: false
math: true
description: "本文整理“洛谷·统计方形-组合数学”的核心思路、典型问题与实现要点，便于刷题复习和后续查阅。"
---

[原题地址](https://www.luogu.com.cn/problem/P2241)
# 统计方形（数据加强版）

## 题目背景

1997年普及组第一题

## 题目描述

有一个 $n \times m$ 方格的棋盘，求其方格包含多少正方形、长方形（不包含正方形）。

## 输入格式

一行，两个正整数 $n,m$（$n \leq 5000,m \leq 5000$）。

## 输出格式

一行，两个正整数，分别表示方格包含多少正方形、长方形（不包含正方形）。

## 样例 #1

### 样例输入 #1

```
2 3
```

### 样例输出 #1

```
8 10
```
# 组合数学的威力
+ 这就是组合数学，把一个需要穷举的麻烦题目变成了简单求和的题目
+ 首先矩形数量=长方形数量+正方形数量
+ 矩形数量是n+1一条边选2*m+1条边选2，围成的图形
```cpp
#include<bits/stdc++.h>
using namespace std;
using ll = long long;
void solve() {
	ll n, m;
	cin >> n >> m;
	ll total = (n * (n + 1) * m * (m + 1)) / 4;
	ll sq=0;
	while (n || m) {
		sq += n * m;
		n = max(int(n-1), 0);
		m = max(int(m-1), 0);
	}
	cout << sq << " " << total - sq;
}
int main(){
	std::ios::sync_with_stdio(false);
	std::cin.tie(0); std::cout.tie(0);
	solve();
	return 0;
}
```
