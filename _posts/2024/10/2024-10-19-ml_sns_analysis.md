---
title: "sns数据分析"
author: MayL
date: 2024-10-19
categories: ["机器学习与数据分析", "数据分析"]
tags: ["数据分析", "机器学习"]
render_with_liquid: false
description: "本文围绕“sns数据分析”整理基本原理、处理流程与实践方法，便于学习复习和数据分析参考。"
---

# 探索性数据分析
这一部分**目的在于了解数据**，包括数据是**什么类型**，数据有**什么特点**
## 数据信息
```python
print(data.shape)
data.info()
```
---
```python
(1086, 12)
<class 'pandas.core.frame.DataFrame'>
Index: 1086 entries, 2020/7/1 0:00 to nan
Data columns (total 12 columns):
 #   Column   Non-Null Count  Dtype  
---  ------   --------------  -----  
 0   水生根茎类    1060 non-null   float64
 1   花叶类      1037 non-null   float64
 2   花菜类      1080 non-null   float64
 3   茄类       1066 non-null   float64
 4   辣椒类      1080 non-null   float64
 5   食用菌      1074 non-null   float64
 6   水生根茎类类别  1085 non-null   object 
 7   花叶类类别    1085 non-null   object 
 8   花菜类类别    1085 non-null   object 
 9   茄类类别     1085 non-null   object 
 10  辣椒类类别    1085 non-null   object 
 11  食用菌类别    1085 non-null   object 
dtypes: float64(6), object(6)
memory usage: 110.3+ KB
```
## 分开数值列和类别列：
`data.select_dtypes(include='float64')`：**去挑选数值类型等于include的行**
```python
numeric_cols=data.select_dtypes(include='float64').columns# df
category_cols=data.select_dtypes(include='object').columns
numeric_cols,category_cols
```
## 统计学描述
data.drop(columns=numeric_col+'z-score',inplace=True)
```python
numeric_data.describe()
```
# 数据预处理环节
## 数据清洗环节
获取缺失值
`null_counts=data.isnull().sum()`：返回一个Series
`null_counts_nonzero=null_counts_nonzero.sort_values(ascending=False)`排序更加直观
数据可视化：
以下是一个描绘一个缺失值大小和占比图像的代码
```python
"""可视化缺失数据"""
plt.rcParams['font.family'] = ['Microsoft YaHei']
plt.rcParams['axes.unicode_minus'] = False
def show_missing_values(data):
    null_counts=data.isnull().sum()    
    
    null_counts_nonzero=null_counts[null_counts>0]
    
    null_counts_nonzero=null_counts_nonzero.sort_values(ascending=False)
    print(type(null_counts_nonzero))
    
    plt.figure(figsize=(10,6))
    if not null_counts_nonzero.empty:
        ax=sns.barplot(x=null_counts_nonzero.values,y=null_counts_nonzero.index,palette="viridis")
    
        # palette调色板 data参数需要传入的是一个DataFrame，可以不传入，传入错误绘图有问题
        # sns中大部分参数会返回ax,可以用来设置标题，添加文本，设置限制和标签与图例
        ax.set_title('null number statics')
    
        for i,value in enumerate(null_counts_nonzero.values):
            ax.text(value+1,i,f'{value}',va='center')
        
        null_counts_nonzero=null_counts_nonzero[numeric_cols] 
        plt.figure(figsize=(10,6))
        plt.pie(x=null_counts_nonzero.values,labels=null_counts_nonzero.index,autopct='%1.1f%%')
        plt.title('null number distribution-pie figure')
        plt.show()
    else:
        print('暂未发现缺失值！绘图提前结束！')
show_missing_values(data)
```
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/c72e2945cb9c4bdb9175439b1d58af44.png){: referrerpolicy="no-referrer" }
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/61f412bcad6e4c48aef4dcc4924b47aa.png){: referrerpolicy="no-referrer" }
## 异常值处理环节
np.where函数，**类似倒置的if条件语句**：**cond,true,false**
```python
np.where(data[numeric_col+'z-score']<-3,
                     mean-3*std,    data[numeric_col]
                )
```
+ 异常值处理1：直接丢弃
+ 异常值处理2：变为上限值

>异常值处理可以优化我们的数据，增强数据的可分析性
```python
"""异常值处理:Z-score>3"""
def abnormal_data_process(data):
    # 异常值处理前的图像
    plt.figure(figsize=(12,8))
    ax=sns.lineplot(data=data,x=np.arange(1,len(data)+1),\
                    y=data[numeric_cols[0]],color='cornflowerblue',linewidth=2,\
                    marker='o',markersize=4,markerfacecolor='white',markeredgecolor='blue')
    
    ax.set_title(f'日期-{numeric_cols[0]}的销售量',fontsize=20)
    ax.set_xlabel(f'日期',fontsize='20')
    ax.set_ylabel(f'{numeric_cols[0]}的销售量',fontsize='20')
    ax.set_yticks(np.arange(1,140,10))
    
    # 异常值处理
    for numeric_col in numeric_cols:
        #计算每列的z-score
        mean=data[numeric_col].mean()
        std=data[numeric_col].std()
        data[numeric_col+'z-score']=(data[numeric_col]-mean)/std
        
        # np.where(cond,true,false)
        
        data[numeric_col]=np.where(data[numeric_col+'z-score']>3,mean+3*std,
            np.where(data[numeric_col+'z-score']<-3,
                     mean-3*std,    data[numeric_col]
                )
            )
        data.drop(columns=numeric_col+'z-score',inplace=True)# 丢弃掉不需要的列
    
    # 异常处理后的图像
    plt.figure(figsize=(12,8))
    ax=sns.lineplot(data=data,x=np.arange(1,len(data)+1),y=data[numeric_cols[0]],
                    color='deepskyblue',
                    marker='o',markersize=4,markerfacecolor='white',
                    markeredgecolor='deepskyblue')# marker='o',markersize=1
    
    ax.set_title(f'日期-{numeric_cols[0]}的销售量',fontsize=20)
    ax.set_xlabel(f'日期',fontsize='20')
    ax.set_ylabel(f'{numeric_cols[0]}的销售量',fontsize='20')
    ax.set_yticks(np.arange(1,140,10))
    return data
data=abnormal_data_process(data)
```
处理前的图像：
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/a15c827df88f4b97a241e045c1c939d0.png){: referrerpolicy="no-referrer" }
处理后的图像：
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/7336d2b63deb4aea9805e9230c38ac91.png){: referrerpolicy="no-referrer" }

