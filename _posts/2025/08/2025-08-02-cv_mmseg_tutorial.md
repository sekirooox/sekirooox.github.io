---
title: "深度学习·mmsegmentation基础教程"
author: MayL
date: 2025-08-02
categories: ["深度学习与计算机视觉", "计算机视觉"]
tags: ["计算机视觉", "语义分割", "深度学习", "学习笔记"]
render_with_liquid: false
description: "本文整理“深度学习·mmsegmentation基础教程”涉及的模型原理、关键方法与实践要点，便于理解和复习相关技术。"
---




# mmsegmentation的使用教程
# mmsegmentation微调方法总结
+ 自定义自己的数据集：`mmsegmentation\configs\_base_\datasets\ZihaoDataset_pipeline.py`
+ 注册：`mmsegmentation\configs\_base_\datasets\__init__.py`
+ 定义训练和测试的pipeline：`mmsegmentation\configs\_base_\datasets\ZihaoDataset_pipeline.py`，修改关键参数(与之前匹配)
+ 融合预训练模型：`configs/fastscnn/fast_scnn_8xb4-160k_cityscapes-512x1024.py`和pipeline：`mmsegmentation\configs\_base_\datasets\ZihaoDataset_pipeline.py`文件，**注意微调分割头!!!**，**注意微调分割头!!!**，**注意微调分割头!!!**
+ 得到最后的config文件`ZihaoDataset_FastSCNN_20230818.py`
+ 下载预训练模型：**修改`mmsegmentation\configs\segformer\segformer_mit-b5_8xb2-160k_ade20k-512x512.py`的pth路径，避免下载！**
+ 训练：命令`tools/train.py Zihao-Configs/ZihaoDataset_PSPNet_20230818.py`，默认使用预训练模型开始微调
+ 测试：需要用到训练时的`.pth`文件
+ 推理：根据**融合后的**config文件和`.pth`文件调用`inference_model()`API对图片进行推理。
+ 可视化：可以使用官方提供的**针对单个图片**的可视化结果
+ 所有指标和日志保存在`work_dirs/xxx/.json`文件下，如果需要单个class的指标结果，可以使用`.log`文件匹配。
+ 注意：opencv加载图片的格式是：**bgr格式**

# 自定义数据集`mmsegmentation\mmseg\datasets\ZihaoDataset.py`
+ 继承`BaseSegDataset`：`from .basesegdataset import BaseSegDataset`
```python
class ZihaoDataset(BaseSegDataset):
```

+ 类别和RGB标签的映射关系
```python
METAINFO = {
        'classes':['background', 'red', 'green', 'white', 'seed-black', 'seed-white'],
        'palette':[[127,127,127], [200,0,0], [0,200,0], [144,238,144], [30,30,30], [251,189,8]]
    }
```
+ 指定图像扩展名、标注扩展名
```python
    def __init__(self,
                 seg_map_suffix='.png',   # 标注mask图像的格式
                 reduce_zero_label=False, # 类别ID为0的类别是否需要除去
                 **kwargs) -> None:
        super().__init__(
            seg_map_suffix=seg_map_suffix,
            reduce_zero_label=reduce_zero_label,
            **kwargs)
```


