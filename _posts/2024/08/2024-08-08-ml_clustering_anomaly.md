---
title: "机器学习·L3W1-聚类和异常检测"
author: MayL
date: 2024-08-08
categories: ["机器学习与数据分析", "机器学习"]
tags: ["聚类", "异常检测", "机器学习", "数据分析"]
render_with_liquid: false
math: true
description: "本文围绕“机器学习·L3W1-聚类和异常检测”整理基本原理、处理流程与实践方法，便于学习复习和数据分析参考。"
---

# Kmean聚类
+ 初始化聚类中心(随机选择)
+ 更新类别
+ 计算新的聚类中心
## 随机选择样本点作为聚类中心
>K个聚类中心的情况
```python
    randidx=np.random.permutation(X.shape[0])
    initial_centers=X[randidx[:K]]
```
## 更新类别
>公式是计算每一个聚类中心和当前样本的距离，挑选一个最短距离作为当前点的类别
>距离不一定是欧式距离

两层for循环直接暴力搜索
```python
def closest_centroid(X,centroids):
    """
    Computes the centroid memberships for every example
    
    Args:
        X (ndarray): (m, n) Input values      
        centroids (ndarray): (K, n) centroids
    
    Returns:
        idx (array_like): (m,) closest centroids
    
    """
    K=centroids.shape[0]
    idx=np.zeros(K)
    for i in range(X.shape[0]):
        index=-1
        dist=99999999 # 最大的数
        for j in range(K):
            temp=np.sum((X[i]-centroids[j])**2)
            if temp<dist:
                dist=temp
                index=j
        idx[i]=index
    return idx
```
## 生成新的聚类中心
>一般采取计算样本的均值，使用`np.mean()`即可
>注意python的条件索引
* Specifically, for every centroid $\mu_k$ we set
$$\mu_k = \frac{1}{\lvert C_k\rvert} \sum_{i \in C_k} x^{(i)}$$

    where 
    * $C_k$ is the set of examples that are assigned to centroid $k$
    * $\lvert C_k\rvert$ is the number of examples in the set $C_k$
```python
def update_centroids(X,idx,centroids):
    """
    Returns the new centroids by computing the means of the 
    data points assigned to each centroid.
    
    Args:
        X (ndarray):   (m, n) Data points
        idx (ndarray): (m,) Array containing index of closest centroid for each 
                       example in X. Concretely, idx[i] contains the index of 
                       the centroid closest to example i
        K (int):       number of centroids
    
    Returns:
        centroids (ndarray): (K, n) New centroids computed
    """
    m,n=X.shape
    K=centroids.shape[0]
    centroids=np.zeros((K,n))
    for i in range(K):
        centroids[i]=np.mean(X[idx==i],axis=0)
    return centroids
```
# 最终代码
```python
def kmeans_plus(X,K,max_iters):
    m,n=X.shape
    # 随机生成中心
    randidx=np.random.permutation(X.shape[0])
    initial_centers=X[randidx[:K]]
    
    idx=np.zeros(K,n)
    centroids=initial_centers
    for i in range(max_iters):
        print("K-Means iteration %d/%d" % (i, max_iters-1))
        idx=closest_centroid(X,centroids)
        centroids=update_centroids(X,idx,centroids)
    return idx,centroids
```

# 异常检测
+ 选择合适的epsilon，常常使用F1分数评估
+ 计算每个特征的概率密度
## 基本原理
计算每个样本点的正态分布概率密度，并且累乘得到最终概率，依据概率选择epsilon处理异常。
**原理及其依赖样本点的分布情况！应该尽可能保证样本点是正态分布！**
>**多使用对数化，多项式化来让样本点保持正态分布！**
## 异常检测和分类的区别
>异常检测是无监督学习，分类是有监督学习；**异常检测更容易发现样本中不经常出现的异常特征，分类更容易发现样本中经常出现的特征。**
## 高斯函数
>注意高斯函数算完后还要**累乘**
```python
def normal_distribution(X):
    m,n=X.shape
    mu=np.mean(X,axis=0)
    sigma=np.std(X,axis=0)
    sigma[sigma==0]=1e-5
    p=1/np.sqrt(2*np.pi*sigma**2)*np.exp(-(X-mu)**2/(2*sigma**2))
    p=np.prod(p,axis=1)
    return p
```

## F1分数计算

   $$\begin{aligned}
   prec&=&\frac{tp}{tp+fp}\\
   rec&=&\frac{tp}{tp+fn},
   \end{aligned}$$ where


  * The $F_1$ score is computed using precision ($prec$) and recall ($rec$) as follows:
    $$F_1 = \frac{2\cdot prec \cdot rec}{prec + rec}$$ 
>利用python的判断语法

```python
def compute_f1(y_val,p_val,epsilon):
    # 1是有缺陷 0是无缺陷
    prediction=p_val<epsilon
    tp=np.sum((y_val==1)&(prediction==1))
    fp=np.sum((y_val==0)&(prediction==1))
    fn=np.sum((y_val==1)&(prediction==0))
    prec=tp/(tp+fp) if tp+fp>0 else 0
    rec=tp/(tp+fn) if tp+fn>0 else 0
    f1=2*prec*rec/(prec+rec) if prec+rec>0 else 0
    return prec,rec,f1
```
## 选择阈值
>参照分类模型的评估标准，选择F1分数最高的模型参数
```python
def select_threshold(y_val,p_val):
    best_epsilon=0
    best_f1=0
    prec_list=[]
    rec_list=[]
    e_list=[]
    step_size=(np.max(p_val)-np.min(p_val))/1000
    for e in np.arange(np.min(p_val),np.max(p_val),step_size):
        prec,rec,temp=compute_f1(y_val,p_val,e)
        prec_list.append(prec)
        rec_list.append(rec)
        e_list.append(e)
        if temp>best_f1:
            best_epsilon=e
            best_f1=temp
    return best_epsilon,best_f1,prec_list,rec_list,e_list
```
