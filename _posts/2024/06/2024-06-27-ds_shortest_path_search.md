---
title: "图论·搜索最短路径"
author: MayL
date: 2024-06-27
categories: ["算法与数据结构", "图论"]
tags: ["图论", "算法", "学习笔记"]
render_with_liquid: false
description: "本文整理“图论·搜索最短路径”的核心思路、典型问题与实现要点，便于刷题复习和后续查阅。"
---

[例题地址](https://kamacoder.com/problempage.php?pid=1203)
# 搜索最短路径
+ 在网格图中按照特定路线搜索，搜索方式基于bfs/dfs
+ 需要搜索出一条源点与终点最短的路径
## 核心思路
+ 无启发式函数：bfs/dfs+
+ 有启发式函数：dijsktra算法,A*(Astar)..
## 个人理解
+ 启发式函数：相当于根据点的权重，对搜索的方向有一定判断，不会盲目的搜索，减少了绝大部分的无用功。
+ 启发式函数一般搭配优先级队列(堆)实现

---
# A*算法
+ 有启发式函数的搜索
+ 效率和准确程度很大程度取决于启发式函数
## 常见启发式函数
+ 欧拉距离：就是平方和，两点距离之差(x1-x2)^2   + (y1-y2) ^2
+ 切比雪夫距离：没用过，有缘再更新
+ 曼哈顿距离：没用过，有缘再更新
## 核心操作
+ 权值的计算：F=G+H
	+ G:源点到当前点走过的距离(不是位移,而是**路程**),**是一个真实值**
	+ H:利用启发式函数计算得到的距离,**是一个期望值**
+ 优先级队列：对于权值进行排序,同时实现基于BFS的搜索
## 个人代码

```cpp
#include<bits/stdc++.h>
using namespace std;
using ll = long long;
int grid[1009][1009];
int n,a1,a2,b1,b2;
int dir[8][2] = { 2,1,1,2,-1,2,-2,1,-2,-1,-1,-2,1,-2,2,-1 };
struct knight {
    int x, y, g, h, f;//f=g+h,g起点到当前结点，h当前结点到终点
};
struct cmp {
    bool operator()(const knight& a, const knight& b) {
        return a.f > b.f;
    }
};
priority_queue<knight,vector<knight>,cmp>q;
int getDist(const int &x,const int &y,const int &b1,const int &b2) {
    return (x - b1) * (x - b1) + (y - b2) * (y - b2);
}
void bfs() {
    q.push({ a1,a2,0,getDist(0,0,b1,b2),getDist(0,0,b1,b2)});
    while (!q.empty()) {
        knight cur = q.top();
        q.pop();
        if (cur.x == b1 && cur.y == b2) {
            cout << grid[cur.x][cur.y] << endl;
            return;
        }
        knight next;
        for (int k = 0;k<8; k++) {
            next.x = cur.x + dir[k][0];
            next.y = cur.y + dir[k][1];
            if (next.x < 1 || next.x>1000 || next.y < 1 || next.y>1000) {
                continue;
            }
            if (!grid[next.x][next.y]) {
                grid[next.x][next.y] = grid[cur.x][cur.y] + 1;//更新距离,并且起到标记作用
                next.g = cur.g + 5;
                next.h = getDist(next.x, next.y, b1, b2);
                next.f = next.g + next.h;
                q.push(next);
            }       
        }
    }
}
void solve(){
    cin >> n;
    while (n--) {
        cin >> a1 >> a2 >> b1 >> b2;
        memset(grid, 0, sizeof(grid));
        bfs();
        while (!q.empty()) {
            q.pop();
        }
    }
}
int main() {
    std::ios::sync_with_stdio(false);
    std::cin.tie(0); std::cout.tie(0);
    solve();
    return 0;
}
```
## 注意事项
+ G是路程，**利用`next.g=getDist(next.x,next.y,a1,a2);`计算与源点的距离是错误的**
+ grid数组不建议使用vector数组，**因为每次使用完都要memset**
+ grid仍然需要标记：这里grid本身就可以起到标记作用
+ 题目的步数可以直接由grid统计得到
# A*算法空间优化-IDA
蜀黍不会，有缘更新

---
# dijsktra作为启发式函数
## 核心操作
+ 结构体:结构体的dist定义为**源点与当前点的距离**
+ 队列:根据结构体的dist排序
+ dist数组的定义:定义dist数组是为了比较二者距离，判断是否应该更新(个人觉得比较累赘，**但是不得不定义**)
```cpp
using namespace std;
using ll = long long;
vector<vector<int>>grid(1009, vector<int>(1009, 0));
int n,a1,a2,b1,b2;
int dir[8][2] = { 2,1,1,2,-1,2,-2,1,-2,-1,-1,-2,1,-2,2,-1 };
struct knight {
    int x, y, dist;
};
struct cmp {
    bool operator()(const knight&a,const knight&b) {
        return a.dist > b.dist;
    }
};
priority_queue<knight, vector<knight>, cmp>q;
vector<vector<int>>dist(1009, vector<int>(1009, INT_MAX));
void bfs(vector<vector<int>>dist) {
    dist[a1][a2] = 0;
    q.push({ a1,a2,dist[a1][a2]});
    while (!q.empty()) {
        knight cur=q.top();
        q.pop();
        if (cur.x == b1 && cur.y == b2) { 
            cout << dist[cur.x][cur.y]<<endl;
            return;
        }
        knight next;
        for (int k = 0; k < 8; k++) {
        	//相当于选点操作
            next.x = cur.x + dir[k][0];
            next.y = cur.y + dir[k][1];
            if (next.x < 1 || next.x>1000 ||next.y < 1 || next.y > 1000) {
                continue;
            }
            
            //因为题目说了一定能找到，所以可以没有visited数组的标记
            
            //相当于更新
            if (cur.dist + 1 < dist[next.x][next.y]) {
            //注意每走一步+1；dist数组也要更新
                dist[next.x][next.y] = cur.dist + 1;
                q.push({ next.x,next.y,dist[next.x][next.y] });
            }
        }
    }
}
void solve(){
    cin >> n;
    while (n--) {
        cin >> a1 >> a2 >> b1 >> b2;
        bfs(dist);//传入dist数组作为形参
        while (!q.empty()) {
            q.pop();
        }
    }
}
int main() {
    std::ios::sync_with_stdio(false);
    std::cin.tie(0); std::cout.tie(0);
    solve();
    return 0;
}
```
## 注意事项
+ grid数组因为没有权值(权值为1)所以在dijsktra算法中属于无效部分，只起到存储网格作用
+ dist数组作为形参，**不能使用引用**
# 时间复杂度：
+ A*算法时间复杂度明显更优，但难以确定，取决于启发函数。但对比BFS/DFS/dijsktra算法是相当大的提升
+ **dijsktra算法在面对无权值(权值为1)的图时，退化为BFS**
+ BFS/DFS时间复杂度高

[参考于代码随想录](https://www.programmercarl.com/kamacoder/0126.%E9%AA%91%E5%A3%AB%E7%9A%84%E6%94%BB%E5%87%BBastar.html#astar)
