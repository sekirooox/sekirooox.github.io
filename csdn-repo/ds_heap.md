@[toc]
# 堆
+ 动态变化的列表

## 应用：动态数组(只能扩大不能缩小)的最大/最小值

# 二叉堆/对顶堆
+ 一个小顶堆和一个大顶堆
+ 特点：**小堆的数据全都大于大堆的数据**，**保持单调性**。
+ 擅长处理第k个大/小的题目，其中**k是动态变化**，**k是动态变化**，**k是动态变化**


## 性质1：在二叉堆中，如果大顶堆有i个元素，则第i个大的元素为大顶堆堆顶元素
要点：
+  推论1：大顶堆的**大小始终等于要维护的动态数组的大小**
## 性质2：条件约束和数量约束，即小顶堆的`最小值`大于`大顶堆`的`最大值`；小顶堆和大顶堆都要存储`特定数量`的元素。
+ **条件约束**：`max(big)<=min(small)`
+ **数量约束**：`size(big)=size(small)+1`(奇数)和`size(big)=size(small)`(偶数)
+ 条件约束的实现：确保调整两个堆，**互相搬运一次堆顶元素**，例如以下代码故意搬运big的堆顶元素到small中，然后再通过数量约束保证small也会搬运至少一次堆顶元素到big中。
### 满足条件约束：强制调整两个堆
```cpp
void adjust(){
        // 强制调整小顶堆
        if(big.size()){
            int v=big.top();
            big.pop();
            small.push(v);
        }
        // 根据当前大小n,调整两个堆.显然至少调整一次big堆
        int mid=n%2==0?n/2:n/2+1;
        while(big.size()<mid&&small.size()){
            int v=small.top();
            small.pop();
            big.push(v);
        }
        // big:mid,small:n-mid
    }
```
## 标准实现

```cpp
class stream{
public:
    priority_queue<int,vector<int>,greater<int>>small;
    priority_queue<int,vector<int>,less<int>>big;
    int n;
    stream(){
        n=0;
    }
    void adjust(){
        // 强制调整小顶堆
        if(big.size()){
            int v=big.top();
            big.pop();
            small.push(v);
        }
        // 根据当前大小n,调整两个堆
        int mid=n%2==0?n/2:n/2+1;
        while(big.size()<mid&&small.size()){
            int v=small.top();
            small.pop();
            big.push(v);
        }
        // big:mid,small:n-mid
    }
    void add(int x){
        // 默认插入到大顶堆
        big.push(x);
        n++;
        adjust();
    }
    void median(){
        if(n%2==0){
            int smalltop=small.top();
            int bigtop=big.top();
            int mid = smalltop+bigtop;
            if(mid%2==0){
                cout<<mid/2<<endl;
            }
            else printf("%.1f\n",mid/2.0);
        }
        else{

            cout<<big.top()<<endl;
        }
    }
};
```

## 应用：动态数组第k个元素


## 例题
### 动态区间大小
> **大顶堆的大小始终等于区间的大小**
+ [黑匣子](https://www.luogu.com.cn/problem/P1801)：
注意：**区间是动态的**，确保从q2中拿回元素保证**q1的大小等于区间大小**。
```cpp
	for (int i = 1; i <= m; i++) {
		q1.push(a[i]);
		while (i == u[utop]) {
			while (q1.size() > utop) {
				q2.push(q1.top());
				q1.pop();
			}
			cout << q1.top()<<endl;
			if (!q2.empty()) {
				q1.push(q2.top());
				q2.pop();
			}
			utop++;
		}

	}
```
+ [中位数](https://www.luogu.com.cn/problem/P1168#submit)：区间动态

```cpp
	for (int i = 1; i <= n; i++) {
		cin >> a[i];
		bq.push(a[i]);
		if ((i + 1) % 2 == 0) {
			int mid = (i + 1) / 2;
			while (bq.size() > mid) {
				sq.push(bq.top());
				bq.pop();
			}
			cout << bq.top() << endl;
			if (!sq.empty()) {
				bq.push(sq.top());
				sq.pop();
			}
		}
	}
```
### 静态区间大小
>**不需要小顶堆！！！不需要小顶堆！！！不需要小顶堆！！！**
+ [P2085 最小函数值](https://www.luogu.com.cn/problem/P2085#submit)：注意利用单调性省时间。
+ [P1631 序列合并](https://www.luogu.com.cn/problem/P1631)
### 应用：k叉树的哈夫曼树/最小最浅生成树
+  [P2168 [NOI2015] 荷马史诗](https://www.luogu.com.cn/problem/P2168#submit)：
+ **k叉哈夫曼树**。注意到深度最浅的时候一定是**只存在度为0(叶子节点)和度为k的节点(满节点)**。
+ 另外最深处可以换一种思路，补充节点，而不是一开始固定合并几个节点。
+ **利用树的性质**：结点数=总度+1->叶子节点数=(k-1)满节点+1，进而确定补充的节点。


```cpp
#include<bits/stdc++.h>
#define MAX_VALUE 1000009
#define mod 1000007
using ll = long long;
using namespace std;
int n, k,res;
ll w,ans,max_depth = 0;
typedef struct node {
	ll val;
	ll depth;
	node(ll a, ll b) :val(a), depth(b) {};
};
class cmp {
public:
	bool operator()(const node& a, const node& b) {
		if (a.val != b.val) {
			return a.val > b.val;
		}
		else {
			return a.depth > b.depth;
		}
	}
};
priority_queue<node, vector<node>, cmp>q;

void printout() {
	while (!q.empty()) {
		cout << q.top().val << " " << q.top().depth << endl;
		q.pop();
	}
}

void solve() {
	cin >> n >> k;
	for (int i = 1; i <= n; i++) {
		cin >> w;
		q.push(node(w,0));
	}
	//哈夫曼编码是一个满k叉树,所有节点的度为0或者k
	//等式有  N=n_0+n_k=0*n_0+k*n_k+1  n_0=(k-1)*n_k+1

	while((n-1)%(k-1)!=0)
	{q.push(node(0, 0));
	n++;
	}

	while (!q.empty()) {
		if (q.size() == 1) {
			cout << ans << endl << max_depth;
			return;
		}
		ll sum = 0, new_depth =INT_MIN;
		for (int i = 1; i <= k; i++) {
			sum += q.top().val;
			new_depth = max(new_depth, q.top().depth+1);
			//cout << q.top().val << " " << q.top().depth << endl;
			q.pop();
		}
		
		ans += sum;
		max_depth = max(max_depth, new_depth);
		//cout << "sum:" << sum << " " << "max_depth:" << max_depth << endl;
		//cout << endl;
		q.push(node(sum, new_depth));
	}
	//printout();
}

```

