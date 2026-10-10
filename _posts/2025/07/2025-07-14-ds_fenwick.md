---
title: "数据结构·数状数组(BIT)"
author: MayL
date: 2025-07-14
categories: ["算法与数据结构", "数据结构"]
tags: ["数据结构", "fenwick-tree", "算法", "学习笔记"]
render_with_liquid: false
math: true
description: "本文整理“数据结构·数状数组(BIT)”的核心思路、典型问题与实现要点，便于刷题复习和后续查阅。"
---

# 树状数组(Binary Index Tree)
>+ ### 英文名：使用二进制下标的树结构
>+ ### 理解：这个树实际上用数组来存，二进制下标就是将正常的下标拆为二进制来看。


## 求x的最低位1的函数`lowbit（x）`
+ 假设x的二进制表示为`x= ...10000`，其中**1是x的最低位1**，前面的位数我们不关心。则`-x=.....01111+1=10000`(取反+1)。
+ `x&-x=...10000&..01111+1=000000...10000`，因此我们可以得到**x的最低位1所对应的那个数**。
```cpp
int lowbit(int pos) {
	return pos & -pos;
}
```
## 树状数组的理解
+ `t[pos]`的含义：$t[pos]=\sum_{\{\forall x \mid x+lowbit(x)=pos\}}{t[x]}+a[pos]$。
+ 例如：$t[8=1000]=t[4=0100]+t[6=0110]+t[7=0111]+a[8]$，其中$a[8]$是原始数组第8个数。
+ 注意：不能通过$pos-lowbit(pos)$得到x。
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/9203012a34294d73a6e27f2396bee927.png){: referrerpolicy="no-referrer" }
## 建树
+ 由于不能通过$pos-lowbit(pos)$反过来确定x，所以我们要**从x开始累加**`lowbit(x)`向上更新，这一步相当于前缀和的累积。
```cpp
void build(int pos,int val) {
	while (pos<=n) {
		t[pos] += val;
		pos += lowbit(pos);
	}
}
```

## 查询
+ 由于`t[pos]`的含义**不能很好确定**，因此只能采取笨方法，不断**递减**`lowbit(pos)`获得`a[1] to a[pos]`的前缀和，然后再来求某一区间的和。
```cpp
int query(int pos) {
	int sum = 0;
	while (pos >0) {
		sum += t[pos];
		pos -= lowbit(pos);
	}
	return sum;
}
```

# 适用问题
> ### 前缀和数组支持$O(1)$的区间和查询，但是不支持动态的区间修改
> ### 差分数组支持$O(1)$的区间修改，但是不支持动态的单点求值
> ### 树状数组相当于是一个折中，区间修改和查询的复杂度为$O(logn)$


# 例题：
+ [P3374 【模板】树状数组 1](https://www.luogu.com.cn/problem/P3374)：动态区间修改和区间求和。**树状数组作为前缀和**。
+ [P3368 【模板】树状数组 2](https://www.luogu.com.cn/problem/P3368)：动态区间修改和输出单一数组值。**树状数组作为差分数组**。
+ [P1908 逆序对](https://www.luogu.com.cn/problem/P1908)：暴力解法的优化。




