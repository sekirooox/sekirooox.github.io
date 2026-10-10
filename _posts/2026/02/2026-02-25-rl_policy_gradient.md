---
title: "强化学习·策略学习-策略梯度定理和Reinforce算法"
author: MayL
date: 2026-02-25
categories: ["大语言模型与强化学习", "强化学习"]
tags: ["强化学习", "策略梯度", "人工智能", "学习笔记"]
render_with_liquid: false
math: true
description: "本文围绕“强化学习·策略学习-策略梯度定理和Reinfor…”梳理核心概念、算法思路与实践要点，便于系统学习和后续查阅。"
---

@[toc]
# 策略学习方法
策略参数化：
The idea is to parameterize the policy. For instance, using a neural network $\pi(\theta)$, this policy will output a probability distribution over actions (stochastic policy).
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/3c7ca8a9b2f045b7845bf6bd94b16b6f.png){: referrerpolicy="no-referrer" }
接受一个状态网络输出的是**动作的分布**。

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/15a81174b4224ddbb3cd49fc00bd89b7.png){: referrerpolicy="no-referrer" }
## 策略学习 vs 价值学习
策略梯度方法能够学习出一种随机策略，而价值函数则无法做到这一点。
这会产生两个后果：
+ 我们无需手动进行**探索与利用之间的权衡**。由于我们输出的是针对行动的概率分布，因此智能体能够在探索状态空间时避免总是遵循相同的路径。
+ 我们还解决了**感知混叠的问题**。感知混叠指的是当两种状态看起来（或实际上是）相同，但需要采取不同的行动时的情况。
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/a8eec3045eec4f41949a262e802ddb27.png){: referrerpolicy="no-referrer" }

当然，策略梯度方法也存在一些缺点：
+ 通常，策略梯度方法会收敛到局部最大值而非全局最优值。
+ 策略梯度方法进展较为缓慢，是逐步进行的：训练过程可能会更耗时（效率低下）。
+ **策略梯度方法可能会存在高方差**。我们将在“演员-评论家”单元中了解其原因以及如何解决这一问题。
>偏差和方差的概念：**偏差一般指的是预测误差**，如果偏差比较低，说明方差一般比较高；


# 策略梯度方法
## 目标函数
对于给定参数化策略，我们希望在这个策略下，**最大化所有轨迹的期望均值**。

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/c64fe41e0de7430c8151deb22c06fd10.png){: referrerpolicy="no-referrer" }
这个等价于：
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/b863964bc4234783afde124938dcd7ae.png){: referrerpolicy="no-referrer" }
其中，**每一个轨迹给定的概率分布**为(全概率公式)：
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/d530d6a334c4457d81a82b1ebbd5d53a.png){: referrerpolicy="no-referrer" }
## 策略梯度定理
揭示了目标函数的梯度等价于以下公式：

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/8fffd19aab224e998458472f7bb3cffc.png){: referrerpolicy="no-referrer" }
### 证明过程
+ 首先将梯度提进去，然后提出一个$P(\tau;\theta)$，拼凑一个$logf(x)$求导的公式

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/c22b517fd786460589d1bf2184b28e07.png){: referrerpolicy="no-referrer" }
+ 根据期望定义将上面的公式重新还原为期望
+ 对于这个期望，我们可以可以利用**大数定理对其采样求解其均值**。
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/7cbb4d9515dd4239b8f57c294d725d46.png){: referrerpolicy="no-referrer" }
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/52e7c6bd76604cd398429e75d029bc67.png){: referrerpolicy="no-referrer" }
+ 我们带入$P(\tau;\theta)$的定义，然后老老实实求梯度，发现除了$\pi(a_t\mid s_t)$之外，所有项不包含$\theta$，因此直接消去。
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/611889abd6224ee4969d8a269ec984f1.png){: referrerpolicy="no-referrer" }

# 蒙特卡洛MC Reinforce算法
我们得到了目标函数的梯度，然后运行梯度上升来最优化我们的策略函数。
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/8d0cbaf7d74a41dc80ab8e3f10584b35.png){: referrerpolicy="no-referrer" }
一般来说收集多个轨迹来计算平均梯度。

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/a148550510ae4072a27308621b2b6d1a.png){: referrerpolicy="no-referrer" }
## 策略梯度方法流程：
+ **经历一次完整的动作序列后才能开始更新。**
+ 对于好的动作序列，增加其动作选择的概率，对于不好的动作，降低其动作选择的概率。
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/621a4024af29449ba33824129b2b974a.png){: referrerpolicy="no-referrer" }
## 实现
我们需要的是：
$$
\begin{align}
\sum_t{\nabla_\theta\log\pi_\theta(a_t^{(i)}\mid s_t^{(i)}){R(\tau^{(i)})}}
\end{align}
$$
然后用其进行梯度上升。
这转换为利用**torch对以下函数进行优化**(会自动求梯度并且执行梯度下降)

$$
\begin{align}
-\sum_{t}{\log\pi_\theta(a_t^{(i)}\mid s_t^{(i)}){R(\tau^{(i)})}}
\end{align}
$$

