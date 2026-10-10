---
title: "数论·快速幂和逆元"
author: MayL
date: 2026-03-22
categories: ["数学基础与数学建模", "数学基础"]
tags: ["数学", "学习笔记"]
render_with_liquid: false
math: true
description: "本文整理“数论·快速幂和逆元”涉及的基本原理、计算方法与应用思路，便于学习复习和建模参考。"
---

@[toc]
# 快速幂：$O(\log b)$
[875. 快速幂](https://www.acwing.com/problem/content/877/)
## 数学定义
目标函数：$$a^b mod p$$
其中a，b，p的值都非常大(1e9+)

快速幂是一种用来**高效计算幂**的方法。
如果直接计算 $a^b$，需要做 $b-1$ 次乘法，时间复杂度是 $O(b)$；
而快速幂利用**指数的二进制拆分性质**，可以把时间复杂度降为 $O(\log b)$。

### 数学原理
任意整数 $b$ 都可以写成二进制形式：
$b = \sum_{i=0}^{k} c_i 2^i \quad (c_i \in {0,1})$

因此，

$a^b = a^{\sum c_i 2^i} = \prod_{i=0}^{k} a^{c_i 2^i}$

因为 $c_i$ 只可能是 $0$ 或 $1$，所以实际上只需要把那些二进制位上为 $1$ 的幂乘起来即可。

例如若

$b = 13 = (1101)_2 = 8 + 4 + 1$

那么

$a^{13} = a^8 \cdot a^4 \cdot a^1$

这就是快速幂的本质：
### 实现

代码中用了三个变量：

* `pow`：当前底数，表示当前处理到的幂次
* `res`：当前答案
* `b`：指数，每次右移一位
* 注意：**一定要开long long！！！一定要开long long！！！一定要开long long！！！**
```cpp
ll qmi(int a, int b, int p) {
	ll pow = a, res = 1;
	while (b) {
		if (b & 1) {
			res = res * pow % p;
		}
		pow = pow * pow % p;
		b = b >> 1;
	}
	return res;
}
```

# 逆元
[876. 快速幂求逆元](https://www.acwing.com/problem/content/878/)

## 数学定义

对于整数 $a$ 和模数 $p$，如果存在整数 $x$，使得

$$
a \cdot x \equiv 1 \pmod{p}
$$

则称 $x$ 是 $a$ 在模 $p$ 意义下的**乘法逆元**（简称**逆元**），记作：

$$
a^{-1} \equiv x \pmod{p}
$$

**存在条件：**

$$
\gcd(a, p) = 1
$$

否则逆元不存在。

---

## 费马小定理

###  定理内容

若 $p$ 是质数，且 $\gcd(a,p)=1$，则：

$$
a^{p-1} \equiv 1 \pmod{p}
$$



###  失效条件

费马小定理及其逆元形式**必须满足以下条件**：

1. $p$ 必须是**质数**
2. $a \not\equiv 0 \pmod{p}$（即 $\gcd(a,p)=1$）

若不满足：

* 当 $p$ 不是质数 → 公式不成立
* **当 $a \equiv 0 \pmod{p}$ → 逆元不存在**





## 快速幂求逆元：$O(\log p)$
### 数学原理
基于公式：

$$
a^{-1} \equiv a^{p-2} \pmod{p}
$$


1. **判断是否存在逆元**

   * 若 $a \equiv 0 \pmod{p}$，输出 `"impossible"`



2. **转化为幂运算**

   * 将问题转化为计算：

     $$
     a^{p-2} \bmod p
     $$


```cpp
ll qmi(int a, int b, int p) {
	ll res = 1, pow = a;
	while (b) {
		if (b & 1) {
			res = res * pow % p;
		}
		b >>= 1;
		pow = pow * pow% p;
	}
	return res;
}
void solve() {
	cin >> n;
	for (int i = 1; i <= n; i++) {
		int a, p;
		cin >> a >>  p;
		if (a % p) {
			cout << qmi(a, p - 2, p) << endl;
		}
		else {
			cout << "impossible" << endl;
		}
	}
}
```