```python
from mmseg.registry import DATASETS
from .basesegdataset import BaseSegDataset

@DATASETS.register_module()
class ZihaoDataset(BaseSegDataset):
    # 类别和对应的 RGB配色
    METAINFO = {
        'classes':['background', 'red', 'green', 'white', 'seed-black', 'seed-white'],
        'palette':[[127,127,127], [200,0,0], [0,200,0], [144,238,144], [30,30,30], [251,189,8]]
    }
    
    # 指定图像扩展名、标注扩展名
    def __init__(self,
                 seg_map_suffix='.png',   # 标注mask图像的格式
                 reduce_zero_label=False, # 类别ID为0的类别是否需要除去
                 **kwargs) -> None:
        super().__init__(
            seg_map_suffix=seg_map_suffix,
            reduce_zero_label=reduce_zero_label,
            **kwargs)
```
# 注册修改`mmsegmentation\mmseg\datasets\__init__.py`
+ 导入`ZihaoDataset`
```python
from .ZihaoDataset import ZihaoDataset
```
+ `__all__ `后面加入`'ZihaoDataset'`
```python
# yapf: enable
__all__ = [
    'BaseSegDataset', 'BioMedical3DRandomCrop', 'BioMedical3DRandomFlip',
    'CityscapesDataset', 'PascalVOCDataset', 'ADE20KDataset',
    'PascalContextDataset', 'PascalContextDataset59', 'ChaseDB1Dataset',
    'DRIVEDataset', 'HRFDataset', 'STAREDataset', 'DarkZurichDataset',
    'NightDrivingDataset', 'COCOStuffDataset', 'LoveDADataset',
    'MultiImageMixDataset', 'iSAIDDataset', 'ISPRSDataset', 'PotsdamDataset',
    'LoadAnnotations', 'RandomCrop', 'SegRescale', 'PhotoMetricDistortion',
    'RandomRotate', 'AdjustGamma', 'CLAHE', 'Rerange', 'RGB2Gray',
    'RandomCutOut', 'RandomMosaic', 'PackSegInputs', 'ResizeToMultiple',
    'LoadImageFromNDArray', 'LoadBiomedicalImageFromFile',
    'LoadBiomedicalAnnotation', 'LoadBiomedicalData', 'GenerateEdge',
    'DecathlonDataset', 'LIPDataset', 'ResizeShortestEdge',
    'BioMedicalGaussianNoise', 'BioMedicalGaussianBlur',
    'BioMedicalRandomGamma', 'BioMedical3DPad', 'RandomRotFlip',
    'SynapseDataset', 'REFUGEDataset', 'MapillaryDataset_v1',
    'MapillaryDataset_v2', 'Albu', 'LEVIRCDDataset',
    'LoadMultipleRSImageFromFile', 'LoadSingleRSImageFromFile',
    'ConcatCDInput', 'BaseCDDataset', 'DSDLSegDataset', 'BDD100KDataset','ZihaoDataset'
]
```
# `mmsegmentation\mmseg` 相当于源码部分
# 在`configs`中自定义训练和测试pipeline `mmsegmentation\configs\_base_\datasets\ZihaoDataset_pipeline.py`
## 必须修改的地方有：
+ 类名和数据集**根地址**，注意**接下来的`img_path`和`seg_map_path`参数会和`data_root`拼接在一起**
+ 还包括一些数据增强和训练相关的参数。
```python
dataset_type = 'ZihaoDataset' # 数据集类名
data_root = 'Watermelon87_Semantic_Seg_Mask/' # 数据集路径（相对于mmsegmentation主目录）
```
+ `img_path`和`seg_map_path`参数
```python
train_dataloader = dict(
    batch_size=2,
    num_workers=2,
    persistent_workers=True,
    sampler=dict(type='InfiniteSampler', shuffle=True),
    dataset=dict(
        type=dataset_type,
        data_root=data_root,
        data_prefix=dict(
            img_path='img_dir/train', seg_map_path='ann_dir/train'),
        pipeline=train_pipeline))

# 验证 Dataloader
val_dataloader = dict(
    batch_size=1,
    num_workers=4,
    persistent_workers=True,
    sampler=dict(type='DefaultSampler', shuffle=False),
    dataset=dict(
        type=dataset_type,
        data_root=data_root,
        data_prefix=dict(
            img_path='img_dir/val', seg_map_path='ann_dir/val'),
        pipeline=test_pipeline))
```

