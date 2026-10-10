---
title: "洛谷·Cities and States S"
author: MayL
date: 2024-06-18
categories: ["算法与数据结构", "算法题解"]
tags: ["算法题解", "算法", "学习笔记"]
render_with_liquid: false
math: true
description: "本文整理“洛谷·Cities and States S”的核心思路、典型问题与实现要点，便于刷题复习和后续查阅。"
---

[原题地址](https://www.luogu.com.cn/problem/P3405)
# [USACO16DEC] Cities and States S

## 题目描述

Farmer John 有若干头奶牛。为了训练奶牛们的智力，Farmer John 在谷仓的墙上放了一张美国地图。地图上表明了每个城市及其所在州的代码（前两位大写字母）。

由于奶牛在谷仓里花了很多时间看这张地图，他们开始注意到一些奇怪的关系。例如，FLINT 的前两个字母就是 MIAMI 所在的 `FL` 州，MIAMI 的前两个字母则是 FLINT 所在的 `MI` 州。  
确切地说，对于两个城市，它们的前两个字母互为对方所在州的名称。

我们称两个城市是一个一对「特殊」的城市，如果他们具有上面的特性，并且来自不同的州。对于总共 $N$ 座城市，奶牛想知道有多少对「特殊」的城市存在。请帮助他们解决这个有趣的地理难题！

## 输入格式

输入共 $N + 1$ 行。

第一行一个正整数 $N$，表示地图上的城市的个数。  
接下来 $N$ 行，每行两个字符串，分别表示一个城市的名称（$2 \sim 10$ 个大写字母）和所在州的代码（$2$ 个大写字母）。同一个州内不会有两个同名的城市。

## 输出格式

输出共一行一个整数，代表特殊的城市对数。

## 样例 #1

### 样例输入 #1

```
6
MIAMI FL
DALLAS TX
FLINT MI
CLEMSON SC
BOSTON MA
ORLANDO FL
```

### 样例输出 #1

```
1
```

## 提示

### 数据规模与约定

对于 $100\%$ 的数据，$1 \leq N \leq 2 \times 10 ^ 5$，城市名称长度不超过 $10$。
# 解题思路
个人感觉没必要用到字符串hash的知识？好像用map自带的hash函数也可以
+ **使用map进行搜索和去重**
+ **双重映射map**：map<int,map<>>

# 个人代码

```cpp
#include<bits/stdc++.h>

#define mod 26//模定义太小了，不如不定义,很容易冲突
using namespace std;
map<int, map<int, int>>mp;//第i第j对应的次数
string a, b;
long long ans = 0;
int gethash(string a) {
	return (a[0] * 26 + a[1]) ;
}
void solve() {
	int n; cin >> n;
	for (int i = 0; i < n; i++) {
		cin >> a >> b;
		int x = gethash(a);
		int y = gethash(b);
		if (x != y) {//x==y的话如果要配对的话只会配到自己省。题目说了不在同一省，所以要排除。
			mp[x][y]++;
			ans += mp[y][x];
		}
	}
	
}
int main() {
	std::ios::sync_with_stdio(false);
	std::cin.tie(0); std:cout.tie(0);
	solve();
	cout << ans;
}
```

