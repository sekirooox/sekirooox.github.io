---
title: "计算机基础·数据库系统"
author: MayL
date: 2026-07-30
categories: ["计算机系统与开发", "数据库"]
tags: ["数据库", "计算机基础", "开发笔记"]
render_with_liquid: false
math: true
description: "本文整理“计算机基础·数据库系统”的核心知识、常用方法与实践注意事项，便于学习复习和开发查阅。"
---


# 数据库的概况
## 数据库系统DBS，数据库管理系统DBMS，操作系统OS，硬件的关系
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/9e4cab88cc764069a0d1b0609c5ddea7.png){: referrerpolicy="no-referrer" }

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/59181fec995e4e148fd086a9404e557f.png){: referrerpolicy="no-referrer" }

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/11581e02d4d34abba0ac7a55f2f0bbfe.png){: referrerpolicy="no-referrer" }

## 概念模型：层次模型和关系模式

## 数据库的三级模式：外模式，模式和内模式
### 外模式：用户模式，例如视图
### 模式：逻辑模式，例如概念模型，不包含具体物理存储

### 内模式：存储模式，例如聚簇索引


# 概念模型：现实世界模型->数据库模型
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/cf9aaacadebe4a37a74c4c4dd06b1900.png){: referrerpolicy="no-referrer" }


## 实体：例如职工，学生等对象

## 属性：实体拥有的一个特征

## 码(Key)：唯一标识一个实体的<span style="color:red">属性</span>，具有<span style="color:red">唯一性</span>，<span style="color:red">非空性</span>；
### 候选码：可以标识实体的码；<span style="color:red">"码"一般都指代候选码</span>

### 主码：选定的唯一标识实体的一个候选码
### 外码：参照其他关系的属性
#### 参照关系与被参照关系：R1引用R2，R1为参照，R2为被参照关系
+ 限制：R1中A属性引用自R2，**则R2在更新时会受到若干限制**

## 域(Domain)：属性的取值范围，例如年龄的域为10-29岁

## 实体型：具有<span style="color:red">相同属性</span>的实体所组成的<span style="color:red">集合</span>

## 实体集：<span style="color:red">同一类型</span>的实体的集合

## 联系：多个<span style="color:red">实体集</span>中的相互关联
### 1:1联系：一个班长领导一个班级，一个班级对应一个班长
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/c0743de89fdb46f680473b0cf0051d40.png){: referrerpolicy="no-referrer" }
### 1:n：一个班级对应多个学生，一个学生只能对应一个班级
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/460393ce542e4a96af35dd0eb69a900b.png){: referrerpolicy="no-referrer" }

### n:m：一个课程对应多个学生，一个学生又可以选秀多个课程
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/0460634ca9bc4c3492850ed5825de3e1.png){: referrerpolicy="no-referrer" }

### 两个以上实体集中的联系(p:r:q)
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/0c68ab24ff2e4e15aac106a2a215329f.png){: referrerpolicy="no-referrer" }

### 单个实体集内部的联系(1:1,1:n,n:m)：职工内有领导，一个领导指挥多个职工，一个职工只能被一个领导指挥

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/be928525a1d2415daa3f9e6649011678.png){: referrerpolicy="no-referrer" }
## 关系模式(Schema)：抽象的关系
### 定义：$$R(U,D,DOM,F)$$，U是属性集，D是域，DOM是域到值的映射，F是依赖关系
## ER关系图：实体用矩形，联系用菱形，属性用椭圆

### 绘制技巧：先确定实体集中的关系，<span style="color:red">省略属性</span>，确定联系。
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/854cab87b0c7448288ba7aee9cee08fa.png){: referrerpolicy="no-referrer" }
## 集合代数


### 集合运算：关系R和S具有<span style="color:red">完全相同的关系模式</span>

设：

$$
\begin{align}
R=\{t\mid t\in R\}
\end{align}
$$

$$
\begin{align}
S=\{t\mid t\in S\}
\end{align}
$$


要求：

- 两个关系必须具有相同的目数；
- 对应属性域相同。


#### 并，交，差，积

$$
\begin{align}
R\cup S=\{t\mid t\in R \vee t\in S\}
\end{align}
$$


---

$$
\begin{align}
R\cap S=\{t\mid t\in R \wedge t\in S\}
\end{align}
$$


---


$$
\begin{align}
R-S=\{t\mid t\in R \wedge t\notin S\}
\end{align}
$$


---


$$
\begin{align}
R\times S=
\{t\mid t=(t_R,t_S),t_R\in R,t_S\in S\}
\end{align}
$$


结果：

- 属性数：

$$
\begin{align}
n_R+n_S
\end{align}
$$

- 元组数：

$$
\begin{align}
|R|\times |S|
\end{align}
$$

