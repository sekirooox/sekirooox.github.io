---
title: "算法·前缀和,差分"
author: MayL
date: 2024-07-12
categories: ["算法与数据结构", "算法"]
tags: ["前缀和", "差分", "算法", "学习笔记"]
render_with_liquid: false
math: true
description: "本文整理“算法·前缀和,差分”的核心思路、典型问题与实现要点，便于刷题复习和后续查阅。"
---

# 前缀和
 + ## 主要思想：整体和局部，通过局部处理来修改整体。
+ ## 区域求和
+ ## 配合差分区间修改
## 前缀和的定义
+ 定义原数组`a[n]`,
+ 前缀和数组`b[n]=a[n]+b[n-1]`,n>=1
>注意这是一个以序列0~n定义的数组，一般来说，如果下标从1开始，我们需要**提前定义下标为0的元素**,防止指针异常
---
## 模板
+ 第一种模板：前缀和数组标准求法
```cpp
for (int i = 1; i <= n; i++) {
        prefix[i] = prefix[i - 1] + a[i];
    }
```
+ 第二种模板：直接在原数组上求前缀和
```cpp
for (int i = 1; i <= n; i++) {
        a[i]+=a[i-1];
    }
```
## 二维前缀和
+ ### 二维空间上的面积求和
+ ### 二维空间上的面积修改
### 二维前缀和的定义
+ 基于容斥原理：`b[i][j]=a[i][j]+b[i][j-1]+b[i-1][j]-b[i-1][j-1];`

---
# 差分
+ ## 核心思想：前缀和的逆运算，求前缀和得到原数组(推导公式的来源)
+ ## 区间修改
+ ## 只支持先修改后输出，不支持边修改边输出
## 差分的定义
+ 定义差分数组diff：`diff[i]=a[i]-a[i-1],i>=1`
+ 定义区间[L,R]上的修改操作：`diff[L]+=c,diff[R+1]-=c`
## 二维差分数组的定义
+ ### 通过前缀和得到原数组：`diff[i][j]=a[i][j]-a[i-1][j]-a[i][j]+a[i-1][j-1]`
+ `a[i][j]`为原数组，可以看出就是**二维前缀和的求区间和**公式的特例:(`x_1=x_2,y_1=y_2`)
## 二维区间修改的理解：
+ ### 由差分数组定义得到，修改`diff[i][j]`会影响其右下角的矩形面积
+ ### 原因：该点由上边和左边的值共同决定
```cpp
diff[x1][y1]+=c
diff[x1][y2+1]-=c;
diff[x2+1][y1]-=c;
diff[x2][y2]+=c
```

# 离散化
+ ## 节约内存的一种手段
+ ## 本质不是一种算法
## 核心操作
+ ### 使用新数组存储过大的元素
+ ### 找到元素与位置的映射，对这个映射关系进行处理!

---
<br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br>
# 【深进1.例1】求区间和

## 题目描述

给定 $n$ 个正整数组成的数列 $a_1, a_2, \cdots, a_n$ 和 $m$ 个区间 $[l_i,r_i]$，分别求这 $m$ 个区间的区间和。

对于所有测试数据，$n,m\le10^5,a_i\le 10^4$

## 输入格式

第一行，为一个正整数 $n$ 。

第二行，为 $n$ 个正整数 $a_1,a_2, \cdots ,a_n$

第三行，为一个正整数 $m$ 。

接下来 $m$ 行，每行为两个正整数 $l_i,r_i$ ，满足$1\le l_i\le r_i\le n$

## 输出格式

共 $m$ 行。

第 $i$ 行为第 $i$ 组答案的询问。

## 样例 #1

### 样例输入 #1

```
4
4 3 2 1
2
1 4
2 3
```

### 样例输出 #1

```
10
5
```
## 解题思路
```cpp
using namespace std;
using ll = long long;
int n,m,l,r; 
vector<int>a(100009, 0);
vector<int>prefix(100009, 0);
void solve() {
    cin >> n;
    for (int i = 1; i <= n; i++) {
        cin >> a[i];
    }
    for (int i = 1; i <= n; i++) {
        prefix[i] = prefix[i - 1] + a[i];
    }
    cin >> m;
    while (m--) {
        cin >> l >> r;
        cout << prefix[r] - prefix[l-1]<<endl;
    }
}
signed main() {
    std::ios::sync_with_stdio(false);
    std::cin.tie(0); std::cout.tie(0);
    solve();
    return 0;
}
```
<br><br><br><br>

