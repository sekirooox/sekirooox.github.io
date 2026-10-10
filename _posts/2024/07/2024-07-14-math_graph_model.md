---
title: "数模·图论"
author: MayL
date: 2024-07-14
categories: ["数学基础与数学建模", "数学基础"]
tags: ["数学", "学习笔记"]
render_with_liquid: false
description: "本文整理“数模·图论”涉及的基本原理、计算方法与应用思路，便于学习复习和建模参考。"
---

# matlab中图的表示
## 顶点集+权值集的形式
>s是源点，t是终点，w是对应的权值
>调用`graph(s,t,w)`作为参数创建图
>调用plot函数绘图`plot(G,'EdgeLabel',G.Edges.Weight,'LineWidth',2)`
>设置x和y的坐标范围`set(gca,'XTick',[],'YTick',[])`
```matlab
s=[1 2 3];
t=[4 1 2];
w=[5 2 6];
G=graph(s,t,w);
plot(G,'EdgeLabel',G.Edges.Weight,'LineWidth',2);
set(gca,'XTick',[],'YTick',[]);%设置x和y的坐标范围
```
## *邻接矩阵转图(常见)
>调用matlab中的特殊数据结构graph和digraph，传入邻接矩阵A
>graph指的是无向图，digraph指的是有向图，graph只接受**对称矩阵**
+ 无向图

```matlab
%% matlab中邻接矩阵转无向图
clear;clc;
A = [0 1 0 0 2;%矩阵A必须是对称的，这样直接传入是错误的！！！
     1 0 3 0 0;
     0 0 0 4 0;
     0 0 0 0 5;
     0 0 0 5 0];
G = graph(A);%直接转换
plot(G,"EdgeLabel",G.Edges.Weight,'LineWidth',2);
set(gca,'XTick',[],'YTick',[]);%设置x和y的坐标范围
```

+ 有向图

```matlab
%% matlab中邻接矩阵转有向图
clear;clc;
A = [0 1 0 0 2;
     1 0 3 0 0;
     0 0 0 4 0;
     0 0 0 0 5;
     0 0 0 5 0];
G = digraph(A);%直接转换
plot(G,"EdgeLabel",G.Edges.Weight,'LineWidth',2);
set(gca,'XTick',[],'YTick',[]);%设置x和y的坐标范围
```

# 最短路算法
>数模里使用的单源最短路算法一般都是指dijsktra算法，也可以使用Bellman算法
## dijsktra算法
+ 注意负权值不可以使用dijsktra算法
## matlab代码
>需要注意的是：dijsktra朴素版一般采取邻接矩阵存储，matlab中一般只接受图作为参数，要将**邻接矩阵转换为有向图**
>P指路径数组，d指最短距离
```matlab
%% dijkstra算法
[P,d]=shortestpath(G,1,4);%路径数组和距离
disp(P);disp(d);
```
<br><br><br><br>

# 网络最大流
## 网络最大流问题的概念
+ 流量图
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/99fdf3fbb6094ebea108830551c723ef.png){: referrerpolicy="no-referrer" }
>就是一条边的权值不再是一个值了，而是**一个元组(c,x)分别表示最大流量和当前流量**，如下图所示
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/1f89108fa9a443ff9aa75f23cb1a730d.png){: referrerpolicy="no-referrer" }
+ 可行流
>进来的流量始终等于出去的流量

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/04fa552e8dbc4797b3df501fc4bd0f0f.png){: referrerpolicy="no-referrer" }
+ 增广链

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/f0d516851fcb42f492d6e58708833904.png){: referrerpolicy="no-referrer" }


## Ford Fulkerson算法
>不断寻找增广链，直到再也找不到为止
>对于一条增广链，将顶点标号为+/-表示前向弧或反向弧，delta表示流量增加，取一条链上最小的增量，对于一条弧，如果是前向弧则增加delta，否则减小
>**邻接矩阵c表示最大流量，x表示当前流量**，这个操作可以通过邻接矩阵顺利完成
>如果没有路径可以采取DFS/BFS搜索创造路径
>必须注意的是，局部最优不一定就是全局最优，表现题目中在**一个管道的流量全部占满不一定是全局最优解**，为了解决这个问题，**我们会添加负权值的反向弧供程序反悔**
>
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/49c24d0c664944ca9dc7a1c73fca0a14.png){: referrerpolicy="no-referrer" }
## matlab代码
>maxflow函数，接受图作为参数，传入起点和终点返回mf作为当前网络最大流
```matlab
%% matlab求解网络最大流问题
clear;clc;
a=zeros(7);
a(1,2)=4;a(1,4)=3;a(1,5)=10;
a(2,3)=1;a(2,4)=3;a(3,7)=7;
a(4,3)=4;a(4,6)=5;a(5,3)=3;
a(5,4)=3;a(5,6)=4;a(6,7)=8;
matrix=digraph(a);
plot(matrix,"EdgeLabel",matrix.Edges.Weight,"LineWidth",2);
mf=maxflow(matrix,1,7)%%不接受邻接矩阵，只接受有向图
```
<br><br><br><br>
# 最小费用最大流问题
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/b56ce6a5dc7045788d5bc68d9bbc7f51.png){: referrerpolicy="no-referrer" }

