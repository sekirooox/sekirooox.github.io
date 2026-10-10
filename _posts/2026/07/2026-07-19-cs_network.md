---
title: "计算机基础·计算机网络"
author: MayL
date: 2026-07-19
categories: ["计算机系统与开发", "计算机基础"]
tags: ["计算机网络", "计算机基础", "开发笔记"]
render_with_liquid: false
math: true
description: "本文整理“计算机基础·计算机网络”的核心知识、常用方法与实践注意事项，便于学习复习和开发查阅。"
---

@[toc]
# 网络的模型
## OSI模型：七层模型
+ ### 应用层：向用户提供应用程序服务
+ ### 表示层：对`格式进行转换`，例如`加密/解密`，`压缩和解压缩`
+ ### 会话层：建立和管理`通信双方的会话`，例如`腾讯会议双方的通信`。
+ ### 传输层：提供`进程为单位`的端到端的传输服务。
+ ### 网际层：`不同网络`之间的通信服务，IP协议，路由和转发。
+ ### 链路层：`同一局域网下`的通信服务，例如成帧，`差错检验`，`信道冲突`和`无线网络`。
+ ### 物理层：二进制比特流的传输服务。
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/f333458546f04468ab1332df8654630f.png){: referrerpolicy="no-referrer" }

## TCP/IP模型：只有四层
+ 无链路层

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/381d8ff85d1d487a812044b86de5a4c0.png){: referrerpolicy="no-referrer" }

# 物理层
## *链路类型：全双工，半双工，单工
### 单工：谁能发送、谁能接收，是固定的；数据流只能`沿一个固定方向传输`；应用：家庭电话。
### 半双工：谁发送、谁接收，可以变化，但必须轮流；数据流可以沿两个相反方向传输，但同一时间`只能传输一个方向`的数据流；应用：无限局域网

### 全双工：谁发送、谁接收，可以变化，并且可以同时进行；数据流可以沿两个相反方向传输，同一时间`可以传输相反方向`的数据流；应用：TCP双向连接。

## 信道传输速率
### 奈奎斯特定律 
在理想条件下（带宽受限**无噪声**），指出**码元传输速率**是有上限的，超过此上限会出现严重的码间串扰

### 香农定律
指出了在**有噪声的条件**下，信道的极限传输速率和**信噪比**和**带宽**有关系，如果两者都达到了极限，想要提高速率只能通过让每个码元携带更多的比特信息（换一种编码方式）。 


## 数字调制Modulation：将模拟信号转换数字信号
### 基带传输
+ NRZ编码：0-1编码，无法识别长期的静默0/1
+ #### 曼切斯特编码：将时钟信号叠加到编码中
+ #### 翻转-NRZ编码：0-1编码，编码跳转的信号，仍然无法解决静默问题
+ 4B/5B编码：使用5B信息编码4B信息，存在浪费

### 宽带传输：多路复用技术
+ 时分复用
+ 频分复用
+ 波长复用
+ #### 码分复用技术：共享信道支持同时发送消息


# 链路层：成帧，差错检验，信道冲突和无限网络

## 成帧：区分不同帧
+ 字节技术法：
+ 标志位法：
+ **字节填充**法：
+ 4B/5B编码中增加新的标志
## 差错检验：冗余位技术---汉明码，奇偶校验，循环冗余码
### 奇偶检验：只能检验奇数位。

### 汉明距离：定义为从一个码字转换为另一个有效码字的最短距离，检验和修复的最短位数？
+ d位汉明码：检验**不超过d位**的错误
+ 2d+1位汉明码：修复小于等于d位的错误。理解：不仅要检测出来，并且确定唯一最短路径(**到两个码字的距离有区别)**。


![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/cfc78901981547cebab32fcaacbe7948.png){: referrerpolicy="no-referrer" }
### 循环冗余码：使用多项式除法决定冗余位
+ 给定**生成多项式$G(x)$**，取生成多项式最高位的系数例如4，扩充原始`码字`的位数
+ 进行多项式的除法，得到最后余数，余数的位数**不超过生成多项式的最高系数+1**(注意0位)
+ 使用该结果填充**冗余位**。
+ 如果没有差错，则**接受的数据应该能整除生成多项式**；否则则说明出现差错。

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/f5d8e1f2d91c41f38c3518d07e630da8.png){: referrerpolicy="no-referrer" }