---
以下是例题
# 最大加权矩形

## 题目描述

为了更好的备战 NOIP2013，电脑组的几个女孩子 LYQ,ZSC,ZHQ 认为，我们不光需要机房，我们还需要运动，于是就决定找校长申请一块电脑组的课余运动场地，听说她们都是电脑组的高手，校长没有马上答应他们，而是先给她们出了一道数学题，并且告诉她们：你们能获得的运动场地的面积就是你们能找到的这个最大的数字。

校长先给他们一个 $n\times n$ 矩阵。要求矩阵中最大加权矩形，即矩阵的每一个元素都有一权值，权值定义在整数集上。从中找一矩形，矩形大小无限制，是其中包含的所有元素的和最大 。矩阵的每个元素属于 $[-127,127]$ ,例如

```plain
 0 –2 –7  0 
 9  2 –6  2
-4  1 –4  1 
-1  8  0 –2
```

在左下角：

```plain
9  2
-4  1
-1  8
```

和为 $15$。

几个女孩子有点犯难了，于是就找到了电脑组精打细算的 HZH，TZY 小朋友帮忙计算，但是遗憾的是他们的答案都不一样，涉及土地的事情我们可不能含糊，你能帮忙计算出校长所给的矩形中加权和最大的矩形吗？

## 输入格式

第一行：$n$，接下来是 $n$ 行 $n$ 列的矩阵。

## 输出格式

最大矩形（子矩阵）的和。

## 样例 #1

### 样例输入 #1

```
4
0 -2 -7 0
 9 2 -6 2
-4 1 -4  1 
-1 8  0 -2
```

### 样例输出 #1

```
15
```
## 解题思路
+ 二维前缀和+枚举
```cpp
using namespace std;
using ll = long long;
int n,ans=0;
vector<vector<int>>grid(150, vector<int>(150, 0));
vector<vector<int>>prefix(150, vector<int>(150, 0));
void solve() {
    cin >> n;
    for (int i = 1; i <= n; i++) {
        for (int j = 1; j <= n; j++) {
            cin >> grid[i][j];
        }
    }
    for (int i = 1; i <= n; i++) {
        for (int j = 1; j <= n; j++) {
            prefix[i][j] = grid[i][j] + prefix[i][j - 1] + prefix[i - 1][j] - prefix[i - 1][j - 1];
        }
    }
    /*for (int i = 1; i <= n; i++) {
        for (int j = 1; j <= n; j++) {
            cout << prefix[i][j] << " ";
        }
        cout << endl;
    }*/
    for (int i = 1; i <= n; i++) {
        for (int j = 1; j <= n; j++) {
            for (int k = 1; k <= i; k++) {//从i，j开始枚举面积
                for (int t = 1; t <= j; t++) {
                    ans = max(ans, prefix[i][j] - prefix[i - k][j] - prefix[i][j - t] + prefix[i - k][j - t]);
                }
            }
        }
    }
    cout << ans;
}
signed main() {
    std::ios::sync_with_stdio(false);
    std::cin.tie(0); std::cout.tie(0);
    solve();
    return 0;
}
```

## 提示

$1 \leq n\le 120$
# 最大正方形
## 题目描述

在一个 $n\times m$ 的只包含 $0$ 和 $1$ 的矩阵里找出一个不包含 $0$ 的最大正方形，输出边长。

## 输入格式

输入文件第一行为两个整数 $n,m(1\leq n,m\leq 100)$，接下来 $n$ 行，每行 $m$ 个数字，用空格隔开，$0$ 或 $1$。

## 输出格式

一个整数，最大正方形的边长。

## 样例 #1

### 样例输入 #1

```
4 4
0 1 1 1
1 1 1 0
0 1 1 0
1 1 0 1
```

### 样例输出 #1

```
2
```
## 解题思路
+ 前缀和+二分枚举

