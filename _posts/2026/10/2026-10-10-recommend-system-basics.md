---
title: "推荐系统基础"
date: 2026-10-10 00:00:00 +0800
description: 推荐系统
categories: ["推荐系统"]
tags: ["推荐系统","深度学习","协同过滤"]
render_with_liquid: false
pin: false
math: true
mermaid: true
---

# 推荐系统基础
## 转换流程
<figure><img src="tui-jian-xi-tong-zhuan-hua-liu-cheng.png" alt="转换流程" width="362"><figcaption><p>转化行为链路</p></figcaption></figure>

## 短期消费指标
消费指标通常具有**短期性和局限性**，不能完整反映推荐系统的整体质量。

>例如，高点击率并不代表推荐结果具有<span style="color:red">多样性</span>，系统可能只是持续推荐“标题党”内容。

$$
\begin{align}
\mathrm{CTR}&=\frac{N_{\mathrm{click}}}{N_{\mathrm{impression}}}\\
r_{\mathrm{like}}&=\frac{N_{\mathrm{like}}}{N_{\mathrm{click}}}\\
r_{\mathrm{collect}}&=\frac{N_{\mathrm{collect}}}{N_{\mathrm{click}}}\\
r_{\mathrm{share}}&=\frac{N_{\mathrm{share}}}{N_{\mathrm{click}}}\\
r_{\mathrm{finish}}&=\frac{N_{\mathrm{finish}}}{N_{\mathrm{click}}}\cdot f(l)
\end{align}
$$

其中，$$N_{\mathrm{impression}}$$ 和 $$N_{\mathrm{click}}$$ 分别表示曝光次数和点击次数，其余 $$N$$ 表示相应行为次数；$$l$$ 为内容长度，$$f(l)$$ 为长度校正函数。

<figure><img src="tui-jian-xi-tong-xiao-fei-zhi-biao.png" alt="消费指标" width="383"><figcaption><p>短期消费指标</p></figcaption></figure>

## 北极星指标
北极星指标用于衡量推荐系统的长期价值和整体质量。

>当消费指标与北极星指标发生冲突时，应该<span style="color:red">优先考虑北极星指标</span>。

<figure><img src="tui-jian-xi-tong-bei-ji-xing-zhi-biao.png" alt="北极星指标" width="397"><figcaption><p>北极星指标构成</p></figcaption></figure>

## 实验流程
+ **离线实验**：在历史数据上完成训练与测试，**不影响线上真实用户**。
+ **A/B 测试**：将策略部署到真实场景，但仅分配**部分流量**进行验证。
+ **全流量上线**：实验通过后，将胜出的策略推广至平台**全部流量**。

<figure><img src="tui-jian-xi-tong-shi-yan-liu-cheng.png" alt="实验流程" width="396"><figcaption><p>推荐实验流程</p></figcaption></figure>

## 推荐系统的链路
<figure><img src="tui-jian-xi-tong-tui-jian-lian-lu.png" alt="推荐链路" width="393"><figcaption><p>推荐系统链路</p></figcaption></figure>

+ 召回：从**数亿**物品中快速筛选出**数千**个候选物品。

<figure><img src="tui-jian-xi-tong-zhao-hui-tong-dao.png" alt="召回通道" width="389"><figcaption><p>多路召回通道</p></figcaption></figure>

+ 粗排与精排：进一步过滤数千个候选物品，保留**数百**个，并计算**排序分数**后进行排序。

<figure><img src="tui-jian-xi-tong-cu-pai-yu-jing-pai.png" alt="粗排与精排" width="396"><figcaption><p>粗排精排打分</p></figcaption></figure>

+ 重排：完成最后一轮筛选，保留**数十**个物品并**推荐给用户**。

>重排阶段还需兼顾**多样性抽样**、规则打散以及广告插入等业务约束。

<figure><img src="tui-jian-xi-tong-lian-lu-jie-duan-zong-jie.png" alt="链路阶段总结" width="375"><figcaption><p>推荐链路总结</p></figcaption></figure>


## A/B 测试
A/B 测试是在真实线上流量中开展的对照实验，主要用于验证策略效果。

### 流量分桶
先对流量进行**分桶**，再将不同流量桶划分为对照组和实验组。

<figure><img src="tui-jian-xi-tong-sui-ji-fen-tong.png" alt="随机分桶" width="359"><figcaption><p>实验随机分桶</p></figcaption></figure>

### 分层实验：同层互斥，不同层正交

<figure><img src="tui-jian-xi-tong-fen-ceng-shi-yan.png" alt="分层实验" width="374"><figcaption><p>分层实验机制</p></figcaption></figure>


#### 同层互斥
同一层中的不同实验可能影响相同指标，例如点击率。

>因此，同层实验不能共用同一个流量桶。

同层实验应当**相互排斥**，避免流量重叠干扰策略效果的判断。

>这里的<span style="color:red">层</span>按实验影响的指标划分。若两项实验可能共同影响点击率等指标，例如新推荐算法 A 与 UI 卡片实验，就应将它们相互隔离。

<figure><img src="tui-jian-xi-tong-tong-ceng-hu-chi.png" alt="同层互斥" width="395"><figcaption><p>同层流量互斥</p></figcaption></figure>


#### 不同层正交
正交表示不同实验之间的相互影响较小。例如，推荐算法 A 对点击率影响较大，而广告算法 B 对点击率的**影响较小**，二者可以复用同一份流量。
<figure><img src="tui-jian-xi-tong-bu-tong-ceng-zheng-jiao.png" alt="不同层正交" width="392"><figcaption><p>跨层流量正交</p></figcaption></figure>


例如，作用<span style="color:red">效果相近</span>的策略（如同时增加两条召回通道）容易相互干扰，因此并不正交；作用<span style="color:red">效果错位</span>的策略（如优化召回与优化粗排）相互影响较小，因此可以视为正交。

<figure><img src="tui-jian-xi-tong-hu-chi-yu-zheng-jiao.png" alt="互斥与正交" width="328"><figcaption><p>互斥正交对比</p></figcaption></figure>

从流量分配角度看，策略 A 与策略 B 的分桶事件<span style="color:red">相互独立</span>；这用于说明不同实验层的流量正交，不等同于证明两项策略的效果彼此独立。

$$
\begin{align}
P(A_1\cap B_1)&=P(A_1)P(B_1)=0.5\times0.5=0.25
\end{align}
$$

其中，$$A_1$$ 和 $$B_1$$ 分别表示两个实验层的处理组事件。

<figure><img src="tui-jian-xi-tong-zheng-jiao-gai-lv-shi-li.png" alt="正交概率示例" width="760"><figcaption><p>正交分组独立</p></figcaption></figure>


### Holdout 机制：对照组
Holdout 机制会预留一组长期使用旧策略的流量，用于对比实验桶与基线之间的差异。

<figure><img src="tui-jian-xi-tong-liu-chu-dui-zhao-tong.png" alt="留出对照桶" width="400"><figcaption><p>留出对照桶</p></figcaption></figure>

值得注意的是，轮换式 Holdout 会按周期将旧桶**自动推全**，随后再**随机选择**新的 Holdout 桶，以持续保留长期对照流量。

### 反转实验：验证长期策略
部分策略需要长期验证，例如需要持续积累用户习惯数据。

为了在快速推全的同时**观察策略的长期效用**，可以预留少量使用旧策略的**反转桶**。

反转桶持续使用旧策略，用于与新策略流量进行长期对比；验证结束后，再删除反转桶并完成推全。

<figure><img src="tui-jian-xi-tong-fan-zhuan-tong-jie-gou.png" alt="反转桶结构" width="348"><figcaption><p>反转实验原理</p></figcaption></figure>

<figure><img src="tui-jian-xi-tong-fan-zhuan-shi-yan-fen-liu.png" alt="反转实验分流" width="379"><figcaption><p>反转实验分流</p></figcaption></figure>

# 召回
## 基于物品的协同过滤（ItemCF）
### 动机：物品之间的关联
ItemCF 假设物品之间存在可由用户行为刻画的<span style="color:red">关联</span>。

### 物品相似度：余弦相似度

$$
\begin{align}
s(i_1,i_2)&=\frac{\sum_{v\in\mathcal V}\operatorname{like}(v,i_1)\operatorname{like}(v,i_2)}{\sqrt{\sum_{u_1\in\mathcal W_1}\operatorname{like}^2(u_1,i_1)}\sqrt{\sum_{u_2\in\mathcal W_2}\operatorname{like}^2(u_2,i_2)}}
\end{align}
$$

其中，$$s(i_1,i_2)$$ 为物品 $$i_1$$ 与 $$i_2$$ 的相似度，$$\operatorname{like}(u,i)$$ 表示用户 $$u$$ 对物品 $$i$$ 的交互强度；$$\mathcal W_1$$ 和 $$\mathcal W_2$$ 为喜欢两个物品的用户集合，$$\mathcal V=\mathcal W_1\cap\mathcal W_2$$。

<figure><img src="tui-jian-xi-tong-wu-pin-yu-xian-xiang-si-du.png" alt="物品余弦相似度" width="399"><figcaption><p>物品余弦相似度</p></figcaption></figure>

### 数学原理
不考虑 Top-K 筛选时，其核心公式如下：

$$
\begin{align}
\mathbf S_{m\times n}&=\mathbf R_{m\times n}\mathbf W_{n\times n}
\end{align}
$$

其中，$$m$$ 为用户数，$$n$$ 为物品数；$$\mathbf R$$ 为用户—物品交互矩阵，$$\mathbf W$$ 为物品相似度矩阵，$$\mathbf S$$ 为预测兴趣矩阵。
<figure><img src="tui-jian-xi-tong-itemcf-ju-zhen-xing-shi.png" alt="ItemCF矩阵形式" width="760"><figcaption><p>物品协同过滤矩阵</p></figcaption></figure>


### 召回流程
先获取用户对若干物品的兴趣分数，再计算这些物品与候选物品的相似度，最后通过**加权求和**得到用户对候选物品的兴趣分数。

$$
\begin{align}
\hat r_{u,i}&=\sum_{j\in I_u}r_{u,j}s_{j,i}=2\times0.1+1\times0.4+4\times0.2+3\times0.6=3.2
\end{align}
$$

其中，$$I_u$$ 为用户 $$u$$ 的历史交互物品集合，$$r_{u,j}$$ 为用户 $$u$$ 对历史物品 $$j$$ 的兴趣分数，$$s_{j,i}$$ 为物品 $$j$$ 与候选物品 $$i$$ 的相似度。

<figure><img src="tui-jian-xi-tong-wu-pin-zhao-hui-ping-fen.png" alt="物品召回评分" width="453"><figcaption><p>物品召回加权评分</p></figcaption></figure>

<figure><img src="tui-jian-xi-tong-wu-pin-suo-yin-jian-li.png" alt="物品索引建立" width="376"><figcaption><p>物品协同过滤离线索引</p></figcaption></figure>

<figure><img src="tui-jian-xi-tong-itemcf-yong-hu-wu-pin-suo-yin.png" alt="ItemCF用户物品索引" width="449"><figcaption><p>物品协同过滤索引</p></figcaption></figure>

<figure><img src="tui-jian-xi-tong-wu-pin-xiang-si-suo-yin.png" alt="物品相似索引" width="438"><figcaption><p>物品相似索引</p></figcaption></figure>

<figure><img src="tui-jian-xi-tong-itemcf-zhao-hui-bu-zhou.png" alt="ItemCF召回步骤" width="429"><figcaption><p>物品协同过滤在线召回</p></figcaption></figure>

<figure><img src="tui-jian-xi-tong-itemcf-hou-xuan-zhao-hui.png" alt="ItemCF候选召回" width="442"><figcaption><p>物品协同过滤候选扩展</p></figcaption></figure>

## Swing（ItemCF 的改进）

### 动机：用户-物品共现证据是否存在重复
同一社群中的用户可能具有**相似偏好**，他们提供的物品关联证据容易**重复**，因此需要适当降低这类证据的权重。

<figure><img src="tui-jian-xi-tong-qun-ti-gong-xian-chong-fu.png" alt="群体共现重复" width="447"><figcaption><p>群体共现重复</p></figcaption></figure>

### 物品相似度：与群体共同偏好的数量成反比

$$
\begin{align}
s_{\mathrm{Swing}}(i,j)&=\sum_{\substack{u,v\in U_i\cap U_j\\u<v}}\frac{w_uw_v}{\alpha+|I_u\cap I_v|}
\end{align}
$$

其中，$$U_i\cap U_j$$ 为同时喜欢物品 $$i$$ 和 $$j$$ 的用户集合，$$I_u\cap I_v$$ 为用户 $$u$$ 和 $$v$$ 的共同交互物品，$$w_u,w_v$$ 为用户权重，$$\alpha$$ 为平滑项。

<figure><img src="tui-jian-xi-tong-swing-xiang-si-du.png" alt="Swing相似度" width="330"><figcaption><p>共现去重相似度</p></figcaption></figure>

<figure><img src="tui-jian-xi-tong-swing-shu-xue-gong-shi.png" alt="Swing数学公式" width="667"><figcaption><p>共现去重相似度公式</p></figcaption></figure>

## 基于用户的协同过滤（UserCF）