## 关系代数

### 选择（Selection）

选择满足条件的元组。


定义：

$$
\begin{align}
\sigma_F(R)=\{t\mid t\in R\land F(t)=true\}
\end{align}
$$

其中**F表示需要满足的表达式**，**R表示目标关系/表**


例如：

查询学生关系中系别为 CS 的学生：

$$
\begin{align}
\sigma_{dept='CS'}(Student)
\end{align}
$$

###  投影（Projection）

选择指定属性列。
定义：

$$
\begin{align}
\pi_A(R)=\{t[A]\mid t\in R\}
\end{align}
$$

其中**A表示属性名**

例如：

查询学生姓名和系别：

$$
\begin{align}
\pi_{name,dept}(Student)
\end{align}
$$


特点：

- 去除重复元组。
### 连接（Join）

连接是两个关系按照条件组合。

一般形式：

$$
\begin{align}
R\bowtie S=
\{t\mid t_R\in R\land t_S\in S\land \theta(t_R,t_S)\}
\end{align}
$$


**其中$$\theta$$表示连接条件**，表示按照等值/不等值/自然条件连接关系。


---

#### 一般连接

$$
\begin{align}
R\bowtie_{A<B}S
\end{align}
$$


---

#### 等值连接：保留多个同名属性

连接条件为等号：

$$
\begin{align}
R\bowtie_{A=B}S
\end{align}
$$


特点：

- 保留两个关系中的连接属性。


---

#### 自然连接：只保留一个同名属性

符号：

$$
\begin{align}
R\bowtie S
\end{align}
$$


特点：

- 自动选择同名属性；
- 同名属性只保留一个。


例如：

$$
\begin{align}
R(A,B,C)
\end{align}
$$

$$
\begin{align}
S(B,D)
\end{align}
$$


自然连接：

$$
\begin{align}
R\bowtie S
\end{align}
$$


结果：

$$
\begin{align}
(A,B,C,D)
\end{align}
$$


---

### 外连接：用于保留无法匹配的元组
#### 悬空元组：<span style="color:red">不满足匹配条件</span>的元组

#### 左外连接：保留左关系的悬空元组
#### 右外连接：保留右关系的悬空元组

#### 全外连接：完全保留悬空元组


###  除运算（Division）：包含<span style="color:red">某些属性组</span>的元组

用于查询：

**“满足所有条件”的对象。**


定义：

$$
\begin{align}
R\div S=
\{t_R|t_R\in R\land
\forall t_S\in S,(t_R,t_S)\in R
\}
\end{align}
$$


例如：

查询选修所有课程的学生。


设：

学生选课关系：

$$
\begin{align}
SC(Sno,Cno)
\end{align}
$$


课程关系：

$$
\begin{align}
Course(Cno)
\end{align}
$$


查询：

选修全部课程的学生号：

$$
\begin{align}
\pi_{Sno}(SC)\div \pi_{Cno}(Course)
\end{align}
$$

### 例题
#### 查询选修课程号为 001 的学生号

已有：

学生选课关系：

$$
\begin{align}
SC(Sno,Cno)
\end{align}
$$


操作：

$$
\begin{align}
\pi_{Sno}(\sigma_{Cno='001'}(SC))
\end{align}
$$


---

#### 查询既选修课程 C1 又选修课程 C2 的学生：可以用除法 / 选择+并

分别求：

$$
\begin{align}
R_1&=\pi_{Sno}(\sigma_{Cno='C1'}(SC))
\\
R_2&=\pi_{Sno}(\sigma_{Cno='C2'}(SC))
\end{align}
$$


结果：

$$
\begin{align}
R_1\cap R_2
\end{align}
$$


# SQL
## Schema：不同于关系型数据库的Schema，表示<span style="color:red">视图</span>，表等多个<span style="color:red">对象(例如关系)的集合</span>，主要用于<span style="color:red">区分不同用户</span>

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/01dfa89fa9284d5893e6cd412294968b.png){: referrerpolicy="no-referrer" }
### 搜索路径：决定表默认<span style="color:red">归属于哪一个模式</span>，手动指定，自动搜索指定

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/b893512055cd427a828506e7fe9a0a6a.png){: referrerpolicy="no-referrer" }


+ 设置搜索路径后，**取第一个模式最为默认模式**。
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/0e00e1781384494795002ee8d64a3044.png){: referrerpolicy="no-referrer" }


## 聚合函数：SUM，COUNT，AVG等
## GROUP BY：分组函数，结果<span style="color:red">只能是分组依据+聚合函数</span>
### HAVING：·GROUP BY的条件语句·，相当于WHERE，可以与聚合函数搭配
### WHERE：一般性的条件语句，<span style="color:red">不能与聚合函数搭配</span>

