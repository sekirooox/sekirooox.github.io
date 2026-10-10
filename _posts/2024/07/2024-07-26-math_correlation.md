---
title: "数模·相关性"
author: MayL
date: 2024-07-26
categories: ["数学基础与数学建模", "数学基础"]
tags: ["数学", "学习笔记"]
render_with_liquid: false
description: "本文整理“数模·相关性”涉及的基本原理、计算方法与应用思路，便于学习复习和建模参考。"
---

# 皮尔逊相关系数
> 注意相关系数r只有0和1一个取值，

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/b1fa0b3d949546dc9b95583e73772fa3.png){: referrerpolicy="no-referrer" }
# 相关系数的使用条件
>**线性相关**，要绘制散点图查看

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/e5a881889f07442992657a3be01ec390.png){: referrerpolicy="no-referrer" }
# 假设检验
## 主观的假设检验，适用于热力图
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/53801ef9b2da43a2bce11ecf74bb53da.png){: referrerpolicy="no-referrer" }
## 假设检验的条件
>样本的均值不是正态分布，需要提前检验

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/19ef6f80feb7460ead59f0e353560273.png){: referrerpolicy="no-referrer" }
## JB检验
>利用之前计算的S,K构造JB统计量
>
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/189042786aaa4a9f810758ae2b1459ff.png){: referrerpolicy="no-referrer" }
## 零假设和备择假设
> 零假设：假设无相关性 r=0;备择假设：有相关性 r=1
> 这里的假设是右尾假设：**也就是只要算出来的t*大于理论值t，就可以拒绝原假设**

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/0a0730f26a174c6aaec3a4ca365204af.png){: referrerpolicy="no-referrer" }![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/741cdea3f71048d38f2af9860f95b8e2.png){: referrerpolicy="no-referrer" }
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/a263c6b0be9c48538b1ebf67affe47d6.png){: referrerpolicy="no-referrer" }
## p假设检验

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/920dadc0e6974231aff33072003dea41.png){: referrerpolicy="no-referrer" }
## 显著性标记
>在学术出版、‌科学研究等领域，‌显著性标记星号通常用于表示统计显著性。‌例如，‌在实验结果中，‌如果某个数据点的p值小于0.05，‌**研究者可能会在该数据点旁边加上星号，‌以表明这个结果具有统计显著性**，‌即这个结果不太可能是由于偶然或随机误差造成的。‌星号的数量（‌如一个星号、‌两个星号等）‌通常代表p值的范围，‌比如一个星号可能表示p<0.05，‌两个星号可能表示p<0.01，‌以此类推。‌这种标记方式帮助读者快速理解哪些结果是统计上显著的，‌从而更好地理解研究结果的意义和重要性。‌

这个部分对p值矩阵来做，可以直接少去一步对每一个变量进行假设检验的步骤

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/ecb314919da7436fb56f083000e37f69.png){: referrerpolicy="no-referrer" }


