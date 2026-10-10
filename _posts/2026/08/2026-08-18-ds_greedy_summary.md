---
title: "贪心·刷题总结"
author: MayL
date: 2026-08-18
categories: ["算法与数据结构", "算法题解"]
tags: ["算法题解", "贪心", "算法", "学习笔记"]
render_with_liquid: false
math: true
description: "本文整理“贪心·刷题总结”的核心思路、典型问题与实现要点，便于刷题复习和后续查阅。"
---


# 最小或最大贪心


## 排序后使用贪心策略

-1262. 可被三整除的最大和 1762
948. 令牌放置 1762
1775. 通过最少操作次数使数组的和相等 1850
2333. 最小差值平方和 2011 批量减少
3645. 最优激活顺序得到的最大总和 2019
2141. 同时运行 N 台电脑的最长时间 2265


+ 可被三整除的最大和 1762：贪心策略-排序，求和，然后根据余数结果，**排除最小的余数为1或者余数为2的结果**。
```cpp
class Solution {
public:
    int maxSumDivThree(vector<int>& nums) {
        unordered_map<int,vector<int>>mp;// [0,1,2]:vector<int>
        int sum=0;
        for(int i=0;i<nums.size();i++){
            mp[nums[i]%3].push_back(nums[i]);
            sum+=nums[i];
        }
        sort(mp[1].begin(),mp[1].end());
        sort(mp[2].begin(),mp[2].end());
        if(sum%3==1){
            int tmp1=INT_MIN,tmp2=INT_MIN;
            if(mp[1].size()){
                tmp1=sum-mp[1][0];
            }
            if(mp[2].size()>=2){
                tmp2=sum-mp[2][0]-mp[2][1];
            }
            if(max(tmp1,tmp2)!=INT_MIN){
                return max(tmp1,tmp2);
            }
            else return 0;
        }
        if(sum%3==2){
            int tmp1=INT_MIN,tmp2=INT_MIN;
            if(mp[1].size()>=2){
                tmp1=sum-mp[1][0]-mp[1][1];
            }
            if(mp[2].size()){
                tmp2=sum-mp[2][0];
            }
            if(max(tmp1,tmp2)!=INT_MIN){
                return max(tmp1,tmp2);
            }
            else return 0; 
        }
        else{
            return sum;
        }
    }
};
```

+ 状态机解法：**分别设定三个状态机，余数分别为0，1，2**，注意初始化和转移方程即可。
```cpp
class Solution {
public:
    int maxSumDivThree(vector<int>& nums) {
        // 状态机DP
        int n=nums.size();
        vector<vector<int>>dp(19,vector<int>(n+9,0));
        dp[0][0]=0;
        dp[1][0]=dp[2][0]=-0x3f3f3f3f;
        dp[nums[0]%3][0]=nums[0];// 3%3=0,dp[0][0]=3
        for(int i=1;i<n;i++){
            int t= nums[i]%3;
            if(t%3==0){
                dp[0][i]=max(dp[0][i-1]+nums[i],dp[0][i-1]); // dp[0]
                dp[1][i]=max(dp[1][i-1]+nums[i],dp[1][i-1]); // dp[1]
                dp[2][i]=max(dp[2][i-1]+nums[i],dp[2][i-1]);
            }
            else if(t%3==1){
                dp[0][i]=max(dp[2][i-1]+nums[i],dp[0][i-1]);
                dp[1][i]=max(dp[0][i-1]+nums[i],dp[1][i-1]);
                dp[2][i]=max(dp[1][i-1]+nums[i],dp[2][i-1]);
            }
            else{// t%3==2
                dp[0][i]=max(dp[1][i-1]+nums[i],dp[0][i-1]);
                dp[1][i]=max(dp[2][i-1]+nums[i],dp[1][i-1]);
                dp[2][i]=max(dp[0][i-1]+nums[i],dp[2][i-1]);
            }
        }
        for(int i=0;i<3;i++){
            for(int j=0;j<n;j++){
                cout<<dp[i][j]<<" ";
            }
            cout<<endl;
        }
        return dp[0][n-1]==-0x3f3f3f3f?0:dp[0][n-1];
    }
};
```

### 例题：使两个数组和相等的最少操作

+ 1775.通过最少操作次数使数组的和相等


+ 最小差值平方和：思路基本一致，但是是**大模拟题目**，需要注意动态更新前面的数值。


## 单一序列配对：满足要求的配对不超过元素的一半

§1.2 单序列配对
同上，从最小/最大的元素开始贪心。

-2592. 最大化数组的伟大值 1569 田忌赛马
2576. 求出最多标记下标 1843
2577. 
§1.3 双序列配对
同上，从最小/最大的元素开始贪心。