### 动机：用户之间的偏好关联
UserCF 假设用户之间存在基于物品偏好的<span style="color:red">关联</span>。
<figure><img src="tui-jian-xi-tong-usercf-yuan-li.png" alt="UserCF原理" width="448"><figcaption><p>用户协同过滤原理</p></figcaption></figure>

### 相似度：余弦相似度

$$
\begin{align}
s(u_1,u_2)&=\frac{|\mathcal J_1\cap\mathcal J_2|}{\sqrt{|\mathcal J_1||\mathcal J_2|}}
\end{align}
$$

其中，$$\mathcal J_1$$ 和 $$\mathcal J_2$$ 为两个用户的交互物品集合。
<figure><img src="tui-jian-xi-tong-yong-hu-yu-xian-xiang-si-du.png" alt="用户余弦相似度" width="365"><figcaption><p>用户余弦相似度</p></figcaption></figure>

#### 改进：降低热门物品的权重
热门物品容易被大量用户点击，<span style="color:red">难以充分区分不同用户的个性</span>；相较之下，冷门物品更能反映用户的特定偏好。

$$
\begin{align}
s(u_1,u_2)&=\frac{\sum_{i\in\mathcal J_1\cap\mathcal J_2}1/\log(1+|U_i|)}{\sqrt{|\mathcal J_1||\mathcal J_2|}}
\end{align}
$$

其中，$$U_i$$ 为与物品 $$i$$ 交互的用户集合；物品越热门，其权重越低。

<figure><img src="tui-jian-xi-tong-chang-wei-pian-hao-qu-fen.png" alt="长尾偏好区分" width="447"><figcaption><p>长尾偏好区分</p></figcaption></figure>
<figure><img src="tui-jian-xi-tong-re-men-wu-pin-jiang-quan.png" alt="热门物品降权" width="335"><figcaption><p>热门物品降权</p></figcaption></figure>

#### 反思：ItemCF为什么不需要调整权重
从相似度公式看，物品之间的相似度已经<span style="color:red">按交互用户数量归一化</span>，因而能够在一定程度上削弱热门物品的影响。

而在用户相似度中，用户向量的模对应<span style="color:red">交互物品数量</span>，这一归一化并不能直接调整热门物品的权重。

$$
\begin{align}
s(i,j)&=\frac{|U_i\cap U_j|}{\sqrt{|U_i||U_j|}}
\end{align}
$$

其中，$$U_i$$ 和 $$U_j$$ 分别为与物品 $$i$$ 和 $$j$$ 交互的用户集合。

<figure><img src="tui-jian-xi-tong-wu-pin-xiang-si-du-gui-yi-hua.png" alt="物品相似度归一化" width="255"><figcaption><p>物品相似度归一化</p></figcaption></figure>

### 数学原理

$$
\begin{align}
\mathbf S_{m\times n}&=\mathbf W_{\mathrm{user},m\times m}\mathbf R_{m\times n}
\end{align}
$$

其中，$$\mathbf W_{\mathrm{user}}$$ 为用户相似度矩阵，$$\mathbf R$$ 为用户—物品交互矩阵，$$\mathbf S$$ 为预测兴趣矩阵。
<figure><img src="tui-jian-xi-tong-usercf-ju-zhen-xing-shi.png" alt="UserCF矩阵形式" width="749"><figcaption><p>用户协同过滤矩阵</p></figcaption></figure>
>主要区别在于：用户相似度矩阵经过了**热门物品修正**。

### 召回流程

$$
\begin{align}
\hat r_{u,i}&=\sum_{v\in N_k(u)}s_{u,v}r_{v,i}=0.9\times0+0.7\times1+0.7\times3+0.4\times0=2.8
\end{align}
$$

其中，$$N_k(u)$$ 为用户 $$u$$ 的 Top-K 相似用户集合，$$s_{u,v}$$ 为用户相似度，$$r_{v,i}$$ 为用户 $$v$$ 对物品 $$i$$ 的兴趣分数。

<figure><img src="tui-jian-xi-tong-yong-hu-zhao-hui-ping-fen.png" alt="用户召回评分" width="432"><figcaption><p>用户召回加权评分</p></figcaption></figure>

<figure><img src="tui-jian-xi-tong-usercf-yong-hu-wu-pin-suo-yin.png" alt="UserCF用户物品索引" width="448"><figcaption><p>用户协同过滤索引</p></figcaption></figure>

<figure><img src="tui-jian-xi-tong-yong-hu-xiang-si-suo-yin.png" alt="用户相似索引" width="470"><figcaption><p>用户相似索引</p></figcaption></figure>

<figure><img src="tui-jian-xi-tong-usercf-zhao-hui-bu-zhou.png" alt="UserCF召回步骤" width="401"><figcaption><p>用户协同过滤在线召回</p></figcaption></figure>

<figure><img src="tui-jian-xi-tong-usercf-hou-xuan-zhao-hui.png" alt="UserCF候选召回" width="442"><figcaption><p>用户协同过滤候选扩展</p></figcaption></figure>

## 矩阵补全（Matrix Completion）
<figure><img src="tui-jian-xi-tong-ju-zhen-bu-quan-jie-gou.png" alt="矩阵补全结构" width="451"><figcaption><p>用户物品双嵌入</p></figcaption></figure>

### 动机：直接匹配用户向量与物品向量
与协同过滤不同，用户和物品是<span style="color:red">解耦的</span>，分别编码为特征向量，再通过向量匹配计算兴趣分数。

>在协同过滤中，用户与物品通过<span style="color:red">用户—物品共现程度</span>建立关联，再由物品或用户相似度矩阵推断用户对候选物品的兴趣。

### 数学原理
分别将用户和物品映射为向量，计算二者的相似度，再根据真实的用户—物品兴趣分数，以 **MSE 损失**进行优化。

$$
\begin{align}
\Omega&=\{(u,i,y_{u,i})\}\\
\min_{\mathbf A,\mathbf B}\quad&\sum_{(u,i,y_{u,i})\in\Omega}\left(y_{u,i}-\mathbf a_u^{\mathsf T}\mathbf b_i\right)^2
\end{align}
$$

其中，$$m$$ 和 $$n$$ 分别为用户数和物品数，$$d$$ 为潜在向量维度；$$\mathbf A\in\mathbb R^{m\times d}$$、$$\mathbf B\in\mathbb R^{n\times d}$$，$$\mathbf a_u,\mathbf b_i\in\mathbb R^d$$；$$\Omega$$ 为观测集合，$$y_{u,i}$$ 为真实兴趣分数。

<figure><img src="tui-jian-xi-tong-ju-zhen-bu-quan-shu-ju-ji.png" alt="矩阵补全数据集" width="413"><figcaption><p>矩阵补全数据集</p></figcaption></figure>

<figure><img src="tui-jian-xi-tong-ju-zhen-bu-quan-xun-lian.png" alt="矩阵补全训练" width="448"><figcaption><p>矩阵补全训练</p></figcaption></figure>

矩阵补全针对稀疏的用户—物品交互矩阵，利用已有交互学习用户与物品向量，进而推断<span style="color:red">未观测用户—物品组合</span>的匹配程度。

<figure><img src="tui-jian-xi-tong-xi-shu-ping-fen-ju-zhen.png" alt="稀疏评分矩阵" width="498"><figcaption><p>稀疏评分矩阵</p></figcaption></figure>

### 缺点
+ 表征能力有限：只编码 ID，未利用用户和物品属性。
+ 负样本的选择会直接影响训练效果。
+ 直接回归兴趣分数通常比学习分类目标更困难。
<figure><img src="tui-jian-xi-tong-ju-zhen-bu-quan-que-dian.png" alt="矩阵补全缺点" width="418"><figcaption><p>矩阵补全局限</p></figcaption></figure>


### 模型存储和线上服务
<figure><img src="tui-jian-xi-tong-qian-ru-ju-zhen-cun-chu.png" alt="嵌入矩阵存储" width="453"><figcaption><p>嵌入矩阵存储</p></figcaption></figure>

<figure><img src="tui-jian-xi-tong-ju-zhen-bu-quan-zai-xian-zhao-hui.png" alt="矩阵补全在线召回" width="428"><figcaption><p>矩阵补全召回</p></figcaption></figure>

### 查询优化
用户向量需要与海量物品向量逐一匹配，时间复杂度为 $$O(n)$$。

通常使用 KNN 或近似最近邻方法优化。其思路类似<span style="color:red">分层索引</span>：先将物品划分为若干簇，并为每个簇选取代表向量（如均值向量）。

查询时先匹配簇的代表向量，再在命中的簇内检索具体物品向量。

<figure><img src="tui-jian-xi-tong-xiang-liang-fen-qu-jian-suo.png" alt="向量分区检索" width="360"><figcaption><p>向量分区检索</p></figcaption></figure>

## 双塔模型
### 动机：利用用户与物品属性，通过神经网络融合特征
其思路与矩阵补全一致：先生成特征向量，再计算向量相似度。

<figure><img src="tui-jian-xi-tong-shuang-ta-mo-xing-jie-gou.png" alt="双塔模型结构" width="435"><figcaption><p>双塔模型结构</p></figcaption></figure>

双塔模型能更充分地建模特征。模型先通过不同的嵌入层获得 **ID 与属性**（离散或连续）的向量表示。

随后使用**神经网络**融合这些特征，学习更**统一的表征**。

<figure><img src="tui-jian-xi-tong-wu-pin-ta-jie-gou.png" alt="物品塔结构" width="511"><figcaption><p>物品塔特征融合</p></figcaption></figure>

### 双塔模型、ItemCF 与 UserCF
协同过滤只依赖用户—物品交互历史，<span style="color:red">不包含用户或物品的语义信息</span>。

双塔模型能够融合属性并学习语义表征，因此通常可以获得更准确的召回结果。

### 数学原理

$$
\begin{align}
s(u,i)&=\cos(\mathbf a_u,\mathbf b_i)=\frac{\mathbf a_u^{\mathsf T}\mathbf b_i}{\|\mathbf a_u\|_2\|\mathbf b_i\|_2}
\end{align}
$$

其中，$$\mathbf a_u,\mathbf b_i\in\mathbb R^d$$ 分别为用户向量与物品向量，$$s(u,i)$$ 为匹配分数。

<figure><img src="tui-jian-xi-tong-shuang-ta-xun-lian-fan-shi.png" alt="双塔训练范式" width="442"><figcaption><p>双塔训练范式</p></figcaption></figure>

#### Pointwise
**独立处理**每个正、负样本，通常使用 BCE 损失。

$$
\begin{align}
L_{\mathrm{BCE}}&=-\left[y\log\sigma(s)+(1-y)\log(1-\sigma(s))\right]
\end{align}
$$

其中，$$y\in\{0,1\}$$ 为交互标签，$$s$$ 为匹配分数，$$\sigma$$ 为 Sigmoid 函数。

<figure><img src="tui-jian-xi-tong-pointwise-xun-lian.png" alt="Pointwise训练" width="339"><figcaption><p>单点训练方法</p></figcaption></figure>


#### Pairwise
正负样本**成对出现**，目标是使正样本相似度显著高于负样本，常用 Logistic Loss 或 Hinge Loss。

$$
\begin{align}
L_{\mathrm{hinge}}(\mathbf a,\mathbf b^{+},\mathbf b^{-})&=\max\{0,\cos(\mathbf a,\mathbf b^{-})+m-\cos(\mathbf a,\mathbf b^{+})\}\\
L_{\mathrm{logistic}}(\mathbf a,\mathbf b^{+},\mathbf b^{-})&=\log\!\left(1+\exp\!\left(\beta\left[\cos(\mathbf a,\mathbf b^{-})-\cos(\mathbf a,\mathbf b^{+})\right]\right)\right)
\end{align}
$$

其中，$$\mathbf a\in\mathbb R^d$$ 为用户向量，$$\mathbf b^{+},\mathbf b^{-}\in\mathbb R^d$$ 分别为正、负物品向量，$$m$$ 为间隔，$$\beta$$ 为尺度参数。

<figure><img src="tui-jian-xi-tong-pairwise-sun-shi.png" alt="Pairwise损失" width="455"><figcaption><p>成对训练损失</p></figcaption></figure>

#### Listwise
训练方式类似对比学习，每个 batch 包含**一个正样本和若干个负样本**，通常使用交叉熵损失。


### 易错点：召回模型的职责
召回模型<span style="color:red">不负责精确预测用户兴趣</span>，而是从海量物品中快速筛出具有潜在相关性的候选集。

<figure><img src="tui-jian-xi-tong-zhao-hui-mo-xing-zhi-ze.png" alt="召回模型职责" width="436"><figcaption><p>召回模型边界</p></figcaption></figure>


## 正样本和负样本的选取

<figure><img src="tui-jian-xi-tong-zheng-yang-ben-ding-yi.png" alt="正样本定义" width="340"><figcaption><p>正样本定义</p></figcaption></figure>

### 正样本
曝光**且被用户选择**的用户—物品二元组通常可作为正样本，但这类样本极度稀疏。

### 负样本

<figure><img src="tui-jian-xi-tong-fu-yang-ben-lai-yuan.png" alt="负样本来源" width="496"><figcaption><p>负样本来源</p></figcaption></figure>

#### 简单负样本

绝大多数物品不会被召回。例如，在 10 亿个物品中可能有 9.99 亿个未被召回，可近似认为<span style="color:red">绝大多数物品都是负样本</span>，并直接从物品库中采样简单负样本。

