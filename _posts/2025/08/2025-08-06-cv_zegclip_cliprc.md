---
title: "深度学习·Zegclip&Clip-RC"
author: MayL
date: 2025-08-06
categories: ["深度学习与计算机视觉", "计算机视觉"]
tags: ["计算机视觉", "clip", "深度学习", "学习笔记"]
render_with_liquid: false
math: true
description: "本文整理“深度学习·Zegclip&Clip-RC”涉及的模型原理、关键方法与实践要点，便于理解和复习相关技术。"
---

# Zegclip
+ 获取图像的特殊编码：使用prompt tuning的技术，目的是减少**过拟合和计算量**。
+ 调整文本编码：使用RD关系描述符，将每一个文本对应的[cls] token和图像对应的[cls] token作哈密顿积，最后文本[cls]token
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/a38257c343924b3d903d19e5e08a1788.png){: referrerpolicy="no-referrer" }

# 形式化任务

+ **文本的[cls] token**和每一个**patch token**进行一一匹配，这一点是通过**交叉注意力实现**的，通过`argmax`操作得到最后的分割结果
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/9b9f33938d5248b882ec4858fce8cffc.png){: referrerpolicy="no-referrer" }

# 图像编码：prompt tuning
+ P作为prompt token
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/0086219013df42f7874b7b39ce11eceb.png){: referrerpolicy="no-referrer" }

# 文本编码：RD关系描述符
>While being quite intuitive, we find this design could lead to severe overfitting. We postulate that this is because the matching capability between the **text query and image patterns is only trained on the seen-class datasets**.

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/6313248954214715b12fcc12eb900f25.png){: referrerpolicy="no-referrer" }

# Non-mutually Exclusive Loss (NEL)
>“the class space will be different from the training scenario, making the logit of an unseen class poorly calibrated with the other unseen classes.” ([Zhou 等, 2023, p. 5](zotero://select/library/items/TFM35HH2)) ([pdf](zotero://open-pdf/library/items/F72R666J?page=5&annotation=JRU84P4B)) 🔤类空间将与训练场景不同，使得看不见的类的 logit 与其他看不见的类的校准很差。🔤
+ 动机：unseen class相比seen class的概率很差，不适合进行softmax
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/7218cfcd79674c7cb78b11fbd434bd43.png){: referrerpolicy="no-referrer" }

# inductive和transductive训练设置
+ inductive：训练只用seen类，**完全不了解unseen class的name**，**完全不知道unseen class的标注信息**，测试时预测seen类和unseen类
+ transductive：训练分为**两个阶段**，**全程都知道seen和unseen class的name**，**但是unseen class的标注信息完全不知道**。第一个阶段只在seen class上训练，**然后预测unseen class的标注信息，生成伪标签**。第二个阶段使用unseen class的为标签和seen class的ground truth进行训练，测试与inductive一致。
>“In the “transductive” setting, we train our ZegCLIP model on seen classes in the first half of training iterations and then apply self-training via generating pseudo labels in the rest of iterations.” ([Zhou 等, 2023, p. 6](zotero://select/library/items/TFM35HH2)) ([pdf](zotero://open-pdf/library/items/F72R666J?page=6&annotation=5TMBRYB4)) 🔤在“转导”设置中，我们在训练迭代的前半部分在看到的类上训练我们的 ZegCLIP 模型，然后在其余迭代中通过生成伪标签来应用自训练。🔤

<br><br><br><br><br><br>

---
# CLIP-RC
+ RLB：VIT的特殊编码
+ RAM：Text encoder的特殊编码+对齐
+ 损失函数：Recovery Decoder With Recovery Loss
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/6bde42a727734958b3d231409972c7bd.png){: referrerpolicy="no-referrer" }

# RLB
+ VIT的输入结构
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/3599f7a604da40159586a3c7d71c268c.png){: referrerpolicy="no-referrer" }
+ VIT的输出结构
+ G是图像token(1,D)，P是prompt token(K,D)，I是patch token(N,D)，**R是作者引入的region token**(M,D)。

## R的理解和掩码设计
+ 作者认为每一个R中的token对应了$\frac{\sqrt{N}\sqrt{M}}{\sqrt{N}\sqrt{M}}$个patches
+ 例子：假设N=4,M=2，**图像中2x2的区域对应一个R的token**
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/b58c86d56dc2499280be527dcfb8003c.png){: referrerpolicy="no-referrer" }
+ 多了个掩码矩阵，一个R的token对应这些patch，其他的patch不需要参与计算，所以说**有个掩码矩阵**
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/169821cba1e841a4a5f30a7c246eac30.png){: referrerpolicy="no-referrer" }

+ 输出结果**正常抛弃prompt token**。
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/48ee6b51a0c94609b01380d7631cc7bd.png){: referrerpolicy="no-referrer" }
# RLB


##  对齐图像编码
+ image特征对齐为：(N,3D)
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/56325badedc94e8e8f3a7e3a7960595d.png){: referrerpolicy="no-referrer" }

## 区域描述符(特殊编码text encoder)
+ 得到特殊编码：(M,C,2D)
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/0e9023ecb1e84003b095b05e43001671.png){: referrerpolicy="no-referrer" }
# Decoder头
+ 先把$\hat{I}$和$\hat{R}$进行线性层映射到D维度(N,D)和(M,C,D)
+ 正常交叉注意力
+ 得到I和R形状不变
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/8f83898f4dbe42b2a725b41001ac1611.png){: referrerpolicy="no-referrer" }
>where, DMHCA and D′  MHCA denotes the decoder for semantic segmentation with multi-head cross attention, and ˆId ∈ RN×D and ˆRd ∈ RM×C×D are the image features and region-specific text queries respectively, used for segmentation. The segmentation map Output ∈ RC×N is obtained by averaging the outputs:
+ Output：(M,C,D)，然后**对M维度平均**得到最后的掩码矩阵。
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/6c8bf3e33e37490f95db869153046020.png){: referrerpolicy="no-referrer" }
# 损失函数
+ NLS+Recovery Loss
+ 完全一模一样架构的**decoder(辅助头)**
>Then, during training, a recovery decoder recovers the features extracted by the decoder into features with strong generalization. The network architecture of the recovery decoder is completely identical to that of the semantic segmentation decoder. They are recovered as follows: 

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/91429d6cd75544c088593cc388ccafd3.png){: referrerpolicy="no-referrer" }
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/ffab8d3c323c4633bf8df429b8e7be77.png){: referrerpolicy="no-referrer" }
+ 这里的I指的是原始CLIP提取的**图像特征**，已经被冻结，R指的是关系描述符，也就是**文本特征**。
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/eb5dcbaa11a743d5b99c6dfdff311090.png){: referrerpolicy="no-referrer" }