-2037. 使每位学生都有座位的最少移动次数 1357
2578. 分发饼干 1381
2579. 运动员和训练师的最大匹配数 1381 同 455 题
2580. 检查一个字符串是否可以打破另一个字符串 1436
2581. 优势洗牌 1648 田忌赛马
2582. 安排工作以达到最大收益 1709
2583. 使数组相似的最少操作次数 2076
2584. 装包裹的最小浪费空间 2214
2585. 重排水果 2222
2586. 你可以安排的最多任务数目 2648
2587. 完成所有工作的最短时间 II（会员题）


+ -2576. 求出最多标记下标 1843：把数组划分两个部分，小的元素一定要当不等式的左侧，计为`nums[i]`，右侧为`nums[j]`。


## 双序列匹配问题：田忌赛马思想
+ 870.优势洗牌&&826.安排工作以达到最大收益：简单题，有明显的单调性。
+ -2583. 使数组相似的最少操作次数 2076：首先任意数组一定可以通过若干次操作恒等，这样的前提是**两个数组的总和完全相等**。关键之处：**需要理解给定两个数组，需要的操作次数等于差值/4**，问题然后就演化为一个双序列配对的问题，保证两个数组排序后一一对应的情况差值少。由于这题比较特殊，奇数不能变成偶数，因此**还需要专门分奇和偶数来排序**。


# 从左/从右贪心：贪心+大模拟

## 例题
-3776. 使循环数组余额非负的最少移动次数 1740：**模拟循环数组**，注意计算循环后的坐标，避免重复。
-861. 翻转矩阵后的得分 1818：HOT100题目，先用行操作保证第一列最优，在用列操作保证列得分最优
-862. 使数组非递减的最少除法操作次数 1864：题目本意就是求最小素因子或者1，因此**预处理使用欧拉筛得到每一个数的最小素因子**，然后**反向遍历即可**！

```cpp
class Solution {
public:
    int minOperations(vector<int>& nums) {
        int n = nums.size();
        if(n < 2) return 0;
        auto flynorpexel = nums;
        int maxnum = *max_element(nums.begin(), nums.end());
        vector<int> minp(maxnum + 1, -1);
        vector<int> primes;
        // 欧拉筛
        for(int i = 2; i <= maxnum; i++) {
            if(minp[i] == -1) {
                primes.push_back(i);
            }
            for(int p : primes) {
                if(1LL * i * p > maxnum) break;
                minp[i * p] = p;
                if(i % p == 0) break;
            }
        }
        int ans = 0;
        for(int i = n - 2; i >= 0; i--) {
            if(nums[i] > nums[i + 1]) {
                // nums[i] 是质数或者 1，无法变小
                if(minp[nums[i]] == -1) {
                    return -1;
                }
                nums[i] = minp[nums[i]];
                ans++;
                if(nums[i] > nums[i + 1]) {
                    return -1;
                }
            }
        }
        return ans;
    }
};
```

-864. 删列造序 II 1876
865. 排布二进制网格的最少交换次数 1881：转换为每一个行的后缀0数量，然后遍历+贪心
866. 使二叉树所有路径值相等的最小代价 1917：可以证明每一个**左右子树的路径和一定要相等**，因此可以通过树上DP的形式来完成。
867. 避免洪水泛滥 1974：注意两种情况，一是**提前的晴天**，而是**用掉了最晚的晴天**，导致早些的晴天无法使用；**使用二分查找来查找最早的晴天下标**，这就是贪心策略(注意查找完需要删除)。


# 字符串划分型贪心：本质线性DP，全局最优到局部最优


-2522. 将字符串分割成值不超过 K 的子字符串 1605
## 局部-全局最优：1D前缀DP的实现方式，受限于$$O(n)$$的复杂度要求
-3557. 不相交子字符串的最大数量 1720
1546. 和为目标值且不重叠的非空子数组的最大数目 1855

```cpp
class Solution {
public:
    int maxNonOverlapping(vector<int>& nums, int target) {
        int n= nums.size(),ans=0;
        unordered_map<int,int>mp;
        mp[0]=0;// 前缀和为0
        int pre=0;
        for(int i=0;i<n;i++){
            // 前缀和
            pre+=nums[i];
            if(mp.contains(pre-target)){
                ans++;
                mp.clear();
                mp[0]=0;
                pre=0;
            }
            else{
                mp[pre]=i;
            }
        }
        return ans;
    }
};
```
- https://pgcode.cn/problem/5179：单词拆分，本质也是**前缀DP**。