## 连接查询
### `WHERE R.A=S.A`语句会自动进行连接，创建虚表

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/4c6aa64b0d92411ca89f31c9b244963c.png){: referrerpolicy="no-referrer" }
### `SELECT S.A,...`会自动创建自然连接


![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/511d218555db42c19426311a9e64c4a9.png){: referrerpolicy="no-referrer" }

### 自身连接：`Course First, Course Second`为自身取两个不同的别名

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/47ed3a463cf9414e8bf2cd32321e94c8.png){: referrerpolicy="no-referrer" }

### 外连接：`FROM R LEFT OUT JOIN S ON`![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/51128aea797543479545e93566371a8b.png){: referrerpolicy="no-referrer" }


![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/958d918731d941f78a23a1947d3dfc42.png){: referrerpolicy="no-referrer" }

### 多表连接：同理，默认创建`R.A，S.A，T.A`等多个同名属性
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/6b20067bfe2b4639b7281a03fc50f5fd.png){: referrerpolicy="no-referrer" }

## 集合代数：交，并，差；作用于查询结果和关系


### UNION：将两个关系取并集，等价于WHERE p OR q
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/133c54ed8d8e4227ae67859ec04a768a.png){: referrerpolicy="no-referrer" }

### INTERSECT：交集，等价于WHERE p AND q
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/1f5feb6915f54ef4ad4aa128179a9f63.png){: referrerpolicy="no-referrer" }

### EXCEPT：差集，等价于p AND NOT q
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/988a04cffc514c75b6e33b286eae0309.png){: referrerpolicy="no-referrer" }


## 插入：INSERT INTO TABLE VALUES(a,b,c)
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/cede7474ca8d4ca8a334f500e68b569e.png){: referrerpolicy="no-referrer" }

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/85cfcd3e44484e31a41bd40cabad9386.png){: referrerpolicy="no-referrer" }
## 更新表：UPDATE TABLE SET COL=x

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/aa318e0b9e2e4fa5827648dee6c0e82c.png){: referrerpolicy="no-referrer" }


![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/5fb0dbdd9181470a828a29fe62b1a16e.png){: referrerpolicy="no-referrer" }

## 删除记录：DELETE FROM TABLE WHERE ..

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/0ee40b17d7144d01935ecdfcfc07b88e.png){: referrerpolicy="no-referrer" }


## 视图VIEW：`CREATE VIEW X WHERE ... AS Y`，根据Y中某些数据创建视图X，<span style="color:red">本身不存储任何数据</span>，作为虚表
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/52c6e3339aba4d85a2255c0e813d2c5c.png){: referrerpolicy="no-referrer" }

### WITH CHECK OPTION：创建视图时检查`WHERE` 的约束条件，用于后续更新
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/6a9ace6ec9894200a1922ec7da4f64f9.png){: referrerpolicy="no-referrer" }

### 视图的更删改查：<span style="color:red">转换为对于基本表的操作</span>，不影响视图本身
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/dae28c0b9734412a8f526ef2bc70cc24.png){: referrerpolicy="no-referrer" }


## 权限控制
### GRANT TO语句：GRANT [操作，例如INSERT 属性] ON TABLE TO USER 
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/78cfc863a22e4396964bd40e690f0bdb.png){: referrerpolicy="no-referrer" }

# 数据库安全控制
## 角色控制
### ROLE：`CREATE ROLE` 创建角色；`GRANT ROLEA TO ROLEB` 授予角色 A 和 B 的权限；`REVOKE` 收回角色权限

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/141de15be0664ecf905e60c42a857b90.png){: referrerpolicy="no-referrer" }
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/543565e795b6453d8197ffe821bf5368.png){: referrerpolicy="no-referrer" }
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/4b1286271dca4eff9886a5e6899b1a61.png){: referrerpolicy="no-referrer" }
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/7e18d08a39c24cbab04c866bff8ceb51.png){: referrerpolicy="no-referrer" }

# 数据库的完整约束

## 实体完整性：每一个实体都是存在且可分的；<span style="color:red">主码唯一且非空</span>
+ CREATE TABLE A(sname CHAR(20) PRIMARY KEY)：**确保姓名非空且唯一，列级定义**
+ CREATE TABLE A(.. PRIMARY KEY(sname))：表格级别的定义
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/1f15437ee423402d9b1fa2a4cb878567.png){: referrerpolicy="no-referrer" }
## 参照完整性：约束不同表之间的引用关系；外建要么为NULL，要么引用被参照关系中存在的取值(不能引用不存在的取值)
+ CREATE TABLE A(... FOREIGN KEY Sno REFERENCES Course(Sno))：**给定被参照的表格名和属性**，与参照属性对应。
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/f63256bd5b1848ddb38c1a9a1c6828f7.png){: referrerpolicy="no-referrer" }
### 违约处理
#### NO ACTION：更新或删除被参照表Course时，由于关联SC表，决绝更新或删除
#### CASCADE：级联更新或删除被参照表Course和SC关联的记录

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/f756ef72715a444a8b5c975e423b6816.png){: referrerpolicy="no-referrer" }

