---
title: "洛谷·跳石头·二分"
author: MayL
date: 2024-06-16
categories: ["算法与数据结构", "算法题解"]
tags: ["算法题解", "二分查找", "算法", "学习笔记"]
render_with_liquid: false
math: true
description: "本文整理“洛谷·跳石头·二分”的核心思路、典型问题与实现要点，便于刷题复习和后续查阅。"
---

[address](https://www.luogu.com.cn/problem/P2678)
# [NOIP2015 提高组] 跳石头

## 题目背景

NOIP2015 Day2T1

## 题目描述

一年一度的“跳石头”比赛又要开始了！

这项比赛将在一条笔直的河道中进行，河道中分布着一些巨大岩石。组委会已经选择好了两块岩石作为比赛起点和终点。在起点和终点之间，有 $N$ 块岩石（不含起点和终点的岩石）。在比赛过程中，选手们将从起点出发，每一步跳向相邻的岩石，直至到达终点。

为了提高比赛难度，组委会计划移走一些岩石，使得选手们在比赛过程中的最短跳跃距离尽可能长。由于预算限制，组委会至多从起点和终点之间移走 $M$ 块岩石（不能移走起点和终点的岩石）。


# 个人理解
+ 为什么能想到二分？基于枚举的思想，枚举所有的最短跳跃距离，但是1~L，时间复杂度非常大，此时需要优化枚举，这时候二分答案就有用武之地了。
+ “那么什么时候适用二分答案呢？注意到题面：使得选手们在比赛过程中的最短跳跃距离尽可能长。如果题目规定了有“**最大值最小**”或者“**最小值最大**”的东西，那么这个东西应该就满足二分答案的**有界性**（显然）和**单调性**（能看出来）”
# 代码如下
+ 需要注意用一个ret存储mid,如果不这样只有70pts;(**忽略了mid的点)**;

```cpp
#include<bits/stdc++.h>
using namespace std;
using ll = long long;
ll L;
int n, m,ret;
bool isValid(ll mid,vector<ll>&a) {
	int ans = 0;
	ll s = a[0];//s当前的未知
	for (int i = 1; i < n +2; i++) {
		if (a[i] - s <mid) {
			ans++;
		}
		else {
			s = a[i];
		}
	}
	if (ans > m) {
		return false;
	}
	return true;

}
void solve() {
	cin >> L >> n >> m;//n岩石术
	vector<ll>a(n + 2, 0);//n+2
	a[0] = 0;
	a[n +1] = L;
	for (int i = 1; i < n +1; i++) {
		cin >> a[i];
	}
	ll left = 0, right = L,mid=0;
	while (left <= right) {
		mid = (left + right) / 2;
		if (isValid(mid,a)) {
			ret = mid;
			left = mid + 1;
		}
		else {
			right = mid - 1;
		}
	}
	cout << ret;
	
}
int main() {
	std::ios::sync_with_stdio(false);
	std::cin.tie(0); std::cout.tie(0);
	solve();
	return 0;
}
```