>简单来说既要最短权值消耗，又要尽可能多的流量
## 解题思路
>优先进行最短路径算法，因为在最大流算法中，**必定会引入负权值的边供程序进行反悔操作**，所以不能使用dijsktra算法，要么使用Bellman要么使用Floyd算法，以下采用Floyd算法
## Floyd算法
>动态规划的思想，不多说了，注意把路径记录下来(利用path存储中继结点)
```matlab
function[path,dis]=Floyd(w)
    dis=w;
    n=size(w);
    path=zeros(n);
    for k=1:n
        for i=1:n
            for j=1:n
                if(dis(i,k)+dis(k,j)<dis(i,j))
                    dis(i,j)=dis(i,k)+dis(k,j);
                    path(i,j)=k;
                end
            end
        end
    end
end

```
## 最终代码(详细注释)
>注意cost的计算方式`cost_all=cost_all+delta*w(mypath(i-1),mypath(i));`
>添加弧的过程不要搞错对象
```matlab
cost_all=0;
vector=input("请输入出发点和终点");
while(1)%死循环
    [path,dis]=Floyd(w);
    i=vector(1);
    j=vector(2);
    mypath=[j];
    %获取路径数组
    while path(i,j)~=0
        j=path(i,j);
        mypath=[mypath j];%matlab中数组拼接操作

    end

    mypath=[i fliplr(mypath)];
    if size(mypath,2)==2%%如果size等于2说明没有最短路了
        break;
    end

    %计算最大流过程
    max_x=[+inf];
    for i=2:size(mypath,2)%%注意size也是默认对行求长度
        max_x=[max_x min(max_x(i-1),c(mypath(i-1),mypath(i))-x(mypath(i-1),mypath(i)))];
    end

    delta=min(max_x);

    %每条边加上流量
    for i=2:size(mypath,2)
        x(mypath(i-1),mypath(i))=x(mypath(i-1),mypath(i))+delta;
        cost_all=cost_all+delta*w(mypath(i-1),mypath(i));%这里是增量乘以权值
    end

    %添加弧的过程
    for i=2:size(mypath,2)
        if(x(mypath(i-1),mypath(i)))==c(mypath(i-1),mypath(i))
            %只能添加反向弧
            w(mypath(i),mypath(i-1))=-w(mypath(i-1),mypath(i));
            %删除原弧
            c(mypath(i-1),mypath(i))=0;
            w(mypath(i-1),mypath(i))=+inf;
        end
        if x(mypath(i-1),mypath(i))<c(mypath(i-1),mypath(i))&&x(mypath(i-1),mypath(i))>0
            w(mypath(i),mypath(i-1))=-w(mypath(i-1),mypath(i));
        end
    end

    %统计费用的过程
end
disp("最小费用最大流的结果是");cost_all
```
<br><br><br><br>

# 旅行商TSP问题
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/a337251d195049b2bf2abfa444bd5b35.png){: referrerpolicy="no-referrer" }
## 解题思路
>从本质来讲，这是一个哈密顿回路，我们需要做的就是不断改变以下结点相互之间的顺序(源点和终点不变)，最终取得合法的最优解
>**注意这个最优解不是全局最优解**，极度依赖于初始回路的顺序

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/2449c11fb0474987afc21bd3a111320d.png){: referrerpolicy="no-referrer" }
## 改良圈算法
>简单来说，如果两个顶点i和j间存在一条路径满足以下约束，我们尝试改变其原有次序，**让他们两个顶点优先靠在一起**
>因为改变了次序，为了得到合法的回路，**我们必须反转i+1~j原有次序。**

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/83d539dd18054491853366ce2bf23a5e.png){: referrerpolicy="no-referrer" }
## 具体步骤

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/cc9de79021e84305bc6d4af755745fe0.png){: referrerpolicy="no-referrer" }
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/1cd2cd1e914d409fa1e5cd6643551b1d.png){: referrerpolicy="no-referrer" }
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/9bc006069dc14e798ad9edbaa2dd3d96.png){: referrerpolicy="no-referrer" }
## matlab代码
>这个算法本质上就是暴力模拟，枚举所有的改变方式
>注意取值范围 `i<i+1<j`
>以下对k的遍历是为了逐步逼近局部最优解，但即使是这样，也不能保证找到全局最优解
```matlab
%% 旅行熵问题
clear;clc;
A = [0 56 21 35;%邻接矩阵
     56 0 49 39;
     21 49 0 77;
     35 39 77 0;]
L=size(A,1);%长度是哈密顿图长度-1
c=[1 2 3 4 1];
res=+inf;
for k=1:L
    flag=0;
    %暴力模拟选i和j的情况，注意TSP要求i<i+1<j,
    for i=1:L-2;
        for j=i+2:L
            %反转i+1~j的路径
            if A(c(i),c(j))+A(c(i+1),c(j+1))<A(c(i),c(i+1))+A(c(j),c(j+1))
                c(i+1:j)=c(j:-1:i+1);%反转i+1~j的路径
                flag=1;
            end
        end
    end
    if flag==1
        temp=0;
        for i=1:L
            temp=temp+A(c(i),c(i+1));
        end
        res=min(res,temp);
    end
end
res
%需要注意的是，这个求法依赖于种子c的取值
```


