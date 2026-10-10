---
title: "算法·字符串哈希"
author: MayL
date: 2026-03-14
categories: ["算法与数据结构", "算法"]
tags: ["字符串", "算法", "学习笔记"]
render_with_liquid: false
math: true
description: "本文整理“算法·字符串哈希”的核心思路、典型问题与实现要点，便于刷题复习和后续查阅。"
---

# 字符串哈希 (字符串前缀哈希法)

## 用法：查询任意子串的哈希值，哈希值近似认为唯一
## 基本思想
+ 将字符串的前缀看作一个**p进制数**，其中**p一般为131**，**左边为高位，右边为低位(不要搞反了！！！)**
+ 为了避免数值过大使用Q=$2^{64}$来当作余数，一般使用unsigned long long，**使用上溢操作来近似这一步。**


## 实现
### 动态规划法初始化hash数组和指数
注意：`s = '0' + s;// 0,n+1`
```cpp
	for (int i = 1; i <= n; i++) {
		h[i] = h[i - 1] * 131 + s[i];
		p[i] = p[i - 1] * 131;
	}
```

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/3a6cc5f3aabe46f0b349c647b42a1311.png){: referrerpolicy="no-referrer" }
---
### 获得任意子串[i,j]的字符串哈希
```cpp
ll query(int l, int r) {
	return h[r] - h[l-1] * p[r - l+1];
}
```
+ h[i-1]，h[j]分别为[0,i-1]，[0,j]部分的字符串对应的哈希值
+ 很显然**将h[i-1]左移动j-i+1位就能与h[j]对齐**，这样就能完美消去前i-1位数字，得到的剩余结果就是子串的哈希值。
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/cd3ea685a82f48b49ec63e88333f0284.png){: referrerpolicy="no-referrer" }



## 例题
+ [AcWing 841. 字符串哈希](https://www.acwing.com/problem/content/843/)
+ [831. KMP字符串](https://www.acwing.com/problem/content/description/833/)：**使用字符串哈希的方法来处理KMP**

```cpp
int n, m;
int P = 131;
ll p[1000006] = { 1 }, h[1000006] = { 0 };
string a, b;
ll query(int l, int r) {
	return h[r] - h[l - 1] * p[r - l + 1];
}
void solve() {
	cin >> n >> a >> m >> b;
	a = '0' + a;
	b = '0' + b;
	for (int i = 1; i <= m; i++) {
		h[i] = h[i - 1] * P + b[i];
		p[i] = P * p[i - 1];
	}
	//for (int i = 1; i <= m; i++) {
	//	cout << h[i] << " " << p[i] << endl;
	//}
	ll hasha = 0;
	for (int i = 1; i <= n; i++) {
		hasha = hasha * P + a[i];
	}
	//cout << hasha << endl;

	for (int i = 1; i <= m - n +1 ; i++) {
		if (query(i, i + n - 1) == hasha) {
			cout << i-1 << " ";
		}
	}
}
```