```python
# 数据处理 pipeline
# 数据集路径
dataset_type = 'ZihaoDataset' # 数据集类名
data_root = 'Watermelon87_Semantic_Seg_Mask/' # 数据集路径（相对于mmsegmentation主目录）

# 输入模型的图像裁剪尺寸，一般是 128 的倍数，越小显存开销越少
crop_size = (512, 512)

# 训练预处理
train_pipeline = [
    dict(type='LoadImageFromFile'),
    dict(type='LoadAnnotations'),
    dict(
        type='RandomResize',
        scale=(2048, 1024),
        ratio_range=(0.5, 2.0),
        keep_ratio=True),
    dict(type='RandomCrop', crop_size=crop_size, cat_max_ratio=0.75),
    dict(type='RandomFlip', prob=0.5),
    dict(type='PhotoMetricDistortion'),
    dict(type='PackSegInputs')
]

# 测试预处理
test_pipeline = [
    dict(type='LoadImageFromFile'),
    dict(type='Resize', scale=(2048, 1024), keep_ratio=True),
    dict(type='LoadAnnotations'),
    dict(type='PackSegInputs')
]

# TTA后处理(增强性能的技巧)
img_ratios = [0.5, 0.75, 1.0, 1.25, 1.5, 1.75] # 先缩放后全部加权得到结果
tta_pipeline = [
    dict(type='LoadImageFromFile', file_client_args=dict(backend='disk')),
    dict(
        type='TestTimeAug',
        transforms=[
            [
                dict(type='Resize', scale_factor=r, keep_ratio=True)
                for r in img_ratios
            ],
            [
                dict(type='RandomFlip', prob=0., direction='horizontal'),
                dict(type='RandomFlip', prob=1., direction='horizontal')
            ], [dict(type='LoadAnnotations')], [dict(type='PackSegInputs')]
        ])
]

# 训练 Dataloader
train_dataloader = dict(
    batch_size=2,
    num_workers=2,
    persistent_workers=True,
    sampler=dict(type='InfiniteSampler', shuffle=True),
    dataset=dict(
        type=dataset_type,
        data_root=data_root,
        data_prefix=dict(
            img_path='img_dir/train', seg_map_path='ann_dir/train'),
        pipeline=train_pipeline))

# 验证 Dataloader
val_dataloader = dict(
    batch_size=1,
    num_workers=4,
    persistent_workers=True,
    sampler=dict(type='DefaultSampler', shuffle=False),
    dataset=dict(
        type=dataset_type,
        data_root=data_root,
        data_prefix=dict(
            img_path='img_dir/val', seg_map_path='ann_dir/val'),
        pipeline=test_pipeline))

# 测试 Dataloader
test_dataloader = val_dataloader

# 验证 Evaluator
val_evaluator = dict(type='IoUMetric', iou_metrics=['mIoU', 'mDice', 'mFscore'])

# 测试 Evaluator
test_evaluator = val_evaluator
```
# 微调(迁移学习)方法
+ 导入两个py文件，一个是**预训练模型的文件**`configs/fastscnn/fast_scnn_8xb4-160k_cityscapes-512x1024.py`
+ 一个是我们定义好的**训练和测试pipeline文件**`./configs/_base_/datasets/ZihaoDataset_pipeline.py`
+ 两个要结合起来
```python
from mmengine import Config
cfg = Config.fromfile('configs/fastscnn/fast_scnn_8xb4-160k_cityscapes-512x1024.py')
dataset_cfg = Config.fromfile('./configs/_base_/datasets/ZihaoDataset_pipeline.py')
cfg.merge_from_dict(dataset_cfg)
```