>**简单负样本**：容易被召回模型区分，因此称之为简单。

<figure><img src="tui-jian-xi-tong-quan-ti-wu-pin-fu-cai-yang.png" alt="全体物品负采样" width="325"><figcaption><p>全体物品负采样</p></figcaption></figure>

热门物品**更容易被采为负样本**，因此需要校正较高采样概率带来的偏差，避免模型对热门物品过度惩罚。

$$
\begin{align}
p_i&\propto c_i^{0.75}\\
\tilde s(u,i)&=\cos(\mathbf a_u,\mathbf b_i)-\log p_i
\end{align}
$$

其中，$$c_i$$ 为物品 $$i$$ 的点击次数，$$p_i$$ 为采样概率，$$\tilde s(u,i)$$ 为校正采样偏差后的匹配分数。

<figure><img src="tui-jian-xi-tong-fei-jun-yun-fu-cai-yang.png" alt="非均匀负采样" width="360"><figcaption><p>非均匀负采样</p></figcaption></figure>

<figure><img src="tui-jian-xi-tong-cai-yang-pian-cha-xiu-zheng.png" alt="采样偏差修正" width="508"><figcaption><p>采样偏差修正</p></figcaption></figure>

#### 困难负样本
已被召回、但随后被粗排或精排淘汰的样本，通常称为**困难负样本**。

<figure><img src="tui-jian-xi-tong-kun-nan-fu-yang-ben.png" alt="困难负样本" width="324"><figcaption><p>困难负样本</p></figcaption></figure>

>之所以称为困难负样本，是因为<span style="color:red">召回模型主要区分“可能感兴趣”和“不感兴趣”</span>。被召回的物品通常已经具备一定相关性，排序阶段的淘汰更多表示**兴趣相对较弱**，这种细粒度差异对召回模型较难学习。



>曝光但未被选择的样本不宜直接作为召回模型的负样本。
>
>原因在于，这类样本往往仍处于用户可能感兴趣的范围，只是在排序竞争中落选。强行将其视为负样本，不仅学习难度高，也容易偏离召回任务的职责。

<figure><img src="tui-jian-xi-tong-bao-guang-wei-dian-ji-yang-ben.png" alt="曝光未点击样本" width="434"><figcaption><p>曝光未点击样本</p></figcaption></figure>


## 线上服务
### 线上召回
物品向量化后存入向量数据库；用户发起推荐请求时，系统**实时**生成用户向量并进行检索。

<figure><img src="tui-jian-xi-tong-xian-shang-yong-hu-bian-ma.png" alt="线上用户编码" width="484"><figcaption><p>线上用户编码</p></figcaption></figure>

<figure><img src="tui-jian-xi-tong-shuang-ta-zai-xian-zhao-hui.png" alt="双塔在线召回" width="413"><figcaption><p>双塔在线召回</p></figcaption></figure>

>需要实时生成用户向量，是因为用户的**个性偏好**会频繁变化。

一种实现方式是**冻结其他 MLP 层**，仅更新 `ID embedding` 层的参数。

>属性 embedding 表示用户之间较通用的属性，应具有良好的<span style="color:red">统计稳定性</span>，因此通常不进行高频动态更新。

<figure><img src="tui-jian-xi-tong-yong-hu-xiang-liang-shi-shi-geng-xin.png" alt="用户向量实时更新" width="422"><figcaption><p>用户向量实时更新</p></figcaption></figure>

### 全量更新
使用前一天的用户—物品交互数据，通过 Listwise 损失进行全量训练。

<figure><img src="tui-jian-xi-tong-quan-liang-geng-xin.png" alt="全量更新" width="406"><figcaption><p>模型全量更新</p></figcaption></figure>

### 增量更新
用户兴趣会持续变化，因此可实时增量更新 `ID embedding` 层参数，确保查询时获得**最新**的用户向量。

<figure><img src="tui-jian-xi-tong-zeng-liang-geng-xin.png" alt="增量更新" width="403"><figcaption><p>模型增量更新</p></figcaption></figure>


### 全量更新与增量更新
全量更新：统计分布更稳定，受时间等**短期因素影响较小**，模型行为更可靠。

增量更新：时效性更强，但更易受短期时间因素影响，模型行为**可能产生偏差**。

<figure><img src="tui-jian-xi-tong-geng-xin-zhou-qi-dui-bi.png" alt="更新周期对比" width="501"><figcaption><p>更新周期对比</p></figcaption></figure>

<figure><img src="tui-jian-xi-tong-shuang-gui-geng-xin-fang-an.png" alt="双轨更新方案" width="381"><figcaption><p>双轨更新方案</p></figcaption></figure>

## 双塔模型+自监督学习
### 动机：解决长尾物品的特征学习问题
热门物品出现频率高，其特征通常能够得到较稳定、可靠的学习。

但大多数物品属于长尾物品，交互数据稀疏，模型往往难以充分学习其特征。

### 数学原理
对同一物品应用两种**特征变换**，由双塔模型编码得到两组表征。训练时最大化同一物品两种表征的**相似度**，并最小化其与其他物品表征的相似度。

