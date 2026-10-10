---
title: "计算机基础·计算机组成原理"
author: MayL
date: 2026-07-23
categories: ["计算机系统与开发", "计算机基础"]
tags: ["计算机组成", "计算机基础", "开发笔记"]
render_with_liquid: false
math: true
description: "本文整理“计算机基础·计算机组成原理”的核心知识、常用方法与实践注意事项，便于学习复习和开发查阅。"
---

@[toc]
# 体系结构通识
## 冯诺依曼架构：计算单元+存储器+输入/输出设备+控制器
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/5ef8534b77834373b6bbfa5271daf6fb.png){: referrerpolicy="no-referrer" }

## 程序的编译过程：预处理-编译-汇编-链接
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/ceaa5eb441004d12a32c23ef8648bf58.png){: referrerpolicy="no-referrer" }
### 预处理器：替换宏定义和头文件为具体的函数或者内容
+ 有宏定义`#Define A B`，将代码中A变量全部替换为B。
+ 替换为头文件`stdio.h`为对应的函数声明：例如`extern int printf('xxxx')`

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/7940e24c72d9496b8e954bc19679864d.png){: referrerpolicy="no-referrer" }

### 编译器：将`高级程序`语言(C语言)替换为`低级通用`的程序语言(汇编语言)

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/591564699c7f41a79149f865f5b1baa6.png){: referrerpolicy="no-referrer" }

### 汇编器(Assembler)：将低级通用程序语言(汇编语言)替换为`机器能理解`的`字节码`(二进制串)

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/6135fe4e915d4865b3f9b4966634cab6.png){: referrerpolicy="no-referrer" }

### 链接器：外部函数的符号解析和地址重定位(确定外部函数对应`所在程序的地址`)

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/932a5d438bae4f4a8d0cca70625ce238.png){: referrerpolicy="no-referrer" }

# 内存地址和字节
## 字节-寻址的内存组织结构：视同为`字节数组`，寻址单位`为1个字节`
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/2567161bb9c941df8874dfb876121437.png){: referrerpolicy="no-referrer" }
### 寻址单位：每一个内存地址代表几个字节，例如`2字节寻址`


### 32位系统和64位系统：代表`逻辑地址的位数`，`虚拟内存空间`的大小




## 字节排序：大端法和小端法
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/735a52cf84284d1392239910498f31b0.png){: referrerpolicy="no-referrer" }

### 大端法：最不重要的字节在高位-顺序存储
### 小端法：最不重要的字节在低位-逆序存储，`更加常用`

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/243b6e847ee34c80aaf8d8d64b2af8ce.png){: referrerpolicy="no-referrer" }

## 字符串的表示：字符用ASCII码(1字节)表示，使用空字符'\0'(null character，'0x00')表示终止
```cpp
char s[6] = "12345";
地址        内容(字符)       ASCII
1000        '1'             0x31
1001        '2'             0x32
1002        '3'             0x33
1003        '4'             0x34
1004        '5'             0x35
1005        '\0'            0x00
```


# 整数的表示：有符号数和无符号数，符号位
## 原码，补码和反码：`默认使用二进制补码`表示`有符号整数`
### *正数转负数技巧：正数取反+1=负数
### 反码-二进制反码：最高位为符号位，数值为$-x_{w-1}\cdot(2^{w-1}-1)$
+ 正数的补码为其本身，负数的补码为正数的原码取反得到。
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/2b7428f1785541589857570a2cbee70b.png){: referrerpolicy="no-referrer" }
#### 补码-二进制补码：最高位为符号位，数值为$-x_{w-1}\cdot2^{w-1}$
+ 补码=反码+1


## 位数的扩展：有符号和无符号数
### 无符号整数-零扩展：直接前面补0，不影响符号位
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/9881d3cd865146fd89725cc21163fb01.png){: referrerpolicy="no-referrer" }
### 有符号整数-符号扩展：扩充k位，前面`填充k个原先的最高位`，不影响结果

+ 符号为0，显然成立
+ 符号为1，**扩充的位数得到的负数恰好就是扩充之前得到的负数**。
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/e06780c33246481b8291ba44dd4bc73d.png){: referrerpolicy="no-referrer" }

## 截断：超出数据范围

## 加法运算：有符号加法和无符号加法
### 无符号加法：mod $2^{w}$即可
### 有符号加法：正溢出和负溢出
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/969a4823d8a9426da0f18a2d4ef6ac1b.png){: referrerpolicy="no-referrer" }


## 乘法运算
### 有符号整数的`通用方法`：`先定符号位`，`转正数`，使用`算盘法`求解，最后构造有符号整数(是负数则取反+1)

```cpp
        0101
    ×   0011
-------------
        0101       (0101 × 1)
       01010       (0101 × 1 << 1)
      00000        (0101 × 0 << 2)
     00000         (0101 × 0 << 3)
-------------
       01111
       
```
### 二进制拆分法：$a\cdot b=a<<(x_0\cdot 2^0+x_1\cdot 2^1+\cdots x_{w-1}\cdot 2^{w-1})$


#### 二的乘法：左移k位

#### 二的除法：右移k位，右移后`空出位全部填充符号位`

# 浮点数的表示

## `IEEE标准表示法`-二进制科学计数法：符号位$s$，指数部分$E$和有效数部分$M$
+ 计算公式为：
$$
\begin{align}
V=(-1)^s \cdot M \cdot 2^E
\end{align}
$$
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/a8eb14a72e2f4a33a1e66e0017e08764.png){: referrerpolicy="no-referrer" }
### 指数位的偏置：偏置一般设置为$2^{k-1}-2=2^{7}-2=126$，排除2种特殊情况，全0和全1，float32中$E$的范围为[-126,127]