```cpp
using namespace std;
using ll = long long;
int n, m,ans=0;
vector<vector<int>>grid(100 + 9, vector<int>(100 + 9, 0));
bool isValid(int x) {
    for (int i = x; i <= n; i++) {
        for (int j = x; j <= m; j++) {
            if (grid[i][j] - grid[i - x][j] - grid[i][j - x] + grid[i - x][j - x]==x*x) {
                return true;
            }
        }
    }
    return false;
}
void solve() {
    cin >> n >> m;
    
    for (int i = 1; i <= n; i++) {
        for (int j = 1; j <= m; j++) {
            cin >> grid[i][j];
        }
    }
    //前缀和数组最好从1开始，这样不用下标为0分类讨论
    for (int i = 1; i <= n; i++) {
        for (int j = 1; j <= m; j++) {
            grid[i][j] = grid[i][j] + grid[i - 1][j] + grid[i][j - 1] - grid[i - 1][j - 1];
        }
    }
    int l = 1, r = min(m, n),mid=0;
    while (l <= r) {
        mid = (l + r) / 2;
        if (isValid(mid)) {
            ans = mid;
            l = mid + 1;
        }
        else {
            r = mid - 1;
        }
    }
    cout << ans;
}
signed main() {
    std::ios::sync_with_stdio(false);
    std::cin.tie(0); std::cout.tie(0);
    solve();
    return 0;
}
```
# [HNOI2003] 激光炸弹

## 题目描述

一种新型的激光炸弹，可以摧毁一个边长为 $m$ 的正方形内的所有目标。现在地图上有 $n$ 个目标，用整数 $x_i$ , $y_i$ 表示目标在地图上的位置，每个目标都有一个价值 $v_i$。激光炸弹的投放是通过卫星定位的，但其有一个缺点，就是其爆破范围，即那个边长为 $m$ 的边必须与 $x$ 轴，$y$ 轴平行。若目标位于爆破正方形的边上，该目标不会被摧毁。

现在你的任务是计算一颗炸弹最多能炸掉地图上总价值为多少的目标。

可能存在多个目标在同一位置上的情况。

## 输入格式

输入的第一行为整数 $n$ 和整数 $m$；

接下来的 $n$ 行，每行有 $3$ 个整数 $x, y, v$，表示一个目标的坐标与价值。

## 输出格式

输出仅有一个正整数，表示一颗炸弹最多能炸掉地图上总价值为多少的目标（结果不会超过 $32767$ ）。

## 样例 #1

### 样例输入 #1

```
2 1
0 0 1
1 1 1
```

### 样例输出 #1

```
1
```

## 解题思路
+ 枚举+二维前缀和
```cpp
#include<bits/stdc++.h>
using namespace std;
using ll = long long;
int n, m, x, y, v;
ll ans = 0;
void solve() {
    cin >>n>> m;
    vector<vector<int>>grid(5009, vector<int>(5009,0));
    while (n--) {
        cin >> x >> y >> v;
        grid[x+1][y+1] += v;
    }
    for (int i = 1; i <= 5001; i++) {
        for (int j = 1; j <= 5001; j++) {
            grid[i][j] +=grid[i - 1][j] + grid[i][j - 1] - grid[i - 1][j - 1];
        }
    }
    for (int i = m; i <= 5001; i++) {
        for (int j = m; j <= 5001; j++) {
            ans = max(ans,ll(grid[i][j] - grid[i - m][j] - grid[i][j - m] + grid[i - m][j - m]));
        }
    }
    cout << ans;
}
signed main() {
    std::ios::sync_with_stdio(false);
    std::cin.tie(0); std::cout.tie(0);
    solve();
    return 0;
}
```



<br><br><br><br>

---
以下是例题
# 语文成绩

## 题目背景

语文考试结束了，成绩还是一如既往地有问题。

## 题目描述

语文老师总是写错成绩，所以当她修改成绩的时候，总是累得不行。她总是要一遍遍地给某些同学增加分数，又要注意最低分是多少。你能帮帮她吗？

## 输入格式

第一行有两个整数 $n$，$p$，代表学生数与增加分数的次数。

第二行有 $n$ 个数，$a_1 \sim a_n$，代表各个学生的初始成绩。

接下来 $p$ 行，每行有三个数，$x$，$y$，$z$，代表给第 $x$ 个到第 $y$ 个学生每人增加 $z$ 分。

## 输出格式

输出仅一行，代表更改分数后，全班的最低分。

## 样例 #1

### 样例输入 #1

```
3 2
1 1 1
1 2 1
2 3 1
```

### 样例输出 #1

```
2
```
## 个人题解