## 流量控制：滑动窗口协议
### 重要的点
#### 捎带确认：在传输数据时顺便传输ACK确认，不单独发送一个ACK确认报文
#### 累计确认：ACKx表示对于前x个报文的累计确认
#### 窗口大小：$W_s+W_R\leq2^{m}$, $m$表示用于编码报文的位数；防止：窗口移动，`相同编号`报文带来的歧义问题。
+ 假设m=2，那么**窗口的编号为0,1,2和3.**
+ 假设发送方窗口为1，接受为4，4+1>4，出现冲突的问题
+ 发送方发送1，但是出现拥塞问题未及时传递。此时重新发送1，正常接受，然后接连发送2，3，4和1。此时**滞留的1号报文和新发送的1号报文都传递来了**，就会出现二义性的问题。
+ 注意此时**接受方窗口已经移到了新的1号了**。

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/f5409e2411e34b6c8292531a43e82122.png){: referrerpolicy="no-referrer" }
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/36cabfa531b6431993dad6c417d54971.png){: referrerpolicy="no-referrer" }


### 停止-等待 Stop-and-wait：接受和发送窗口都为1
### 退回N步 Go-back-N：接受窗口为1，发送窗口为N
+ 接受方返回的是一个**累计的确认**
### `选择性重传 Selective Repeat`：接受和发送窗口数大于等于1
+ 只是**选择性的重传**特定的报文(packet)


## 链路利用率的计算方式

## 传输时延和传播时延
+ 传输时延：数据**从网卡推送到物理链路**/从链路下载到网卡的时间，例如以太网为10Mbps
+ 传播时延：二进制数据流从**物理链路**一段传播到另一端的时间。

## MAC层：媒体访问控制，数据链路层的一个子层

### 信道划分：静态划分和动态划分
#### 静态划分：时分/频分/码分复用信道
#### 动态划分：CSMA/CD协议

### CSMA/CD协议：载波监听，如果`有冲突不发送`；冲突避免，发送后还需要`检测冲突`，如果`有冲突随机等待`并且重发

#### 冲突检测时间和如何避免`冲突检测不及时`：规定数据大小，约束帧的`传输时间`>信道上的往返`传播时延`

+ 冲突检测时间：**往返传播时间** RTT


### 以太网：802.3
#### 以太网帧的结构
+ 长度为1536个字节左右
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/21cf3aa4b06c463c9f96a5ee677dc887.png){: referrerpolicy="no-referrer" }

#### MTU：单个网络中最大传输单元，表示为`以太网帧的负载`
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/ae8d3489b7a54cc292eea8e4886f9e87.png){: referrerpolicy="no-referrer" }
##### 透明传输：每一个路由器负责包裹的`拆分和整合`

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/d8e5ec413fa74a7abb2d4b1f78022e78.png){: referrerpolicy="no-referrer" }

##### 非透明传输：每一个路由器`只负责包裹的拆分`，整合工作在接受方

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/d2db31c5ed3b4c5a8c1929357a62c07f.png){: referrerpolicy="no-referrer" }


#### 以太网的`传输`速率：标准以太网10Mbps，快速100Mbps等


### WIFI：802.11
#### 连接过程：与基站连接，分为积极连接(主动探索基站)，消极连接(基站主动介绍)

#### *隐藏终端和暴露终端问题
+ 隐藏终端：传输方向相反，未发现覆盖的情况，以为信道空闲，同时发送产生冲突。
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/60e5ce5ee7444627b2653654cf6be195.png){: referrerpolicy="no-referrer" }

+ 暴露终端：传输方向相反**但并未覆盖**。误以为产生冲突，放弃发送。


![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/15750cb9497247e8a4581bf576c81db0.png){: referrerpolicy="no-referrer" }


# 网络层

## IP协议：互联网协议
IP协议（Internet Protocol，网际协议）是TCP/IP体系中的网络层协议，主要负责：
+ IP地址**分配与寻址**
+ **路由选择算法**
+ IP**数据报封装**
+ 数据分片与重组
+ 无连接的数据报传输
+ TTL控制防止循环
+ 标识上层协议（TCP/UDP等）