## 微调方法
+ 修改分割头
```python
NUM_CLASS = 6
cfg.norm_cfg = dict(type='BN', requires_grad=True) # 只使用GPU时，BN取代SyncBN
cfg.model.backbone.norm_cfg = cfg.norm_cfg
cfg.model.decode_head.norm_cfg = cfg.norm_cfgcfg.dump('Zihao-Configs/ZihaoDataset_FastSCNN_20230818.py')
cfg.model.auxiliary_head[0].norm_cfg = cfg.norm_cfg
cfg.model.auxiliary_head[1].norm_cfg = cfg.norm_cfg

# 模型 decode/auxiliary 输出头，指定为类别个数
cfg.model.decode_head.num_classes = NUM_CLASS
cfg.model.auxiliary_head[0]['num_classes'] = NUM_CLASS
cfg.model.auxiliary_head[1]['num_classes'] = NUM_CLASS

cfg.train_dataloader.batch_size = 4

cfg.test_dataloader = cfg.val_dataloader

# 结果保存目录
cfg.work_dir = './work_dirs/ZihaoDataset-FastSCNN'

cfg.train_cfg.max_iters = 30000 # 训练迭代次数
cfg.train_cfg.val_interval = 500 # 评估模型间隔
cfg.default_hooks.logger.interval = 100 # 日志记录间隔
cfg.default_hooks.checkpoint.interval = 2500 # 模型权重保存间隔
cfg.default_hooks.checkpoint.max_keep_ckpts = 2 # 最多保留几个模型权重
cfg.default_hooks.checkpoint.save_best = 'mIoU' # 保留指标最高的模型权重

# 随机数种子
cfg['randomness'] = dict(seed=0)
```
## 保存为最终的`Config`配置文件

```python
cfg.dump('Zihao-Configs/ZihaoDataset_FastSCNN_20230818.py')
```

## 修改预训练模型
`mmsegmentation\configs\segformer\segformer_mit-b5_8xb2-160k_ade20k-512x512.py`：默认会下载预训练模型(见下面的url链接)，可以**手动修改为预先下载的文件**。
```python
_base_ = ['./segformer_mit-b0_8xb2-160k_ade20k-512x512.py']

# checkpoint = 'https://download.openmmlab.com/mmsegmentation/v0.5/pretrain/segformer/mit_b5_20220624-658746d9.pth'  # noqa
checkpoint = 'C:\\Users\\ASUS\\PycharmProjects\\pythonProject\\research\\MMSegmentation_Tutorials-main\\MMSegmentation_Tutorials-main\\20230816\\mmsegmentation\\pretrained\\mit_b5_20220624-658746d9.pth'  # noqa
# model settings
model = dict(
    backbone=dict(
        init_cfg=dict(type='Pretrained', checkpoint=checkpoint),
        embed_dims=64,
        num_heads=[1, 2, 5, 8],
        num_layers=[3, 6, 40, 3]),
    decode_head=dict(in_channels=[64, 128, 320, 512]))

```

## 训练细节