```cpp
#include<bits/stdc++.h>
using namespace std;
using ll = long long;
int n,p,ans=INT_MAX;
void solve() {
    cin >> n >> p;
    vector<int>a(n + 9, 0);
    vector<int>diff(n + 9, 0);
    vector<int>prefix(n + 9, 0);
    for (int i = 1; i <= n; i++)cin >> a[i];
    for (int i = 1; i <= n; i++)diff[i] = a[i] - a[i - 1];
    int x, y, z;
    while (p--) {
        cin >> x >> y>>z;
        diff[x] += z;
        diff[y + 1] -= z;
    }
    for (int i = 1; i <= n; i++) {
        prefix[i] = diff[i] + prefix[i - 1];
        ans = min(prefix[i], ans);
    }
    cout << ans;
}
signed main() {
    std::ios::sync_with_stdio(false);
    std::cin.tie(0); std::cout.tie(0);
    solve();
    return 0;
}
```



<br><br><br><br>

---
以下是例题
# 地毯
## 题目描述

在 $n\times n$ 的格子上有 $m$ 个地毯。

给出这些地毯的信息，问每个点被多少个地毯覆盖。

## 输入格式

第一行，两个正整数 $n,m$。意义如题所述。

接下来 $m$ 行，每行两个坐标 $(x_1,y_1)$ 和 $(x_2,y_2)$，代表一块地毯，左上角是 $(x_1,y_1)$，右下角是 $(x_2,y_2)$。

## 输出格式

输出 $n$ 行，每行 $n$ 个正整数。

第 $i$ 行第 $j$ 列的正整数表示 $(i,j)$ 这个格子被多少个地毯覆盖。

## 样例 #1

### 样例输入 #1

```
5 3
2 2 3 3
3 3 5 5
1 2 1 4
```

### 样例输出 #1

```
0 1 1 1 0
0 1 1 0 0
0 1 2 1 1
0 0 1 1 1
0 0 1 1 1
```

## 提示

### 样例解释

覆盖第一个地毯后：

|$0$|$0$|$0$|$0$|$0$|
|:-:|:-:|:-:|:-:|:-:|
|$0$|$1$|$1$|$0$|$0$|
|$0$|$1$|$1$|$0$|$0$|
|$0$|$0$|$0$|$0$|$0$|
|$0$|$0$|$0$|$0$|$0$|

覆盖第一、二个地毯后：

|$0$|$0$|$0$|$0$|$0$|
|:-:|:-:|:-:|:-:|:-:|
|$0$|$1$|$1$|$0$|$0$|
|$0$|$1$|$2$|$1$|$1$|
|$0$|$0$|$1$|$1$|$1$|
|$0$|$0$|$1$|$1$|$1$|

覆盖所有地毯后：

|$0$|$1$|$1$|$1$|$0$|
|:-:|:-:|:-:|:-:|:-:|
|$0$|$1$|$1$|$0$|$0$|
|$0$|$1$|$2$|$1$|$1$|
|$0$|$0$|$1$|$1$|$1$|
|$0$|$0$|$1$|$1$|$1$|

---
## 解题思路
+ 二维差分模板题
```cpp
#include<bits/stdc++.h>
using namespace std;
using ll = long long;
int n, m;
void solve() {
    cin >> n >> m;
    //这题权值默认为0，本来就是差分数组
    vector<vector<int>>diff(n + 9, vector<int>(n + 9, 0));
    vector<vector<int>>pre(n + 9, vector<int>(n + 9, 0));
    int x1, y1, x2, y2;
    while (m--) {
        cin >> x1 >> y1 >> x2 >> y2;
        diff[x1][y1] += 1;
        diff[x1][y2 + 1] -= 1;
        diff[x2 + 1][y1] -= 1;
        diff[x2 + 1][y2 + 1] += 1;
    }
    for (int i = 1; i <= n; i++) {
        for (int j = 1; j <= n; j++) {
            diff[i][j] += diff[i - 1][j] + diff[i][j - 1] - diff[i - 1][j - 1];
            cout << diff[i][j] << " ";
        }
        cout << endl;
    }
    
}
signed main() {
    std::ios::sync_with_stdio(false);
    std::cin.tie(0); std::cout.tie(0);
    solve();
    return 0;
}
```
---
# [Poetize6] IncDec Sequence
## 题目描述