### IPv4地址：32位，0.0.0.0-255.255.255.255，8bit/1字节为一组，分别私有和公开IP地址。
### IP数据报封装
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/3173077deda2419a9103511baa846c2f.png){: referrerpolicy="no-referrer" }
+ DF：**不允许分片**
+ MF：该分片**是否为最后一个分片**，也就是"还有没有其他分片"
+ Offset：该分片所处偏差(前n-1个分片的累计)/8。**注意不是最后真实的偏移量**，**因为13位<16位，所以一个单位代表8bit，还需要单独乘以8**。
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/6ed5b8243cf04e718ff88c2c3a45ff2e.png){: referrerpolicy="no-referrer" }

### IP寻址：网络id+主机id---分类寻址，子网寻址，CIDR

#### 分类寻址：网络id和主机id的地址范围进行分类
+ **前几位是固定**，避免出现相同前缀的网络
+ 分类标准是：**网络id的范围增大，但主机id的范围缩小**。
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/58d9f17ddb564fa08a5e8be78fd96a49.png){: referrerpolicy="no-referrer" }
#### 子网寻址：确定网络id+子网id+主机id，固定/可变子网划分，默认网关和`子网掩码`
+ 出了网络id后，还需要进一步划分不同的子网id，最后才是主机id
+ 固定子网：**子网的大小是完全一致的**
+ 可变子网：根据所需要的主机数(例如8-3位，16-4位)，定义子网的大小。

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/ab22fee054824c698ad7ded4555aeae8.png){: referrerpolicy="no-referrer" }

##### 寻址方式
+ 目标地址&子网掩码，和当前网络&子网掩码，比较目标地址和当前网络是否属于同一个局域网下。
+ 如果不属于，则**发送给默认网关(路由器)**，**由默认网关决定下一跳**。
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/91c6ca8c64b742e48c5b020ec088b392.png){: referrerpolicy="no-referrer" }


#### CIDR：无分类域间路由，只区分前缀id和主机id，路由聚合确定`共同前缀和掩码`和最长前缀匹配确定`网络`
+ 不区分网络，子网和主机。
+ **只区分前缀id和主机id**。使用206.0.68.0/22**中的22标记前缀长度**。

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/936a3997aad6409597b3f28df3dcf1de.png){: referrerpolicy="no-referrer" }
##### 路由聚合
+ 多个IP地址**取共同前缀**，作为**前缀ID**。
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/a04eba31dcce4e899da90b8929d3ab4d.png){: referrerpolicy="no-referrer" }

##### 最长前缀匹配：进行子网掩码匹配时，取最长匹配
+ 多个IP地址和路由表项匹配时，**优先选择最长匹配的一项**作为下一跳。
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/4ceed4ac82eb4fd992a430312d14909e.png){: referrerpolicy="no-referrer" }

### NAT：网络地址翻译
+ 路由器会将用户的**私有地址**翻译为互联网上的**公开地址**。
#### 私有地址和公开地址
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/92c6d964df6f49e0889b3416f62f03cf.png){: referrerpolicy="no-referrer" }
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/6dd3be82fdc243c5a01433ba488520d9.png){: referrerpolicy="no-referrer" }

## 互联网控制协议
### ICMP：互联网控制消息协议，用于`错误报告`和`回复请求`(`ping`命令)

### ARP：MAC地址寻求协议，用于查询某个IP地址对应的MAC地址，如果不属于一个局域网，则改为`发送默认网关的ARP请求`。
+ 局域网内广播ARP请求
+ 如果局域网内有对应IP地址，则该主机会回复ARP请求
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/d1d7572523fe4491896802216afcec72.png){: referrerpolicy="no-referrer" }
+ 如果没有人回复，则会发送对于默认网关的ARP请求，**将包裹发送至网关处理**。


### DHCP：动态主机控制协议，为每一个主机分配IP地址，子网掩码和默认网关等网络必备信息。
#### 本地DHCP服务器和DHCP缓存
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/ec4aa64b7bb045c78dce95dde6f18aac.png){: referrerpolicy="no-referrer" }
### 路由算法
#### 路由和转发的含义
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/b5a8ac4998d64602b476980190ec1482.png){: referrerpolicy="no-referrer" }

#### 泛洪：与广播类似，对于不同局域网的概念，保证不会出现环