```cpp
string s;
int m;
vector<string>words(1009);
// vector<vector<int>>dp(m+9,vector<int>(309,0));
vector<int>dp(309,0);
bool match(const string&a,const string&b){
    // cout<<a<<" "<<b<<endl;
    return a==b;
}
void solve(){
    cin>>s>>m;
    for(int i=0;i<m;i++){
        cin>>words[i];
    }
    int n=s.size();
    s='0'+s;
    dp[0]=1;
    for(int i=1;i<=n;i++){// 字符串
        for(int j=0;j<m;j++){// 物体
            if(words[j].size()>i)continue;
            int idx=i-words[j].size()+1;// 4-4+1=1
            if(match(s.substr(idx,words[j].size()),words[j])){
                dp[i]=dp[i]||dp[i-words[j].size()];
            }
        }
    }
}
```

# 区间贪心
[题单](https://leetcode.cn/discuss/post/3091107/fen-xiang-gun-ti-dan-tan-xin-ji-ben-tan-k58yb/)
区间贪心有如下经典问题：

## 应用
### 区间选点-射气球
### 不相交区间-一间课室容纳多少门课
### 区间分组-课程安排
### 区间覆盖-灌溉花园一定范围内最少使用的水龙头
## 最多不相交区间=区间选点，每一个点代表一个与其他区间不相交的区间
### 反面：删除最少的区间是的剩下的区间不相交
+ 给定一些区间，从中选出尽量多的两两互不相交的区间。

```cpp
    int eraseOverlapIntervals(vector<vector<int>>& intervals) {
        // 最大重叠子区间
        sort(intervals.begin(),intervals.end(),[&](const vector<int>&a,const vector<int>&b){return a[0]<b[0];});
        int r= intervals[0][1],ans=0;
        for(int i=1;i<intervals.size();i++){
            if(intervals[i][0]>=r){
                ans++;
                r=intervals[i][1];
            }
            else{
                r=min(r,intervals[i][1]);
            }
        }
        return intervals.size()-ans-1;
    }
```

=435. 无重叠区间 约 1700
646. 最长数对链 同 435 题
1520. 最多的不重叠子字符串 2363
3458. 选择 K 个互不重叠的特殊子字符串 同 1520 题
变形：每个区间有各自的分数，从中选一些两两互不相交的区间，最大化得分之和。详见 动态规划题单 的「§7.2 不相交区间」。
## 区间分组：贪心策略向左端点排序，实时选择最小的右端点合并分组

```cpp
    int minGroups(vector<vector<int>>& intervals) {
        sort(intervals.begin(), intervals.end(),
             [&](const vector<int>& a, const vector<int>& b) {
                 return a[0] < b[0];
             });
        priority_queue<vector<int>, vector<vector<int>>, cmp> q;
        for(int i=0;i<intervals.size();i++){
            if(q.size()){
                auto vec=q.top();
                if(vec[1]<intervals[i][0]){
                    q.pop();
                    q.push({vec[0],intervals[i][1]});
                    continue;
                }
            }
            q.push(intervals[i]);
        }
        return q.size();
    }
```

+ 给定一些区间，把这些区间分成最少的组，使得每组内的区间互不相交。

=2406. 将区间分为最少组数 1713
253. 会议室 II（会员题）

## 区间选点：射气球问题
+ 给定一些区间，在数轴上放置最少的点，使得每个区间都包含至少一个点。最少要放置多少个点？

```cpp
int findMinArrowShots(vector<vector<int>>& points) {
        // 最大重叠子区间
        sort(points.begin(),points.end(),[&](const vector<int>&a,const vector<int>&b){return a[0]<b[0];});
        int r= points[0][1],ans=0;
        for(int i=1;i<points.size();i++){
            if(points[i][0]>r){
                ans++;
                r=points[i][1];
            }
            else{
                r=min(r,points[i][1]);
            }
        }
        return ans+1;
    }
```


=452. 用最少数量的箭引爆气球 约 1700
757. 设置交集大小至少为2 2379
2589. 完成所有任务的最少时间 2381
LCP 32. 批量处理任务
## 区间覆盖：实际问题-跳跃游戏
+ 给定一些区间，从中选出尽量少的区间，覆盖一条指定线段 [s,t]。
+ 确定区间的右端点，然后一直**遍历到该右端点，更新区间新长度**。在区间的有效长度内，任意更新长度的操作都是合理的；**如果区间的长度已经达到要求，直接停止**。
```cpp
    int jump(vector<int>& nums) {
        if(nums.size()==1)return 0;
        int i=1,r=nums[0],ans=0;
        while(i<nums.size()){
            if(r>=nums.size()-1){
                break;
            }
            int newr=-1;
            while(i<=r&&i<nums.size()){
                newr=max(i+nums[i],newr);
                i++;
            }
            ans++;
            r=newr;
        }
        return ans+1;
    }
```

=45. 跳跃游戏 II 约 1700
1024. 视频拼接 1746
1326. 灌溉花园的最少水龙头数目 1885