### Reinforce算法的改进：使用$G_t$替代准确的$R(\tau)$
+ 公平性：$R(\tau)$表示某轨迹的累积折扣奖励，对于所有的状态的动作都给相同的 $R(\tau)$ 是不公平的，因为前面的动作更加重要，因此采用$G_t$为每个动作概率根据执行顺序赋予不同的权重进行优化。
+ 方差改进：$R(\tau)$偏差为0，所以方差必然很大。$G_t$作为当前动作的一种估计，以提高偏差为代价降低方差， 进而增强稳定性。

**我们最终需要优化的方程为：**
$$
\begin{align}
\sum_{t}{\log\pi_\theta(a_t^{(i)}\mid s_t^{(i)}){G_t}}
\end{align}
$$
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/ee70599bed5c4b66b16bf162e2954ee1.png){: referrerpolicy="no-referrer" }

### 参数化策略代码

```python
class Policy(nn.Module):
    def __init__(self, s_size, a_size, h_size):
        super(Policy, self).__init__()
        self.fc1 = nn.Linear(s_size, h_size)
        self.fc2 = nn.Linear(h_size, a_size)

    def forward(self, x):
        x = F.relu(self.fc1(x))
        x = self.fc2(x)
        return F.softmax(x, dim=1)
    
    def act(self, state):
        state = torch.from_numpy(state).float().unsqueeze(0).to(device)
        probs = self.forward(state).cpu()
        m = Categorical(probs)# torch.distribution的对象
        action = m.sample()# idx, log_prob[idx]
        return action.item(), m.log_prob(action)
```

### Reinforce训练代码

```python
def reinforce(policy, optimizer, n_training_episodes, max_t, gamma, print_every):
    # Help us to calculate the score during the training
    scores_deque = deque(maxlen=100)
    scores = []
    # Line 3 of pseudocode
    for i_episode in range(1, n_training_episodes+1):
        saved_log_probs = []
        rewards = []
        state = env.reset()# TODO: reset the environment

        # Line 4 of pseudocode
        for t in range(max_t):
            action, log_prob = policy.act(state)# TODO get the action
            saved_log_probs.append(log_prob)
            state, reward, done, _ = env.step(action)# TODO: take an env step
            rewards.append(reward)
            if done:
                break 
        scores_deque.append(sum(rewards))
        scores.append(sum(rewards))
        
        # Line 6 of pseudocode: calculate the return
        returns = deque(maxlen=max_t) 
        n_steps = len(rewards) 
        # Compute the discounted returns at each timestep,
        # as the sum of the gamma-discounted return at time t (G_t) + the reward at time t
        
        # In O(N) time, where N is the number of time steps
        # (this definition of the discounted return G_t follows the definition of this quantity 
        # shown at page 44 of Sutton&Barto 2017 2nd draft)
        # G_t = r_(t+1) + r_(t+2) + ...
        
        # Given this formulation, the returns at each timestep t can be computed 
        # by re-using the computed future returns G_(t+1) to compute the current return G_t
        # G_t = r_(t+1) + gamma*G_(t+1)
        # G_(t-1) = r_t + gamma* G_t
        # (this follows a dynamic programming approach, with which we memorize solutions in order 
        # to avoid computing them multiple times)
        
        # This is correct since the above is equivalent to (see also page 46 of Sutton&Barto 2017 2nd draft)
        # G_(t-1) = r_t + gamma*r_(t+1) + gamma*gamma*r_(t+2) + ...
        
        
        ## Given the above, we calculate the returns at timestep t as: 
        #               gamma[t] * return[t] + reward[t]
        #
        ## We compute this starting from the last timestep to the first, in order
        ## to employ the formula presented above and avoid redundant computations that would be needed 
        ## if we were to do it from first to last.
        
        ## Hence, the queue "returns" will hold the returns in chronological order, from t=0 to t=n_steps
        ## thanks to the appendleft() function which allows to append to the position 0 in constant time O(1)
        ## a normal python list would instead require O(N) to do this.
        for t in range(n_steps)[::-1]:# inverse order
            disc_return_t = (returns[0] if len(returns)>0 else 0)
            returns.appendleft(gamma*disc_return_t+rewards[t]) # TODO: complete here        
       
        ## standardization of the returns is employed to make training more stable
        eps = np.finfo(np.float32).eps.item()
        
        ## eps is the smallest representable float, which is 
        # added to the standard deviation of the returns to avoid numerical instabilities
        returns = torch.tensor(returns)
        returns = (returns - returns.mean()) / (returns.std() + eps)
        
        # Line 7:
        policy_loss = []
        for log_prob, disc_return in zip(saved_log_probs, returns):
            policy_loss.append(-log_prob * disc_return)# G(tau)
        policy_loss = torch.cat(policy_loss).sum()
        
        # Line 8: PyTorch prefers gradient descent 
        optimizer.zero_grad()
        policy_loss.backward()
        optimizer.step()
        
        if i_episode % print_every == 0:
            print('Episode {}\tAverage Score: {:.2f}'.format(i_episode, np.mean(scores_deque)))
        
    return scores
```
