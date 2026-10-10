# 核心思想
+ 本质都是讲原本$O(n^2)$的算法优化为$O(n)$
+ **都是利用使用一个容器维护某段区间，节省一段for循环，同时这段区间维持单调性**
+ **出发点：删除容器内的冗余元素。**

# 理解
都是删除冗余元素
都是往容器末尾添加冗余元素，从末尾取需要的元素。
对于当前元素也要考虑到冗余元素

# 单调栈
例题：
+ [830. 单调栈](https://www.acwing.com/problem/content/832/)：
+ [739. 每日温度](https://leetcode.cn/problems/daily-temperatures/description/)：相似题目
## 应用：第1个小于/大于当前数的数
+ 暴力做法是两个for循环，第一层循环表示当前数，第二层循环用于搜索第一个小于当前数的数。
+ 使用容器存储第二个for循环中遍历的数，意味着我们可以去掉一重for循环。
   + 方便查询目标数
   + 因此我们想到可以**优化容器内的数据存储，删除冗余的数据**。
+ **删除容器中的冗余元素**：我们发现如果i<j,且a[i]>a[j]，那么a[i]一定是当前容器中的冗余元素，我们就可以删去它。**此时容器末位的元素就是我们需要的第1个小于当前数的数。(如果容器为空，则返回-1)**
+ 然后按照这个规则，容器内的元素就变成单调递增了，然后我们用栈方便我们的实现。
+ [84.柱状图中最大的矩形](https://leetcode.cn/problems/largest-rectangle-in-histogram/)
```cpp
int n, a;
stack<int>st;
void solve() {
	cin >> n;
	for (int i = 1; i <= n; i++) {
		cin >> a;
		while (!st.empty() && st.top() >= a) {
			st.pop();
		}
		if (st.empty())cout << -1 << " ";
		else {
			cout << st.top() << " ";
		}
		st.push(a);
	}
}
```


# 单调队列
例题：[154. 滑动窗口](https://www.acwing.com/problem/content/156/)
## 应用：滑动窗口最大/最小值，动态变换数组的最小和最大
+ 暴力方法遍历每一个窗口和窗口内元素
+ 尝试使用一个容器维护当前窗口：
   + 这个容器需要实现**窗口移动时容器大小减少以保持一致**
   + 方便查询最大值或者最小值。
   + 因此我们想到可以**优化容器内的数据存储，删除冗余的数据**。
+ 删除冗余数据：对于最小值的情况，j>i,a[j]<a[i]，那么之后窗口a[i]一定不会被选中，因此直接删除a[j]，由此我们得到一个单调递增的数组。此时，**头部元素就是最小值**。
+ 最后使用队列方便我们的实现。
```cpp
int n,k,a[1000009];
deque<int>q;
void solve() {
	cin >> n >> k;
	for (int i = 1; i <= n; i++) {
		cin >> a[i];
	}
	// min
	for (int i = 1; i <= n; i++) {
		if (i >= k + 1) {
			if (q.size()&&q.front() == a[i - k]) {
				q.pop_front();
			}
		}
		while (q.size() && q.back() > a[i]) {
			q.pop_back();
		}
		q.push_back(a[i]);
		if (i >= k) {
			cout << q.front() << " ";
		}
	}
	cout << endl;
	q.clear();
	// max
	for (int i = 1; i <= n; i++) {
		if (i >= k + 1) {
			if (q.size() && q.front() == a[i - k]) {
				q.pop_front();
			}
		}
		while (q.size() && q.back() < a[i]) {
			q.pop_back();
		}
		q.push_back(a[i]);
		if (i >= k) {
			cout << q.front() << " ";
		}
	}
	cout << endl;
}
```
## 应用：最小栈，只是弹出元素的位置改变了

```cpp
class MinStack {
private:
    stack<int> st;
    stack<int> st_min;

public:
    MinStack() {
        
    }
    
    void push(int value) {
        st.push(value);

        if (st_min.empty() || value <= st_min.top()) {
            st_min.push(value);
        }
    }
    
    void pop() {
        if (st.top() == st_min.top()) {
            st_min.pop();
        }

        st.pop();
    }
    
    int top() {
        return st.top();
    }
    
    int getMin() {
        return st_min.top();
    }
};

/**
 * Your MinStack object will be instantiated and called as such:
 * MinStack* obj = new MinStack();
 * obj->push(value);
 * obj->pop();
 * int param_3 = obj->top();
 * int param_4 = obj->getMin();
 */
```

