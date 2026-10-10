---
title: "洛谷·阶乘"
author: MayL
date: 2024-06-11
categories: ["算法与数据结构", "算法题解"]
tags: ["算法题解", "actor-critic", "算法", "学习笔记"]
render_with_liquid: false
math: true
description: "本文整理“洛谷·阶乘”的核心思路、典型问题与实现要点，便于刷题复习和后续查阅。"
---

# 高精度之阶乘
+ # 计算高阶阶乘 
```cpp
using namespace std;
#define maxv 9999
class bigInt {
public:
	int len;
	int a[maxv];//从1开始，尽量开大点
	bigInt() {
		memset(a, 0,sizeof(a));
		a[1] = 1;//从1开始
		len = 1;
	}
	void operator*(int x) {
		for (int i = 1; i <= len; i++) {
			a[i] *= x;
		}
		len = len + 2;//最大长度
		for (int i = 1; i <= len; i++) {
			a[i + 1] += a[i] / 10;
			a[i] %= 10;
		}
		for (; !a[len];len--) {
		}
		//返回真实的len长度
		return;
	}
	void print() {
		for (int i = max(1,len); i >= 1; i--) {
			cout << a[i];
		}
	}
private:
};
void solve() {
	int n; cin >> n;//n>=2
	bigInt x;
	for (int i = 2; i <= n; i++) {
		x * i;//重载运算符的知识，懒得写==号
	}
	x.print();
}
int main(){
	std::ios::sync_with_stdio(false);
	std::cin.tie(0); std::cout.tie(0);
	solve();
	return 0;
}
```
+ 定义一个类bigInt，便于使用高精度操作
+ 这样写就是有点偷懒，**一直使用同一个x**，输出也是同一个x
# 阶乘加法
[原题地址](https://www.luogu.com.cn/problem/P1009)
## [NOIP1998 普及组] 阶乘之和

### 题目描述

用高精度计算出 $S = 1! + 2! + 3! + \cdots + n!$（$n \le 50$）。

其中 `!` 表示阶乘，定义为 $n!=n\times (n-1)\times (n-2)\times \cdots \times 1$。例如，$5! = 5 \times 4 \times 3 \times 2 \times 1=120$。

### 输入格式

一个正整数 $n$。

### 输出格式

一个正整数 $S$，表示计算结果。

### 样例 #1

### 样例输入 #1

```
3
```

### 样例输出 #1

```
9
```

### 提示

**【数据范围】**

对于 $100 \%$ 的数据，$1 \le n \le 50$。


#  个人代码
```cpp
using namespace std;
#define maxv 5200
class bigInt {
public:
	int len;
	int a[maxv];//从1开始，尽量开大点
	bigInt() {//构造函数无所谓，就考虑阶乘为1的情况就好了
		memset(a, 0,sizeof(a));
		a[1] = 1;//a从1开始
		len = 1;
	}
	void operator*(int x) {
		for (int i = 1; i <= len; i++) {
			a[i] *= x;
		}
		len = len + 2;//最大长度
		for (int i = 1; i <= len; i++) {//进位
			a[i + 1] += a[i] / 10;
			a[i] %= 10;
		}
		for (; !a[len];len--) {//返回真实的len长度
		}
		
		return;
	}
	void operator+(bigInt x) {
		int mlen = max(this->len+1, x.len+1);//加法最大位数是原位数+1
		for (int i = 1; i <= mlen; i++) {
			a[i] += x.a[i];

		}
		for (int i = 1; i <= mlen; i++) {//进位
			a[i + 1] += a[i] / 10;
			a[i] %= 10;
		}
		for (; !a[mlen]; mlen--) {
		}
		len = mlen;
		return;

	}
	/*void operator=(bigInt x) {
		for (int i = 1; i <= x.len; i++) {
			a[i] = x.a[i];
		}
		len = x.len;
	}*/	
	void print() {
		for (int i = max(1,len); i >= 1; i--) {
			cout << a[i];//逆序输出
		}
	}
private:
};
bigInt res;
void solve() {
	int n; cin >> n;
	bigInt x;
	for (int i = 2; i <= n; i++) {
		x* i;//可以理解为x*=i
		res + x;//可以理解为res+=x
	}
	res.print();
}
int main(){
	std::ios::sync_with_stdio(false);
	std::cin.tie(0); std::cout.tie(0);
	solve();
	return 0;
}
```
# 要点：
+ **不定义=运算符**，主要是麻烦且费时，
+ 用两个bigInt就可以解决，+/*都**对本身进行修改**，最后输出就好
+ 关键还是位的运算，**用数组取模拟运算结果，最后倒序输出**
