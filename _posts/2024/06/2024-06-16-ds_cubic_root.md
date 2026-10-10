---
title: "洛谷·一元三次根·二分"
author: MayL
date: 2024-06-16
categories: ["算法与数据结构", "算法题解"]
tags: ["算法题解", "二分查找", "算法", "学习笔记"]
render_with_liquid: false
math: true
description: "本文整理“洛谷·一元三次根·二分”的核心思路、典型问题与实现要点，便于刷题复习和后续查阅。"
---

[地址](https://www.luogu.com.cn/problem/P1024)
# [NOIP2001 提高组] 一元三次方程求解

## 题目描述

有形如：$a x^3 + b x^2 + c x + d = 0$  这样的一个一元三次方程。给出该方程中各项的系数（$a,b,c,d$ 均为实数），并约定该方程存在三个不同实根（根的范围在 $-100$ 至 $100$ 之间），且根与根之差的绝对值 $\ge 1$。要求由小到大依次在同一行输出这三个实根(根与根之间留有空格)，并精确到小数点后 $2$ 位。

提示：记方程 $f(x) = 0$，若存在 $2$ 个数 $x_1$ 和 $x_2$，且 $x_1 < x_2$，$f(x_1) \times f(x_2) < 0$，则在 $(x_1, x_2)$ 之间一定有一个根。

## 输入格式

一行，$4$ 个实数 $a, b, c, d$。

## 输出格式

一行，$3$ 个实根，从小到大输出，并精确到小数点后 $2$ 位。

## 样例 #1

### 样例输入 #1

```
1 -5 -4 20
```

### 样例输出 #1

```
-2.00 2.00 5.00
```

## 提示

**【题目来源】**

NOIP 2001 提高组第一题

# nt题硬控我1个小时！
+ `abs(func(x)) < 10e-4)`double是有误差的,不能令func(x)==0
```cpp
else if (abs(func(y)) < 10e-4) {
    continue;
}
```
**右边界冲突**问题！！！
**这题用二分做还是太勉强了**
# 二分做法
```cpp
using namespace std;
using ll = long long;
double a, b, c, d;
double func(double x) {
	return a * x * x * x + b * x * x + c * x + d;
}
void solve() {
	cin >> a >> b >> c >> d;
	for (double i = -100; i <= 100; i++) {
		double x, y, m;
		x = i, y = i + 1;
		if (abs(func(x)) < 10e-4) {
			printf("%.2f ", x); //右边界冲突
		}
		else if (abs(func(y)) < 10e-4) {
			continue;
		}
		else if (func(x) * func(y) < 0) {
			while (y - x > 10e-4) {
				 m= (x + y) / 2;
					
				if (func(x) * func(m) < 0) {
					y = m;
				}
				else{
					x = m;

				}
			}
			printf("%.2f ", m);
		}
	}
}
int main(){
	std::ios::sync_with_stdio(false);
	std::cin.tie(0); std::cout.tie(0);
	solve();
	return 0;
}
```
# 枚举的做法
```cpp
using namespace std;
using ll = long long;
double a, b, c, d;
double func(double x) {
	return a * x * x * x + b * x * x + c * x + d;
}
void solve() {
	cin >> a >> b >> c >> d;
	for (double i = -100; i <= 100; i += 0.01) {//注意精度
		if (abs(func(i)) < 10e-4) {
			printf("%.2f ", i);
		}
	}
}
int main() {
	std::ios::sync_with_stdio(false);
	std::cin.tie(0); std::cout.tie(0);
	solve();
	return 0;
}
```