#### 距离矢量算法：分布式的Bellman-Fold算法，代表：路由信息算法
+ 每一个路由器定期向周边节点**发送/接受路由表**。路由表关于与其他节点的距离信息
+ **运行Bellman-Fold算法中的松弛操作**，决定更新到哪一个路由器的距离。

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/ba74ce4bd7b0457882d53afcbb498417.png){: referrerpolicy="no-referrer" }
##### 缺点：坏消息传递慢，被相邻节点误导
#### 链路状态算法：全局式的Dijsktra算法，代表：开放最短路径算法
+ 每一个节点将其位置的拓扑信息，**定期泛洪到网络上每一个节点**。
+ 所有节点都会定期这么做，使得任意一个节点都维护当前网络的拓扑信息。
+ 运行dijsktra算法获得最短路径。
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/9d0c5c9db5a947a68e873ace3e07738f.png){: referrerpolicy="no-referrer" }
##### 缺点：维护全局拓扑结构的代价昂贵

#### 边界路由算法：自治系统，内层边界路由算法，外层边界路由算法
##### 自治系统：不同路由器所连接的一个`网络整体`
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/3eaa41652e5e4ec6a61fbe705c987055.png){: referrerpolicy="no-referrer" }


##### 内层边界路由算法：每一个网络整体所使用的路由算法，例如OBPF和RIP算法

##### 外层边界路由算法：`边界路由器`，不同网络整体所使用的路由算法，`公平性且非最优`
#### 网际层中的多播和广播(泛洪)

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/790b6e724c23417f8355eaa93e037eca.png){: referrerpolicy="no-referrer" }


# 传输层：提供进程级端到端的服务
## 网络套接字-Socket：应用层与传输层通信的一个抽象接口，包括IP地址(主机)+端口号(进程)
## 端口号：知名端口号
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/882bd6409ff04df5a664be9f605f69ba.png){: referrerpolicy="no-referrer" }

## TCP：面向连接，基于字节流的服务
### 数据格式：TCP Segment-TCP段
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/de17c359afff4db1a62da7c0d8f94db4.png){: referrerpolicy="no-referrer" }
### TCP Header结构：端口号，SYN/FIN/ACK表示，序列号字段
#### 序列号-Sequence Number：负载中`第一个字节`的序号，例如Seq=100，表示负载中下一次传递的第一个字节序号为100
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/c90d07ffd2f7448fb8b0690d9ea6dcd5.png){: referrerpolicy="no-referrer" }

#### 确认码-ACK Number：期待接受的`下一个字节`的序号，例如序号101，表示预期接受导的下一个字节序号为101
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/99a91e6f65b04c0c99d841fd3f21d9c1.png){: referrerpolicy="no-referrer" }

### TCP连接建立：三次握手，SYN占据一个字节
+ 客户发送TCP建立请求：SYN=1
+ 服务器返回ACK=1，并且也请求建立TCP连接，SYN=1（**此时客户端-服务器的传输路径成立**）
+ 客户返回ACK=1（**此时服务器-客户端的传输路径成立**）
+ 只有**最后一步可以通过捎带ACK的方式实现**。
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/0ad6e65fba284091bbfdb254a92c4ae2.png){: referrerpolicy="no-referrer" }

#### 为什么不能改为二次握手：`滞留的`TCP连接建立请求

### TCP连接取消：四次挥手，FIN占据一个字节
+ 客户端发起TCP连接取消请求FIN=1
+ 此时服务器返回ACK=1，**客户端-服务器的传输连接断开**。
+ **但是服务器可能还有数据发送给客户**，因此暂不断开服务器-客户端的传输连接
+ 数据传输完毕后，服务器发起TCP连接取消请求FIN=1
+ 最后客户端返回ACK确认。**双向的连接都断开**。
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/95281fb5c15e40e6a449200a6ce84810.png){: referrerpolicy="no-referrer" }

#### 为什么不能改为四次挥手：服务器可能还有数据需要传输给客户
### TCP流量控制
#### 流量控制的动机：发送方和接受方的发送/接受速率不匹配
#### 滑动窗口协议：序列号，剩余接受窗口大小
+ 发送方正常发送数据和序列号
+ 接受方返回确认号和**剩余的窗口大小(WIN=2048)**

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/5ee25b08151348268966380b763cce06.png){: referrerpolicy="no-referrer" }

