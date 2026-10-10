---
title: "数模·降维"
author: MayL
date: 2024-07-25
categories: ["数学基础与数学建模", "数学基础"]
tags: ["数学", "学习笔记"]
render_with_liquid: false
description: "本文整理“数模·降维”涉及的基本原理、计算方法与应用思路，便于学习复习和建模参考。"
---

# 降维
>用较少的新变量代替较多的旧变量，并且最大限度保留原来变量的特征，叫做降维
# 主成分分析
## 1.标准化处理
>也可以不进行标准化处理，到时候使用协方差矩阵即可，但是如果数据进行标准化后，一定要使用相关系数矩阵

![在这里插入图片描](https://i-blog.csdnimg.cn/direct/5f78dedeabd74407b7bff027e334445a.png){: referrerpolicy="no-referrer" }
## 2.计算协方差矩阵或者相关系数矩阵
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/8c2897eeb2c04b56b885ceab0490d366.png){: referrerpolicy="no-referrer" }
## 3.特征值
>这里的特征值大小蕴含着方差大小

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/48c4c64283a147a185f0ffe74ced6dd7.png){: referrerpolicy="no-referrer" }
## 4.计算贡献率
>将特征值进行排序，特征值越大的贡献率越大，越应该成为主成分

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/d63b32d274bf4faca4502fe1d29403f8.png){: referrerpolicy="no-referrer" }
## 5.主成分确定
>计算累加贡献率时应该对特征值列表进行排序(注意排序后下标变了)
>**对累计贡献率取一个阈值85%**

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/56de61123c2d46c9a7e267c687e52956.png){: referrerpolicy="no-referrer" }
## 6++ 分析结果
# PCA+改进代码

```python
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt


def pca():
    data = pd.read_excel('girl3.xlsx')  # 有可能依赖openxyl
    print('请确保数据进行标准化！')
    covariance_matrix = data.cov(ddof=1)  ## 参数ddof=1，表示结果除以N-1
    # 打印协方差矩阵
    print(F'协方差矩阵如下\n{covariance_matrix}')

    # 数据标准化后使用相关系数矩阵，数据未标准化可以使用协方差矩阵
    # 计算数据集中各列之间的相关系数
    correlation_matrix = data.corr()
    print(f'相关系数矩阵如下\n{correlation_matrix}')

    featValue, featVec = np.linalg.eig(correlation_matrix)  # 求解协方差矩阵的特征值和特征向量
    # print(f'特征值如下{featValue}长度为{len(featValue)}')
    dict={}
    for i in range(len(featValue)):
        dict[featValue[i]]=i
    print(f'特征值如下{featValue}长度为{len(featValue)}')
    featValue = sorted(featValue)[::-1]  # 对特征值进行排序，特征值大的贡献多
    print(f'特征向量矩阵如下\n{featVec}')

    x = np.linspace(0, 1, len(featValue))
    plt.plot(x, featValue)
    plt.show()

    # 主成分贡献和累加贡献
    featValue_contribute = featValue / np.sum(featValue)
    cumsum_contribute = np.cumsum(featValue_contribute)
    print(f'累加贡献如下{cumsum_contribute}')

    # 选出主成分
    k =[] # 选择85%作为阈值
    for i in range(len(cumsum_contribute)):
        if cumsum_contribute[i]<0.85:
            k.append(dict[featValue[i]])
    k=sorted(k)
    print(f'选择的主成分如下{k}')

    # 选出主成分对应的特征向量矩阵
    selectVec = np.matrix(featVec.T[k]).T
    finalData = np.dot(data, selectVec)
    # finalData = data @ selectVec
    print(F'特征向量矩阵如下\n{finalData}')
if __name__ == '__main__':
    pca()
```
# 因子分析
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/c96e2ffa4d09460a91bf7a82e5b07bbe.png){: referrerpolicy="no-referrer" }
>**以下图中的成分(FACTOR)都是上述图里的公共因子**

## 1.前提：KMO检验和巴特利特球形检验
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/4ee18bbd6c9645c8afaa194895fbe3ae.png){: referrerpolicy="no-referrer" }

### KMO检验
>解释一下KMO检验是否通过，显著性水平大小体现了置信程度

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/6d1b6e251881412ab208663e89fb8ea8.png){: referrerpolicy="no-referrer" }
### 巴特利特球形检验：
>原假设相关系数矩阵是一个单位阵，这个检验利用p值检验，**注意解释一下p值检验小于显著性系数**

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/77532e1906cb47b590d1a33afdd230e5.png){: referrerpolicy="no-referrer" }
## 2.评价
### 碎石图
>**特征值代表贡献率**，贡献率越大越有可能成为主成分

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/252ffe72786340c78d299bd231b7724a.png){: referrerpolicy="no-referrer" }
### 公因子方差
>提取的两个公因子对这些的贡献率

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/8758121e63064243b981390008b57b02.png){: referrerpolicy="no-referrer" }
### 总方差
>每一个表格的**第二列就是贡献率，第三列是累计贡献率**
旋转后的指标应该集中于55开，两个指标都有较大贡献

 ![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/2aeaa271031c45cf87abd255bcbbaed9.png){: referrerpolicy="no-referrer" }



