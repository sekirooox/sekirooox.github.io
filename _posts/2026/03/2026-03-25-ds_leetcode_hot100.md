---
title: "leetcode-hot100"
author: MayL
date: 2026-03-25
categories: ["算法与数据结构", "算法题解"]
tags: ["算法题解", "算法", "学习笔记"]
render_with_liquid: false
math: true
description: "本文整理“leetcode-hot100”的核心思路、典型问题与实现要点，便于刷题复习和后续查阅。"
---

@[toc]
# 哈希表

## 核心思想：哈希查找$O(1)$，使用`set`去重

# 例题
[1. 两数之和](https://leetcode.cn/problems/two-sum/description/?envType=study-plan-v2&envId=top-100-liked)：
+ 只能使用O(n)的算法，因此不能考虑二分。暴力法是两次遍历，考虑仅使用一次遍历。
+ 解决方法：**将遍历的元素存储在哈希表中**，往已有哈希表中查找对应元素，可以实现一次遍历。

[49. 字母异位词 ](https://leetcode.cn/problems/group-anagrams/?envType=study-plan-v2&envId=top-100-liked)：
+ 注意到所有字符串的顺序无关，所以**对所有字符串进行排序**，以排序后的值作为键建立映射关系。
[128.最长连续序列](https://leetcode.cn/problems/longest-consecutive-sequence/?envType=study-plan-v2&envId=top-100-liked)：``
+ 这题只能使用O(n)的算法。
+ 考虑只能遍历一次，**将所有数组预先存储到哈希表中方便查找**。
+ 优化重复遍历：**对于非首位元素，不进行查找**。


# 双指针：快慢指针

[283.移动零](https://leetcode.cn/problems/move-zeroes/description/?envType=study-plan-v2&envId=top-100-liked)：
+ 这题就是典型的双指针例题，双指针具有明显的**单调特性**。

[11.盛最多水的容器](https://leetcode.cn/problems/container-with-most-water/?envType=study-plan-v2&envId=top-100-liked)：
+ 假设h[i]<h[j]：**说明i是瓶颈，必须移动i，如果i是单调递增，可以计算一次答案，否则可以继续移动i**，直到h[i]>=h[j]，此时拼接换到j。
```cpp
class Solution {
public:
    int maxArea(vector<int>& height) {
        int ans=INT_MIN;
        int i=0,j=height.size()-1;
        while(i<j){
            int w =j-i;
            int h=min(height[i],height[j]);
            ans=max(ans,w*h);
            while(height[i]<height[j]&&i<j){
                i++;
                int w =j-i;
                int h=min(height[i],height[j]);
                ans=max(ans,w*h);
            }
            while(height[i]>=height[j]&&i<j){
                j--;
                int w =j-i;
                int h=min(height[i],height[j]);
                ans=max(ans,w*h);
            }            
        }
        return ans;
    }
};
```

[15.三数之和](https://leetcode.cn/problems/3sum/description/?envType=study-plan-v2&envId=top-100-liked)
+ 注意到这题的**时间复杂度要求O(n^2)左右即可，因此可以考虑排序数组**。
+ 第一重循环固定i，第二重循环使用双指针优化。
+ **注意数组具有明显的单调性**，可以使用双指针用来寻找答案。

**排列问题去重**：`if a[i]=a[i-1] then continue`
+ i需要去重
```cpp
if(j>i+1&&nums[j]==nums[j-1]){
                    j++;
                    continue;
                }
```
+ j和k也需要进行去重
```cpp
                if(j>i+1&&nums[j]==nums[j-1]){
                    j++;
                    continue;
                }
                if(k<nums.size()-1&&nums[k]==nums[k+1]){
                    k--;
                    continue;
                }
```


[42.接雨水](https://leetcode.cn/problems/trapping-rain-water/?envType=study-plan-v2&envId=top-100-liked)
+ 暴力做法：对于当前台阶，选择左右两边最高的柱子，然后**按照列的方式计算当前台阶的雨水量**。
+ 简单优化：加速寻找最大台阶的步数，**使用单调容器获得比当前柱子大的最近一个元素所在的位置**。时间复杂度快一点，**但是最坏仍然是平方**。

```cpp
class Solution {
public:
    typedef struct node{
        int idx,val;
        node(int x,int y):idx(x),val(y){};
    };
    int trap(vector<int>& height) {
        vector<int>left(height.size(),-1);
        vector<int>right(height.size(),-1);
        deque<node>q;
        for(int i=0;i<height.size();i++){
            while(q.size()&&q.back().val<=height[i]){
                q.pop_back();
            }
            if(q.size()){
                left[i]=q.back().idx;
            }
            q.push_back(node(i,height[i]));
        }
        q.clear();
        for(int i=height.size()-1;i>=0;i--){
            while(q.size()&&q.back().val<=height[i]){
                q.pop_back();
            }
            if(q.size()){
                right[i]=q.back().idx;
            }
            q.push_back(node(i,height[i]));
        }
        int res=0;
        for(int i=0;i<height.size();i++){
            int j=i,k=i;
            while(left[j]!=-1)j=left[j];
            while(right[k]!=-1)k=right[k];
            if(i==j||j==k)continue;
            int h = min(height[j],height[k])-height[i];
            res+=h;
        }
        return res;
    }
};
```
+ 优化思路2：按照行的形式问题，**之前的元素递减时不需要计算，一旦出现递增的情况，就要横向计算雨水量**。发现可以使用单调栈来模拟这一个过程。
**一定要使用行的形式计算雨水！！！**

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/7ee8515912eb4dfebbd1a580238823b0.png){: referrerpolicy="no-referrer" }

# 双指针：滑动窗口

[3.无重复字符的最长子串](https://leetcode.cn/problems/longest-substring-without-repeating-characters/?envType=study-plan-v2&envId=top-100-liked)
+ 双指针：当出现重复就增加指针j，试图删去重复元素。

438.找到字符串中所有字母异位词
+ 异位词：位置不同，字符种类和数量一致。
+ **排序后可以作为键**。
+ 如果连续，**子串可以共用一个hash数组**；如果不连续的子串需要使用两个hash数组进行控制。判断是否是一个词可以直接暴力，**复杂度取决于种类**。**例如26个字母复杂度为$O(26)$**


# 子串
560.和为K 的子数组
+ 使用hash表加速查询，使用前缀和加速求和运算。

239.滑动窗口最大值
+ 单调队列模板题


76.最小覆盖子串
+ 双指针之滑动窗口：**可以证明最短子串要么为[i，j]，要么不包含i**。
+  子串的暴力比较算法：**遍历哈希表中每一个种类**；然后使用双指针即可。
+ 时间复杂度1e7，**勉强能过**

+ 不暴力比较的方法
[优化方法](https://leetcode.cn/problems/minimum-window-substring/solutions/2713911/liang-chong-fang-fa-cong-o52mn-dao-omnfu-3ezz/?envType=study-plan-v2&envId=top-100-liked)


# 数组
## 53.最大子数组和
+ 序列问题：首选考虑动态规划
+ 注意状态定义：**以j结尾**[0,j]范围内的**连续子数组**。为什么不能是考虑j结尾？因为这题要求连续，**都用考虑来说可能会出现全都不考虑的问题，子数组无效！**
+ 状态转移：和j-1拼接起来，或者**从头开始(容易被忽略)**。

```cpp
    int maxSubArray(vector<int>& nums) {
        int ans=INT_MIN;
        vector<int>dp(1e5+9,0);// [0,j]结尾连续的子数组
        for(int i=1;i<=nums.size();i++){
            dp[i]=max(dp[i-1]+nums[i-1],nums[i-1]);
            ans = max(ans,dp[i]);
        }
        // for(int i=1;i<=nums.size();i++){
        //     cout<<dp[i]<<" ";
        // }
        // cout<<endl;
        return ans;
    }
```
56.合并区间
+ 贪心：等价于区间合并，区间拆分。

## 189.轮转数组
+ 几何法
+ 等价于**翻转数组**

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/a62d32cb97304386ae191837a45ed5a8.png){: referrerpolicy="no-referrer" }

```cpp
class Solution {
public:
    void rotate(vector<int>& nums, int k) {
        k%=nums.size();
        reverse(nums.begin(),nums.end());
        reverse(nums.begin(),nums.begin()+k);
        reverse(nums.begin()+k,nums.end());
    }
};
```

 238.除了自身数之外的乘积
+ 简单的思路：左边前缀和，右边右缀和，然后a[i-1]*b[i+1]
+ 优化为O(n)：**在算前缀和的时候用累积变量表示并立即参与运算即可**。

## 41.缺失的第一个正数
+ [灵神解法](https://leetcode.cn/problems/first-missing-positive/solutions/3655377/huan-zuo-wei-tong-guo-li-zi-li-jie-suan-qa94e)
+ 简要概括：对号入座法。**第一个不是正确座位的地方为缺失的正数**。

73.矩阵置零
+ **不是模拟题，不是模拟题，不是模拟题**。
+ 用数组记录**哪行哪列要被删除**。
+ 可以将删除的边存在第一行和第一列上

54.螺旋矩阵
+ 这题模拟反而好一点

## 48.旋转图像
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/441ef3ca79b844568fd89645bd21fd65.png){: referrerpolicy="no-referrer" }

+ 顺时针90度：(i,j)->(j,n-i+1)
+ 寻找中间操作：(j,i)
+ **先转置后交换列的值**。

```cpp
    void rotate(vector<vector<int>>& matrix) {
        // i,j->j,n-i-1; 
        for(int i=0;i<matrix.size();i++){
            for(int j=i;j<matrix[0].size();j++){
                swap(matrix[i][j],matrix[j][i]);
            }
        }
        for(int j=0;j<matrix[0].size()/2;j++){
            for(int i=0;i<matrix.size();i++){
                swap(matrix[i][j],matrix[i][matrix[0].size()-1-j]);
            }
        }
    }
```

## 240.搜索二维矩阵
+ 从右上角搜索
+ 利用矩阵的单调性，**删除不需要的行/列(模拟的方法)**。

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/4f30ab24883b49dbbb4b97fb3c26c7c4.png){: referrerpolicy="no-referrer" }

```cpp
class Solution {
public:
    bool searchMatrix(vector<vector<int>>& matrix, int target) {
        int i = 0;
        int j = matrix[0].size()-1;
        while (i>=0&&i<matrix.size()&&j>=0&&j<matrix[0].size()){
            if(matrix[i][j]==target){
                return true;
            }
            else if(matrix[i][j]<target){
                i+=1;
            }
            else{
                j-=1;
            }
        }
        return false;
    }
};
```
# 链表
160.相交链表
+ 模拟题

206.反转链表
+ 模拟题

234.回文链表
+ 模拟题
+ 暴力法：中间往两边搜索。

## 141.环形链表
+ 快慢指针的应用
+ 为什么有交点，两个指针一定会重合？**直觉：在环中，快指针一定保证与慢指针的相对距离在缩小**，也就是相对速度大，且一定保证会出现重合，不会一直跳过。
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/fc1eaf6246c14b31b1939cd4ad3fe15a.png){: referrerpolicy="no-referrer" }
## 142.环形链表
+ 快慢指针一定相遇，**但是不保证在环的开始点相遇**。
+ 我们想要保证慢指针在圆环起始点，假设开始点距离圆环起始点距离为x，**当环内路程t-x为圆环长度c的倍数时，可以确定慢指针一定在起点处**。
+ 寻找t的等式：$s1-s2=n*c=2t-t=t$，**因此t一定是c的倍数**，只需要补上x，就一定能保证$c\mid(t-x+x)$
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/cfba0b93698949fc9e4ccc7c4198671b.png){: referrerpolicy="no-referrer" }
