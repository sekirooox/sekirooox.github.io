---
title: "数论·欧拉函数"
author: MayL
date: 2026-03-22
categories: ["数学基础与数学建模", "数学基础"]
tags: ["数学", "学习笔记"]
render_with_liquid: false
math: true
description: "本文整理“数论·欧拉函数”涉及的基本原理、计算方法与应用思路，便于学习复习和建模参考。"
---

@[toc]
# 欧拉函数
## 互质（Coprime）
若两个整数 $a, b$ 满足它们的**最大公约数为 1**，即
$$
\gcd(a,b)=1
$$
则称 $a$ 与 $b$ **互质**（或称互素）。
等价表述：$a$ 与 $b$ 没有任何大于 1 的公共因子。
## 欧拉函数（Euler's Totient Function）
欧拉函数 $\varphi(n)$ 定义为：
**在 $1$ 到 $n$ 中**，**与 $n$ 互质**的正整数的个数。

即
$$
\varphi(n) = \left\lvert \{ k \in \mathbb{Z}^+ \mid 1 \le k \le n,\ \gcd(k,n)=1 \} \right\rvert
$$
## 欧拉函数的计算公式
设正整数 $n$ 的质因数分解为
$$
n = p_1^{k_1} p_2^{k_2} \cdots p_m^{k_m}
$$
其中 $p_i$ 为互不相同的**质数**，则
$$
\varphi(n) = n \left(1 - \frac{1}{p_1}\right)\left(1 - \frac{1}{p_2}\right)\cdots\left(1 - \frac{1}{p_m}\right)
$$
### 证明思路
* 先删去能被p1倍数的
* 删去p1和p2倍数的
* 删去p1、p2和p3倍数的
* 因此类推，**使用容斥原理避免重复删除**

### 证明过程

可以用“从 $1$ 到 $n$ 中，删去所有与 $n$ 不互质的数”这个思路，用容斥原理做一个很自然的证明。

设
$$
n=p_1^{k_1}p_2^{k_2}\cdots p_m^{k_m}
$$
其中 $p_1,p_2,\dots,p_m$ 是 $n$ 的全部不同质因子。

欧拉函数 $\varphi(n)$ 表示在 $1,2,\dots,n$ 中，与 $n$ 互质的正整数个数。
因此，我们只要统计：在 $1$ 到 $n$ 中，有多少个数 **不被任何一个 $p_i$ 整除**。

---

首先看全集
$$
{1,2,\dots,n}
$$
一共有 $n$ 个数。

对于每个质因子 $p_i$，设
$$
A_i={1\leq k\leq n:\ p_i\mid k}
$$
即 $A_i$ 表示“能被 $p_i$ 整除的数”的集合。

那么，与 $n$ 不互质的数，恰好就是落在并集
$$
A_1\cup A_2\cup\cdots\cup A_m
$$
中的那些数。
所以
$$
\varphi(n)=n-\left|A_1\cup A_2\cup\cdots\cup A_m\right|
$$

---

接下来用容斥原理计算这个并集的大小。

因为 $p_i\mid n$，所以在 $1$ 到 $n$ 中，能被 $p_i$ 整除的数有
$$
|A_i|=\frac{n}{p_i}
$$

同理，同时被 $p_i,p_j$ 整除的数，就是被 $p_ip_j$ 整除的数，因此有
$$
|A_i\cap A_j|=\frac{n}{p_ip_j}
$$

类似地，
$$|A_{i_1}\cap A_{i_2}\cap\cdots\cap A_{i_r}|
=\frac{n}{p_{i_1}p_{i_2}\cdots p_{i_r}}
$$
于是由容斥原理，

$$|A_1\cup\cdots\cup A_m|=\sum_{i}\frac{n}{p_i}
-\sum_{i<j}\frac{n}{p_ip_j}
+\sum_{i<j<k}\frac{n}{p_ip_jp_k}
-\cdots
+(-1)^{m+1}\frac{n}{p_1p_2\cdots p_m}
$$
因此

$$
\varphi(n)=n-\left|A_1\cup\cdots\cup A_m\right|
$$
就变成
$$
\varphi(n)=
n\left(
1-\sum_i\frac{1}{p_i}
+\sum_{i<j}\frac{1}{p_ip_j}
-\sum_{i<j<k}\frac{1}{p_ip_jp_k}
+\cdots
+(-1)^m\frac{1}{p_1p_2\cdots p_m}
\right)
$$
最后注意到，括号里的式子正好就是下面乘积展开后的结果：
$$
\left(1-\frac{1}{p_1}\right)\left(1-\frac{1}{p_2}\right)\cdots\left(1-\frac{1}{p_m}\right)
$$

所以得到
$$
\varphi(n)=n\left(1-\frac{1}{p_1}\right)\left(1-\frac{1}{p_2}\right)\cdots\left(1-\frac{1}{p_m}\right)
$$

这就是所要证明的公式。


## 试除法(定义法)求欧拉函数：1个数-$O(\log n)-O(\sqrt{n})$
[873. 欧拉函数](https://www.acwing.com/problem/content/875/)
### 实现
+ 素因子分解+定义
+ 防止溢出的技巧，先除后乘：**(1-1/p)=(p-1)/p=/p*(p-1)**

```cpp
void solve() {
	cin >> n;

	for (int i = 1; i <= n; i++) {
		int a;
		cin >> a;
		int res = a;
		for (int j = 2; j <= a / j; j++) {
			if (a % j == 0) {
				while (a % j == 0) {
					a /= j;
				}
				res = res / j *(j-1);
			}
		}
		if (a > 1) {
			res = res / a * (a - 1);
		}
		cout << res << endl;
	}
}
```

## 线性筛法求欧拉函数：n个数-$O(n)$
[874. 筛法求欧拉函数](https://www.acwing.com/problem/content/876/)

### 实现
+ 引入`phi`数组，`phi[i]`表示i的欧拉函数值
+ 注意：**素数p的欧拉函数值为p-1**，一定要记得赋值！一定要记得赋值！一定要记得赋值！
+ 如果`i % prime == 0`：则i已经**i包含prime这个素因子**(**素因子的次数不影响欧拉函数的值**)，所以根据欧拉的计算公式，只需要补齐prime即可(N=prime*i)
+ 如果`i % prime != 0`，则i不包含prime这个素因子，因此需要补齐prime和(1-1/prime)，化简得到就是prime-1.
```cpp
void solve() {
	cin >> n;
	for (int i = 2; i <= n; i++) {
		if (isprimes[i]) {
			phi[i] = i - 1;
			primes.push_back(i);
		}
		for (auto prime : primes) {
			if (prime > n / i)continue;// subscript out of range
			isprimes[prime * i] = 0;
			if (i % prime == 0) {
				phi[i * prime] = phi[i] * prime;
				break;
			}
			else {
				phi[i * prime] = phi[i] * (prime - 1);
			}
		}
	}
	ll res = 0;
	for (int i = 1; i <= n; i++) {
		res += (ll)phi[i];
	}
	cout << res;
}
```