```python
08/02 12:35:34 - mmengine - INFO - Iter(val) [11/11]    aAcc: 87.5900  mIoU: 56.0600  mAcc: 71.7300  mDice: 65.9000  mFscore: 79.0800  mPrecision: 75.2700  mRecall: 71.7300  data_time: 0.0069  time: 0.0345
08/02 12:35:47 - mmengine - INFO - Iter(train) [ 9600/10000]  lr: 1.1351e-01  eta: 0:00:50  time: 0.1238  data_time: 0.0031  memory: 864  loss: 0.0688  decode.loss_ce: 0.0305  decode.acc_seg: 92.9966  aux_0.loss_ce: 0.0163  aux_0.acc_seg: 87.6057  aux_1.loss_ce: 0.0220  aux_1.acc_seg: 87.0640
08/02 12:35:59 - mmengine - INFO - Iter(train) [ 9700/10000]  lr: 1.1344e-01  eta: 0:00:37  time: 0.1298  data_time: 0.0033  memory: 864  loss: 0.1297  decode.loss_ce: 0.0651  decode.acc_seg: 71.6496  aux_0.loss_ce: 0.0297  aux_0.acc_seg: 69.3979  aux_1.loss_ce: 0.0349  aux_1.acc_seg: 58.9588
08/02 12:36:12 - mmengine - INFO - Iter(train) [ 9800/10000]  lr: 1.1337e-01  eta: 0:00:25  time: 0.1242  data_time: 0.0031  memory: 864  loss: 0.1223  decode.loss_ce: 0.0587  decode.acc_seg: 51.1257  aux_0.loss_ce: 0.0292  aux_0.acc_seg: 53.5561  aux_1.loss_ce: 0.0345  aux_1.acc_seg: 46.3654
08/02 12:36:25 - mmengine - INFO - Iter(train) [ 9900/10000]  lr: 1.1330e-01  eta: 0:00:12  time: 0.1261  data_time: 0.0032  memory: 864  loss: 0.0845  decode.loss_ce: 0.0380  decode.acc_seg: 86.1641  aux_0.loss_ce: 0.0210  aux_0.acc_seg: 77.3401  aux_1.loss_ce: 0.0255  aux_1.acc_seg: 62.3304
08/02 12:36:37 - mmengine - INFO - Exp name: ZihaoDataset_FastSCNN_20230818_20250802_121506
08/02 12:36:37 - mmengine - INFO - Iter(train) [10000/10000]  lr: 1.1323e-01  eta: 0:00:00  time: 0.1213  data_time: 0.0031  memory: 864  loss: 0.0956  decode.loss_ce: 0.0432  decode.acc_seg: 93.6745  aux_0.loss_ce: 0.0243  aux_0.acc_seg: 90.1726  aux_1.loss_ce: 0.0281  aux_1.acc_seg: 90.2538
08/02 12:36:37 - mmengine - INFO - Saving checkpoint at 10000 iterations
08/02 12:36:38 - mmengine - INFO - per class results:
08/02 12:36:38 - mmengine - INFO - 
+------------+-------+-------+-------+--------+-----------+--------+
|   Class    |  IoU  |  Acc  |  Dice | Fscore | Precision | Recall |
+------------+-------+-------+-------+--------+-----------+--------+
| background | 85.65 | 89.88 | 92.27 | 92.27  |   94.79   | 89.88  |
|    red     |  81.3 | 98.28 | 89.69 | 89.69  |   82.47   | 98.28  |
|   green    | 59.15 | 67.73 | 74.33 | 74.33  |   82.37   | 67.73  |
|   white    | 58.04 | 69.85 | 73.45 | 73.45  |   77.44   | 69.85  |
| seed-black | 61.43 | 78.07 | 76.11 | 76.11  |   74.24   | 78.07  |
| seed-white |  0.0  |  0.0  |  0.0  |  nan   |    nan    |  0.0   |
+------------+-------+-------+-------+--------+-----------+--------+
08/02 12:36:38 - mmengine - INFO - Iter(val) [11/11]    aAcc: 88.9900  mIoU: 57.5900  mAcc: 67.3000  mDice: 67.6400  mFscore: 81.1700  mPrecision: 82.2600  mRecall: 67.3000  data_time: 0.0075  time: 0.0340
```

