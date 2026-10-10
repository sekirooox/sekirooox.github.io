---
title: "数论·约数"
author: MayL
date: 2026-03-22
categories: ["数学基础与数学建模", "数学基础"]
tags: ["数学", "学习笔记"]
render_with_liquid: false
math: true
description: "本文整理“数论·约数”涉及的基本原理、计算方法与应用思路，便于学习复习和建模参考。"
---

@[toc]
# 约数 / 因子

## 数学定义
+ 在数论中，**约数等于因子**。
+ 例如对于12来说，约数有1，2，3，4，6，12。
+ 对于一个数x，任何能整除x的数都是x的约数。$a\in [1,x], a\mid x$



# 试除法求约数：$O(\sqrt{n})$
[869. 试除法求约数](https://www.acwing.com/problem/content/871/)
## 数学原理
+ 约数的对称性：**假设i是x的约数之一，那么x/i(注意可能与i相等)一定也是x的约数**。
+ 如果一个数 $n$ 是合数，它一定有一个小于等于 $\sqrt{n}$ 的因子。
+ **注意特判：i从1开始保证对于素数也成立**。

## 实现
```cpp
void get_divisors(int x) {
	set<int>res;
	for (int i = 1; i <= x / i; i++) {
		if (x % i == 0) {
			res.insert(i);
			res.insert(x / i);
		}
	}
	for (auto item : res) {
		cout << item << " ";
	}
	cout << endl;
}
```

# 约数的数量与约数之和
[871. 约数之和](https://www.acwing.com/problem/content/873/)
[870. 约数个数](https://www.acwing.com/problem/content/description/872/)
## 数学原理
算术基本定理（Fundamental Theorem of Arithmetic）指出：

**每个大于 1 的正整数 $n$ 都可以唯一地分解成有限个素数的乘积**，即

$$
n = p_1^{a_1} p_2^{a_2} \cdots p_k^{a_k}
$$

其中 $p_1 < p_2 < \cdots < p_k$ 是互不相同的素数，$a_1, a_2, \dots, a_k$ 是正整数。若忽略素因数的排列顺序，该分解是**唯一**的。

---


## 约数的数量：$O(\log n)-O(\sqrt{n})$
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/0e41f2977f3c4676afa6a7d11977b539.png){: referrerpolicy="no-referrer" }


+ 简单理解：**我们有的是素因子，但是我们可以通过组合素因子的方法得到合数因子！**
+ 注意：指数可以取0。

### 实现
+ 使用map存储一下素因子即可
```cpp
void solve() {
	cin >> n;
	for (int i = 1; i <= n; i++) {
		int a;
		cin >> a;
		for (int j = 2; j <= a / j; j++) {
			while (a % j == 0) {
				mp[j]++;
				a /= j;
			}
		}
		if (a > 1)mp[a]++;
		//for (auto item : mp) {
		//	cout << item.first << " " << item.second << endl;
		//}
		//cout << endl;
	}
	ll res = 1;
	for (auto item : mp) {
		res *= (ll)(item.second + 1);
		res %= mod;
	}
	cout << res;
}
```

## 约数之和：$O(\log n)-O(\sqrt{n})$
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/eeb9c695cc114df28893a7f06537aaf9.png){: referrerpolicy="no-referrer" }
+ 简单理解：既然我们知道**任何一个因子都可以由素因子组合得到**。因此我们**对所有因子进行求和，可以化简为对单个因子进行求和，最后乘积的形式**。
### 实现
+ **对单个因子求和的公式如下：$S_n=S_{n-1}*p+1$**，循环n次即可。
+ 最后分别乘在一起即可。

```cpp
int n;
unordered_map<int, int>mp;
void solve() {
	cin >> n;
	for (int i = 1; i <= n; i++) {
		int a;
		cin >> a;
		for (int j = 2; j <= a / j; j++) {
			while (a % j == 0) {
				mp[j]++;
				a /= j;
			}
		}
		if (a > 1)mp[a]++;
	}
	//for (auto item : mp) {
	//	cout << item.first << " " << item.second << endl;
	//}
	//cout << endl;
	ll res = 1;
	for (auto item : mp) {
		ll sum = 1;//S0
		int p = item.first;
		for (int i = 1; i <= item.second; i++) {
			sum = (ll)(sum * p) + 1;
			sum %= mod;
		}
		//cout << sum << endl;
		res = (res * sum) % mod;
	}
	cout << res;

}
```


# 最大公约数：$O(\log{\max{(a,b)}})$
[872. 最大公约数](https://www.acwing.com/problem/content/874/)


## 数学原理
+ $gcd(a,b)=gcd(b,r)$,where $a=bq+r$
+ **证明思路：a，b，r的公约数都是d。**
+ 假设d是a和b的公约数，那么证明d也是r和b的公约数；假设d是b和r的公约数，那么d也是a的公约数。使用**整除的线性性质即可**，`d|a,d|b -> d|ax+by`

### 实现
+ 注意gcd(a,0)定义为a。**a一定要大于b！a一定要大于b！a一定要大于b！**。
```cpp
int gcd(int x, int y) {// x>y
	if (y == 0)return x;
	else {
		return gcd(y, x % y);
	}
}
```
