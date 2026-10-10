---
title: "算法·动态规划"
author: MayL
date: 2025-03-22
categories: ["算法与数据结构", "算法"]
tags: ["动态规划", "算法", "学习笔记"]
render_with_liquid: false
math: true
description: "本文整理“算法·动态规划”的核心思路、典型问题与实现要点，便于刷题复习和后续查阅。"
---

@[toc]
# 动态规划
## 动态规划使用范围
+ 选择问题：背包模型
+ 序列问题：最长子序列
+ 状态压缩：
+ 状态压缩DP
+ 状态机DP
+ 树形DP
+ 区间DP：区间的组合或**区间内的顺序问题(括号问题)**

# 动态规划分析法
## 理解动态规划
将动态规划问题理解**有限集合中的最值问题**。
### DP数组的含义
+ 一个集合DP[i,j,k...]，满足条件i，j，k的集合的数学
+ 数学：例如最大，最多...
### 状态转移
+ 将一个集合划分为若干的子集(子问题)
+ 划分要求：不出现遗漏，可以出现重复。
+ 划分技巧：**最后一个不同点，不同之处**。
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/bc5bd863a5ba4129ab6e15a89b3687ce.png){: referrerpolicy="no-referrer" }

---

# 动态规划的概念
## 子问题与记忆化搜索
+ 记忆化搜索本质是对回溯搜索的一种优化，很多时候先想到回溯，由回溯想到记忆化搜索，再想到动态规划
+ **记忆化搜索是动态规划的起源**，有助于我们**分解子问题**
### 重复子问题，状态，状态转移
+ [P1216 [IOI 1994] 数字三角形 Number Triangles](https://www.luogu.com.cn/problem/P1216)
### 动态规划的起源：记忆化搜索
+ [P1434 [SHOI2002] 滑雪](https://www.luogu.com.cn/problem/P1434)
+ [P4017 最大食物链计数](https://www.luogu.com.cn/problem/P4017)
### 图搜索问题中的动态规划
+ [P1002 [NOIP 2002 普及组] 过河卒](https://www.luogu.com.cn/problem/P1002) :边界条件+数组拷贝
---
## 状态
+ 可以理解为**n元函数**$f(x_1,x_2,\cdots,x_n)$：完成某个特定任务，需要**考虑哪些变量**?
+ **状态的定义来自 子问题(本质)** 
---
## 状态转移
### 当前问题与子问题的关系是什么？**当前问题如何分解为子问题**？
+ LCS：考虑`[i,j]`为止的字符串与`[i-1,i-1]`,`[i-1][j]`,`[i][j-1]`的字符串有什么关系？ 
+ 最长回文子串：范围为`[i,j]`的字符串与`[i-1][j-1]`的字符串有什么关系？
### 状态转移方程定义来自 1.子问题(本质) + 2.操作(分情况)
+  操作的数量就是 状态图中 不同状态边的数量
+ LCS：操作是**删除**或者**不删除**当前字符：对应考虑两种情况
+ 编辑距离：操作是**删除**，**插入**，**替换**：对应考虑三种情况
<br><br><br><br><br><br><br><br>
---
## 遍历顺序和初始化
### 遍历顺序和初始化取决 1.状态+状态转移方程(本质) 2.题目的特点


## 状态压缩
+ ### 本质是精简 $f(x_1,x_2\cdots,x_n)$中变量的个数，通常用于优化空间效率
+ ### 状态压缩 来自于 1.可以直接减少无关状态变量 2.递推公式
---


## dp五部曲的理解
见：[代码随想录](https://www.programmercarl.com/0416.%E5%88%86%E5%89%B2%E7%AD%89%E5%92%8C%E5%AD%90%E9%9B%86.html#_01%E8%83%8C%E5%8C%85%E9%97%AE%E9%A2%98)
+ 优先确定：**状态的定义，状态转移的房产**
+ 根据状态转移方程确定：遍历顺序，初始化
+ 初始化和遍历顺序
---

# 背包问题：方案的选择规划
>难点：遍历顺序和动态规划的初步理解

## DP数组的定义：考虑`[0,i]`集合中的物体,`[0,j]`的重量下
### 背包问题的理解：遍历顺序
+ 一般来说，先遍历背包还是物体,顺序不重要，更**取决于递推公式**。
+ **对于一些问题(排列或组合)，遍历顺序影响答案**。


<br><br><br><br>

---
## 0-1背包问题：$O(nm)$，$O(n)-O(nm)$
+ [P1048 [NOIP 2005 普及组] 采药
](https://www.luogu.com.cn/problem/P1048)
+ [P1802 5 倍经验日](https://www.luogu.com.cn/problem/P1802):这个背包问题需要考虑`dp[0]`的情况
### 价值等于重量：是否恰好装满背包
+ [416. 分割等和子集](https://leetcode.cn/problems/partition-equal-subset-sum/description/)：典型问题，**价值等于重量，能否装满背包**。
+ [1049. 最后一块石头的重量 II](https://leetcode.cn/problems/last-stone-weight-ii/description/)：思路类同[416. 分割等和子集](https://leetcode.cn/problems/partition-equal-subset-sum/description/)

+ [P2392 kkksc03考前临时抱佛脚](https://www.luogu.com.cn/problem/P2392):**贪心不能通过**，改为动态规划，与 [416. 分割等和子集](https://leetcode.cn/problems/partition-equal-subset-sum/description/)，思路一致，**背包最多能装多少重量的物体**？

```cpp
int s1, s2, s3, s4,ans=0;
int sum1 = 0, sum2 = 0, sum3 = 0, sum4 = 0;
vector<int>a(29, 0);
vector<int>b(29, 0);
vector<int>c(29, 0);
vector<int>d(29, 0);
int pd(vector<int>w,int sum,int wlen) {
	int len = sum / 2;
	vector<int>dp(2009, 0);
	for (int i = 1; i <= wlen; i++) {
		for (int j = len; j>=w[i]; j--) {
			dp[j] = max(dp[j - w[i]] + w[i], dp[j]);
		}
	}
	return max(dp[len], sum - dp[len]);
}
void solve() {
	cin >> s1 >> s2 >> s3 >> s4;
	for (int i = 1; i <= s1; i++) {
		cin >> a[i];
		sum1 += a[i];
	}
	for (int i = 1; i <= s2; i++) {
		cin >> b[i];
		sum2 += b[i];
	}
	for (int i = 1; i <= s3; i++) {
		cin >> c[i];
		sum3 += c[i];
	}
	for (int i = 1; i <= s4; i++) {
		cin >> d[i];
		sum4 += d[i];
	}
	int cnt1 = pd(a, sum1, s1);
	int cnt2 = pd(b, sum2, s2);
	int cnt3 = pd(c, sum3, s3);
	int cnt4 = pd(d, sum4, s4);
	//cout << "cnt1:" << cnt1 << endl;
	//cout << "cnt2:" << cnt2 << endl;
	//cout << "cnt3:" << cnt3 << endl;
	//cout << "cnt4:" << cnt4 << endl;

	cout << cnt1 + cnt2 + cnt3 + cnt4;
}
```



<br><br><br><br>

---

## 完全背包问题：$O(nm)$，$O(n)-O(nm)$
+ 物体可以**重复使用无限次**
+ 区别是:是否能利用刚更新的状态
+ **不能直接转换为0-1背包问题**

+ [52. 携带研究材料（第七期模拟笔试）](https://kamacoder.com/problempage.php?pid=1052)
+ [518. 零钱兑换 II](https://leetcode.cn/problems/coin-change-ii/description/)
+ [322. 零钱兑换](https://leetcode.cn/problems/coin-change/)
+ [279.完全平方数](https://leetcode.cn/problems/perfect-squares/description/):

### 推导过程
+ 子集可以分为选0，1，2，...k，**正无穷个**物体的最大价值。
+ 状态转移函数：`dp[i][j]=max(dp[i-1][j],dp[i][j-w[i]])`，注意`dp[i][j-w[i]]`由以下公式推导得到，这也就是了为什么1D-dp**应该从小到大遍历**。

$$
dp[i][j]=max(dp[i-1][j-0\times w[i]]+0\times v[i],...,dp[i-1][j-k\times w[i]]+k\times v[i],...)\\
dp[i][j-w[i]]=max(dp[i-1][j-1\times w[i]]+1\times v[i],...,dp[i-1][j-k\times w[i]]+k\times v[i],...)\\
dp[i][j]=max(dp[i-1][j],dp[i][j-w[i]])
$$


## 多重背包问题：$O(nmk)$，$O(n)-O(nm)$
### 朴素多重背包解法：$O(nmk)$
+ **多一重循环k，用于遍历使用次数**(注：不能直接根据`c[i]`来遍历，这样会有干扰)
+ 部分问题可以完全转换为0-1背包
+ 倒序遍历j(参照0-1背包）
+ [P1077 [NOIP 2012 普及组] 摆花](https://www.luogu.com.cn/problem/P1077)：不能直接转换为0-1背包
### 倍增思想优化：$O(nm\log(k))$
+ 使用二进制优化：**任意二进制1,2,4,8,16,R(表示余数)，可以唯一确定一个数k。**
+ 将物体数量按照二进制进行分解，**每一维度代表1个，2个，4个...，R个物体**，**然后将问题完全转换为0-1背包(防止重复)**

```cpp
void solve() {
	cin >> n >> m;
	for (int i = 1; i <= n; i++) {
		cin >> v[i] >> w[i]>>s[i];
	}
	for (int i = 1; i <= n; i++) {
		// k from 1,2,4,8...,r
		for (int k = 1; s[i] > 0; k <<= 1) {
			if (k > s[i])k = s[i];
			s[i] -= k;
			for (int j = m; j >= k*v[i]; j--) {
				dp[j] = max(dp[j], dp[j - k * v[i]] + k * w[i]);
			}
		}
	}
	cout << dp[m];
}
```

## 计数类DP：等价于背包问题

+ 416. 分割等和子集


<br><br><br><br>

---


# 状态机DP
## DP数组的定义：解决问题`依赖`哪些有限状态，状态定义上一般是互斥的

## 买卖股票问题

>+ 隐含状态:`dp[i][0]`:第0天不持有，控制着买只能一次
>+ 状态的定义:有多少个状态？哪些状态可以压缩?
+ [121. 买卖股票的最佳时机](https://leetcode.cn/problems/best-time-to-buy-and-sell-stock/)：因为只能卖一次，所以转移函数需要特别注意.
+ [122.买卖股票的最佳时机II](https://leetcode.cn/problems/best-time-to-buy-and-sell-stock-ii/submissions/615328122/)：只能买一次和买多次递推公式的区别.
+ [123.买卖股票的最佳时机III](https://leetcode.cn/problems/best-time-to-buy-and-sell-stock-iii/description/)：`dp[0][2]=-prices[0];`，**初始化的含义**
+ [188.买卖股票的最佳时机IV](https://leetcode.cn/problems/best-time-to-buy-and-sell-stock-iv/):**隐含状态`dp[i][0]`**
+ [309.最佳买卖股票时机含冷冻期](https://leetcode.cn/problems/best-time-to-buy-and-sell-stock-with-cooldown/submissions/615560158/)：**状态定义，状态压缩**。

三种状态：持有，不持有但不在冷冻期，冷冻期
```cpp
        dp[0][0]=-prices[0];
        dp[0][1]=0;
        dp[0][2]=0;
        for(int i=1;i<prices.size();i++){
            dp[i][0]=max(dp[i-1][0],dp[i-1][1]-prices[i]);
            dp[i][1]=max(dp[i-1][1],dp[i-1][2]);
            dp[i][2]=dp[i-1][0]+prices[i];
        }
```
两种状态：
持有和不持有
```cpp
        dp[0][0]=-prices[0];
        dp[0][1]=0;
        dp[1][0]=max(-prices[1],dp[0][0]);
        dp[1][1]=max(dp[0][1],dp[0][0]+prices[1]);
        for(int i=2;i<prices.size();i++){
            dp[i][0]=max(dp[i-1][0],dp[i-2][1]-prices[i]);
            dp[i][1]=max(dp[i-1][1],dp[i-1][0]+prices[i]);
        }
```
+ [714.买卖股票的最佳时机含手续费](https://leetcode.cn/problems/best-time-to-buy-and-sell-stock-with-transaction-fee/description/):白给题.

## 其他例题
+  可被三整除的最大和 1762：也是状态机DP

<br><br><br><br>

---

# 线性DP：连续/不连续区间的规划和前缀问题
## DP数组定义：考虑/确定以`a[j]`结尾的数组
## 打家劫舍问题
> 难点：**状态定义，状态压缩**
+ [198.打家劫舍](https://leetcode.cn/problems/house-robber/submissions/614436503/)：状态压缩：`dp[i][2]->dp[i]`
+ [213.打家劫舍II](https://leetcode.cn/problems/house-robber-ii/description/)：初始化有问题，分类讨论。
+ [337.打家劫舍 III](https://leetcode.cn/problems/house-robber-iii/)：树上DP，使用 [198.打家劫舍](https://leetcode.cn/problems/house-robber/submissions/614436503/)：定义的类似状态:`dp[i][2]`，就能理解。**当然这题也可以进行状态压缩!**
## 最长递增序列问题 (LIS)：$O(n^2)$，$O(n)$
### 最长递增子序列
+ dp定义：以j结尾的子序列的属性。**不一定包含a[j]**。
```cpp
void solve() {
	cin >> n;
	for (int i = 1; i <= n; i++) {
		cin >> a[i];
	}
	a[0] = INT_MIN;
	for (int i = 1; i <= n; i++) {
		for (int j = 0; j <= i - 1; j++) {
			if (a[j] < a[i])dp[i] = max(dp[i], dp[j] + 1);
			ans = max(ans, dp[i]);
		}
	}
	cout << ans;
}
```
## 例题
+ [P1115 最大子段和](https://www.luogu.com.cn/problem/P1115)：**引用背包问题的定义，维护虚假的序列和**
+ [300.最长递增子序列](https://leetcode.cn/problems/longest-increasing-subsequence/description/)：状态的定义，**三种情况：删除，不删除连续，不删除重开**。因此可以定义为两种，**实际上可以压缩为一种状态**。
+ [674. 最长连续递增序列](https://leetcode.cn/problems/longest-continuous-increasing-subsequence/submissions/)：状态只有**保留和重开**，所以自然只有一种状态。
+ [718. 最长重复子数组](https://leetcode.cn/problems/maximum-length-of-repeated-subarray/description/)：注意序列要求连续,`else{}`的情况不需要处理。**因为要求连续，最后一个元素必须选择。**
**状态压缩**:类似背包，注意需要**防止继承`dp[i-1][j]`的状态**，需要显式赋0.
```cpp
        vector<int>dp(nums2.size()+9,0);
        int res=0;
        for(int i=0;i<nums1.size();i++){
            for(int j=nums2.size()-1;j>=0;j--){//倒序
                if(nums1[i]==nums2[j]){
                    if(j-1>=0){
                        dp[j]=dp[j-1]+1;
                    }
                    else{
                        dp[j]=1;
                    }
                }
                else{
                    dp[j]=0;//防止继承前一个状态,需要赋0
                }
            res=max(res,dp[j]);
            }
        }
        return res;
```

<br><br><br><br>

---

### 区间DP转前缀DP：最长有效括号
+ DP数组的定义：以s[i]为结尾的连续子串
+ 理论上区间DP是最适合的，因为可以**单独研究每一个有效括号**。但是要求线性复杂度，因此**只能使用前缀DP**。
+ 如果`s[i]=='('`，不存在有效的括号数
+ 如果`s[i]==')`，存在`s[j,i]`为子串的有效括号。
```cpp
// 前缀DP
    vector<int>dp(n+10,0);// 考虑以s[i]结尾的连续子串
    for(int i=2;i<=n;i++){
        if(s[i]==')'){
            // 考虑配对
            if(s[i-1]=='('){
                // 前面的配对
                dp[i]=max(dp[i],dp[i-2]+2);// )()
            }
            else{// s[i-1]==')'
                int j=i-dp[i-1]-1;
                if(s[j]=='('){
                    dp[i]=max(dp[i],dp[i-1]+2);// (())
                }
            }
            // 包含配对不上的问题
        }
        else dp[i]=0;// 
    }    
```

# 多维度动态规划问题
## 公共子序列问题：$O(nm)，O(nm)$
## DP数组的定义：考虑目标`A[0,i]`和`B[0,j]`之间的属性
+ dp数组：`dp[i][j]`，考虑`[0，i]`和`[0，j]`的子串属性。
+ 子集划分依据：可以不包含i，不包含j，也可以不包含i和j(被前者囊括进去)，同时包含i和j。
```cpp
void solve() {
	cin >> n >> m;
	cin >> a >> b;
	a = '0' + a;
	b = '0' + b;
	for (int i = 1; i <= n; i++) {
		for (int j = 1; j <= m; j++) {
		    // dp[i-1][j]不一定确保j被选择. 但是不影响结果
			dp[i][j] = max(max(dp[i - 1][j - 1], dp[i][j - 1]),dp[i - 1][j]);
			if (a[i] == b[j])dp[i][j] = max(dp[i][j], dp[i - 1][j - 1] + 1);
		}
	}
	//for (int i = 1; i <= n; i++) {
	//	for (int j = 1; j <= m; j++) {
	//		cout << dp[i][j] << " ";
	//	}
	//	cout << endl;
	//}
	//cout << endl;
	cout << dp[n][m];
}
```
<br><br><br><br>

---
# 区间DP：区间组合和括号问题，$O(n^{2})$

+ [282. 石子合并](https://www.acwing.com/problem/content/description/284/)：$O(N^2K)$
+ 矩阵乘法链：$O(N^2K)$
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/80b12709bd3d4aea8a130d6ef6a30f78.png){: referrerpolicy="no-referrer" }
+ [回文串](https://leetcode.cn/problems/longest-palindromic-substring/description/?envType=study-plan-v2&envId=top-100-liked)：DP不擅长获得具体的方案实现，因此将问题转换为判定回文数。
+ 括号问题：
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/a3ac1f0c406e4e1ca561f1d3589c8e39.png){: referrerpolicy="no-referrer" }

## DP数组定义：考虑数组`[i,j]`区间的属性
+ ``dp[i][j]``：区间`[i,j]`被合并的为一堆的方案。
+ **大区间使用了小区间的结果**，先遍历小区间，然后大区间利用小区间的值进行更新。
+ 先遍历区间大小，确保小区间先被更新。
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/ce5580fa6e514c9da7515462fc10a303.png){: referrerpolicy="no-referrer" }

```cpp
void solve() {
	cin >> n;
	for (int i = 1; i <= n; i++) {
		cin >> a[i];
		a[i] += a[i - 1];
	}
	for (int len = 2; len <= n; len++) {
		for (int i = 1; i+len-1<=n; i++) {
			int j = i + len - 1;
			dp[i][j] = INT_MAX;
			for (int k = i; k <= j - 1; k++) {
				dp[i][j] = min(dp[i][j], dp[i][k] + dp[k + 1][j] + a[j] - a[i - 1]);
			}
		}
		//for (int i = 1; i <= n; i++) {
		//	for (int j = 1; j <= n; j++) {
		//		cout << dp[i][j] << " ";
		//	}
		//	cout << endl;
		//}
		//cout << endl;
	}
	cout << dp[1][n];
}
```

<br><br><br><br>

---

## 例题

+ [1143.最长公共子序列](https://leetcode.cn/problems/longest-common-subsequence/description/)：这题与上一题有点不一样，需要考虑不等的情况。`dp[i][j]=max(dp[i-1][j],dp[i][j-1])`，**注意两个情况都蕴含了`dp[i-1][j-1]`的情况**。**未要求连续，所以最后一个元素不一定要选，下标定义为"考虑"某个元素**。

```cpp
for(int i=0;i<text1.size();i++){
        for(int j=0;j<text2.size();j++){
            int left=0,top=0;
                if(i-1>=0){
                    top=dp[i-1][j];
                }
                if(j-1>=0){
                    left=dp[i][j-1];
                }
            if(text1[i]==text2[j]){
                if(i-1>=0&&j-1>=0){
                    dp[i][j]=dp[i-1][j-1]+1;
                }
                else{
                    dp[i][j]=1;
                }
            }
            else{
                dp[i][j]=max(left,top);
            }
        }
    }
```
+ [53. 最大子序和](https://leetcode.cn/problems/maximum-subarray/description/): 与  [P1115 最大子段和](https://www.luogu.com.cn/problem/P1115)基本一致，白给题。
+ [392.判断子序列](https://leetcode.cn/problems/is-subsequence/):**注意递推公式的微小变化**,`dp[i-1][j] or dp[i][j-1] ->>> dp[i][j-1]`,`s[i]`这个字符是必须保留的(不然就不是原来的字符串了!)。与标准LCS问题差距在于只能删除**一边的字符串**。
```cpp
        vector<vector<int>>dp(s.size()+9,vector<int>(t.size()+9,0));
        for(int i=0;i<s.size();i++){
            for(int j=0;j<t.size();j++){
                if(s[i]==t[j]){
                    if(i-1>=0&&j-1>=0){
                        dp[i][j]=dp[i-1][j-1];
                    }
                    else{
                        dp[i][j]=1;
                    }
                }
                else{
                    if(j-1>=0){
                        dp[i][j]=dp[i][j-1];
                    }
                    else{
                        dp[i][j]=0;
                    }
                }
            }
        }
```
+ [115.不同的子序列](https://leetcode.cn/problems/distinct-subsequences/description/)：
这题的难点在于有重复的情况。

**方法1**：递推公式不变，我们**使用map记录某一个字符串重复的次数**，**且只有两个字符串在同一位置匹配时才这么做**。注意：`mp[t[i]]=dp[i][j]`，不是从1开始，要考虑多种重复字符的情况。
```cpp
        for(int i=0;i<t.size();i++){
            unordered_map<char,int>mp;
            for(int j=i;j<s.size();j++){//j至少从i开始,
                if(t[i]==s[j]){
                    int times=mp.find(t[i])==mp.end()?0:mp[t[i]];
                    if(i-1>=0&&j-1>=0){
                        dp[i][j]=(dp[i-1][j-1]+times)%mod;
                    }
                    else{
                        dp[i][j]=(1+times)%mod;
                    }
                    mp[t[i]]=dp[i][j];
                }
                else{
                    if(j-1>=0){
                        dp[i][j]=(dp[i][j-1])%mod;
                    }
                    else{
                        dp[i][j]=0;
                    }
                }
            }
        }
```
**方法2**：注意到，字符匹配时，还可以取`dp[i][j-1]`的部分，如果也是恰好`t[i]`和`s[j]`相等，则种类自然加，如果不是，则由不匹配时`dp[i][j]=dp[i][j-1]`继承前一轮的状态，也蕴含该重复的过程。
```cpp
        for(int i=0;i<t.size();i++){
            for(int j=i;j<s.size();j++){
                if(t[i]==s[j]){
                    if(i-1>=0&&j-1>=0){
                        dp[i][j]=(dp[i-1][j-1]+dp[i][j-1])%mod;
                    }
                    else{
                        if(j-1>=0){
                            dp[i][j]=(dp[i][j-1]+1)%mod;
                        }
                        else{
                            dp[i][j]=1;
                        }
                    }                    
                }
                else{
                    if(j-1>=0){
                        dp[i][j]=(dp[i][j-1])%mod;
                    }
                }
            }
        }
```
+ [583. 两个字符串的删除操作](https://leetcode.cn/problems/delete-operation-for-two-strings/)：这道题和LCS基本一致，都可以删除后者保留字符，只不过初始化条件判断有点繁杂，所以我数组开大了一点。dp数组**表示考虑i-1和j-1为止的字符串最少删除操作次数**。然后特殊初始化就行。

```cpp
        for(int i=1;i<=word1.size();i++){
            for(int j=1;j<=word2.size();j++){
                if(word1[i-1]==word2[j-1]){
                    dp[i][j]=dp[i-1][j-1];
                }
                else{
                    dp[i][j]=min(dp[i-1][j],dp[i][j-1])+1;
                }
            }
        }
```
+ [72. 编辑距离](https://leetcode.cn/problems/edit-distance/submissions/)：这道题看上去有三种操作， 但是**插入和删除字符是等价的**，所以与LCS只多出一个替换操作，**只有两种操作**。这个替换操作就是当 当前字符不匹配时，替换任意一个字符，达到匹配的效果(**也就是沿用匹配的递推公式**)。初始化不变。
+ 注意：`dp[i][1]=i`的初始化方式是错误的，`dp[i][0]=i`是正确的初始化。
```cpp
        for(int i=1;i<=word1.size();i++){
            for(int j=1;j<=word2.size();j++){
                if(word1[i-1]==word2[j-1]){
                    dp[i][j]=dp[i-1][j-1];
                }
                else{
                    dp[i][j]=min(dp[i][j-1],min(dp[i-1][j],dp[i-1][j-1]))+1;
                }
            }
        }
```

+ [647. 回文子串](https://leetcode.cn/problems/palindromic-substrings/)：
这道题状态的定义有难度，要**根据子问题推出来i和j的含义(i开始j结尾)**。与之前不同，**DP数组本身的定义不是按照题目的要求(回文串数目)**。本人尝试使用回文串数目，但发现**去重上总是有错误**。建议使用bool值作标记的方法。
数组的**遍历顺序**也非常不同，这是根据**递推公式和数组定义**得到的。
```cpp
        vector<vector<bool>>dp(s.size()+9,vector<bool>(s.size()+9,false));
        for(int j=1;j<=s.size();j++){
            for(int i=j;i>=1;i--){
                if(s[i-1]==s[j-1]){
                    if(i==j){
                        dp[i][j]=true;
                        res++;
                    }
                    else if(i+1==j){
                        dp[i][j]=true;
                        res++;
                    }
                    else{
                        dp[i][j]=dp[i+1][j-1];
                        if(dp[i][j])res++;
                    }
                }
            }
        }
```


+ [516.最长回文子序列](https://leetcode.cn/problems/longest-palindromic-subsequence/):这题见到那很多，就是一般的定义。**注意要求是子序列，所以即使不相等也要继承前一个状态**。特殊处理`i==j`的情况。
```cpp
        for(int j=1;j<=s.size();j++){
            for(int i=j;i>=1;i--){
                if(s[i-1]==s[j-1]){
                    if(i==j){
                        dp[i][j]=1;
                    }
                    else{
                        dp[i][j]=dp[i+1][j-1]+2;
                    }
                }
                else{
                    dp[i][j]=max(dp[i+1][j],dp[i][j-1]);
                }
            }
        }
```

# 状态压缩DP：$O(2^m*n)$，m为需要压缩的状态数，n为普通状态数



## 核心思想：用二进制表示状态
## 例题
[291. 蒙德里安的梦想](https://www.acwing.com/problem/content/description/293/)：搜索问题，其中二进制中每一位**表示横放(1) / 竖放(0或者继承自横放)**
+ 使用预处理处理合并的状态，剔除不合法的状态
+ 同时两列之间的状态也有不合法之处(**`a&b!=0`说明有1的部分重叠了，这是不合法**)。
+ **枚举各种状态进行转移**。
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/ad74cccbbcd04402b74e78fd8f138dca.png){: referrerpolicy="no-referrer" }

```cpp
void solve() {
	while (cin >> n >> m, n || m) {
		for (int i = 0; i < 1 << n; i++) {
			int cnt = 0;
			st[i] = 1;
			for (int j = 0; j < n; j++) {
				if (getbit(i, j) == 1) {
					if (cnt % 2 != 0) {
						st[i] = 0;
						break;
					}
				}
				else cnt++;
			}
			if (cnt % 2 != 0)st[i] = 0;
		}

		memset(dp, 0, sizeof dp);
		dp[0][0] = 1;
		for (int i = 1; i <= m; i++) {
			for (int j = 0; j < 1 << n; j++) {
				for (int k = 0; k < 1 << n; k++) {
					if ((j & k) == 0 && st[j| k]) {
						dp[i][j] += dp[i - 1][k];
					}
				}
			}
		}
		cout << dp[m][0] << endl;

	}
}
```

[91. 最短Hamilton路径](https://www.acwing.com/problem/content/description/93/)：搜索问题，状态表示比较容易理解，但是需要表示每一种情况下是否遍历过(visited数组表示)，状态复杂度比较高，因此**可以考虑使用二进制优化状态表示**。
+ **先枚举状态，再枚举结点(确保已经更新)。**
+ [分数分割](https://pgcode.cn/problem/2704)：对于每一个最大分数的限制条件，都不能简单的使用背包的思想来解决，一定要考虑每一个状态之间的转换，其中状态定义为**每件物品是否都有且选用过**，可以使用**状态压缩的方式来解决**。


# 树形DP：$O(n)+$
## DP数组的定义：以某一节点为根的节点集合


## 做法1：后序遍历的形式转译为DP问题
### 例题
+ [树的重心](https://pgcode.cn/problem/2705)：树上差分+注意区分子节点和父节点的路径
## 做法2：转换为一般数组问题，但是要记录`父亲节点`
### 例题
+ [285. 没有上司的舞会](https://www.acwing.com/problem/content/description/287/)


# 例题
## 背包问题
### 背包容量为负数
+ [494.目标和](https://leetcode.cn/problems/target-sum/)：目标和
### 组合数和排序数：遍历问题
+ [377. 组合总和 Ⅳ](https://leetcode.cn/problems/combination-sum-iv/description/):完全背包，需要排序。
+ [139.单词拆分](https://leetcode.cn/problems/word-break/):潜在考虑单词顺序

### 多维(3D及以上)背包问题

+ [474. 一和零](https://leetcode.cn/problems/ones-and-zeroes/description/)


