---
title: "算法·离散化"
author: MayL
date: 2025-03-17
categories: ["算法与数据结构", "算法"]
tags: ["算法", "学习笔记"]
render_with_liquid: false
description: "本文整理“算法·离散化”的核心思路、典型问题与实现要点，便于刷题复习和后续查阅。"
---


# 离散化
> 离散化就是把**大而分散的一段段使用到的稀疏区间**，整合映射到**连续的一段较小的稠密区间里**，本质上就是化大为小，把稀疏离散化简为稠密连续的一段。
## 思路：将有关下标都放在同一个数组内
+ 将**题目所给/感兴趣的下标**存储到新的数组中。
+ **原来的下标对应整个数轴**，**新的下标对应离散化后的下标数组的下标**。
+ 进行任意操作时，**使用二分查询下标数组的位置**。
+ 根据问题类型决定是否需要对下标进行去重！

```cpp
#include<bits/stdc++.h>
#define MAX_VALUE 1000009
#define mod 1000007
using ll = long long;
using namespace std;
int n,m,x[100009],c[100009],l[100009],r[100009],a[500009],b[500009],len=0;
void solve(){
    cin>>n>>m;
    for(int i=1;i<=n;i++){
        cin>>x[i]>>c[i];
        a[++len]=x[i];
    }
    for(int i=1;i<=m;i++){
        cin>>l[i]>>r[i];
        a[++len]=l[i];
        a[++len]=r[i];
    }
    sort(a+1,a+len+1);
    len = unique(a+1,a+len+1)-a-1;
    for(int i=1;i<=n;i++){
        int idx = lower_bound(a+1,a+len+1,x[i])-a;// 找到x[i]对应的下标然后+c
        b[idx]+=c[i];
    }
    for(int i=1;i<=len;i++){
        b[i]+=b[i-1];
    }
    for(int i=1;i<=m;i++){
        int left_idx = lower_bound(a+1,a+len+1,l[i])-a;
        int right_idx = lower_bound(a+1,a+len+1,r[i])-a;
        cout<<b[right_idx]-b[left_idx-1]<<endl;
    }
}
int main() {
	std::ios::sync_with_stdio(false);
	std::cin.tie(0);
	std::cout.tie(0);
	solve();
	return 0;
};
```

# 离散化的应用
## 染色问题
+  ### 本质上是一种模拟问题，染色即标记
+ ### 但是很多情况下，数组过大，必须使用离散化的技巧

### 注意事项
+ `for (int a = x_1[i]; a < x_2[i]; a++) `染色时，区间应该是左开右闭，**这样是为了避免重复计算**，例如[l1,r1),[l2,r2)。
如果去相等的话：
>**存在[l1,r1],[l2,r2]的区间，不小心把[r1,l2]的区间也统计在一起了**。
+ `for (int i = 1; i <lenx ; i++)`：**遍历存储离散点的数组时，不需要遍历最后一个点**。因为按照`int h = x[i + 1] - x[i]`区间求和公式，最后一个点应该是结尾，与下一个元素求和无意义。

---
<br><br><br><br><br><br>


# 例题
+ [P1496 火烧赤壁](https://www.luogu.com.cn/problem/P1496)：1D离散化例题
+ [P1884 [USACO12FEB] Overplanting S](https://www.luogu.com.cn/problem/P1884)：2D离散化，基本思路不变，分别用两个数组存储离散后前的值，记得排序和去重。然后也是照样二分查找新数组的x，y下标(共有四个)，进行染色。最后根据染色结果进行更新。
+ 染色时，**为了避免重叠情况，保持区间左闭右开**。
+ 注意遍历离散点的区间，**不要遍历最后一个维度**
```cpp
int n,x_1[1009], y_1[1009], x_2[1009], y_2[1009], x[2009], y[2009], f[2009][2009];
ll ans=0;
void solve() {
	cin >> n;
	int lenx = 0, leny = 0;
	for (int i = 1; i <= n; i++) {
		cin >> x_1[i] >> y_2[i] >> x_2[i] >> y_1[i];
		x[++lenx]= x_1[i];
		y[++leny]= y_2[i];
		x[++lenx]= x_2[i];
		y[++leny]= y_1[i];
	}
	sort(x + 1, x + lenx + 1);
	sort(y + 1, y + leny + 1);
	//printout(x, lenx);
	//printout(y, leny);
	for (int i = 1; i <= n; i++) {
		x_1[i] = lower_bound(x + 1, x + lenx + 1, x_1[i]) - x;
		x_2[i] = lower_bound(x + 1, x + lenx + 1, x_2[i]) - x;
		y_1[i] = lower_bound(y + 1, y + leny + 1, y_1[i]) - y;
		y_2[i] = lower_bound(y + 1, y + leny + 1, y_2[i]) - y;
		for (int a = x_1[i]; a < x_2[i]; a++) {
			for (int b = y_1[i]; b < y_2[i]; b++) {
				f[a][b] = 1;
			}
		}
	}
	for (int i = 1; i <lenx ; i++) {
		for (int j = 1; j <leny; j++) {
			//cout << f[i][j] << " ";
			if (f[i][j]) {
				int h = x[i + 1] - x[i];
				int w = y[j + 1] - y[j];
				ans += (ll)h * w;
;			}
		}
	}
	cout << ans;
}
int main() {
	std::ios::sync_with_stdio(false);
	std::cin.tie(0);
	std::cout.tie(0);
	solve();
	return 0;
};
```


---
<br><br><br><br><br><br>
# 染色问题解决思路归纳
+ ## 收集离散的点
### 可以用数组，也可以用结构体
```cpp
	for (int i = 1; i <= n; i++) {
		cin >> a[i] >> b[i];
		c[++idx] = a[i];
		c[++idx] = b[i];
	}
```

+ ## 数组排序+去重
+ ### C++的去重函数`unique(v,begin,v.begin+len)`，返回去重后最后一个元素的**下一位置**
```cpp
	int len = unique(x.begin() + 1, x.begin() + 2*n + 1) - x.begin()-1;
```
+ ### 获取实际长度`len`

+ ## 重新找回离散点的映射关系
+ ### 二分查找函数 `lower_bound(v.begin(),v.begin()+len,elem)` 返回第一个大于等于查找函数的值，否则为末位元素下一位置的指针

```cpp
		auto iter_a = lower_bound(c.begin() + 1, c.begin() + 2*n + 1,a[i]);
		auto iter_b = lower_bound(c.begin() + 1, c.begin() + 2*n + 1,b[i]);
		int idx_a = iter_a - c.begin();
		int idx_b = iter_b - c.begin();
```
+ ### 染色新数组
```cpp
		for (int j = idx_a; j < idx_b; j++) {
			f[j] = 1;
```

## 计算长度或面积
+ ### 注意：离散化后的一维或二维数组，表示边界，计算长度或面积的公式为：`c[i+1]-c[i]` 
---
<br><br><br><br><br><br>
