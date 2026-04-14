# Boehm-Demers-Weiser 垃圾回收

https://docs.unity.cn/cn/2021.3/Manual/performance-garbage-collector.html
https://www.hboehm.info/gc/
https://www.hboehm.info/gc/gcdescr.html
https://www.hboehm.info/gc/faq.html
https://www.hboehm.info/gc/gc_source/

注：hboehm 页面内容基本上就是吹自己的 acm 论文，不好啃。知道有哪些内容就行了。Unity 和 Mono 不见得就一点不改照搬实现，得看源码

### 标记-清扫（mark-sweep）算法的4个阶段
1. 准备：每个对象拥有标记位，标记为清空，所有对象暂定不可达
2. 标记：通过指针链标记所有可达对象
3. 清扫：从堆中扫描不可达即为标记的对象，添加到释放列表中以被复用
4. 释放：不可达的、且注册为待释放的对象进入释放队列

## 标记阶段

### 根集

- 各寄存器
- 各线程栈
- 各静态变量集

### 增量标记
每次调用 GC_mark_some 函数会进行少量标记，GC_mark_state 记录着标记进度：
- MS_INVALID：存在可到达的未标记对象，进入下一步
- MS_PUSH_UNCOLLECTABLE：接下来需要把不可回收对象、根集压入标记栈，标记它们所有从它们开始的可达对象
- MS_ROOTS_PUSHED：标记栈已空，意味着连根集对象也入栈了。标记已完成进入下一步
- MS_NONE：可达对象已完成标记

在 MS_ROOTS_PUSHED 状态下，核心标记过程函数 GC_mark_from 在标记栈填满后开始频繁调用直至清空栈。该过程设计为有限数量的标记，供增量回收器利用。

Q: 增量扫描间隔期间对象引用结构变化，那标记栈是不是失效了？应该会有写屏障之类的处理吧

### 标记栈栈帧
栈帧带有候选指针区间。回收器需要决定一个候选指针是否为堆内存块的地址
（步骤看不懂）

## 清扫阶段

## 释放阶段

## 分代和脏标记
http://www.acm.org/pubs/citations/proceedings/pldi/155090/p197-boehm/
https://www.hboehm.info/gc/papers/pldi91.ps.Z


## 黑名单
https://www.hboehm.info/gc/papers/pldi93.ps.Z

## 多线程支持

## 线程各自分配