## 用户定义完整性：应用数据满足语义约束；例如约束条件(NOT NULL等)和CHECK短语
### CHECK检查语句：CHECK <表达式>
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/d98de2aae0794802b39c52a7cba0bb20.png){: referrerpolicy="no-referrer" }

#### 属性上的约束条件：Sname CHAR(20) CHECK(...)/ NOT NULL
#### 元组上的约束条件：CREATE TABLE(... CHECK(A AND B))


### CONSTRAINT约束语句：CONSTRAINT 约束名 CHECK语句
#### 定义约束
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/0d246c4b053c42de95b5340af4e45274.png){: referrerpolicy="no-referrer" }

#### 删除约束
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/9ce70f4d1c9448179745a6466a07fdd7.png){: referrerpolicy="no-referrer" }
### ASSERTATION断言语句：ASSERATION 断言名 限制条件表达式
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/2a112a2194164404a1800277a6a54407.png){: referrerpolicy="no-referrer" }

## 触发器

### 定义触发器名-触发时机(前或者后)-新旧行别名(用于更新/删除)-触发条件-执行语句

```cpp
CREATE TRIGGER <触发器名>

{BEFORE | AFTER} <触发事件> ON <表名>

REFERENCING NEW | OLD ROW AS <变量>

FOR EACH {ROW | STATEMENT}

[WHEN <触发条件>]

<触发动作体>
```

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/90a9c2a048d547088195c57c31dd3f68.png){: referrerpolicy="no-referrer" }

### 多个触发器的竞争机制：BEFORE先于AFTER，<span style="color:red">相同定义时机先创建先触发</span>


# 关系数据库理论

## 函数依赖
### 完全函数依赖与部分函数依赖：$$X\rightarrow Y$$，但是$$X$$的任意一个<span style="color:red">真子集</span>不能推出Y；否则为部分函数依赖
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/1f1c553b7e08442a93573dad72459391.png){: referrerpolicy="no-referrer" }
### 传递函数依赖：$$X\rightarrow Y,Y\rightarrow Z$$，X，Y，Z互不包含。
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/dc25289c259749e8b9f07a3a57efa9c9.png){: referrerpolicy="no-referrer" }

## 主属性和非主属性：<span style="color:red">包含在候选码</span>中的属性叫主属性，否则为非主属性

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/b4a9e96ec213463480b71aab0d5fc700.png){: referrerpolicy="no-referrer" }
## 多值依赖

## 范式
### 1NF：第一范式，属性/元组的成分不可再分，具有原子性；
+ 例如教师这一属性不能再细分为语文教师和数学教师
### 2NF：第二范式，非主属性必须<span style="color:red">完全函数依赖</span>于<span style="color:red">任何</span>一个候选码；暗示候选码至少有<span style="color:red">两个属性</span>
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/0daf7cff74d84888842c63395f8ac87a.png){: referrerpolicy="no-referrer" }
+ Sdept部分依赖于**任意一个/所有的候选码(Sno，Cno)**，不属于第二范式
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/a07bc005e0af4dda97db7178cb15549a.png){: referrerpolicy="no-referrer" }


#### 关系分解：关系进行拆分，拆分为多个关系以满足范式要求
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/89fec15d511940f1b36e4397bb347ec2.png){: referrerpolicy="no-referrer" }

### 3NF：不能出现非主属性的传递函数依赖；X-Y-Z，其中X为候选码，<span style="color:red">Y为非主属性</span>，Z为非主属性
+ Sno(候选码)-Sdept-Sloc：本质上Sloc依赖于Sdept，但是Sdept不是候选码，所以不符合3NF范式。
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/73bde08b4e274c1491e5f3ec5f6edb8d.png){: referrerpolicy="no-referrer" }

+ 部分依赖：显然候选码为Cno，**不存在部分依赖**。
+ 传递依赖：课程号推测课程名，但是课程名无法确定先导课号，**不存在传递依赖**。

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/492c35008e7b4651b02c796796cedf3b.png){: referrerpolicy="no-referrer" }

### BCNF：$$X\rightarrow Y$$，每一个决定因素都含有候选码
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/ff0368e062024abab56830079cab5050.png){: referrerpolicy="no-referrer" }

+ 例子：STJ都是主属性，所以不存在对于非主属性的部分依赖和传递依赖
+ 但是T->J这条路径中，**T不是候选码**(回忆：**候选码是一个主属性的集合**)，所以不属于BCNF范式
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/b90d378aed94466c8a892156fef1dac4.png){: referrerpolicy="no-referrer" }

