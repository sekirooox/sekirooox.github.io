---
title: "mmsegmentation·数据结构"
author: MayL
date: 2025-08-05
categories: ["深度学习与计算机视觉", "计算机视觉"]
tags: ["计算机视觉", "语义分割", "深度学习", "学习笔记"]
render_with_liquid: false
description: "本文整理“mmsegmentation·数据结构”涉及的模型原理、关键方法与实践要点，便于理解和复习相关技术。"
---

# PixelData
+ 简单的理解为torch.tensor或者ndarray的一个封装
+ 常用属性为`.data`,`..metainfo`
data属性
```python
gt_segmentations = PixelData(metainfo=img_meta,data=torch.randint(0, 2, (1, 4, 4)))
gt_segmentations.data
```
metainfo：**字典类型**

```python
img_meta = dict(img_shape=(4, 4, 3),
                 pad_shape=(4, 4, 3))
```
```python
tensor([[[1, 1, 1, 0],
         [0, 0, 1, 1],
         [0, 1, 1, 1],
         [0, 1, 0, 0]]])
```
---
```python
gt_segmentations.metainfo['img_shape']
(4, 4, 3)
```
+ 完全**支持torch.tensor的常见操作**：

```python
# 类张量的操作
gt_segmentations = PixelData(metainfo=img_meta)
gt_segmentations.data = torch.randint(0, 2, (1, 4, 4))
cuda_gt_segmentations = gt_segmentations.cuda()
cuda_gt_segmentations = gt_segmentations.to('cuda:0')

```

```python
cuda_gt_segmentations=cuda_gt_segmentations.detach().cpu().numpy()
print(type(cuda_gt_segmentations.data))
<class 'numpy.ndarray'>

```

# SegDataSample
+ `gt_sem_seg`，`pred_sem_seg`和`metainfo`
+ `gt_sem_seg`，`pred_sem_seg` 貌似只接受`PixelData`类型的数据

```python
import torch
from mmengine.structures import PixelData
from mmseg.structures import SegDataSample

img_meta = dict(img_shape=(4, 4, 3),
                 pad_shape=(4, 4, 3))
data_sample = SegDataSample()
```