# Python全过程代码
>一定要先对数据进行预处理！！！
```python
import matplotlib.pyplot as plt
import seaborn as sns
import pandas as pd
import numpy as np
from scipy.stats import pearsonr, t
from scipy.stats import ttest_ind
from statannotations.Annotator import Annotator
from scipy import stats
import statsmodels.api as sm

# 优先绘制散点图看是否呈现线性趋势
def JB_test(data):
    alpha=0.05
    #直接调包进行jb检验
    # 绘制QQ图

    for col in data.columns:
        jb_stat, jb_pvalue, skew, kurtosis=sm.stats.jarque_bera(data[col])
        print(f"{col} 的JB检验结果如下：")
        print(f"p值: {jb_pvalue}")
        if jb_pvalue<0.05:
            print(f'我们应该拒绝零假设，{col}列通过了JB检验')
        else:
            print(f'我们无法拒绝零假设,{col}列有{1-jb_pvalue}的把握通过JB检验')

        # 查看每一列的QQ图

        fig = sm.qqplot(data[col])
        plt.title(f'{col}的QQ图')
        plt.show()

def describe_data(data):
    print('现在打印前几行数据\n', data.head())
    # 描述性统计
    statistics=data.describe(include='all')
    print(statistics)

    sns.pairplot(data)
    plt.show()

def corr_test(data):
    cov_matrix=data.cov(ddof=1)
    print(f'协方差矩阵如下：\n{cov_matrix}')
    corr_matrix = data.corr()
    print(f'相关系数矩阵如下：\n{corr_matrix}')
    plt.figure(figsize=(9, 6), dpi=100)
    sns.set_style(rc={'font.sans-serif': "Microsoft Yahei"})
    sns.heatmap(data.corr().round(2), annot=True, cmap='YlOrRd')
    plt.show()


    p_values = pd.DataFrame(index=data.columns, columns=data.columns)
    for i in data.columns:
        for j in data.columns:
            if i==j:
                p_values.loc[i,j]=1
                continue
            _,p_values.loc[i,j]=stats.pearsonr(data[i],data[j])

    print(f'皮尔逊相关系数矩阵如下\n{p_values}')

    ##显著性标记
    significance_mark=pd.DataFrame(index=data.columns,columns=data.columns)
    for i in range(len(p_values.columns)):
        for j in range(len(p_values.columns)):
            if p_values.iloc[i,j] <= 0.0001:
                significance_mark.iloc[i,j]='****'
            elif p_values.iloc[i,j] <= 0.001:
                significance_mark.iloc[i, j] ="***"
            elif p_values.iloc[i,j] <= 0.01:
                significance_mark.iloc[i,j]="**"
            elif p_values.iloc[i,j] <= 0.05:
                significance_mark.iloc[i,j]="*"
            else:
                significance_mark.iloc[i,j]="ns"
    #如果有*表示通过了县官系数检验，二者具有相关性
    print('以下打印显著性标记矩阵\n：ns表示没有通过假设检验！*表示通过假设检验')
    print(f'{significance_mark}')

if __name__ == '__main__':
    plt.rcParams['font.family'] = ['Microsoft YaHei']
    plt.rcParams['axes.unicode_minus'] = False

    # 使用前确定数据进行标准化处理
    data=pd.read_excel('girl.xlsx')
    describe_data(data)
    JB_test(data)
    corr_test(data)
```

# spss制作矩阵散点图
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/5d4b98cba6ca40c38e7ef0abfb78e772.png){: referrerpolicy="no-referrer" }
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/477e2201171f4bb7ba94e39deef80793.png){: referrerpolicy="no-referrer" }
## 函数调用步骤
+ 求解相关系数的充分条件：绘制散点图，确定变量之间是否出于线性关系
+ 求解相关系数，绘图：
+ 检验相关系数的充分条件：数据是否呈正态分布-JB检验
+ 检验相关系数：

# 典型相关分析
>典型相关分析（Canonical Correlation Analysis, CCA）的主要目的是**确定两组变量之间的相关性**，但它与简单的相关性分析不同。CCA不仅仅是在单个变量之间寻找相关性，而是**寻找两组变量中线性组合的最大相关性**
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/91d55e234cf44cdbb8254117bd5fc859.png){: referrerpolicy="no-referrer" }


## spss调用
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/79750b386729469fb0e434fa21e5b98c.png){: referrerpolicy="no-referrer" }
## 结果解释
### 典型相关性表
>**只选择相关性最大的一列进行解释**
>描述p值小于显著性水平，通过假设性检验

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/0418fa127bce42369096186e45ad1e0c.png){: referrerpolicy="no-referrer" }
### 标准化/非标准化典型相关系数表
>每一个集合中各自变量之间的相关系数
>**应该看标准化的结果**

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/8ab3eed492cb4a508737c667b990c193.png){: referrerpolicy="no-referrer" }
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/d9801b9b91d9456089f081e1064e6e6d.png){: referrerpolicy="no-referrer" }
### 载荷
>载荷就是**线性组合的系数**
>行变量是典型变量名
>应该往列看，**一般也只看第一列**

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/3b7ae30325144044901f0ed60fbdf874.png){: referrerpolicy="no-referrer" }
### 贡献率
>看第一行
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/b7326cfc8e2d4d2cbf50e945d59d8165.png){: referrerpolicy="no-referrer" }







