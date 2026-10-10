---
title: "图论·并查集 (未完)"
author: MayL
date: 2025-03-16
categories: ["算法与数据结构", "图论"]
tags: ["图论", "并查集", "算法", "学习笔记"]
render_with_liquid: false
math: true
description: "本文整理“图论·并查集 (未完)”的核心思路、典型问题与实现要点，便于刷题复习和后续查阅。"
---

# 并查集

## 核心思想：集合合并($O(1)$)，集合查询(~$O(1)$)和集合判断($O(1)$)的高效数据结构
+ 关键是集合合并，暴力方法需要$O(n)$复杂度。
+ 图论中的应用：**是否存在回路，图是否有连通性**
+ 其他应用：两个**元素之间是否存在关系**，可以建模为图论中的连通性

## 例题
总结：
并查集**往往不定义为一个类使用，因为merge和find操作很多时候都需要重写**。 
例如，find和merge操作都可以用于维护其他信息。
```cpp
void merge(int x, int y) {
	x = find(x);
	y = find(y);
	fa[x] = y;
	if (x != y) {
		sizes[y] += sizes[x];
	}
}
```
---

## 边带权的并查集：考虑与根节点的权值
+ 每一个结点维护其到根结点的权值，例如**与根结点的距离等等**
+ 
+ 合并操作：考虑两个集合根结点的权值合并。
+ 路径压缩操作：更新**非根结点的权值**
+ 注意：**只有集合(子集)的根节点**的权值是一定有效的，**非根结点不一定有效**。
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/73eb50bc5c5c47d7ababa3f49a3ad495.png){: referrerpolicy="no-referrer" }


### 例题
+ [AcWing 837. 连通块中点的数量](https://www.acwing.com/activity/content/problem/content/886/)：并查集中元素的利用，不定义为类使用，重写find和merge方法。

+ [P1196 [NOI2002] 银河英雄传说](https://www.luogu.com.cn/problem/P1196#submit)：**depth表示距离根结点的距离**

+ [240. 食物链](https://www.acwing.com/problem/content/description/242/)：*未完成*。
+ [P1955 [NOI2015] 程序自动分析](https://www.luogu.com.cn/problem/P1955)：相等的元素放在同一个集合，最后比较不相等的元素是否出现在同一集合当中。这题还需要使用离散化的技巧，将下标i和j离散化为有限数组。时间复杂度接近10^8。


```cpp
int n,t,flag=1;
typedef struct node {
	int x, y, e;
};
node edges[100009];

int a[200009] = { 0 }, lena = 0, fa[200009];
void init() {
	for (int i = 1; i <= 2*n; i++) {// i*n + j*n
		fa[i] = i;
	}
}
int find(int x) {
	if (fa[x] == x) {
		return x;
	}
	else {
		return fa[x] = find(fa[x]);
	}
}
void merge(int x, int y) {
	x = find(x);
	y = find(y);
	fa[x] = y;
}
bool issame(int x, int y) {
	return find(x) == find(y);
}
void printout() {
	for (int i = 1; i <= 2 * n; i++)cout << fa[i] << " ";
	cout << endl;
}
// 1.store e=1 into uset 2.check e=0
void solve() {
	cin >> t;
	for (int i = 1; i <= t; i++) {
		cin >> n;
		init();// 2*n
		//printout();

		memset(a, 0, sizeof(a));
		lena = 0;
		flag = 1;

		// input
		for (int j = 1; j <= n; j++) {
			cin >> edges[j].x >> edges[j].y >> edges[j].e;
			a[++lena] = edges[j].x;
			a[++lena] = edges[j].y;
		}

		// discrete
		sort(a + 1, a + lena + 1);
		lena = unique(a + 1, a + lena + 1) - a - 1;

		//for (int j = 1; j <= lena; j++) {
		//	cout << a[j] << " ";
		//}
		//cout << endl;

		for (int j = 1; j <= n; j++) {
			if (edges[j].e) {
				//find new idx
				int idx_x = lower_bound(a + 1, a + lena + 1, edges[j].x) - a;
				int idx_y = lower_bound(a + 1, a + lena + 1, edges[j].y) - a;
				merge(idx_x, idx_y);
			}
		}

		for (int j = 1; j <= n; j++) {
			if (!edges[j].e) {
				int idx_x = lower_bound(a + 1, a + lena + 1, edges[j].x) - a;
				int idx_y = lower_bound(a + 1, a + lena + 1, edges[j].y) - a;
				if (issame(idx_x, idx_y)) {
					flag = 0;
					break;
				}
			}
		}
		if (flag)cout << "YES" << endl;
		else cout << "NO" << endl;
		
	}
	
}
```