### 4NF：略


## 规范化方法：低级范式通过<span style="color:red">模式分解</span>转换为高级范式的过程
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/9f24b217a14b4c709d9c7118f6e9aa92.png){: referrerpolicy="no-referrer" }

### 投影分解：将部分依赖的主属性拆开，单独成立一个关系
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/d611f77784fd42749e6745ee43918406.png){: referrerpolicy="no-referrer" }

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/3ec9cd2b90a24cd2ab0d04f0b0b3282d.png){: referrerpolicy="no-referrer" }
## 数据库依赖的公理系统(偏理论)
## ❓模式分解(偏理论)


# 数据库设计
## 需求分析
## 概念模型设计：ER图和UML
### ER图
### ❓UML：统一建模语言
### 概念结构设计
#### 实体还是属性：如果可再分或者存在相互联系用实体；不可再分/1对1的特征用属性
+ 职称和病房都可以进一步细分，因此需要作为一个实体
+ **病人和病房需要相互联系**，因此病房只能是一个实体


![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/fea586e60a2e468fab9aa1bb25c9f6ea.png){: referrerpolicy="no-referrer" }

#### 系统集成：多个ER图的集成

## 逻辑结构设计
### ER图转关系模型
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/a0f4236d58804c8a95cdcc9aec6a93f0.png){: referrerpolicy="no-referrer" }
#### 对于实体：实体+属性直接转关系(表)
#### 对于联系：单独建表或者合并
+ **供应这一关系**只能使用新关系来表示
+ **参加这一关系**只能使用新关系来表示**(n:m)**

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/d07bfe1ae862417e86dc0fd310f4fcd5.png){: referrerpolicy="no-referrer" }
##### 1:1联系：用新的关系表示，包含两个实体间的码；将联系合并到任意一端的关系，例如"负责"联系合并到"职工"中，使用对应的外键区分


##### 1:n联系：用新关系表示；合并到n的一端

##### m:n：只能用新关系表示

##### 三个及以上的实体的联系：只能使用一个新关系表示

### 数据模型优化

### 用户子模式优化

## 物理结构设计
### 关系数据库的存储方式

#### 逻辑组织方式：一个表包含多个分段，分段又包含多个数据块
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/6cec1f0b59a04e2e9c297a056ab31027.png){: referrerpolicy="no-referrer" }
##### 表空间：DB中存储的多个关系
##### 分段：分为数据区和索引区
##### 数据块：分为数据块或者索引块

#### 物理存储方式：文件-块-元组
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/78556015171841f7b1a65a45fc93e1ff.png){: referrerpolicy="no-referrer" }
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/ce9db70d0926448e87897ef5dd397c04.png){: referrerpolicy="no-referrer" }
#### 多表聚簇：多个表按照某个键依次存放；例如Student表和SC表依次存储Sno相等的两个表的元组；连接块查询慢
+ 优点：连接操作很快
+ 缺点：一个元组更着来自其他表的连接元组，因此每一个物理块存储的存储的某一个表的元组数量显著降低，因此普通的查询更慢！ 
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/c8a8b8155c5f4456949f71633539c3ff.png){: referrerpolicy="no-referrer" }
### 索引原理


#### 有序表的索引

##### 稠密查询：记录每一个元组的索引；索引开销巨大
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/9d298e5ff0054f5ab3043930ee3b960a.png){: referrerpolicy="no-referrer" }
##### 稀疏索引：记录每一个物理块第一个元组的索引；查询效率波动大
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/ede8127d44e442329375064b83798a97.png){: referrerpolicy="no-referrer" }
##### 多级索引：系数索引+稠密索引；索引维护代价高
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/ec3ded9efea147e5849f48a6fc0cf705.png){: referrerpolicy="no-referrer" }
### B+树索引
#### B+树的性质
##### B+树是二叉排序树，B+树是平衡二叉树
##### 节点的最大分支数$$m$$为B+树的阶或秩(Order)
##### 非根节点的节点数至少为$$m/2$$，至多为$$m-1$$；有$$m$$个索引指针
##### 叶子节点存储<span style="color:red">元组</span>所在的指针和键：$$Node(P_1,K_1,P_2,K_2 \cdots,P_n,K_n)$$，$$P_i$$指向元组$$t$$，$$P_n$$指向兄弟节点

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/9b9d86724c7e4f9288f2a7a84c47defe.png){: referrerpolicy="no-referrer" }
##### 非叶子节点存储<span style="color:red">下一级节点</span>所在的指针和键：$$Node(P_1,K_1,P_2,K_2 \cdots,P_n,K_n)$$，$$P_i$$指向下一级节点，$$P_n$$指向兄弟节点
+ Pi指向的下一级节点的键范围**一定处于Ki-1和Ki之内**

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/a66e30b696d64a24a5c87b0a910ed8aa.png){: referrerpolicy="no-referrer" }