## 可视化数据`mmsegmentation\work_dirs\ZihaoDataset-FastSCNN\20250802_121506\vis_data`
在`vis_data`目录下的`log_path = './work_dirs/ZihaoDataset-FastSCNN/20250802_121506/vis_data/scalars.json'`的文件，用于记录**整体各种指标**的记录情况。
```python
with open(log_path, "r") as f:
    json_list = f.readlines()
    eval(json_list[4])
```
输出结果如下：
```python
{'lr': 0.11973086417099389,
 'data_time': 0.004000043869018555,
 'loss': 0.1377907693386078,
 'decode.loss_ce': 0.07181963995099068,
 'decode.acc_seg': 88.35430145263672,
 'aux_0.loss_ce': 0.032481906749308107,
 'aux_0.acc_seg': 85.88199615478516,
 'aux_1.loss_ce': 0.03348922152072191,
 'aux_1.acc_seg': 81.13632202148438,
 'time': 0.12697319984436034,
 'iter': 400,
 'memory': 863,
 'step': 400}
```
针对**每一个类别**的各种指标可视化
存储在**log文件**中：`work_dirs/ZihaoDataset-FastSCNN/20250802_121506/20250802_121506.log`
我们要读取的就是这种格式的指标：
```python
+------------+-------+-------+-------+--------+-----------+--------+
|   Class    |  IoU  |  Acc  |  Dice | Fscore | Precision | Recall |
+------------+-------+-------+-------+--------+-----------+--------+
| background | 85.65 | 89.88 | 92.27 | 92.27  |   94.79   | 89.88  |
|    red     |  81.3 | 98.28 | 89.69 | 89.69  |   82.47   | 98.28  |
|   green    | 59.15 | 67.73 | 74.33 | 74.33  |   82.37   | 67.73  |
|   white    | 58.04 | 69.85 | 73.45 | 73.45  |   77.44   | 69.85  |
| seed-black | 61.43 | 78.07 | 76.11 | 76.11  |   74.24   | 78.07  |
| seed-white |  0.0  |  0.0  |  0.0  |  nan   |    nan    |  0.0   |
+------------+-------+-------+-------+--------+-----------+--------+
```

## pth权重保存路径`mmsegmentation\work_dirs\ZihaoDataset-FastSCNN`
我将这个pth文件移动到`mmsegmentation\pretrained\ZihaoDataset_FastSCNN_20230818.pth`这个路径下

## 测试方法
最终**config配置文件**+**模型的权重文件**
```python
python tools/test.py Zihao-Configs/ZihaoDataset_FastSCNN_20230818.py pretrained/ZihaoDataset_FastSCNN_20230818.pth
```
默认保存路径`mmsegmentation\work_dirs\ZihaoDataset-FastSCNN\20250802_134015`，**与训练的保存目录一致**。


# 推理
使用合并后的config配置文件和权重
## 载入模型
```python
# 模型 config 配置文件
config_file = 'Zihao-Configs/ZihaoDataset_FastSCNN_20230818.py'
# 模型 checkpoint 权重文件
checkpoint_file = 'pretrained/ZihaoDataset_FastSCNN_20230818.pth'
# device = 'cpu'
device = 'cuda:0'
model = init_model(config_file, checkpoint_file, device=device)
```
## 推理过程
`result = inference_model(model, img_bgr)`，好像**要用BGR格式的图片进行推理**？返回一个result，`SegDataSample`类型，分为两个东西，**一个是预测的类别，一个是概率**，其余就是**tensor的使用方法**。
```python
result = inference_model(model, img_bgr)
result.keys()  ['pred_sem_seg', 'seg_logits']
pred_mask = result.pred_sem_seg.data[0].cpu().numpy()
pred_mask.shape (1280, 1280)
result.seg_logits.data.shape torch.Size([6, 1280, 1280])
```
## 批量推理
其实就是**将每个图像都预测一下**，然后与掩码矩阵叠加一下，保存到输出文件夹下
```python
def process_single_img(img_path, save=False):
    
    img_bgr = cv2.imread(img_path)

    # 语义分割预测
    result = inference_model(model, img_bgr)
    pred_mask = result.pred_sem_seg.data[0].cpu().numpy()

    # 将预测的整数ID，映射为对应类别的颜色
    pred_mask_bgr = np.zeros((pred_mask.shape[0], pred_mask.shape[1], 3))
    for idx in palette_dict.keys():
        pred_mask_bgr[np.where(pred_mask==idx)] = palette_dict[idx]
    pred_mask_bgr = pred_mask_bgr.astype('uint8')

    # 将语义分割预测图和原图叠加显示
    pred_viz = cv2.addWeighted(img_bgr, opacity, pred_mask_bgr, 1-opacity, 0)
    
    # 保存图像至 outputs/testset-pred 目录
    if save:
        save_path = os.path.join('../','../','../','outputs', 'testset-pred', 'pred-'+img_path.split('/')[-1])
        cv2.imwrite(save_path, pred_viz)
```
## 摄像头推理(实时分割)
但是我没有摄像头😒
```python
python demo/video_demo.py 0 Zihao-Configs/ZihaoDataset_FastSCNN_20230818.py pretrained/ZihaoDataset_FastSCNN_20230818.pth --device cuda:0 --opacity 0.5 --show
```


