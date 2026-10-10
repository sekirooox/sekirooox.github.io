---
title: "Python·数据分析和数据预处理"
author: MayL
date: 2024-07-23
categories: ["机器学习与数据分析", "数据分析"]
tags: ["数据分析", "数据预处理", "python", "机器学习"]
render_with_liquid: false
description: "本文围绕“Python·数据分析和数据预处理”整理基本原理、处理流程与实践方法，便于学习复习和数据分析参考。"
---

# numpy
>一个数值计算包
# numpy.array
>类似一个matlab的矩阵
## 生成方式
**以行向量默认生成**
+ 直接生成：`a = np.array([1,2,3,4])`和`a = np.array([[0,1,2,3],[10,11,12,13]])`
+ 列表中产生数组：`a = np.array(l)`
+ 其他函数：`np.zeros(5) ` 和`np.ones(5) `
+ 多维度数组：`np.zeros(5).reshape(5,3)`reshape函数
+ 随机数组：`np.random.random(1,(2,3))`接受列表为维度参数
## 矩阵属性
+ dtype：`np.ones(5,dtype="bool") `数组中要求所有元素的 dtype 是一样的
+ astype：`a = a.astype("float")`强制类型转换
+ **矩阵形状**：`m,n=a.shape`
+ 矩阵维度：`a.nidm`
## 索引：
+ **matlab的索引**:`a[1,:]`等价于`a[1]`返回第一行元素
+  **列表索引**：`a[[1,4,5]] ` 传入列表索引特定行
>多维列表索引一个一维数组：转换为一个维度：`a[[[1,2],[3,4]]]`
## 切片操作
+ 多维度切片：`a[0,3:5]`
+ 计算前缀和/差技巧：`ob = np.array([21000,21800,22240,23450,25000])`
计算公式：`ob2 = ob[1:]-ob[:-1]`
## 分块矩阵
+ 分块：`np.vstack(())`垂直堆叠矩阵	`np.hstack()`水平堆叠
+ 简写：`r-`和`v-`
## 数学函数：
以下对行元素操作
>**所有操作加`arg`表示返回参数(索引)**
>默认对所有元素操作
>常用参数：axis(1行0列)
+ 极值：`np.max(a,axis=1)`返回所有元素中的极值
+ 求和：`np.sum(a)`
+ 均值：`np.mean(a)`
+ 标准差：`np.std(a)`
+ 相关系数矩阵：`np.cov(a,b)`**注意传入两个向量**
+ 转置：`a.T`



# Pandas
>数据分析包，分为两种基本结构
>>Series	一维数组
>>DataFrame二维数组

# DataFrame和Series
>类似excel的**表格**
>**DataFrame支持numpy中的许多操作**
# Series
>**Series本质上也是一个DataFrame**
+ 默认生成方式：`s = pd.Series([1,3,5,np.nan,6,8])`
>**np.nan表示缺失值，注意不等于空**

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/33cadbbc43994dff8cb511e7907831ca.png){: referrerpolicy="no-referrer" }
# DataFrame
>index：左侧标号
>columns：上方索引
>**数据集：一个np形式的矩阵，索引和列作为参数给出**
+ 默认生成方式：`df = pd.DataFrame(np.random.randn(6,4), index = date, columns = list("ABCD"))`
+ 读取表格：`df = pd.read_excel(r"C:\Users\Lovetianyi\Desktop\python\作业3\豆瓣电影数据.xlsx",index_col = 0) `
+ 
## 查看操作
+ 查看头尾数据：`df.head()`和`df.tail(3)`默认为5
+ 取出index:`df.index()`和取出columns：`df.columns`
+ 返回numpy矩阵：`df.values`
## 映射关系
>pandas结构本质上是**多个column对多个index的映射关系**
+ 追加操作：`df['E']=[A,B,C,D,E,F]`
## *索引操作
>pandas不同于numpy，**可以支持多个类型，且数据量大 **，所以采用更加高效的索引方式
+ 朴素索引：`df[name]`根据**编号索引，可行可列**
+ **行索引**：`df.iloc[0:5] `根据**下标索引**和`df.loc['20130101']`根据**编号索引**
+ 列索引：`df.loc[:,['A':'B']]`使用**loc函数**
+ **条件索引**：`df[df["产地"] == "美国"][:5]`和`df[(df.产地 == "美国") & (df.评分 > 9)][:5]`
>**条件索引返回满足列条件的行，列索引返回的是对应列**
## 缺失值处理
+ 丢失缺失值：`.dropna()`将所有有缺失值的行丢弃
+ 缺失值填充：`dp.fillna(value)`填充特定值
### 排序操作
`df.sort_values(by = "投票人数", ascending = False)[:5] #默认从小到大`	注意dataframe结构的构成，中间的矩阵都是**values**

# 数据预处理
## 描述性分析：`df.describe()`
给出一系列基本的统计值
## 统计性的函数
>pandas默认对列进行求值，这点于numpy不同

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/b969b8c943804bb8ba17e5c463041aa2.png){: referrerpolicy="no-referrer" }
## 切片和拼接
+ `pieces=[df[:3],df[3:7],d[7:]]`切片,**返回的是dataframe**
+ `pd.concat(pieces)`拼接碎片**纵向合并**
+ `pd.merge(A,B.on='key',how='inner/outer')`合并操作，取on的**并集或者交集**
## *融合表格
`pd.merge(left,right,on='key')`按照key，融合key相同的表格，**key不同的表格列将被舍弃**
## stack压缩

## 分组
`df["评分"].groupby(df["年代"]).mean()`每一个分组仍然是一个dataframe，可以进行数学运算，注意非数值型元素进行数学运算会错误！
`df[产地].astype('str')`
## pivot_table透视表

# Matplotlib可视化
>matplotlib.pyplot包含一系列类似MATLAB中绘图函数的相关函数
## 绘图函数
+ 显示图片：`plt.show()` 一般不会直接显示图
### 绘制函数：`plt.plot([1,2,3,4],[1,4,9,16],linewidth = 4.0,"ro")` **
+ 属性如下：
	+ 线条属性
	+ 字符和类型属性
+ 提前修改属性：plt.setp(line,"color",'r',"linewidth",4)
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/f76dc9c64c034a6f9213e04ed4879302.png){: referrerpolicy="no-referrer" }
+ 指定坐标轴：`plt.axis([xmin, xmax, ymin, ymax])`
+ 支持传入多张图。
## 子图
>figure是窗口，subplot是子图，
+ 子图figure：`plt.figure(num)` 
这里，figure(1)其实是可以省略的，因为默认情况下plt会自动产生一幅图像。
```python
t1 = np.arange(0.0,5.0,0.1)
t2 = np.arange(0.0,4.0,0.02)

plt.figure(figsize = (10,6))
plt.subplot(211)
plt.plot(t1,f(t1),"bo",t2,f(t2),'k') #子图1上有两条线

plt.subplot(212)
plt.plot(t2,np.cos(2*np.pi*t2),"r--")
plt.show()
```

# 具有统计意义图像绘制
>直接看笔记查对应参数