#### 随机查询和范围查询：从根节点沿着索引遍历到叶子节点，获得对应元组
+ 随机索引：搜索Sno=20180011，根据节点的索引范围逐层往下，直到获得**叶子节点指向Sno=20180011所在元组的指针**。
+ 范围索引：如果是范围索引，那么会**沿着叶子节点顺序搜索得到所有元组**。

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/a8c201153c9a43c69ed0f5624d1a7ff5.png){: referrerpolicy="no-referrer" }


### B+树的维护
#### 插入维护：插入元素时，首先确定插入位置。如果位置未满，则直接插入；否则将最后一个键$$K_n$$与插入元素$$K$$单独<span style="color:red">组成新叶子节点</span>，$$K_n$$作为<span style="color:red">父节点的新键</span>；如果父节点仍然满，则递归进行下去
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/e706be0beb1945b1a379a5529f166337.png){: referrerpolicy="no-referrer" }


#### 删除维护：删除元素时，首先确定删除位置。如果删除后节点仍能满足阶数要求($$>m/2$$)，则直接删除；否则在不影响左侧节点的情况下，向左侧兄弟节点借一个$$K_n$$键，扩充当前节点$$Node(K_1,K_2,\cdots)\rightarrow Node(K_n,K_1,K_2,\cdots)$$
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/bcc60c593757474e9ed710ade953aa8b.png){: referrerpolicy="no-referrer" }
### 哈希索引
#### 静态哈希索引：不适合数据动态扩充，容易溢出
+ 哈希映射到某个桶，多个桶对应一个物理块。查询某个键时，顺序搜索取出对应的元组。
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/e5de99d2adf84332904fc2bac0dce8bb.png){: referrerpolicy="no-referrer" }
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/a29c280305af4e9fa0536a6f423e72aa.png){: referrerpolicy="no-referrer" }

##### 桶溢出：溢出桶(链表法)
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/c5c3fb4849704c03a9f630b2fbafe1c3.png){: referrerpolicy="no-referrer" }
### 动态哈希：使用二进制方法动态扩充桶的数量
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/208935fadf8f4a4a84e7bf7769ea443c.png){: referrerpolicy="no-referrer" }
#### 聚簇索引：将索引<span style="color:red">聚集保存</span>于数据块中，集中读取

---

# ❌数据库编程

# 查询处理和查询优化
## 关系数据库的查询处理(如何查询)
### 查询处理的步骤：查询分析(语法/句法)-查询检查(完整性初步检查)-查询优化-查询结果

### 选择操作的处理：索引扫描(B+树)和全表扫描
#### 全表扫描：适合选择率高(>=10%)，顺序读取完整数据块，选择率高时IO效率更高
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/23fe0ea061e34ca69b2a7f327a83b827.png){: referrerpolicy="no-referrer" }
### 连接操作的处理：嵌套循环，排序-合并，<span style="color:red">索引连接</span>，<span style="color:red">哈希连接</span>算法

#### 嵌套循环和排序-合并：按照规则依次读取关系表，先排序性能会有提高
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/18fa576c82564cecb9205717f7406066.png){: referrerpolicy="no-referrer" }
#### 索引连接：其中一个关系建立索引，利用索引确定对应元组，进行连接

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/be7b7b73706c4801bac9f2047d80894a.png){: referrerpolicy="no-referrer" }

#### 哈希连接：基于同一个连接属性建立哈希表，由第一个关系表确立，第二个关系表进行哈希查询，找到对应的元组
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/15a3136f925f4f289de783c48a3e4632.png){: referrerpolicy="no-referrer" }

#### 索引扫描：适合选择率很低(<10%)，需要先读取根-孩子-叶子节点，然后根据叶子节点的主码寻找完整数据行，更加精确但是是随机索引
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/3bb12dc4f0544e289bca5bd240c20db6.png){: referrerpolicy="no-referrer" }


## 关系数据库的查询优化
+ 优化数据库的查询语句，Q1拼接两个大表，效率最低
+ Q2进行自然连接，避免笛卡尔乘积的无效元组
+ Q3**先进行选择操作**，然后再拼接相对小的表，最后投影，效率最高。
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/90393ef335bd40989b02da27d8fb9941.png){: referrerpolicy="no-referrer" }

### 代数优化：通过关系代数进行优化

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/5571d5decb924aefa478af59eea7d01f.png){: referrerpolicy="no-referrer" }
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/f9ee7de4179848669dce9cb8eecbed61.png){: referrerpolicy="no-referrer" }