$$
\begin{align}
\max\quad&\cos(\mathbf b_i',\mathbf b_i'')\\
\min\quad&\cos(\mathbf b_i',\mathbf b_j'')\quad(i\ne j)
\end{align}
$$

其中，$$\mathbf b_i',\mathbf b_i''\in\mathbb R^d$$ 为同一物品的两种增强表征，$$\mathbf b_j''\in\mathbb R^d$$ 为其他物品的增强表征。

<figure><img src="tui-jian-xi-tong-wu-pin-zi-jian-du-shi-tu.png" alt="物品自监督视图" width="501"><figcaption><p>物品增强视图</p></figcaption></figure>

<figure><img src="tui-jian-xi-tong-zi-jian-du-xue-xi-mu-biao.png" alt="自监督学习目标" width="370"><figcaption><p>自监督学习目标</p></figcaption></figure>

#### 特征变换
随机掩码可表示为 $$U=\{\text{数码},\text{摄影}\}\rightarrow U'=\{\mathrm{default}\}$$，即用默认值替换被掩码的特征。

<figure><img src="tui-jian-xi-tong-sui-ji-yan-ma.png" alt="随机掩码" width="382"><figcaption><p>随机特征掩码</p></figcaption></figure>

特征丢弃可表示为 $$U=\{\text{美妆},\text{摄影}\}\rightarrow U'=\{\text{美妆}\}$$，即随机删除部分特征。

<figure><img src="tui-jian-xi-tong-te-zheng-diu-qi.png" alt="特征丢弃" width="377"><figcaption><p>多值特征丢弃</p></figcaption></figure>

<figure><img src="tui-jian-xi-tong-hu-bu-te-zheng.png" alt="互补特征" width="376"><figcaption><p>互补特征变换</p></figcaption></figure>

关联特征掩码依据 $$p(u,v)$$ 衡量特征 $$u$$ 与 $$v$$ 的共同出现概率，并优先联合处理高关联特征。

<figure><img src="tui-jian-xi-tong-guan-lian-te-zheng-yan-ma.png" alt="关联特征掩码" width="377"><figcaption><p>关联特征掩码</p></figcaption></figure>

#### 损失函数
损失函数采用对比学习目标：
+ 同一物品的两种表征相似度应最大，目标标签为 1。
+ 不同物品的表征相似度应最小，目标标签为 0。

>该目标可以转化为多分类问题，并使用交叉熵损失进行优化。

$$
\begin{align}
L_{\mathrm{self}}^{(i)}&=-\log\frac{\exp\!\left(\cos(\mathbf b_i',\mathbf b_i'')\right)}{\sum_{j=1}^{m}\exp\!\left(\cos(\mathbf b_i',\mathbf b_j'')\right)}
\end{align}
$$

其中，$$m$$ 为批内物品数，分子对应正样本对，分母包含批内候选物品。

<figure><img src="tui-jian-xi-tong-zi-jian-du-dui-bi-sun-shi.png" alt="自监督对比损失" width="390"><figcaption><p>自监督对比损失</p></figcaption></figure>

#### 训练原理
自监督目标与双塔模型的主任务<span style="color:red">联合训练</span>。

$$
\begin{align}
L&=\frac{1}{n}\sum_{i=1}^{n}L_{\mathrm{main}}^{(i)}+\alpha\frac{1}{m}\sum_{j=1}^{m}L_{\mathrm{self}}^{(j)}
\end{align}
$$

其中，$$n$$ 和 $$m$$ 分别为主任务与自监督任务的样本数，$$\alpha$$ 为自监督损失权重。

<figure><img src="tui-jian-xi-tong-lian-he-xun-lian-mu-biao.png" alt="联合训练目标" width="422"><figcaption><p>联合训练目标</p></figcaption></figure>

## 深度检索（Deep Retrieval）

### 动机
基于向量的方法（如 ANN 或 MIPS）存在两个主要局限：
1. 用户与物品嵌入的内积结构可能**难以捕捉**复杂的用户—物品交互；
2. ANN 或 MIPS 旨在**近似求解已学习的内积模型**，而非直接针对用户—物品交互数据优化索引。

>概括而言，内积建模的表达能力有限，也无法直接优化用户—物品之间的索引关系。

### 深度检索与双塔模型：索引建模方式
深度检索<span style="color:red">直接建模</span>用户—物品的<span style="color:red">索引关系</span>，并用路径表示物品索引。

双塔模型先学习用户和物品的向量表示，再通过最近邻搜索<span style="color:red">间接构建</span>索引。

二者学习的目标不同。

### 数学原理
深度检索模型包含以下基本要素：
+ 索引：路径与物品之间是<span style="color:red">多对多</span>关系，一条路径可以对应多个物品，一个物品也可以拥有多条路径。
+ 神经网络：用于预测用户对给定路径的**兴趣概率**。
+ 召回过程：用户 → 路径 → 物品。
+ 训练：神经网络利用正样本学习模型参数，同时为物品优化最优路径，后者属于**离散优化**问题。

<figure><img src="tui-jian-xi-tong-shen-du-jian-suo-kuang-jia.png" alt="深度检索框架" width="400"><figcaption><p>深度检索框架</p></figcaption></figure>


#### 神经网络
模型通过<span style="color:red">自回归</span>方式生成用户可能感兴趣的路径。

$$
\begin{align}
p(a,b,c\mid\mathbf x)&=p_1(a\mid\mathbf x)p_2(b\mid a;\mathbf x)p_3(c\mid a,b;\mathbf x)
\end{align}
$$

其中，$$\mathbf x$$ 为用户特征向量，$$a,b,c$$ 为路径上的节点，$$p_1,p_2,p_3$$ 为各层的条件概率。

<figure><img src="tui-jian-xi-tong-lu-jing-zi-hui-gui-yu-ce.png" alt="路径自回归预测" width="379"><figcaption><p>路径自回归预测</p></figcaption></figure>

#### 线上召回

<figure><img src="tui-jian-xi-tong-shen-du-jian-suo-zai-xian-zhao-hui.png" alt="深度检索在线召回" width="471"><figcaption><p>深度检索网络</p></figcaption></figure>

使用 Beam Search 获得**固定数量**的候选路径，以控制节点搜索的计算量。

<figure><img src="tui-jian-xi-tong-shu-sou-suo-lu-jing.png" alt="束搜索路径" width="427"><figcaption><p>束搜索候选路径</p></figcaption></figure>

将候选路径映射为物品**列表**，再经简单排序得到最终召回结果。

<figure><img src="tui-jian-xi-tong-shen-du-jian-suo-zai-xian-zhao-hui-bu-zhou.png" alt="深度检索在线召回步骤" width="403"><figcaption><p>深度检索召回流程</p></figcaption></figure>

#### 训练
训练采用最大似然估计（MLE），并且<span style="color:red">只使用正样本</span>。

对于用户交互过的正样本物品，获取其对应的 $$J$$ 条路径，并通过神经网络**最大化这些路径出现的概率**。

$$
\begin{align}
L(\mathbf x,i)&=-\log\sum_{j=1}^{J}p(a_j,b_j,c_j\mid\mathbf x)
\end{align}
$$

其中，$$i$$ 为正样本物品，$$J$$ 为该物品对应的路径数，$$(a_j,b_j,c_j)$$ 为第 $$j$$ 条路径。

<figure><img src="tui-jian-xi-tong-lu-jing-mo-xing-xun-lian.png" alt="路径模型训练" width="404"><figcaption><p>路径网络参数学习</p></figcaption></figure>


### 物品分配路径
该过程本质上属于离散优化：给定 $$p$$ 条路径和 $$m$$ 个物品，需要为每个物品分配至多 $$k$$ 条路径，其中 $$p\gg k$$。

思路：
+ 首先计算物品—路径的联合分布概率，即<span style="color:red">匹配分数</span>。
+ 选择第 $i$ 条路径，**固定**其余 $k-1$ 条路径，并尝试用剩余 $p-k$ 条路径替换它。
+ 若替换后损失更小，则更新该物品的第 $i$ 条路径。
+ 为**避免重复分配路径**，在目标函数中加入正则项。

$$
\begin{align}
p(\mathrm{path}\mid\mathrm{user})&=p(a,b,c\mid\mathbf x)\\
\operatorname{score}(i,\mathrm{path})&=\sum_{u}p(\mathrm{path}\mid u)\operatorname{click}(u,i)\\
\mathrm{path}_l&\leftarrow\arg\min_{\mathrm{path}_l}\left[L(i,\Pi)+\alpha\operatorname{reg}(\mathrm{path}_l)\right]
\end{align}
$$

其中，$$u$$ 为用户，$$i$$ 为物品，$$\Pi=\{\mathrm{path}_1,\ldots,\mathrm{path}_J\}$$ 为物品的路径集合且 $$J\le k$$；$$L(i,\Pi)$$ 为物品路径损失，$$\alpha$$ 为正则权重，$$\operatorname{reg}$$ 用于避免路径拥挤或重复。更新第 $$l$$ 条路径时，固定其余 $$J-1$$ 条路径。


<figure><img src="tui-jian-xi-tong-wu-pin-lu-jing-ping-fen.png" alt="物品路径评分" width="442"><figcaption><p>物品路径相关性评分</p></figcaption></figure>

<figure><img src="tui-jian-xi-tong-lu-jing-tan-xin-geng-xin.png" alt="路径贪心更新" width="427"><figcaption><p>路径贪心更新</p></figcaption></figure>

<figure><img src="tui-jian-xi-tong-wu-pin-lu-jing-biao-zheng.png" alt="物品路径表征" width="475"><figcaption><p>物品路径表征示例</p></figcaption></figure>


## 其他召回
以下召回策略依赖地理位置等场景信息，<span style="color:red">并不完全以用户兴趣为依据</span>。

<figure><img src="tui-jian-xi-tong-qi-ta-zhao-hui-fang-shi.png" alt="其他召回方式" width="360"><figcaption><p>场景化召回方式</p></figcaption></figure>

## 曝光过滤问题
曝光过滤通常在**召回层**执行：最终展示的物品会在曝光后写入记录，后续召回再据此过滤。

### 动机：物品曝光给用户后，短时间内不应再出现

### Bloom Filter
基本思想是使用哈希函数和位数组判断物品是否已经曝光。

>注意：存在哈希冲突，理论上可能误判。

<figure><img src="tui-jian-xi-tong-bu-long-guo-lv-yuan-li.png" alt="布隆过滤原理" width="453"><figcaption><p>布隆过滤器原理</p></figcaption></figure>

<figure><img src="tui-jian-xi-tong-bu-long-guo-lv-shi-li.png" alt="布隆过滤示例" width="507"><figcaption><p>布隆过滤误判示例</p></figcaption></figure>

### 曝光过滤的链路
需要注意，曝光通常指排序后**实际展示给用户的物品**，因此无需记录在召回或粗排阶段已经淘汰的内容。

<figure><img src="tui-jian-xi-tong-bao-guang-guo-lv-lian-lu.png" alt="曝光过滤链路" width="485"><figcaption><p>曝光过滤服务链路</p></figcaption></figure>

#### 定时退出机制
<figure><img src="tui-jian-xi-tong-bu-long-guo-lv-ju-xian.png" alt="布隆过滤局限" width="391"><figcaption><p>布隆过滤器局限</p></figcaption></figure>

# 排序
## 排序的基本原理
神经网络根据用户—物品交互数据<span style="color:red">预测点击率等指标</span>，再<span style="color:red">融合多个指标</span>得到最终排序分数，并据此生成推荐结果。

<figure><img src="tui-jian-xi-tong-yong-hu-jiao-hu-zhi-biao.png" alt="用户交互指标" width="333"><figcaption><p>用户交互率指标</p></figcaption></figure>

<figure><img src="tui-jian-xi-tong-pai-xu-fen-shu-yi-ju.png" alt="排序分数依据" width="351"><figcaption><p>排序分数生成流程</p></figcaption></figure>

<figure><img src="tui-jian-xi-tong-pai-xu-lian-xi-ti.png" alt="排序练习题" width="425"><figcaption><p>随机抽样练习题</p></figcaption></figure>

### 类别不平衡
在点击率预测任务中，历史数据的大多数样本为负样本，容易造成**类别不平衡**。

<figure><img src="tui-jian-xi-tong-lei-bie-bu-ping-heng.png" alt="类别不平衡" width="391"><figcaption><p>类别不平衡与降采样</p></figcaption></figure>

一种解决方法是对负样本进行<span style="color:red">降采样</span>，即**降低**负样本的使用比例。但这会使模型预测的点击率产生**统计偏差**，因此需要根据采样比例进行校准。

<figure><img src="tui-jian-xi-tong-fu-yang-ben-jiang-cai-yang.png" alt="负样本降采样" width="345"><figcaption><p>负采样导致预估偏高</p></figcaption></figure>

$$
\begin{align}
p_{\mathrm{true}}&=\frac{n_{+}}{n_{+}+n_{-}}\\
p_{\mathrm{pred}}&=\frac{n_{+}}{n_{+}+\alpha n_{-}}\\
p_{\mathrm{true}}&=\frac{\alpha p_{\mathrm{pred}}}{(1-p_{\mathrm{pred}})+\alpha p_{\mathrm{pred}}}
\end{align}
$$

其中，$$n_{+}$$ 和 $$n_{-}$$ 分别为正、负样本数，$$\alpha\in(0,1)$$ 为负样本保留率，$$p_{\mathrm{pred}}$$ 与 $$p_{\mathrm{true}}$$ 分别为采样后预测概率和校准后的真实概率。

<figure><img src="tui-jian-xi-tong-yu-gu-zhi-jiao-zhun-gong-shi.png" alt="预估值校准公式" width="411"><figcaption><p>点击率校准公式</p></figcaption></figure>

当负样本保留比例（**采样率** $$\alpha$$）较低时，模型对点击率（CTR）的估计会**失真**，需要经过校准才能接近真实值。

<figure><img src="tui-jian-xi-tong-dian-ji-lv-jiao-zhun-shi-li.png" alt="点击率校准示例" width="760"><figcaption><p>点击率校准示例</p></figcaption></figure>

从数学上看，负采样会使训练集与线上场景的条件概率分布产生差异。概率校准用于使<span style="color:red">训练分布下的预测概率对齐线上真实分布</span>。

$$
\begin{align}
P_{\mathrm{train}}(Y=1\mid X=\mathbf x)&\ne P_{\mathrm{online}}(Y=1\mid X=\mathbf x)
\end{align}
$$

其中，$$X$$ 为输入特征，$$Y$$ 为点击标签，$$\mathbf x$$ 为给定特征取值。

<figure><img src="tui-jian-xi-tong-xun-lian-xian-shang-fen-bu-pian-yi.png" alt="训练线上分布偏移" width="650"><figcaption><p>条件点击概率偏移</p></figcaption></figure>

直观来看，校准前的 CTR 估计通常偏高，若直接用于线上实验，会使各实验桶的 CTR 预测过于乐观。

概率校准会适当抑制模型的预测分数，使其更接近真实 CTR 分布。

<figure><img src="tui-jian-xi-tong-jiao-zhun-qian-hou-dian-ji-lv.png" alt="校准前后点击率" width="525"><figcaption><p>负采样下点击率校准</p></figcaption></figure>

>该校准公式<span style="color:red">可以从采样前后的概率关系严格推导</span>。

## MMoE 模型
MMoE 是多任务场景下的 MoE 模型。每个任务都有独立的门控网络，用于分配专家，并根据门控概率对专家输出进行**加权融合**。

<figure><img src="tui-jian-xi-tong-mmoe-jie-gou.png" alt="MMoE结构" width="497"><figcaption><p>多门控专家多任务结构</p></figcaption></figure>

### 极化现象
训练过程中，门控分布可能趋近于 0—1 分布，使少数专家被频繁选择，而其他专家逐渐失效。

<figure><img src="tui-jian-xi-tong-zhuan-jia-ji-hua-xian-xiang.png" alt="专家极化现象" width="513"><figcaption><p>门控极化与专家失效</p></figcaption></figure>

可参考 MoE 的常见改进方法：
+ Dropout：使专家随机失活；
+ 门控熵或温度正则：避免门控概率过早趋近 0—1；
+ 负载均衡损失（load-balancing loss）：鼓励不同专家获得更均衡的流量。

## 预估分数的融合
加法或点击率加权融合可写为：

$$
\begin{align}
s_{\mathrm{add}}&=p_{\mathrm{click}}+w_1p_{\mathrm{like}}+w_2p_{\mathrm{collect}}+\cdots\\
s_{\mathrm{click}}&=p_{\mathrm{click}}\left(1+w_1p_{\mathrm{like}}+w_2p_{\mathrm{collect}}+\cdots\right)
\end{align}
$$

其中，$$p_{\mathrm{click}}$$、$$p_{\mathrm{like}}$$ 和 $$p_{\mathrm{collect}}$$ 为各行为概率，$$w_1,w_2$$ 为权重。

<figure><img src="tui-jian-xi-tong-jia-fa-rong-he-fen-shu.png" alt="加法融合分数" width="410"><figcaption><p>预估分数加法融合</p></figcaption></figure>

按名次融合时，可使用：

$$
\begin{align}
s&=\frac{w_1}{r_{\mathrm{time}}^{\alpha_1}+\beta_1}+\frac{w_2}{r_{\mathrm{click}}^{\alpha_2}+\beta_2}+\frac{w_3}{r_{\mathrm{like}}^{\alpha_3}+\beta_3}+\cdots
\end{align}
$$

其中，$$r$$ 为各目标的排序名次，$$w$$ 为权重，$$\alpha$$ 控制名次衰减，$$\beta$$ 为平滑项。

<figure><img src="tui-jian-xi-tong-shi-pin-rong-he-fen-shu.png" alt="视频融合分数" width="385"><figcaption><p>短视频名次融合</p></figcaption></figure>

乘法融合适合表达漏斗阶段之间的联合影响：

$$
\begin{align}
s_{\mathrm{mul}}&=p_{\mathrm{click}}^{\alpha_1}p_{\mathrm{cart}}^{\alpha_2}p_{\mathrm{pay}}^{\alpha_3}\operatorname{price}^{\alpha_4}
\end{align}
$$

其中，各 $$p$$ 为漏斗阶段概率，$$\alpha_1,\ldots,\alpha_4$$ 为指数权重。

<figure><img src="tui-jian-xi-tong-cheng-fa-rong-he-fen-shu.png" alt="乘法融合分数" width="384"><figcaption><p>电商漏斗乘法融合</p></figcaption></figure>

## 视频播放的建模
<figure><img src="tui-jian-xi-tong-tu-wen-shi-pin-pai-xu-cha-yi.png" alt="图文视频排序差异" width="386"><figcaption><p>图文与视频排序差异</p></figcaption></figure>

### 播放时长预测
神经网络输出 logit $$z$$，并通过 `sigmoid()` 将其映射到 $$(0,1)$$；再与变换后的真实播放时长 $$t$$ 计算 BCE 损失。

>需要注意，$$t$$ 是连续值，因此该任务<span style="color:red">并非传统分类任务</span>；但在这一场景中，BCE 形式的建模效果可能优于 MSE。

$$
\begin{align}
y&=\frac{t}{1+t}\\
p&=\frac{\exp(z)}{1+\exp(z)}\\
p&=y\Longrightarrow\exp(z)=t
\end{align}
$$

其中，$$t$$ 为播放时长，$$z$$ 为网络 logit，$$p$$ 和 $$y$$ 为映射到 $$(0,1)$$ 的预测值与标签。

<figure><img src="tui-jian-xi-tong-bo-fang-shi-chang-yu-ce.png" alt="播放时长预测" width="488"><figcaption><p>播放时长预测结构</p></figcaption></figure>

#### 修正
播放时长的预测目标需要进行**标准化**，避免不同视频时长尺度差异过大（例如 60 秒与 3 600 秒）。

### 完播概率预测
#### 回归方法
标签与预测值均为完播率，可继续使用 BCE 形式的损失进行建模。

$$
\begin{align}
L_{\mathrm{BCE}}&=-\left[y\log p+(1-y)\log(1-p)\right]
\end{align}
$$

其中，$$y\in[0,1]$$ 为真实完播率，$$p\in(0,1)$$ 为预测完播率。

<figure><img src="tui-jian-xi-tong-wan-bo-lv-hui-gui.png" alt="完播率回归" width="381"><figcaption><p>完播率回归方法</p></figcaption></figure>

#### 分类方法
将播放时长这一连续变量离散化，构造多个**二分类**标签。

$$
\begin{align}
y&=\mathbb{I}\left(\frac{T_{\mathrm{play}}}{T_{\mathrm{video}}}>\tau\right)
\end{align}
$$

其中，$$T_{\mathrm{play}}$$ 为播放时长，$$T_{\mathrm{video}}$$ 为视频时长，$$\tau$$ 为完播阈值。

<figure><img src="tui-jian-xi-tong-wan-bo-lv-fen-lei.png" alt="完播率分类" width="391"><figcaption><p>完播率二分类方法</p></figcaption></figure>

#### 修正
实际使用完播率预测结果时，还需根据视频时长进行校正。

>时间越长的视频，完播率越低。

$$
\begin{align}
p_{\mathrm{finish}}^{\mathrm{adj}}&=\frac{\hat p_{\mathrm{finish}}}{f(T_{\mathrm{video}})}
\end{align}
$$

其中，$$\hat p_{\mathrm{finish}}$$ 为原始预测值，$$T_{\mathrm{video}}$$ 为视频时长，$$f$$ 为时长校正函数。

<figure><img src="tui-jian-xi-tong-shi-chang-yu-wan-bo-lv.png" alt="时长与完播率" width="409"><figcaption><p>视频时长与完播率</p></figcaption></figure>

<figure><img src="tui-jian-xi-tong-wan-bo-lv-shi-chang-xiu-zheng.png" alt="完播率时长修正" width="305"><figcaption><p>完播率时长校正</p></figcaption></figure>

## 模型的特征

<figure><img src="tui-jian-xi-tong-tui-jian-shu-ju-fu-wu.png" alt="推荐数据服务" width="469"><figcaption><p>排序数据服务架构</p></figcaption></figure>

<figure><img src="tui-jian-xi-tong-te-zheng-lei-xing-zong-jie.png" alt="特征类型总结" width="221"><figcaption><p>排序特征类型汇总</p></figcaption></figure>

### 用户画像：用户的静态特征

<figure><img src="tui-jian-xi-tong-yong-hu-hua-xiang.png" alt="用户画像" width="328"><figcaption><p>物品画像特征</p></figcaption></figure>

### 物品画像：物品的静态特征

<figure><img src="tui-jian-xi-tong-wu-pin-hua-xiang.png" alt="物品画像" width="329"><figcaption><p>物品画像特征</p></figcaption></figure>

### 场景特征
场景特征是<span style="color:red">实时</span>信息，例如用户当前的地理位置。

<figure><img src="tui-jian-xi-tong-chang-jing-te-zheng.png" alt="场景特征" width="325"><figcaption><p>场景上下文特征</p></figcaption></figure>

### 统计特征
统计特征是用户或物品的<span style="color:red">动态</span>特征，例如近 7 天点赞最多的主题。
<figure><img src="tui-jian-xi-tong-yong-hu-tong-ji-te-zheng.png" alt="用户统计特征" width="391"><figcaption><p>用户统计特征</p></figcaption></figure>

<figure><img src="tui-jian-xi-tong-wu-pin-tong-ji-te-zheng.png" alt="物品统计特征" width="395"><figcaption><p>物品统计特征</p></figcaption></figure>

## 粗排

### 粗排与精排：计算量差异

<figure><img src="tui-jian-xi-tong-cu-pai-jing-pai-dui-bi.png" alt="粗排精排对比" width="469"><figcaption><p>粗排与精排对比</p></figcaption></figure>

### 精排模型
精排采用<span style="color:red">早期融合</span>：先编码并拼接用户、物品、统计和场景特征，再将融合后的特征输入神经网络，得到最终预测指标。

<figure><img src="tui-jian-xi-tong-jing-pai-mo-xing-jie-gou.png" alt="精排模型结构" width="464"><figcaption><p>精排多任务模型</p></figcaption></figure>

#### 在线服务
特征需要先完成拼接，因此输入维度较大。

每个用户—物品对都需要**重新编码**。由于特征在网络前部就完成融合，服务器必须对 $$n$$ 个候选物品分别执行一次推理。

<figure><img src="tui-jian-xi-tong-jing-pai-zai-xian-tui-li.png" alt="精排在线推理" width="340"><figcaption><p>精排在线推理开销</p></figcaption></figure>


### 粗排：三塔模型
三塔模型的基本思路不变，但会在提取用户和物品的动态、静态特征时，**离线处理**静态特征，以减少早期融合的计算量。

其整体效率仍然**取决于**上游神经网络预测物品指标的速度。

<figure><img src="tui-jian-xi-tong-san-ta-mo-xing-jie-gou.png" alt="三塔模型结构" width="483"><figcaption><p>粗排三塔模型结构</p></figcaption></figure>

<figure><img src="tui-jian-xi-tong-cu-pai-san-ta-mo-xing.png" alt="粗排三塔模型" width="495"><figcaption><p>三塔推理与缓存</p></figcaption></figure>


# 特征交叉（Cross）

## 特征交叉的定义
特征交叉是一种<span style="color:red">特征工程</span>方法：它显式建模不同特征之间的交互，<span style="color:red">生成新的特征表示</span>，从而补充单一特征无法表达的信息。


<figure><img src="tui-jian-xi-tong-xian-xing-mo-xing.png" alt="线性模型" width="431"><figcaption><p>线性模型</p></figcaption></figure>

线性模型只能对各维特征加权求和：

$$
\begin{align}
p(\mathbf{x}) &= b+\sum_{i=1}^{d}w_i x_i
\end{align}
$$

其中，$$\mathbf{x}\in\mathbb{R}^{d}$$ 为输入向量，$$\mathbf{w}\in\mathbb{R}^{d}$$ 为权重向量，$$b\in\mathbb{R}$$ 为偏置，$$p(\mathbf{x})\in\mathbb{R}$$ 为预测值。

特征交叉进一步建模 $$x_i$$ 与 $$x_j$$ 的**相互作用**。例如，面积与层高的交互可以近似表达房屋体积，为房价预测提供更有意义的组合特征。
<figure><img src="tui-jian-xi-tong-er-jie-te-zheng-jiao-cha.png" alt="二阶特征交叉" width="376"><figcaption><p>二阶特征交叉</p></figcaption></figure>

二阶交叉模型写为：

$$
\begin{align}
p(\mathbf{x}) &= b+\sum_{i=1}^{d}w_i x_i+\sum_{i=1}^{d}\sum_{j=i+1}^{d}u_{ij}x_i x_j
\end{align}
$$

其中，$$u_{ij}\in\mathbb{R}$$ 为特征对 $$(i,j)$$ 的交叉权重。直接学习全部权重需要 $$O(d^2)$$ 个参数，可用低秩分解降低复杂度：

$$
\begin{align}
u_{ij} &\approx \mathbf{v}_i^{\mathsf T}\mathbf{v}_j,\qquad \mathbf{V}\in\mathbb{R}^{d\times k}
\end{align}
$$

其中，$$\mathbf{v}_i,\mathbf{v}_j\in\mathbb{R}^{k}$$ 是特征嵌入，且通常有 $$k\ll d$$；因此参数量由 $$O(d^2)$$ 降为 $$O(dk)$$。

<figure><img src="tui-jian-xi-tong-di-zhi-fen-jie.png" alt="低秩分解" width="434"><figcaption><p>低秩分解</p></figcaption></figure>

<figure><img src="tui-jian-xi-tong-yin-zi-fen-jie-ji.png" alt="因子分解机" width="426"><figcaption><p>因子分解机</p></figcaption></figure>

## 特征交叉的几种方式
特征交叉主要有以下形式：
+ **内积**：输出标量，用于衡量两组特征的相关性。
+ **逐元素乘法**：输出向量，保留各维之间的交互信息。
+ **双线性内积**：在两向量之间引入可学习的权重矩阵，输出加权相关性。

三种交互可以统一表示为：

$$
\begin{align}
f_{ij}^{\mathrm{inner}} &= \mathbf{x}_i^{\mathsf T}\mathbf{x}_j\in\mathbb{R}\\
\mathbf{f}_{ij}^{\mathrm{had}} &= \mathbf{x}_i\odot\mathbf{x}_j\in\mathbb{R}^{m}\\
f_{ij}^{\mathrm{bilinear}} &= \mathbf{x}_i^{\mathsf T}\mathbf{W}_{ij}\mathbf{x}_j\in\mathbb{R}
\end{align}
$$

其中，$$\mathbf{x}_i,\mathbf{x}_j\in\mathbb{R}^{m}$$，$$\mathbf{W}_{ij}\in\mathbb{R}^{m\times m}$$。内积与双线性交叉生成**标量分数**；逐元素乘法生成向量，通常需要拼接多个交叉向量作为后续网络的输入。

<figure><img src="tui-jian-xi-tong-te-zheng-jiao-cha-fang-shi.png" alt="特征交叉方式" width="497"><figcaption><p>特征交叉方式</p></figcaption></figure>

<figure><img src="tui-jian-xi-tong-shuang-xian-xing-jiao-cha.png" alt="双线性交叉" width="369"><figcaption><p>双线性交叉</p></figcaption></figure>


## 深度交叉网络（DCN）

### 交叉层
交叉层可与 MLP 并行或串联使用，其核心结构类似<span style="color:red">残差连接</span>。

#### 动机：通过残差连接让低层特征与高层特征进行交互

<figure><img src="tui-jian-xi-tong-jiao-cha-ceng-can-cha-jie-gou.png" alt="交叉层残差结构" width="510"><figcaption><p>交叉层残差结构</p></figcaption></figure>

<figure><img src="tui-jian-xi-tong-jiao-cha-ceng-ji-suan.png" alt="交叉层计算" width="449"><figcaption><p>交叉层计算</p></figcaption></figure>

### 原理
交叉层反复将原始特征与当前层特征交互，并通过残差路径保留已有表示：

$$
\begin{align}
\mathbf{x}_{l+1} &= \mathbf{x}_0\odot\left(\mathbf{W}_l\mathbf{x}_l+\mathbf{b}_l\right)+\mathbf{x}_l
\end{align}
$$

其中，$$\mathbf{x}_0,\mathbf{x}_l,\mathbf{x}_{l+1}\in\mathbb{R}^{d}$$，$$\mathbf{W}_l\in\mathbb{R}^{d\times d}$$，$$\mathbf{b}_l\in\mathbb{R}^{d}$$，$$\odot$$ 表示逐元素乘法。

<figure><img src="tui-jian-xi-tong-shen-du-jiao-cha-wang-luo.png" alt="深度交叉网络" width="493"><figcaption><p>深度交叉网络</p></figcaption></figure>

## LHUC
### LHUC 与 DCN 的区别

DCN 侧重同一组特征的多阶交叉；LHUC 则让主信号与另一组条件信号<span style="color:red">反复交互</span>。

### 语音识别的LHUC
语音信号与用户的**个性信号**进行反复的交互，旨在**不断强化**用户的个性数据，让其**叠加在**语音信号特征中。

>门控向量可写为 $$\mathbf{g}=2\operatorname{sigmoid}(\mathbf{h})\in(0,2)^d$$。该范围允许每一维被抑制或放大，而不是简单地让用户信号大于语音信号。

<figure><img src="tui-jian-xi-tong-lhuc-shuang-lu-shu-ru.png" alt="LHUC双路输入" width="488"><figcaption><p>LHUC双路输入</p></figcaption></figure>

<figure><img src="tui-jian-xi-tong-lhuc-duo-ceng-jiao-hu.png" alt="LHUC多层交互" width="497"><figcaption><p>LHUC多层交互</p></figcaption></figure>

### 推荐系统的LHUC
将用户特征叠加在物品特征上，实现物品的个性化调整。

<figure><img src="tui-jian-xi-tong-tui-jian-chang-jing-lhuc.png" alt="推荐场景LHUC" width="483"><figcaption><p>推荐场景LHUC</p></figcaption></figure>

## SENet
### 动机：多个离散特征的加权

<figure><img src="tui-jian-xi-tong-senet-li-san-te-zheng.png" alt="SENet离散特征" width="300"><figcaption><p>SENet离散特征</p></figcaption></figure>

### 原理
SENet 先为各字段学习权重，再对离散特征进行重标定，从而<span style="color:red">动态调整不同字段的重要性</span>。若输入为 $$\mathbf{X}\in\mathbb{R}^{m\times k}$$、字段权重为 $$\mathbf{s}\in\mathbb{R}^{m}$$，则输出仍为 $$\widetilde{\mathbf{X}}\in\mathbb{R}^{m\times k}$$。

<figure><img src="tui-jian-xi-tong-senet-jia-quan-jie-gou.png" alt="SENet加权结构" width="498"><figcaption><p>SENet加权结构</p></figcaption></figure>

>实现时可通过广播对不同字段加权，因此各字段的原始嵌入长度可以不同；进入统一的批量矩阵运算前，仍需完成对齐、填充或分组处理。
<figure><img src="tui-jian-xi-tong-senet-bian-chang-shu-ru.png" alt="SENet变长输入" width="491"><figcaption><p>SENet变长输入</p></figcaption></figure>


## FiBiNet

<figure><img src="tui-jian-xi-tong-fibinet-jie-gou.png" alt="FiBiNet结构" width="485"><figcaption><p>FiBiNet结构</p></figcaption></figure>

# 用户行为序列建模（Last-N）

## Last-N
Last-N 表示用户最近点击、点赞或收藏的 $$n$$ 个物品。基础方法收集这些物品的 ID 与嵌入向量，并通过均值池化得到用户行为特征：

$$
\begin{align}
\mathbf{u}_{\mathrm{LastN}} &= \frac{1}{n}\sum_{i=1}^{n}\mathbf{e}_i
\end{align}
$$

其中，$$\mathbf{e}_i\in\mathbb{R}^{d}$$ 为第 $$i$$ 个历史物品的嵌入，$$\mathbf{u}_{\mathrm{LastN}}\in\mathbb{R}^{d}$$ 为聚合后的用户特征。不同交互类型也可分别池化后再拼接。

<figure><img src="tui-jian-xi-tong-last-n-te-zheng.png" alt="Last-N特征" width="389"><figcaption><p>Last-N特征</p></figcaption></figure>

<figure><img src="tui-jian-xi-tong-duo-xing-wei-last-n.png" alt="多行为Last-N" width="438"><figcaption><p>多行为Last-N</p></figcaption></figure>

## DIN

<figure><img src="tui-jian-xi-tong-din-mo-xing.png" alt="DIN模型" width="402"><figcaption><p>DIN模型</p></figcaption></figure>

### 动机：采用注意力机制确定加权分数

### 原理
DIN 以候选物品作为查询，以最近 $$n$$ 个行为物品作为键和值，通过注意力机制进行加权聚合：

$$
\begin{align}
\mathbf{h} &= \sum_{i=1}^{n}\alpha_i\mathbf{x}_i
\end{align}
$$

其中，$$\mathbf{x}_i,\mathbf{h}\in\mathbb{R}^{d}$$，$$\alpha_i\in[0,1]$$ 且 $$\sum_{i=1}^{n}\alpha_i=1$$；权重 $$\alpha_i$$ 由候选向量 $$\mathbf{q}\in\mathbb{R}^{d}$$ 与行为向量 $$\mathbf{x}_i$$ 共同决定。

<figure><img src="tui-jian-xi-tong-din-zhu-yi-li.png" alt="DIN注意力" width="461"><figcaption><p>DIN注意力</p></figcaption></figure>

<figure><img src="tui-jian-xi-tong-jun-zhi-yu-zhu-yi-li-dui-bi.png" alt="均值与注意力对比" width="420"><figcaption><p>均值与注意力对比</p></figcaption></figure>

缺点是该表示依赖候选物品，不能直接作为与候选无关的**用户塔**向量。

>若要用于双塔召回，需要改造用户塔，使其在候选无关的约束下生成固定用户向量。

## SIM

### 动机：缓解注意力机制中对于序列长度的限制
SIM 先从长行为序列中筛选 **Top-K 物品**，再进行注意力聚合，从而降低计算量并<span style="color:red">支持更长的时间跨度</span>。

<figure><img src="tui-jian-xi-tong-sim-mo-xing.png" alt="SIM模型" width="394"><figcaption><p>SIM模型</p></figcaption></figure>

### 原理
#### 查询：Hard or Soft
硬查找（Hard Search）按类目、品牌等离散属性筛选；软查找（Soft Search）则根据向量相似度执行近邻检索。

<figure><img src="tui-jian-xi-tong-sim-jian-suo.png" alt="SIM检索" width="417"><figcaption><p>SIM检索</p></figcaption></figure>


#### 注意力机制建模
候选物品向量与检索得到的 Top-K 行为物品交互，并通过注意力层得到聚合表示。

<figure><img src="tui-jian-xi-tong-sim-zhu-yi-li.png" alt="SIM注意力" width="409"><figcaption><p>SIM注意力</p></figcaption></figure>

#### 时间维度建模
DIN 的序列长度受限，通常只能覆盖较近期的行为。

SIM 支持更长的序列，但检索出的物品在时间上并不连续，因此需要引入交互时间间隔 $$\delta_i$$。将其离散化并编码为 $$\mathbf{d}_i\in\mathbb{R}^{d_t}$$ 后，与物品向量拼接，再由注意力层共同建模。

>距今**越久**的物品，对于用户行为建模的贡献**越少**。

<figure><img src="tui-jian-xi-tong-sim-shi-jian-dong-ji.png" alt="SIM时间动机" width="408"><figcaption><p>SIM时间动机</p></figcaption></figure>

<figure><img src="tui-jian-xi-tong-shi-jian-jian-ge-bian-ma.png" alt="时间间隔编码" width="405"><figcaption><p>时间间隔编码</p></figcaption></figure>

<figure><img src="tui-jian-xi-tong-shi-jian-gan-zhi-zhu-yi-li.png" alt="时间感知注意力" width="434"><figcaption><p>时间感知注意力</p></figcaption></figure>

# 重排的多样性

## 多样性

### 相似度
依据：物品的固定属性，例如类目**标签**或者**向量**表征。

相似度既可以依据类目标签定义为**离散值**，也可以根据向量表征计算内积或余弦相似度。对于标签相似度，同类可记为 $$1$$、异类记为 $$0$$；向量相似度可写为：

$$
\begin{align}
\operatorname{sim}(\mathbf{a},\mathbf{b}) &= \frac{\mathbf{a}^{\mathsf T}\mathbf{b}}{\lVert\mathbf{a}\rVert_2\lVert\mathbf{b}\rVert_2}
\end{align}
$$

其中，$$\mathbf{a},\mathbf{b}\in\mathbb{R}^{d}$$ 为物品向量，$$\operatorname{sim}(\mathbf{a},\mathbf{b})\in[-1,1]$$ 为余弦相似度。

<figure><img src="tui-jian-xi-tong-biao-qian-xiang-si-du.png" alt="标签相似度" width="416"><figcaption><p>标签相似度</p></figcaption></figure>

<figure><img src="tui-jian-xi-tong-shuang-ta-xiang-liang-xiang-si-du.png" alt="双塔向量相似度" width="447"><figcaption><p>双塔向量相似度</p></figcaption></figure>

<figure><img src="tui-jian-xi-tong-duo-mo-tai-wu-pin-biao-zheng.png" alt="多模态物品表征" width="380"><figcaption><p>多模态物品表征</p></figcaption></figure>

### 多样性处理的时机
多样性可在粗排后处理和精排后的重排阶段介入，避免候选集合中留下过多同质内容。

>为确保**多样性的内容足够多**，因此对粗排也要进行多样性处理。

<figure><img src="tui-jian-xi-tong-duo-yang-xing-chu-li-lian-lu.png" alt="多样性处理链路" width="510"><figcaption><p>多样性处理链路</p></figcaption></figure>

## MMR 算法

### 动机：兼顾奖励分数与多样性

### 原理
MMR 引入平衡因子 $$\theta$$，同时考虑候选物品的奖励分数和它与已选集合之间的最大相似度：

$$
\begin{align}
i^{*} &= \arg\max_{i\in\mathcal{R}}\left[\theta r_i-(1-\theta)\max_{j\in\mathcal{S}}\operatorname{sim}(i,j)\right]
\end{align}
$$

其中，$$\mathcal{R}$$ 为未选候选集合，$$\mathcal{S}$$ 为已选集合，$$r_i$$ 为奖励分数，$$\theta\in[0,1]$$ 控制相关性与冗余惩罚的权衡。

<figure><img src="tui-jian-xi-tong-mmr-ping-fen.png" alt="MMR评分" width="445"><figcaption><p>MMR评分</p></figcaption></figure>

### 实现1：贪心算法

<figure><img src="tui-jian-xi-tong-mmr-tan-xin-liu-cheng.png" alt="MMR贪心流程" width="428"><figcaption><p>MMR贪心流程</p></figcaption></figure>

### 实现2：贪心+滑动窗口算法

为减少较早结果对当前选择的影响，可将已选集合替换为最近的滑动窗口 $$\mathcal{W}\subseteq\mathcal{S}$$：

$$
\begin{align}
i^{*} &= \arg\max_{i\in\mathcal{R}}\left[\theta r_i-(1-\theta)\max_{j\in\mathcal{W}}\operatorname{sim}(i,j)\right]
\end{align}
$$

其中，$$\mathcal{W}$$ 仅保留最近若干个已选物品。

<figure><img src="tui-jian-xi-tong-mmr-hua-dong-chuang-kou.png" alt="MMR滑动窗口" width="435"><figcaption><p>MMR滑动窗口</p></figcaption></figure>

<figure><img src="tui-jian-xi-tong-hua-chuang-duo-yang-xing-ji-suan.png" alt="滑窗多样性计算" width="514"><figcaption><p>滑窗多样性计算</p></figcaption></figure>



## DPP 算法
### 超平行体：衡量集合的整体多样性
对于 $$k$$ 个 $$d$$ 维向量，当 $$k\le d$$ 且向量尽量线性无关时，它们张成的超平行体体积可以衡量集合的<span style="color:red">整体多样性</span>。任一点可写为：

$$
\begin{align}
\mathbf{x} &= \sum_{i=1}^{k}\alpha_i\mathbf{v}_i,\qquad \alpha_i\in[0,1]
\end{align}
$$

其中，$$\mathbf{x},\mathbf{v}_i\in\mathbb{R}^{d}$$，$$\alpha_i$$ 为组合系数。

<figure><img src="tui-jian-xi-tong-er-wei-ping-xing-si-bian-xing.png" alt="二维平行四边形" width="516"><figcaption><p>二维平行四边形</p></figcaption></figure>

<figure><img src="tui-jian-xi-tong-san-wei-ping-xing-liu-mian-ti.png" alt="三维平行六面体" width="508"><figcaption><p>三维平行六面体</p></figcaption></figure>

令 $$\mathbf{V}=[\mathbf{v}_1,\ldots,\mathbf{v}_k]\in\mathbb{R}^{d\times k}$$，则广义体积满足：

$$
\begin{align}
\det\left(\mathbf{V}^{\mathsf T}\mathbf{V}\right) &= \operatorname{vol}\!\left(\mathcal{P}(\mathbf{v}_1,\ldots,\mathbf{v}_k)\right)^2
\end{align}
$$

其中，$$\mathcal{P}(\mathbf{v}_1,\ldots,\mathbf{v}_k)$$ 表示这些向量张成的超平行体；当 $$d=k$$ 时，其体积也等于 $$\left|\det(\mathbf{V})\right|$$。

<figure><img src="tui-jian-xi-tong-ji-he-ti-ji-du-liang.png" alt="集合体积度量" width="498"><figcaption><p>集合体积度量</p></figcaption></figure>

### 原理
DPP 选择使 Gram 行列式最大的子集，实际可采用与 MMR 类似的贪心迭代：

$$
\begin{align}
\mathcal{S}^{*} &= \arg\max_{\mathcal{S}:|\mathcal{S}|=k}\log\det\left(\mathbf{V}_{\mathcal{S}}^{\mathsf T}\mathbf{V}_{\mathcal{S}}\right)
\end{align}
$$

其中，$$\mathbf{V}_{\mathcal{S}}\in\mathbb{R}^{d\times k}$$ 为所选物品向量组成的矩阵。若同时考虑奖励，可在目标中加入 $$\theta\sum_{j\in\mathcal{S}}r_j$$。

<figure><img src="tui-jian-xi-tong-dpp-tan-xin-mu-biao.png" alt="DPP贪心目标" width="449"><figcaption><p>DPP贪心目标</p></figcaption></figure>

#### 实现 1：贪心与 Hulu 加速
Hulu 通过 Cholesky 分解高效更新行列式。令 $$\mathbf{A}_{\mathcal{S}}=\mathbf{V}_{\mathcal{S}}^{\mathsf T}\mathbf{V}_{\mathcal{S}}\in\mathbb{R}^{k\times k}$$，则：

$$
\begin{align}
\mathbf{A}_{\mathcal{S}} &= \mathbf{L}\mathbf{L}^{\mathsf T}\\
\det(\mathbf{A}_{\mathcal{S}}) &= \det(\mathbf{L})^2=\prod_{l=1}^{k}L_{ll}^{2}
\end{align}
$$

其中，$$\mathbf{L}\in\mathbb{R}^{k\times k}$$ 为下三角矩阵。该增量计算将相关复杂度由 $$O(n^2d+nk^4)$$ 降至 $$O(n^2d+nk^2)$$。

<figure><img src="tui-jian-xi-tong-dpp-fu-za-du.png" alt="DPP复杂度" width="417"><figcaption><p>DPP复杂度</p></figcaption></figure>

<figure><img src="tui-jian-xi-tong-hulu-kuai-su-ji-suan.png" alt="Hulu快速计算" width="420"><figcaption><p>Hulu快速计算</p></figcaption></figure>

<figure><img src="tui-jian-xi-tong-cholesky-fen-jie.png" alt="Cholesky分解" width="412"><figcaption><p>Cholesky分解</p></figcaption></figure>

#### 实现 2：贪心、Hulu 与滑动窗口

滑动窗口版本仅对最近集合 $$\mathcal{W}$$ 计算体积增益，使历史结果的影响随窗口移动而消失。

<figure><img src="tui-jian-xi-tong-dpp-hua-dong-chuang-kou.png" alt="DPP滑动窗口" width="508"><figcaption><p>DPP滑动窗口</p></figcaption></figure>


## 重排规则：业务定义的多样性
业务规则可以限制连续同类内容的数量，或约束图文、视频与推广内容的占比。

>重排规则通常是<span style="color:red">优先级最高的多样性约束</span>。

<figure><img src="tui-jian-xi-tong-lian-xu-nei-rong-xian-zhi.png" alt="连续内容限制" width="414"><figcaption><p>连续内容限制</p></figcaption></figure>

<figure><img src="tui-jian-xi-tong-dan-yi-nei-rong-xian-zhi.png" alt="单一内容限制" width="437"><figcaption><p>单一内容限制</p></figcaption></figure>


在筛选候选集合的物品时，优先考虑重排规则，然后再考虑定义的多样性。

<figure><img src="tui-jian-xi-tong-gui-ze-yue-shu-mmr.png" alt="规则约束MMR" width="458"><figcaption><p>规则约束MMR</p></figcaption></figure>




# 冷启动

## 冷启动的定义
新物品刚发布时，**用户—物品交互数据不足**，模型难以准确估计其质量与受众，这一阶段称为冷启动。

## 评估指标
<figure><img src="tui-jian-xi-tong-leng-qi-dong-zhi-biao.png" alt="冷启动指标" width="409"><figcaption><p>冷启动指标</p></figcaption></figure>

### 从用户与物品两侧评估
用户侧既要激励创作者持续发布，也要尽量减少<span style="color:red">被推荐用户</span>消费指标的下降；物品侧则要从新内容中识别高质量物品，为后续推荐积累可靠反馈。

### 作者侧指标
发布渗透率统计当天至少发布一次的用户占日活用户的比例，同一用户发布多篇内容也<span style="color:red">只计一次</span>：

$$
\begin{align}
r_{\mathrm{publish}} &= \frac{N_{\mathrm{publisher}}}{N_{\mathrm{DAU}}}
\end{align}
$$

其中，$$N_{\mathrm{publisher}}$$ 为当日发布人数，$$N_{\mathrm{DAU}}$$ 为日活用户数。

按图中口径，人均发布量以日活用户为分母，发布多篇内容会<span style="color:red">重复累计</span>：

$$
\begin{align}
q_{\mathrm{publish}} &= \frac{N_{\mathrm{post}}}{N_{\mathrm{DAU}}}
\end{align}
$$

其中，$$N_{\mathrm{post}}$$ 为当日发布内容数。若业务希望统计“发布用户人均”，分母应改为 $$N_{\mathrm{publisher}}$$。

<figure><img src="tui-jian-xi-tong-fa-bu-shen-tou-lv.png" alt="发布渗透率" width="404"><figcaption><p>发布渗透率</p></figcaption></figure>

<figure><img src="tui-jian-xi-tong-ren-jun-fa-bu-liang.png" alt="人均发布量" width="383"><figcaption><p>人均发布量</p></figcaption></figure>

### 用户侧指标

<figure><img src="tui-jian-xi-tong-xin-bi-ji-xiao-fei-zhi-biao.png" alt="新笔记消费指标" width="385"><figcaption><p>新笔记消费指标</p></figcaption></figure>

冷启动应**尽可能减少**对DAU等北极星指标的影响。

<figure><img src="tui-jian-xi-tong-da-pan-xiao-fei-zhi-biao.png" alt="大盘消费指标" width="410"><figcaption><p>大盘消费指标</p></figcaption></figure>

### 物品侧指标
**挖掘高质量物品**，寻找点击次数高的笔记。

<figure><img src="tui-jian-xi-tong-gao-re-bi-ji-zhan-bi.png" alt="高热笔记占比" width="380"><figcaption><p>高热笔记占比</p></figcaption></figure>

冷启动可从召回、排序和流量调控三个方面优化。

## 优化方法：召回通道
<figure><img src="tui-jian-xi-tong-leng-qi-dong-zhao-hui-tong-dao.png" alt="冷启动召回通道" width="300"><figcaption><p>冷启动召回通道</p></figcaption></figure>

### ItemCF（不适合）

ItemCF**依赖用户-历史交互数据**，因此在新物品交互数据匮乏的情况下，不适合使用协同过滤。

### 双塔模型：优化物品 ID 嵌入
冷启动物品的 ID 嵌入可以使用训练得到的默认向量，而不是随机向量或全零向量；也可以用内容最相似的若干物品嵌入的均值进行初始化。

<figure><img src="tui-jian-xi-tong-shuang-ta-leng-qi-dong.png" alt="双塔冷启动" width="446"><figcaption><p>双塔冷启动</p></figcaption></figure>

<figure><img src="tui-jian-xi-tong-leng-qi-dong-id-qian-ru.png" alt="冷启动ID嵌入" width="395"><figcaption><p>冷启动ID嵌入</p></figcaption></figure>

### 新增类目召回

按照类目建立新内容索引，并按发布时间倒序召回。

<figure><img src="tui-jian-xi-tong-lei-mu-zhao-hui.png" alt="类目召回" width="462"><figcaption><p>类目召回</p></figcaption></figure>

### 新增关键词召回

按照关键词建立新内容索引，并按发布时间倒序召回。

#### 缺点
针对新发布的物品，个性化差。

>部分物品**存在一定时间，**但是交互数据比较少，关键词/类目召回很难优化这类物品的冷启动现象。

### 新增聚类召回：根据簇召回

#### 动机：召回最近的相似物品
<figure><img src="tui-jian-xi-tong-ju-lei-zhao-hui-si-lu.png" alt="聚类召回思路" width="374"><figcaption><p>聚类召回思路</p></figcaption></figure>

#### 原理
首先将物品编码为特征向量，再对这些向量进行**聚类**，得到 $$k$$ 个聚类中心。

在线阶段根据用户最近的 Last-N 个物品确定对应簇，再<span style="color:red">从聚类中心反向索引候选物品</span>，每个簇召回 $$m$$ 个物品，完成冷启动召回。

>按照时间顺序排序。

<figure><img src="tui-jian-xi-tong-ju-lei-zai-xian-zhao-hui.png" alt="聚类在线召回" width="406"><figcaption><p>聚类在线召回</p></figcaption></figure>

<figure><img src="tui-jian-xi-tong-ju-lei-zhao-hui-zong-jie.png" alt="聚类召回总结" width="422"><figcaption><p>聚类召回总结</p></figcaption></figure>

#### 如何训练向量表征
##### 特征提取
使用 BERT 与 CNN 分别提取文本和图像特征，再将两类向量拼接并通过全连接层得到统一表征。

<figure><img src="tui-jian-xi-tong-duo-mo-tai-te-zheng-ti-qu.png" alt="多模态特征提取" width="467"><figcaption><p>多模态特征提取</p></figcaption></figure>

##### 训练：对比损失
<figure><img src="tui-jian-xi-tong-wu-pin-yu-xian-xiang-si-du-2.png" alt="物品余弦相似度" width="449"><figcaption><p>物品余弦相似度</p></figcaption></figure>

物品向量的余弦相似度为：

$$
\begin{align}
\operatorname{sim}(\mathbf{a},\mathbf{b}) &= \frac{\mathbf{a}^{\mathsf T}\mathbf{b}}{\lVert\mathbf{a}\rVert_2\lVert\mathbf{b}\rVert_2}
\end{align}
$$

其中，$$\mathbf{a},\mathbf{b}\in\mathbb{R}^{d}$$ 为两个物品的多模态表征。

<figure><img src="tui-jian-xi-tong-dui-bi-sun-shi.png" alt="对比损失" width="441"><figcaption><p>对比损失</p></figcaption></figure>

常用的三元组铰链损失与逻辑损失分别为：

$$
\begin{align}
L_{\mathrm{hinge}} &= \max\left\{0,\operatorname{sim}(\mathbf{a},\mathbf{b}^{-})+m-\operatorname{sim}(\mathbf{a},\mathbf{b}^{+})\right\}\\
L_{\mathrm{logistic}} &= \log\left(1+\exp\left(\operatorname{sim}(\mathbf{a},\mathbf{b}^{-})-\operatorname{sim}(\mathbf{a},\mathbf{b}^{+})\right)\right)
\end{align}
$$

其中，$$\mathbf{a},\mathbf{b}^{+},\mathbf{b}^{-}\in\mathbb{R}^{d}$$ 分别为锚点、正样本与负样本向量，$$m>0$$ 为间隔超参数。

##### 构造正负样本
从热门物品中构造正样本，确保物品之间的**相似度较高**。

相似度通过类目匹配或者用户-物品点击数据查找得到。

<figure><img src="tui-jian-xi-tong-zheng-yang-ben-gou-zao.png" alt="正样本构造" width="407"><figcaption><p>正样本构造</p></figcaption></figure>

大部分都是负样本，因此可以从全体笔记中随机挑选。
<figure><img src="tui-jian-xi-tong-fu-yang-ben-gou-zao.png" alt="负样本构造" width="317"><figcaption><p>负样本构造</p></figcaption></figure>


### 新增 Look-Alike 召回：U2U
新笔记与有限个用户进行交互，然后根据用户的向量与候选用户进行相似度匹配。

通常将与新物品交互过的多个用户向量取平均，作为该物品的<span style="color:red">代理特征向量</span>；它本质上仍位于用户向量空间中。

<figure><img src="tui-jian-xi-tong-yong-hu-xiang-liang-ju-he.png" alt="用户向量聚合" width="760"><figcaption><p>用户向量聚合</p></figcaption></figure>

<figure><img src="tui-jian-xi-tong-xin-wu-pin-te-zheng-xiang-liang.png" alt="新物品特征向量" width="760"><figcaption><p>新物品特征向量</p></figcaption></figure>

<figure><img src="tui-jian-xi-tong-yong-hu-jin-lin-jian-suo.png" alt="用户近邻检索" width="760"><figcaption><p>用户近邻检索</p></figcaption></figure>


## 流量调控
流量调控为新物品提供有限的探索曝光，以便更快收集反馈，但要避免过度干预造成分布偏差。

<figure><img src="tui-jian-xi-tong-leng-qi-dong-liu-liang-ce-lue.png" alt="冷启动流量策略" width="760"><figcaption><p>冷启动流量策略</p></figcaption></figure>

### 强制插入
在推荐结果中插入少量新物品，以帮助其完成冷启动。

### 提权（Boost）
在排序阶段为新物品的得分乘以大于 $$1$$ 的系数，使其获得更多曝光机会。

>理论上也适用于召回。

<figure><img src="tui-jian-xi-tong-tui-jian-lian-lu-ti-quan.png" alt="推荐链路提权" width="760"><figcaption><p>推荐链路提权</p></figcaption></figure>

<figure><img src="tui-jian-xi-tong-xin-wu-pin-ti-quan.png" alt="新物品提权" width="746"><figcaption><p>新物品提权</p></figcaption></figure>

### 保量
根据新内容的发布时间（如 $$0\text{--}24$$ 小时）与累计曝光量，施加不同程度的提权系数。

<figure><img src="tui-jian-xi-tong-fen-shi-duan-bao-liang.png" alt="分时段保量" width="760"><figcaption><p>分时段保量</p></figcaption></figure>

<figure><img src="tui-jian-xi-tong-bao-liang-nan-dian.png" alt="保量难点" width="760"><figcaption><p>保量难点</p></figcaption></figure>

过度提权可能<span style="color:red">反而不利于新内容</span>：内容被推荐给不匹配的用户后，消费指标会被低估，并影响冷启动结束后的自然分发。

>这并非必然结果；优质内容增加曝光后，<span style="color:red">消费指标不一定下降</span>。因此应结合内容质量与实时反馈实施差异化保量。

<figure><img src="tui-jian-xi-tong-ti-quan-fu-zuo-yong.png" alt="提权副作用" width="760"><figcaption><p>提权副作用</p></figcaption></figure>

#### 差异化保量

<figure><img src="tui-jian-xi-tong-cha-yi-hua-bao-liang.png" alt="差异化保量" width="760"><figcaption><p>差异化保量</p></figcaption></figure>


# 指标优化

## 提高召回表现
召回优化可分为两类：在**不改变总配额**的前提下增加少量补充通道，或升级承担主要配额的召回模型与网络结构。

<figure><img src="tui-jian-xi-tong-zhao-hui-mo-xing-yu-tong-dao.png" alt="召回模型与通道" width="760"><figcaption><p>召回模型与通道</p></figcaption></figure>

### 优化召回模型：双塔模型
可从正负样本构造、训练目标、采样偏差校准和网络结构等方面改进双塔模型，提高向量表征质量。

<figure><img src="tui-jian-xi-tong-shuang-ta-yang-ben-you-hua.png" alt="双塔样本优化" width="760"><figcaption><p>双塔样本优化</p></figcaption></figure>

<figure><img src="tui-jian-xi-tong-shuang-ta-xun-lian-you-hua.png" alt="双塔训练优化" width="760"><figcaption><p>双塔训练优化</p></figcaption></figure>

编码网络可引入 DCN 等特征交叉结构，增强用户与物品特征的组合表达能力。

<figure><img src="tui-jian-xi-tong-shuang-ta-jie-gou-you-hua.png" alt="双塔结构优化" width="760"><figcaption><p>双塔结构优化</p></figcaption></figure>

### 优化召回模型：I2I

<figure><img src="tui-jian-xi-tong-i2i-zhao-hui.png" alt="I2I召回" width="760"><figcaption><p>I2I召回</p></figcaption></figure>


### 优化召回模型：U2U

<figure><img src="tui-jian-xi-tong-u2u-zhao-hui.png" alt="U2U召回" width="760"><figcaption><p>U2U召回</p></figcaption></figure>

### 采用其他模型：例如Deep Retrieval

<figure><img src="tui-jian-xi-tong-fu-za-zhao-hui-mo-xing.png" alt="复杂召回模型" width="760"><figcaption><p>复杂召回模型</p></figcaption></figure>


## 提高排序表现

### 优化基座
基座指的是编码特征的神经网络。优化基座一般要么增大参数量，要么采用DCN等特征工程的做法。

>Bilinear 指双线性交互，不等同于逐元素乘法。多个特征对分别完成双线性交互后，可将结果拼接并融合。


### 优化预估目标
<figure><img src="tui-jian-xi-tong-duo-ren-wu-yu-gu-jie-gou.png" alt="多任务预估结构" width="760"><figcaption><p>多任务预估结构</p></figcaption></figure>

#### 新增新的预估指标：例如转发率
<figure><img src="tui-jian-xi-tong-duo-mu-biao-jing-pai.png" alt="多目标精排" width="760"><figcaption><p>多目标精排</p></figcaption></figure>

<figure><img src="tui-jian-xi-tong-jing-pai-duo-mu-biao-fang-an.png" alt="精排多目标方案" width="760"><figcaption><p>精排多目标方案</p></figcaption></figure>

### 粗排和精排一致性建模
精排模型通常参数量更大、预测更准确，可作为**教师模型**，让粗排模型学习其软标签。一个简单的混合目标为：

$$
\begin{align}
\widetilde{y} &= \lambda y+(1-\lambda)p_{\mathrm{T}}
\end{align}
$$

其中，$$y\in\{0,1\}$$ 为真实标签，$$p_{\mathrm{T}}\in[0,1]$$ 为教师模型预测，$$\lambda\in[0,1]$$ 为混合权重，$$\widetilde{y}$$ 为粗排模型的训练目标。

>精排模型受计算成本限制，难以直接用于粗排；蒸馏可以让粗排模型<span style="color:red">在有限参数量下逼近精排效果</span>。

<figure><img src="tui-jian-xi-tong-cu-jing-pai-zheng-liu.png" alt="粗精排蒸馏" width="760"><figcaption><p>粗精排蒸馏</p></figcaption></figure>

### 用户行为序列建模
更长的用户<span style="color:red">行为序列通常包含更完整的兴趣信息</span>，但计算成本也更高。实践中可用注意力机制动态加权，并通过聚类或近邻检索筛出较短的相关子序列。

<figure><img src="tui-jian-xi-tong-xing-wei-xu-lie-fang-an.png" alt="行为序列方案" width="760"><figcaption><p>行为序列方案</p></figcaption></figure>

<figure><img src="tui-jian-xi-tong-xu-lie-jian-mo-you-hua.png" alt="序列建模优化" width="760"><figcaption><p>序列建模优化</p></figcaption></figure>

### 在线学习
#### 长期资源占据
在线更新会<span style="color:red">持续占用 GPU 资源</span>。当 Holdout、全量基线和多组实验同时运行时，每个模型都需要独立更新，资源开销会显著增加。

<figure><img src="tui-jian-xi-tong-zai-xian-xue-xi-zi-yuan-kai-xiao.png" alt="在线学习资源开销" width="760"><figcaption><p>在线学习资源开销</p></figcaption></figure>

<figure><img src="tui-jian-xi-tong-zai-xian-shi-yan-zi-yuan-fen-pei.png" alt="在线实验资源分配" width="760"><figcaption><p>在线实验资源分配</p></figcaption></figure>

<figure><img src="tui-jian-xi-tong-duo-mo-xing-geng-xin-cheng-ben.png" alt="多模型更新成本" width="760"><figcaption><p>多模型更新成本</p></figcaption></figure>

#### 老汤模型
“老汤模型”是指经过长期全量更新的旧模型。新结构即使更合理，也可能因训练时间短而暂时落后，尤其是参数占比较大的嵌入层尚未充分学习，这会<span style="color:red">干扰新旧结构的公平比较</span>。

<figure><img src="tui-jian-xi-tong-lao-tang-mo-xing-xian-xiang.png" alt="老汤模型现象" width="760"><figcaption><p>老汤模型现象</p></figcaption></figure>

##### 验证新模型结构是否优于老模型
可让新旧模型共享同一份嵌入层参数，并分别随机初始化 MLP 层，在相同数据和训练时长下比较，以尽量消除历史全量训练的影响。

<figure><img src="tui-jian-xi-tong-mo-xing-gong-ping-bi-jiao.png" alt="模型公平比较" width="760"><figcaption><p>模型公平比较</p></figcaption></figure>

##### 如果新模型更优，如何快速追上老模型
老模型作为教师，新模型直接蒸馏老模型的结果，走捷径追赶。

追上之后新模型就无需蒸馏老模型，**行为逐渐特异化**。

<figure><img src="tui-jian-xi-tong-xin-mo-xing-zhui-gan.png" alt="新模型追赶" width="760"><figcaption><p>新模型追赶</p></figcaption></figure>

## 多样性
### 召回多样性

#### 为用户向量加入随机噪声
这个很好理解，用户向量有噪声，每次召回的结果会**变得随机化**。

<figure><img src="tui-jian-xi-tong-yong-hu-xiang-liang-jia-zao.png" alt="用户向量加噪" width="760"><figcaption><p>用户向量加噪</p></figcaption></figure>

#### 抽样用户行为序列
抽样用户最近的兴趣，并且抽样之前交互过的物品，后面为**合成用户行为向量提供随机性**。

<figure><img src="tui-jian-xi-tong-xing-wei-xu-lie-chou-yang.png" alt="行为序列抽样" width="760"><figcaption><p>行为序列抽样</p></figcaption></figure>

U2I2I 可从行为序列中抽取<span style="color:red">类目较均衡</span>的种子物品，再基于这些种子检索新的候选物品。

<figure><img src="tui-jian-xi-tong-u2i2i-xu-lie-chou-yang.png" alt="U2I2I序列抽样" width="760"><figcaption><p>U2I2I序列抽样</p></figcaption></figure>

### 粗排多样性
层次化筛选，先固定**小数量不考虑多样性**，然后再**大数量考虑多样性结果**。

<figure><img src="tui-jian-xi-tong-cu-pai-duo-yang-xing.png" alt="粗排多样性" width="760"><figcaption><p>粗排多样性</p></figcaption></figure>

### 精排多样性
MMR，DDP算法和基于**人为规则**来进行排序。

<figure><img src="tui-jian-xi-tong-jing-pai-duo-yang-xing.png" alt="精排多样性" width="760"><figcaption><p>精排多样性</p></figcaption></figure>

### 探索流量
引入极少量探索性内容，**在排序后暴力插入**。

<figure><img src="tui-jian-xi-tong-tan-suo-liu-liang.png" alt="探索流量" width="760"><figcaption><p>探索流量</p></figcaption></figure>

## 特殊人群建模

### 特殊人群
例如，低活新用户和特定性别群体。

<figure><img src="tui-jian-xi-tong-te-shu-ren-qun-dong-ji.png" alt="特殊人群动机" width="760"><figcaption><p>特殊人群动机</p></figcaption></figure>

### 召回
可根据特殊人群的兴趣建立**专属内容池**，再使用单独训练的双塔模型召回。由于数据分布和优化目标不同，该模型通常<span style="color:red">不与普通用户的双塔模型共用</span>。

<figure><img src="tui-jian-xi-tong-te-shu-nei-rong-chi-gou-jian.png" alt="特殊内容池构建" width="760"><figcaption><p>特殊内容池构建</p></figcaption></figure>

<figure><img src="tui-jian-xi-tong-nei-rong-chi-jiao-hu-shai-xuan.png" alt="内容池交互筛选" width="760"><figcaption><p>内容池交互筛选</p></figcaption></figure>

#### 训练代价
需要训练一个特异的双塔模型，用于编码**特殊人群和特定物品**之间的映射关系。

<figure><img src="tui-jian-xi-tong-te-shu-nei-rong-chi-zhao-hui.png" alt="特殊内容池召回" width="760"><figcaption><p>特殊内容池召回</p></figcaption></figure>

#### 部署代价
使用最近邻查找，由于内容池比较小，因此**代价很低**。

<figure><img src="tui-jian-xi-tong-zhao-hui-bu-shu-dai-jia.png" alt="召回部署代价" width="760"><figcaption><p>召回部署代价</p></figcaption></figure>

### 排序

#### 差异化的排序预估分数
主要是根据业务，理解特殊人群的特点。

>例如，低活用户的主要目标是提升留存，可适当降低多样性权重，并提高 CTR 等兴趣指标的权重。

<figure><img src="tui-jian-xi-tong-cha-yi-hua-rong-he-fen-shu.png" alt="差异化融合分数" width="760"><figcaption><p>差异化融合分数</p></figcaption></figure>

#### 排序模型的优化
特殊人群可视为相对主流样本的<span style="color:red">分布外数据</span>。当其行为分布差异较大时，通用模型的预测会产生偏差，可增加轻量校准模型进行修正。

<figure><img src="tui-jian-xi-tong-te-shu-ren-qun-pai-xu.png" alt="特殊人群排序" width="760"><figcaption><p>特殊人群排序</p></figcaption></figure>

<figure><img src="tui-jian-xi-tong-cha-yi-hua-pai-xu-fang-an.png" alt="差异化排序方案" width="760"><figcaption><p>差异化排序方案</p></figcaption></figure>

##### 大模型评估与小模型残差校准
小模型在**特殊人群数据集**上学习<span style="color:red">大模型的预测残差</span>，并将修正量叠加到原预测上。若大模型预测为 $$p$$、小模型残差为 $$q$$，则校准结果为 $$\widehat{y}=p+q$$。

<figure><img src="tui-jian-xi-tong-can-cha-jiao-zhun-mo-xing.png" alt="残差校准模型" width="760"><figcaption><p>残差校准模型</p></figcaption></figure>

##### MMoE 方案

<figure><img src="tui-jian-xi-tong-mmoe-jiao-zhun-fang-an.png" alt="MMoE校准方案" width="760"><figcaption><p>MMoE校准方案</p></figcaption></figure>

##### 大模型的知识蒸馏给小模型
大模型对特殊用户的评估结果作为输入，和它们的行为数据用于训练小模型。

>该方案<span style="color:red">不直接复制大模型输出</span>，而是将大模型预测作为输入特征，同时利用特殊人群的真实行为监督。

<figure><img src="tui-jian-xi-tong-zheng-liu-jiao-zhun-fang-an.png" alt="蒸馏校准方案" width="760"><figcaption><p>蒸馏校准方案</p></figcaption></figure>

#### 不建议：长期维护多个独立小模型
独立小模型会增加训练和部署成本，而且特殊人群样本量有限，容易过拟合。

当大模型对特殊人群的泛化能力提升后，旧的小模型可能失去价值，并使这部分用户<span style="color:red">无法及时获得主模型升级带来的收益</span>。

<figure><img src="tui-jian-xi-tong-duo-xiao-mo-xing-ju-xian.png" alt="多小模型局限" width="760"><figcaption><p>多小模型局限</p></figcaption></figure>

## 利用新增交互行为

### 关注度

#### 改进召回策略
增加面向**高关注概率内容**的召回通道或内容池。

<figure><img src="tui-jian-xi-tong-guan-zhu-zhao-hui-tong-dao.png" alt="关注召回通道" width="760"><figcaption><p>关注召回通道</p></figcaption></figure>

#### 改进排序策略
用户留存率可抽象为关注作者数的饱和函数 $$r=g(f)$$，其中 $$f$$ 为关注作者数，$$r$$ 为留存率。排序模型可以增加关注率预测，并根据作者粉丝数对该目标进行衰减，避免头部作者长期占优。融合分数可写为：

$$
\begin{align}
s_{u,i} &= s_{u,i}^{(0)}+\lambda w(f_a)p_{u,i}^{\mathrm{follow}}
\end{align}
$$

其中，$$s_{u,i}^{(0)}$$ 为基础排序分，$$p_{u,i}^{\mathrm{follow}}$$ 为用户 $$u$$ 关注物品 $$i$$ 作者的预测概率，$$f_a$$ 为作者粉丝数，$$w(f_a)$$ 为随粉丝数增大而衰减的权重，$$\lambda\ge0$$ 为融合系数。

<figure><img src="tui-jian-xi-tong-guan-zhu-lv-yu-zuo-zhe.png" alt="关注率与作者" width="760"><figcaption><p>关注率与作者</p></figcaption></figure>

<figure><img src="tui-jian-xi-tong-guan-zhu-lv-jia-quan.png" alt="关注率加权" width="760"><figcaption><p>关注率加权</p></figcaption></figure>

### 粉丝数
#### 排序
为帮助优质作者获得新关注，排序模型可预测物品带来的**关注概率**，并将其作为一个排序目标。

<figure><img src="tui-jian-xi-tong-fen-si-zeng-zhang-jia-quan.png" alt="粉丝增长加权" width="760"><figcaption><p>粉丝增长加权</p></figcaption></figure>


#### 隐式关注

隐式关注表示用户长期消费某位作者的内容，但尚未显式关注。可根据消费频次或作者数量阈值识别该关系，并建立 U2A2I 召回通道。

<figure><img src="tui-jian-xi-tong-yin-shi-guan-zhu-guan-xi.png" alt="隐式关注关系" width="760"><figcaption><p>隐式关注关系</p></figcaption></figure>

### 转发率

#### KOL：关键意见领袖
<figure><img src="tui-jian-xi-tong-kol-jian-mo.png" alt="KOL建模" width="760"><figcaption><p>KOL建模</p></figcaption></figure>

#### 召回
新增促进关注和转发的召回池，并对识别出的站外 KOL 生效。

#### 排序

识别站外 KOL 后，可为转发目标增加额外权重：

$$
\begin{align}
s_{u,i} &= s_{u,i}^{(0)}+\lambda k_u p_{u,i}^{\mathrm{share}}
\end{align}
$$

其中，$$k_u\in\{0,1\}$$ 表示用户 $$u$$ 是否为站外 KOL，$$p_{u,i}^{\mathrm{share}}$$ 为转发物品 $$i$$ 的预测概率，$$\lambda\ge0$$ 为融合系数。
<figure><img src="tui-jian-xi-tong-kol-zhuan-fa-jia-quan.png" alt="KOL转发加权" width="760"><figcaption><p>KOL转发加权</p></figcaption></figure>