给定一个长度为 $n$ 的数列 ${a_1,a_2,\cdots,a_n}$，每次可以选择一个区间$[l,r]$，使这个区间内的数都加 $1$ 或者都减 $1$。 
  
请问至少需要多少次操作才能使数列中的所有数都一样，并求出在保证最少次数的前提下，最终得到的数列有多少种。

## 输入格式

第一行一个正整数 $n$   
接下来 $n$ 行,每行一个整数,第 $i+1 $行的整数表示 $a_i$。

## 输出格式

第一行输出最少操作次数   
第二行输出最终能得到多少种结果

## 样例 #1

### 样例输入 #1

```
4
1
1
2
2
```

### 样例输出 #1

```
1
2
```
## 解题思路
+ 差分+贪心

```cpp
using namespace std;
using ll = long long;
int n;
ll p = 0, q = 0;//p正q负
vector<int>vec(100009, 0);
vector<int>diff(100009, 0);
void solve() {
    cin >> n;
    for (int i = 1; i <= n; i++) {
        cin >> vec[i];
        diff[i] = vec[i] - vec[i - 1];
        if (i>1&&diff[i] > 0) {//第一个不能随便消
            p += diff[i];
        }
        if (i>1&&diff[i] < 0) {
            q -=(diff[i]);
        }
    }
    cout << min(p, q) + abs(p - q) << endl;
    cout << abs(p - q) + 1;
  /*  for (int i = 1; i <= n; i++) {
        cout << diff[i] << " ";
    }
    cout << endl;*/
}
signed main() {
    std::ios::sync_with_stdio(false);
    std::cin.tie(0); std::cout.tie(0);
    solve();
    return 0;
}
```
---
<br><br><br><br><br><br>
# 例题：
+ [P2004 领地选择](https://www.luogu.com.cn/problem/P2004)：一看到**区间和**就想到了前缀和(2D)
+ [P3406 海底高铁](https://www.luogu.com.cn/problem/P3406)：首先这个**肯定是贪心**，但是具体要比较某一段铁路走过多少次，这一操作就用到的差分这一**区间修改**的预处理了。

```cpp
	for (int i = 1; i <= m-1; i++) {
		if (p[i] > p[i+1]) {//p[i]开头++ p[i+1]开头 -- 
			diff[p[i + 1]]++;
			diff[p[i]]--;
		}
		else {
			diff[p[i]]++;
			diff[p[i + 1]]--;
		}
	}
```
+ [P1083 [NOIP 2012 提高组] 借教室](https://www.luogu.com.cn/problem/P1083)：这道题很容易想到使用**差分修改**某一段区间剩下的教室数量。但是难点在于**不能实时输出结果是否为0**，会超时。这时可以考虑使用二分的写法，**答案蕴含一个潜在的单调性结论**。

```cpp
	int l = 1, r = m;
	while (l <= r) {
		int mid = (l + r) >> 1;
		if (isvalid(diff,mid)) {
			ans = min(ans, mid);
			r = mid - 1;
		}
		else {
			l = mid + 1;
		}
	}
```

+ [P2882 [USACO07MAR] Face The Right Way G](https://www.luogu.com.cn/problem/P2882)：这题和差分其实没太大关系，**使用标志位代替差分的修改操作**。首先求最小的相应 K 和最小的操作次数 M非常困难，会想到枚举的方法。其次验证结果需要$O(n)$的操作，还要考虑使用贪心的策略，维护**局部最优的策略**，差分不支持实时修改，考虑**使用标志位代替这一作用**：

```cpp
void solve() {
	cin >> n;
	for (int i = 1; i <= n; i++) {
		cin >> tmp;
		if (tmp == 'B')a[i] = 0;
		else a[i] = 1;
	}
	//printout(a, n);
	for (int k = 1; k <= n; k++) {//操作次数
		vector<int>tmp(5009, 0);
		int tag = 0, cnt = 0,flag=1;
		for (int i = 1; i <= n; i++) {
			if ((a[i] + tag) % 2 == 0) {
				if (i + k - 1 > n) {
					flag = 0;
					break;
				}

				tag++;
				cnt++;
				tmp[i + k - 1] = -1;// 标记
			}
			if (tmp[i]==-1) {
				tag--;
			}
		}
		if (flag==1) {
			if (cnt < min_cnt) {
				min_cnt = cnt;
				min_k = k;
			}
		}
	}
	cout << min_k << " " << min_cnt;
}
```