# seaborn绘图
## plt中绘制子图
先讲一下怎么绘制子图
```python
fig,axes=plt.subplots(5,1)
```
返回一个可以索引的axes对象，可以进行plt的各种操作
**注意`subplot`函数与其类似，但是功能不相同**
## `sns.xxx`函数的返回值
大部分`sns.xxx`返回一个**ax对象**，这个对象有很多操作：设置标题，添加文本，设置横纵坐标上下界，设置图例
其中这样理解：使用`set_XXX`的都是主动操作，不使用的都视作ax本身的属性
+ `ax.set_title('null number statics')`
+ `ax.set_xlabel(f'日期',fontsize='20')`
+ ` ax.set_ylabel(f'{numeric_cols[0]}的销售量',fontsize='20')`
+ `ax.set_yticks(np.arange(1,140,10))`
+ `ax.legend()`:**与`label=str`属性一起使用**，往往与text或者axvline函数配合
+ `ax.text()`
+ `ax.axvline(x=q,color='black',linestyle='--',label=f'Quantile{i:}-{q:.2f}')`
---
对于`ax.legend()`函数:

```python
 for i,q in zip(quantities_indices,quantities):
     ax.axvline(x=q,color='black',linestyle='--',label=f'Quantile{i:}-{q:.2f}')
     ax.legend()
```
**与`label=str`属性一起使用**，往往与text或者axvline函数配合

---
对于`ax.text()`函数：
```python
ax.text(x,y,f'label',va='center',ha='center')
```
+ x和y是注释的位置：**对于object数据来说，直接使用[0,n]的数据进行代替，而不是使用名称进行索引**
+ label：是一个字符串，建议使用`f{str}`
+ `va='center',ha='center'`默认设置即可
---
对于`ax.axvline()`/`ax.axhline()`函数
```python
ax.axv/hline(x/y,color=,linestyle=,label=str)
```
+ 如果是竖线则绘制**竖线的x坐标**，为横线则为横线的**y坐标**
+ linestyle最好设置为虚线
+ `label='str'`:**字符串**形式

```python

ax=sns.barplot(x=null_counts_nonzero.values,y=null_counts_nonzero.index,palette="viridis")
    
        # palette调色板 data参数需要传入的是一个DataFrame，可以不传入，传入错误绘图有问题
        # sns中大部分参数会返回ax,可以用来设置标题，添加文本，设置限制和标签与图例
        ax.set_title('null number statics')
    
        for i,value in enumerate(null_counts_nonzero.values):
            ax.text(value+1,i,f'{value}',va='center')
```
## `sns.xxx`的通用格式
```python
ax=sns.barplot(
	x=,y=,data=,
	color=,linewidth=,
	palette=,
	marker=,markersize=,markefacecolor=,markeredgecolor=)
```
+ data：**必须接受一个DataFrame参数**，否则会出现意料之外的错误，**可以不设置这个参数**
+ x：横轴数据；y：纵轴数据。可以接受object对象,可以**接受ndarray，series**，一般**不接受dataframe**
+ palette:调色板对象，**一般使用`palette='viridis'` VIRIDIS**
+ marker一类：`marker='o'`,其余两个是标记本身和标记边缘的颜色，**一般将边缘颜色设置为与color一致**
## histogram直方图
```python
ax=sns.histplot(x=sale_data,kde=True,color='purple',bins='auto')
```
+ kde:核密度曲线是否绘制
+ bins：一般默认auto
+ x：**接受series或者ndarray**
## boxplot
```python
ax=sns.boxplot(data=data,orient='h',palette="viridis",fliersize=2,flierprops=flierprops)
```
+ 只需要传入data
+ orient：朝向水平h或者垂直v
+ flier过滤点一类的参数：
```python
    flierprops={'marker':'o','markerfacecolor':'black','markeredgecolor':'white',
                'markersize':4
                }
```
## heatmap
```python
sns.heatmap(corr_matrix,fmt='.2g',cmap='Reds',annot=True)
```
+ fmt:小数格式
+ cmap：映射
+ annot：数值注释
## pie
sns没有绘制pie的函数，但是绘制pie的函数与其通用格式非常像
```python
 plt.pie(x=null_counts_nonzero.values,labels=null_counts_nonzero.index,autopct='%1.1f%%')
```
+ x：ndarray或者series
+ label：标签
+ autopct：小数格式

