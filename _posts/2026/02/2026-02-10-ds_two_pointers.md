---
title: "算法基础·双指针算法"
author: MayL
date: 2026-02-10
categories: ["算法与数据结构", "算法"]
tags: ["算法", "学习笔记"]
render_with_liquid: false
math: true
description: "本文整理“算法基础·双指针算法”的核心思路、典型问题与实现要点，便于刷题复习和后续查阅。"
---

# 双指针算法
>通用模板，适用于**快慢指针和左右指针**
>**如何推断双指针的单调性：反证法**
>特点：将$O(n^2)$的暴力方法优化为$O(n)$
+ 确定**两个指针的移动方向一定是单调的，但不一定要一致的**。
+ 左右指针：**i往右走，j往左走**。
+ 快慢指针：**i和j都往右走**，但是i比j快。
```cpp
for(int i=1,j=1;i<=n;i++){
	while(j<i&&check(j,i)){
		j++; // or j--
	}
}
```

# 例题
+ [AcWing 799. 最长连续不重复子序列](https://www.acwing.com/activity/content/problem/content/833/)：模板题
+ [800. 数组元素的目标和](https://www.acwing.com/problem/content/802/)：A+B问题，单调性
+ [977.有序数组的平方](https://leetcode.cn/problems/squares-of-a-sorted-array/)：左右指针，i和j相向运动
+ [27. 移除元素](https://leetcode.cn/problems/remove-element/)
+ [2816. 判断子序列](https://www.acwing.com/problem/content/2818/)
+ [209.长度最小的子数组](https://leetcode.cn/problems/minimum-size-subarray-sum/)


