---
title: "算法·二分"
author: MayL
date: 2024-07-08
categories: ["算法与数据结构", "算法"]
tags: ["二分查找", "算法", "学习笔记"]
render_with_liquid: false
description: "本文整理“算法·二分”的核心思路、典型问题与实现要点，便于刷题复习和后续查阅。"
---

# 二分法
本质是求左区间的右端点，右区间的左端点
左区间和右区间分别满足某种对立的性质(例如，**左区间满足x<=3，也可以使用函数判断的性质**)

## 二分法模板
# 整数二分
+ 整数区间分为**左区间和右区间**
+ **左区间的右边界点mid需要+1！！!**`int mid = l + r + 1>> 1`

## 整数二分模板
>### 注意：左区间条件为true时，当r=l-1时，l会一直被赋值为`l=mid=l`，无法移动！因此需要使用`mid=l+r+1>>1`！
### 右区间求左端点的二分
```cpp
while (l < r) {
			int mid = l + r >> 1;
			if (a[mid] >= k) {
				r = mid;
			}
			else {
				l = mid + 1;
			}
		}
```

## 左区间求右端点的二分
```cpp
l = 0, r = n - 1;
		while (l < r) {
			int mid = l + r + 1>> 1;
			if (a[mid] <= k) {
				l = mid;
			}
			else {
				r = mid - 1;
			}
		}
```
---
# 例题
## 使用二分查找来查找数第一次出现和最后一次出现的位置。
+ [AcWing 789. 数的范围 ](https://www.acwing.com/activity/content/problem/content/823/)
+ [P2249 【深基13.例1】查找](https://www.luogu.com.cn/problem/P2249)：**二分查找本质上也是找左右区间的端点。**
+ [P1102 A-B 数对](https://www.luogu.com.cn/problem/P1102)：
+ [P1678 烦恼的高考志愿](https://www.luogu.com.cn/problem/P1678)


## 二分答案：答案具有“单调性”
>### 题目中出现"至少/最多"等字眼，且验证答案比计算答案简单的时候使用

+ [P1873 [COCI 2011/2012 #5] EKO / 砍树](https://www.luogu.com.cn/problem/P1873)
+ [P2440 木材加工](https://www.luogu.com.cn/problem/P2440)
+ [P2678 [NOIP 2015 提高组] 跳石头](https://www.luogu.com.cn/problem/P2678)
+ [P3853 [TJOI2007] 路标设置](https://www.luogu.com.cn/problem/P3853)
+ [P1182 数列分段 Section II](https://www.luogu.com.cn/problem/P1182)
+ [P3743 小鸟的设备](https://www.luogu.com.cn/problem/P3743)：**这题直接用贪心求答案好像不可行，发现答案很显然具有单调性**，于是简化为二分答案。注意，**这题答案的上界未知**，需要开大一点。

```cpp
void solve() {
	cin >> n >> p;
	double cost = 0;
	for (int i = 1; i <= n; i++) {
		cin >> a[i] >> b[i];
		cost += a[i];
	}
	if (p >= cost) {
		cout << -1;
		return;
	}

	double l = 0, r = 1e8;// 上界求不出来
	while(r-l>=1e-6) {
		double mid = (l + r) / 2;
		if (check(mid)) {
			l = mid;
		}
		else r = mid;
	}
	printf("%.10f", l);
}
```


