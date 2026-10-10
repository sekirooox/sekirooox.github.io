---
title: "数据结构·ST表"
author: MayL
date: 2025-05-10
categories: ["算法与数据结构", "数据结构"]
tags: ["数据结构", "sparse-table", "算法", "学习笔记"]
render_with_liquid: false
math: true
description: "本文整理“数据结构·ST表”的核心思路、典型问题与实现要点，便于刷题复习和后续查阅。"
---

# ST表(Sparse Table)
## 可重复贡献问题
+ $x \ opt\ x = x$ ：如果两个区间重复计算某些元素时，对**重复元素**进行$opt$操作**没有任何影响**
## 理解
>ST表的思想是倍增，**每一次处理上一次处理的两倍的元素**，倍增的方式有重叠部分，**如果重叠部分可重复贡献，则倍增的思路是正确的。**
+ 长度：`int len=log2(n)`,向下取整，避免出现无效元素参与计算
+ 构造时的递推公式：`amax[j][m] = max(amax[j - 1][m], amax[j - 1][m + (1 << j - 1)])`，例子：**第3层第1个元素，由第2层第1，2，3个元素累积得到**，其中第二个元素出现重复。
+ query：`max(amax[len][l], amax[len][r - (1 << len) + 1])`，首先查询当前层l处的元素，然后考虑当前层代表了$2^{len}$个元素，由第一层元素反推第`len`层元素。
## 模板
+ init()操作：$O(nlogn)$复杂度
```cpp
		int len = log2(n);
		for (int j = 1; j <= len; j++) {
			for (int m = 1; m <= n - (1 << j) + 1; m++) {
				amax[j][m] = max(amax[j - 1][m], amax[j - 1][m + (1 << j - 1)]);
				amin[j][m] = min(amin[j - 1][m], amin[j - 1][m + (1 << j - 1)]);
			}
		}
```

+ query()操作:$O(1)$，**仅仅支持静态查询，不支持任意修改方式**

```cpp
int query(int l,int r,int flag) {//flag==1 max
	int len = log2(r - l + 1);
	if (flag)return max(amax[len][l], amax[len][r - (1 << len) + 1]);
	return min(amax[len][l], amax[len][r - (1 << len) + 1]);
}
```
+ 优化：**log2操作比较费时**，所以可以采用dp方式优化该运算。

```cpp
lg[0]=-1;
for(int i=1;i<=n;i++)lg[i]=lg[i>>1]+1;
```
# 例题
+ [P3865 【模板】ST 表 && RMQ 问题](https://www.luogu.com.cn/problem/P3865)
+ [P2880 [USACO07JAN] Balanced Lineup G](https://www.luogu.com.cn/problem/P2880)：模板题
+ ## [P7333 [JRKSJ R1] JFCA](https://www.luogu.com.cn/problem/P7333)：环的处理，二分的选择。
+ [P8818 [CSP-S 2022] 策略游戏](https://www.luogu.com.cn/problem/P8818)
+ ## [P10059 Choose](https://www.luogu.com.cn/problem/P10059)：二分，注意到当L=n-k+1时，就能取到X的最大值，且L的取值与取到X的最大值有**单调关系**，使用二分。