# 可视化
## 官方提供的可视化分割图片的代码
**根据在Dataset中定义METAINFO来绘制掩码矩阵**的，最后**返回处理好的图片**。

```python
 METAINFO = {
        'classes':['background', 'red', 'green', 'white', 'seed-black', 'seed-white'],
        'palette':[[127,127,127], [200,0,0], [0,200,0], [144,238,144], [30,30,30], [251,189,8]]
    }
```

```python
from mmseg.apis import show_result_pyplot
img_viz = show_result_pyplot(model, img_path, result, opacity=0.8, title='MMSeg', out_file='outputs/K1-4.jpg')
plt.figure(figsize=(14, 8))
plt.imshow(img_viz)
plt.show()
```


## 批量可视化代码：用于获得n行n列的图像
不用记忆
```python
# n 行 n 列可视化
n = 4

fig, axes = plt.subplots(nrows=n, ncols=n, figsize=(16, 10))

for i, file_name in enumerate(os.listdir()[:n**2]):
    
    img_bgr = cv2.imread(file_name)
    
    # 可视化
    axes[i//n, i%n].imshow(img_bgr[:,:,::-1])
    axes[i//n, i%n].axis('off') # 关闭坐标轴显示
fig.suptitle('Semantic Segmentation Predictions', fontsize=30)
# plt.tight_layout()
plt.savefig('../K3.jpg')
plt.show()
```
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/a493f4b973dd4390825e8a908b56ab25.png){: referrerpolicy="no-referrer" }


<br><br><br><br><br><br>
----
# 数据集的存储要求(待续)
## 整数掩码/掩膜
+ 存储格式**必须是`png`**，目的是为了**无损**
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/f2c6f4de363b492b841272546c29b572.png){: referrerpolicy="no-referrer" }
像素太小，什么都看不出来。

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/5bc9d363001b408dba486e9f1f9b7451.png){: referrerpolicy="no-referrer" }

虽然掩码是一个**整数矩阵**，但是保存为`png`格式时，**必须存储3通道**
```python
img.shape
mask.shape
(300, 440, 3)
(300, 440, 3)
```

整数掩码转换为**RGB通道**可视化
取图像的任一一个通道，关键是使用`np.where()`

```python
mask = mask[:,:,0]

# 将整数ID，映射为对应类别的颜色
viz_mask_bgr = np.zeros((mask.shape[0], mask.shape[1], 3))
for idx in palette_dict.keys():
    viz_mask_bgr[np.where(mask==idx)] = palette_dict[idx]
viz_mask_bgr = viz_mask_bgr.astype('uint8')

# 将语义分割标注图和原图叠加显示
opacity = 0.1 # 透明度越大，可视化效果越接近原图
label_viz = cv2.addWeighted(img, opacity, viz_mask_bgr, 1-opacity, 0)
```
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/34d19466288e4af69db423c7d4d1751b.png){: referrerpolicy="no-referrer" }
## opencv的注意事项
注意opencv**载入图片是bgr格式**，要进行一个转换`img_bgr[:,:,::-1]`
```python
img_bgr = cv2.imread(img_path)
```
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/319176cff9a548a0a6bd343a4c6dace3.png){: referrerpolicy="no-referrer" }
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/87c6ed402cf74337b7555360f63fd365.png){: referrerpolicy="no-referrer" }
<br><br><br><br>
---
# 参考文献
[同济子豪兄](https://space.bilibili.com/1900783?spm_id_from=333.788.upinfo.head.click)