#### 启发式的优化方法：选择和投影优先做，自然连接替代笛卡尔积
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/be3119d1f47b4378879b3fc89d7725b6.png){: referrerpolicy="no-referrer" }
### 物理优化
#### 基于启发式(规则)的优化
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/686345df99f24e0ea51e4dca765ff1cf.png){: referrerpolicy="no-referrer" }
#### 基于代价估算

# 数据库的恢复
## 事务(TRANSACTION)：一系列数据库操作
### 事务的代码定义

```cpp
BEGIN TRANSACTION
XXX...
XXX...
XXX..
COMMIT / ROLLBACK
```

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/ee740258ddcf43caa9724d541bb7e66e.png){: referrerpolicy="no-referrer" }

### 事务的ACID特征
#### A-原子性：事务里的所有操作要么都做，要么全都不做

#### C-一致性：事务里的所有操作都完成/都没有执行时的数据库状态，部分完成部分没有完成称之为非一致性状态
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/786d6c7fa6394e65a3ae500dc3293148.png){: referrerpolicy="no-referrer" }
#### I-隔离：多个事务的并行执行互不影响

#### D-持续性：事务对于数据库的修改时持久的

## 恢复技术
### 数据转存：存储数据的后备副本，又分为静态转存和动态转存(转存中可以处理其他事务)
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/ecee2c3897454b1fa8d725649c6c570a.png){: referrerpolicy="no-referrer" }
### 日志：记录对于数据库更新和操作的文件，<span style="color:red">边执行事务操作，边记录！</span>
#### 日志记录的内容：事务名，操作类型和对象，旧值和新值
+ 例如`<T,UPDATE,A,1000,700>`，表示事务T，**修改对象A的取值从1000至700**

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/2ffaa856bd2a4ba5b62dafc6ea11a1b0.png){: referrerpolicy="no-referrer" }


#### 日志原则：日志按照时间戳记录；先写日志，后写数据库

## 恢复策略
### 事务故障：事务执行了一半
#### 反向扫描，撤销(UNDO)修改=逆操作
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/e80d60db7f7b4f7a935c0984c471fb3a.png){: referrerpolicy="no-referrer" }
### 系统故障：1.事务执行了一半，修改了数据库 2.事务提交了未执行(在缓存区)，未修改数据库
#### 1.事务执行一半：加入撤销队列，反向扫描进行逆操作
#### 2.事务提交未执行：加入重做(REDO)队列，正向扫描进行重做
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/9c290b2511ea4bed92f44ec1316d1566.png){: referrerpolicy="no-referrer" }


### 介质故障(硬件故障)


## 检查点：日志中的特殊记录

### 动机：需要搜索日志文件，<span style="color:red">遍历整个日志文件</span>查找所需事务记录，效率低下
### 检查点的结构：<<span style="color:red">正在执行</span>的事务，对应日志记录地址> + 重新开始文件(新文件，记录检查点及其所在的地址，用于最近版本的恢复)
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/36f7e03947404ba9a0e045677fd9710f.png){: referrerpolicy="no-referrer" }


### 恢复逻辑：检查点前提交不管；<span style="color:red">检查点后，故障点前</span>提交了都重做，故障发生后仍未提交，直接撤销。

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/07812e87567148d8bcc2e102da981863.png){: referrerpolicy="no-referrer" }
## 数据库镜像技术

# 数据库的并发控制
## 数据不一致：丢失修改，不可重复读，读取脏数据
### 丢失修改：事务T1的修改<span style="color:red">被事务T2覆盖</span>
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/b355f85d3dce41cbadc39a8bb5254eae.png){: referrerpolicy="no-referrer" }
### 不可重复读：事务T1读取A记录，其中<span style="color:red">A被事务T2修改/删除/插入新记录</span>，导致A记录<span style="color:red">前后不一致</span>
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/9838efd53abd431fa6c317960c5a8429.png){: referrerpolicy="no-referrer" }

### 读取脏数据：事务T1修改A记录，T2此时读取A记录，但是T1被撤销，导致<span style="color:red">T2读取的A记录(中间值)</span>无意义
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/8e4106f2121e4a05ae4055fafdc801b1.png){: referrerpolicy="no-referrer" }


## 封锁：多个读写者的同步问题
### 排他锁-写锁-X锁：持有后其他不能再对A进行任何的<span style="color:red">读和写操作</span>(注意读操作写不行)


### 共享锁-读锁-S锁：对A的<span style="color:red">读操作</span>可以继续<span style="color:red">共享锁</span>，但是写操作被禁止

### 注意：排他锁和共享锁同一时刻<span style="color:red">只能有一个事务</span>拥有一个