### TCP超时时间管理：确认合适的超时时间，SRTT，RTO等

### TCP拥塞控制：快启动，拥塞避免，快重传，快回复
#### 最大段长-MSS：拥塞控制中，数据传输的基本单位


![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/fb7634fbc3d94f2baa1872944edf2ba4.png){: referrerpolicy="no-referrer" }

#### MTU和MSS：帧的负载的长度=IP包裹的总长度=IP头+TCP段=IP头+TCP头+TCP段

#### 快启动：小于拥塞阈值时，每返回一个MSS的`ACK`，窗口大小+1，乘法增加
+ 在拥塞窗口小于拥塞阈值时，每收到一个ACK就增加窗口大小
#### 拥塞避免：大于等于拥塞阈值时，每一个`RTT`，窗口大小+1，线性增加

#### 快回复：遇到连续三个重复的ACK时，窗口和阈值缩小为`一半`
#### 快重传：遇到连续三个重复的ACK时，直接重传`丢失的TCP段`

#### 超时处理：阈值变为一半，窗口变为1

#### TCP Reno和Tahoe：前者包含快速重传和回复的逻辑
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/22a9b353f9004d8f871934eca09dddbc.png){: referrerpolicy="no-referrer" }

### QUIC：快速UDP网络连接


## UDP：无连接，不可靠的连接服务
### UDP数据报的格式
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/1e73097219c84adebdc88de980600b89.png){: referrerpolicy="no-referrer" }


# 应用层
## 网络应用架构/模型-Application Architecture：CS模式和P2P模式
### CS模式：架构简单，方便管理，随时可提供服务；不易扩展，服务器压力大
### P2P模式：架构复杂，不方便管理，消息传递复杂；容易扩展，分布式，扩展性强




## 域名系统-DNS：网址-IP地址
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/c98430ab08d14e3ea98c0d78c93f1666.png){: referrerpolicy="no-referrer" }

### 根服务器：提供顶级域名服务器的IP地址

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/605a0d7a2c854276af9dbc2d676d04f6.png){: referrerpolicy="no-referrer" }

### 顶级域名服务器：包含edu/com等顶级域名的服务器
### 权威服务器：包含所需域名的名称服务器，查询时`直接返回IP地址`
### DNS缓存和本地DNS服务器：包含一些常用域名缓存的本地服务器

### 迭代查询和递归查询
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/1c615009d3e5414eb08c1c780688455a.png){: referrerpolicy="no-referrer" }

## URL：统一资源定位符

## HTTP/HTTPs
### Cookie和Session
+ Cookie是在HTTP回应中设置的，**存放在用户本地**。
+ Session ID对应Cookie ID，存储用户的个性化信息，**存放在服务器端**。
+ 均是为了解决**HTTP无状态**这一特点。
## HTML

## 邮件系统：用户代理和邮件服务器
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/f7690f848b4a46e0b9fbc39f1b20fe6e.png){: referrerpolicy="no-referrer" }

### 发送协议：简单邮件传输协议-SMTP，`只能发送文本类数据`；MIME，可以`发送多媒体数据`

### 接受协议：POP3协议，IMAP-允许用户以文件夹形式管理邮件
# 网络设备

## 集线器：存在冲突，信道共享，需要开启CSMA/CD协议
## 交换器和网桥：不存在冲突，信道独立，分割`冲突域`

## 直接转发 / 存储转发机制
+ 直接转发：只**读取/下载目的地址(MAC地址)**，然后根据MAC地址将数据转发到下一个链路
+ 存储转发：将**数据暂时缓存下来**，**期间检查目的地址，是否出现差错**，然后再进行转发。

| 设备         | 典型方式           |
| ---------- | -------------- |
| 集线器 Hub    | 直接转发（物理层）      |
| 交换机 Switch | 主要是存储转发，**也可直接转发** |
| 路由器 Router | 必须存储转发         |


### 为什么路由器需要存储转发：根据IP地址查找路由表(非根本)，`检验数据`，`修改条数`,等
## 路由器：分割`不同网络`/`广播域`
### 路由功能：交换控制信息，更新路由表
### 转发功能：根据路由表+路由算法决定下一跳