### 规格化值：指数位非特殊情况(全0或者全1)，有效数定义为$M=f+1$，f为尾数转小数

### 非规格值：指数位全为0，有效数定义为$M=f$，f为尾数转小数
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/dbdbc78b37804f9da6798c3c404dd5af.png){: referrerpolicy="no-referrer" }
### 无穷值：指数位全为1，但是`尾数全为0`，`特殊定义值`。

### 非有效数字NaN：指数位全1，但是尾数`非0`，`特殊定义值`。


![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/12fee9eea16e4a758da53ad613ba769e.png){: referrerpolicy="no-referrer" }

### 舍入-rounding：浮点数只能近似表达某些实数，涉及到近似到`具体小数位` / `整数`的问题
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/3e45d677261440dfa181c8ba2cb7f360.png){: referrerpolicy="no-referrer" }

### 浮点数加法：`变为规范数`，对齐指数部分，还原为浮点数表示

### 浮点数的乘法：`变为规范数`，计算重要数的乘法结果，还原为浮点数表示


---


# 机器级别的编程：常见汇编指令-未完待续

# 处理器架构：以Y86-64为例

## 指令集
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/b6356c1c5d2b4d328bac56167d5cdcaf.png){: referrerpolicy="no-referrer" }

## 时序电路执行阶段：取指-译码-执行-内存-写回-更新程序计数器


![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/ed1b34ef271c4feca189679edbdcc3af.png){: referrerpolicy="no-referrer" }
### 取指：从指令内存中根据PC取出指令
### 译码：读取指令类型和操作数
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/09a216e225f74f1fa31d36bc1a1328e3.png){: referrerpolicy="no-referrer" }
### ALU：返回计算结果

# 软件角度优化程序性能
## 循环展开
## 增强并行性
## 程序的局部性：时间局部性和空间局部性
+ 时间局部性：在相邻时间访问同个数据
+ 空间局部性：倾向访问相邻的元素
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/fd7f1a57b7e44e398f55950d4f64a4df.png){: referrerpolicy="no-referrer" }


# 主存储器

## 非易失存储器：断电不会丢失数据
### PROM：只可以被编程一次
### *ROM："只读"存储，实际上`可读可写`。
#### EEPROM：可读可写，例如闪存(手机存储和SSD)。

## 易失存储器：断电会丢失数据
### RAM：随机访问内存
#### DRAM：依靠电容器存储状态，电容器电量会流失，需要`定期刷新`；速度较慢，但容量大
+ ##### 存储单位为单元/超单元，16x8的DRAM芯片表示16个单元，每个单元8个bit
+ 通过内存控制器索引DRAM的supercell，**按照二维结构组织，分别需要行索引和列索引**
+ 每次进行行索引时，会将这一行的supercells全部缓存下来。
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/009aa1df39dd4658a995aad7f44deb48.png){: referrerpolicy="no-referrer" }
+ 可以通过**叠加多个DRAM芯片**的方式**一次性索引更多字节**，例如1字节*8=8字节。
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/2469df4dc8f942c29dc018d541194f66.png){: referrerpolicy="no-referrer" }
### SRAM：使用双稳态晶体管存储状态，不需要定期刷新；速度快但造假昂贵


# 存储器架构：L0(CPU寄存器)-L1/L2(SRAM)-L3(DRAM)-L4+(磁盘或者SSD)
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/4d8ac5e393924b278eb677fc0e563f0a.png){: referrerpolicy="no-referrer" }

## 存储器层次中的"缓存"
### 缓存交换抽象原理：不同级别存储(例如L1和L2)，以`数据块`为单位交换缓存；缓存命中和缓存不命中。
 + 缓存：SRAM，以数据块的形式存储和交换数据

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/c23ec23d2b414139b2152b210bed58e0.png){: referrerpolicy="no-referrer" }
### 缓存未命中：冷启动(启动时无缓存)，映射冲突(`哈希冲突`，相互覆盖)和容量冲突(需要`缓存太多数据`)
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/4ee5b14dfc094c8297b14dba66dc3495.png){: referrerpolicy="no-referrer" }


## 高速缓存存储器的通用架构

### 缓存行与组：$(S,E,B,m)$，S代表组数，E代表缓存行，B代表数据块大小(字节)，m代表内存地址的位数，$t=m-s-e$代表标记位数，用于区分同一组不同缓存

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/6e20641c31934a6cb186c6a596b0b99e.png){: referrerpolicy="no-referrer" }
### 直接映射缓存：$E=1$，每一个组只对应一个缓存行，根据$s$，有效位和标记位$t$确定缓存是否存在
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/71fa7949fb5641b58a14b3708cacea1c.png){: referrerpolicy="no-referrer" }


### 组相联映射缓存：$E>1$，每一个组对应多个缓存行，根据$s$，有效位和标记位$t$对缓存行进行`一一匹配`，确定缓存是否存在。
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/f9deac18db8141aa94d90b24ca8702d4.png){: referrerpolicy="no-referrer" }
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/7226dce5900d4af0948e39d448212578.png){: referrerpolicy="no-referrer" }


### 全相联映射缓存：$S=1$，只有一组，包含$E>1$个缓存行；使用有效位和标记位$t$并行地进行匹配，不需要组数位$s$。例如`TLB快表`。

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/e70e9fefd14b4a83b5d33dee61d481cd.png){: referrerpolicy="no-referrer" }