## 封锁协议
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/62f1b8a71e5b4160921e7332c9e880c1.png){: referrerpolicy="no-referrer" }
### 一级封锁协议：修改数据前必须加X锁；解决"丢失修改"的问题


### 二级封锁协议：读取数据前加S锁，持续到<span style="color:red">读取操作完成</span>；解决"读取脏数据"的问题，存在"不可重复读取的问题"
+ 读取也要加锁，确保读取过程中，**没有其他事务在修改数据，也就避免读取中间数据**。

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/31eba437809a4ec6afefb826d50587a2.png){: referrerpolicy="no-referrer" }


### 三级封锁协议：读取数据前加S锁，持续到<span style="color:red">事务完成</span>；解决"不可重复读取的问题"
+ 二级协议读取完成后锁会被释放，其他事务可以趁机修改数据，容易造成前后不一致的问题
+ 三级封锁协议确保在整个事务结束后再释放，确保读取的数据符合操作序列的流程，不会出现前后不一致的问题。
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/b84e0461a4ba4f2cbedd42548a8a942f.png){: referrerpolicy="no-referrer" }

## 活锁和死锁

### 活锁：某事务一直请求不到资源(但理论上仍能请求资源)，属于<span style="color:red">公平性</span>问题
+ T2一直想要请求资源R，但是一直被其他事务封锁
+ 但理论上T2始终有计划请求资源R
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/d46faec681a8496a91fc400217850c90.png){: referrerpolicy="no-referrer" }

### 死锁：事务间互相封锁，谁也无法执行
#### 死锁预防：一次性请求，抢占式和顺序请求
+ 一次性请求：**请求所有的资源**进行封锁
+ 抢占式：抢占锁
+ 顺序请求：**请求的资源编号递增**

#### 死锁检测：超时法，等待图法
#### 死锁解决：释放资源，终止并恢复事务

## 并发事务的可串行化
### 串行调度的结果：按照<span style="color:red">一定顺序</span>严格执行事务，例如T1,T2,T3或T2,T1,T3；<span style="color:red">存在多种串行调度结果</span>
### 可串行化的调度：<span style="color:red">并发</span>事务的执行结果等于<span style="color:red">某一种</span>串行调度的结果
+ (c)的执行结果：A=3,B=3不符合任意一种串行调度结果(T1,T2或者T2,T1)，因此结果是错误的。
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/d80fe02721304cf09383a3edc4e03d1e.png){: referrerpolicy="no-referrer" }

### 冲突操作：<span style="color:red">不同</span>事务Ti和Tj对于<span style="color:red">同一个</span>对象A的读写和写写操作；冲突操作是<span style="color:red">不可以交换的</span>
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/acd88f5958a5489689b64561389e5cbe.png){: referrerpolicy="no-referrer" }

#### 冲突可串行化调度：通过交换<span style="color:red">非冲突操作</span>，实现事务之间的串行化调度
+ r2(A)和w2(A)与r1(B)与w1(B)是非冲突操作，可以进行交换
+ 交换后，第一组操作来自于T1，第二组来自于T2，则他们之间可认为是T1,T2串行的结果。
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/bbff51422ed944ac9bd71f18b317c247.png){: referrerpolicy="no-referrer" }
## 封锁粒度

### 封锁粒度和并发性的关系：封锁粒度越大(例如封锁整个数据库)，并发性越低

### 多粒度封锁：<span style="color:red">封锁树</span>的每一个节点都可以加锁
#### 显示加锁和隐式加锁：显示-自身加锁，隐式-子节点加锁
#### 冲突检查：需要<span style="color:red">同时检查父节点的锁(隐式封锁)和孩子节点的锁</span>(其显示锁与本事务所加隐式锁是否冲突)；效率较低

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/788c5ac6619741b78b487979a603d68b.png){: referrerpolicy="no-referrer" }
### 意向锁：解决向<span style="color:red">下层节点</span>检查(元组数很多)时效率低下的问题
+ 对于本节点加锁时，需要对<span style="color:red">父节点</span>(例如关系，数据库等)加入意向锁，避免<span style="color:red">逐一检查</span>下一级的锁
#### IS：对当前节点加入IS锁，对孩子节点加入S锁
#### IX：对当前节点加入IX锁，对孩子节点加入X锁
#### SIX：对于当前节点加入S锁和IX锁，表示既要读取当前表，还需要修改部分元组
#### 相容关系
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/1d5e294df99d495981259fea1bc13512.png){: referrerpolicy="no-referrer" }
+ 对于R1加S锁，则对于数据库也要加IS锁。此时**该表元组是否有X类型的锁尚不知道**，此时检查**同一级的节点R1**是否存在IX锁，**来判断元组间是否有X锁**。

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/d3c89c433afa492987541565c9ce4092.png){: referrerpolicy="no-referrer" }

