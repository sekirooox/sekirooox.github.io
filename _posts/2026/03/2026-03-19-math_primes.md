---
title: "数论·质数"
author: MayL
date: 2026-03-19
categories: ["数学基础与数学建模", "数学基础"]
tags: ["最小生成树", "数学", "学习笔记"]
render_with_liquid: false
math: true
description: "本文整理“数论·质数”涉及的基本原理、计算方法与应用思路，便于学习复习和建模参考。"
---

@[toc]
# 质数 vs 合数
## 数学定义
+ 0和1不是质数也不是合数
+ 大于等于2且公因子只有1和它本身的数


# 判定质数
## 试除法：$O(\sqrt{n})$
### 数学原理
这个判定质数的方法基于一个重要的数学原理：
+ **如果一个数 $n$ 是合数，它一定有一个小于等于 $\sqrt{n}$ 的因子**。
+ **如果一个数 $n$ 是合数，它至多有一个大于 $\sqrt{n}$ 的因子**
### 举例验证
+ 26=2*13属于合数
+ 2满足定理1，13满足定理2
### 实现
+ 注意**小于2的都不是质数。**
+ **判断条件使用`i<x/i`等价于`i*i<x`,但是前者不容易溢出**。
```cpp
bool isprime(int x) {
	if (x < 2)return false;
	for (int i = 2; i <= x / i; i++) {
		if (x % i == 0)return false;
	}
	return true;
}
```

# 质因数分解
## 试除法：$O(log_2^n)-O(\sqrt{n})$
### 数学定义

**定理（算术基本定理）**  
任意大于 1 的整数 $x$ 都可以唯一地表示为若干个质数的乘积：

$$
x = p_1^{\alpha_1} \cdot p_2^{\alpha_2} \cdots p_k^{\alpha_k}
$$

其中 $p_1 < p_2 < \cdots < p_k$ 是质数，$\alpha_i \in \mathbb{N}^+$。
#### 注意：该定义同时适用于素数和合数


### 实现
+ 如果当前数可以被整除，则可以一直整除得到**因子和对应指数**。
+ **该算法保证：没有一个因子为合数**。证明：如果有一个因子是合数，那么在算法处理过程中，该合数的因子率先被处理，不可能留下该合数。
+ 特判：如果是质数，那么前面的循环完全无效，因此需要特判

```cpp
void divide(int x) {
	for (int i = 2; i <= x / i; i++) {
		if (x % i == 0) {
			int s = 0;
			cout << i << " ";
			while (x % i == 0) {
				s++;
				x /= i;
			}
			cout << s << endl;
		}
	}
	if (x > 1)cout << x << " " << 1 << endl;
	cout << endl;
}
```
# 筛选质数
## 筛选的理解
>**删除合数，保留质数**

## 暴力筛选 $O(nlogn)$
### 实现
+ 对于每一个数(2-n-1)，将其倍数都标记为合数
+ 问题：**出现了例如2和4会重复对4进行筛选的问题**。
## 埃式筛：$O(nloglogn）$
### 实现
+ 对于**每一个质数**(2，3，5...)进行筛选，**2-n中质数的数量为logn**，可以有效降低筛选次数
+ 问题：**仍然出现重复筛选，例如2和5都对10进行了筛选，这是不必要的**。
```cpp
void getprimes() {
	for (int i = 2; i <= n; i++) {
		if (isprimes[i]) {
			primes.push_back(i);
			for (int j = i + i; j <= n; j+=i) {
				isprimes[j] = 0;
			}
		}
	}
}
```

## 欧拉筛：$O(n)$
###  数学原理
其核心思想是：**确保每个合数只被它的最小质因数标记一次**。

根据算术基本定理，任意合数 $n$ 可以唯一地表示为：
$$n = p_1^{\alpha_1} \cdot p_2^{\alpha_2} \cdots p_k^{\alpha_k}$$
其中 $p_1 < p_2 < \cdots < p_k$ 是质数，$\alpha_i \in \mathbb{N}^+$。

特别地，$n$ 可以写成：
$$n = p_{\min} \cdot m$$
其中 $p_{\min}$ 是 $n$ 的最小质因数，且 $m > p_{\min}$（因为如果 $m \le p_{\min}$，则 $m$ 会有更小的质因数）。

---

对于合数 $n = p_{\min} \cdot m$，必然有：
$$p_{\min} \le m$$
- 若 $p_{\min} > m$，则 $m$ 的最小质因数会小于 $p_{\min}$，矛盾。

这意味着在欧拉筛的过程中，当用 $i$ 遍历时，对每个质数 $p_j$：
- 若 $p_j \mid i$，则 $p_j$ 是 $i$ 的最小质因数
- 此时 $i \cdot p_j$ 的最小质因数就是 $p_j$，应该被标记
- 但 $i \cdot p_{j+1}$ 的最小质因数仍然是 $p_j$（因为 $p_j < p_{j+1}$ 且 $p_j \mid i$），所以不应该由 $p_{j+1}$ 标记


### 实现
+ 确保`i % primes[j] == 0`时停止，因为`i=primes[j]*k`，而`primes[j+1]*i=primes[j+1]*primes[j]*k`，最小因子一定是`prime[j]`，不符合欧拉筛的标准。

```cpp
void getprimes() {
	for (int i = 2; i <= n; i++) {
		if (isprimes[i]) {
			primes.push_back(i);
			
		}
		// 合数也要参会筛选
		for (int j = 0; j < primes.size(); j++) {
			if (i * primes[j] > n)break;
			isprimes[i * primes[j]] = 0;
			if (i % primes[j] == 0)break;
		}
	}
}
```

