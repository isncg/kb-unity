# Boehm-Demers-Weiser 垃圾回收

Unity GC 文档：https://docs.unity.cn/cn/2021.3/Manual/performance-garbage-collector.html

hboehm gc 主页：https://www.hboehm.info/gc/

算法概述：https://www.hboehm.info/gc/gcdescr.html

源码FAQ: https://www.hboehm.info/gc/faq.html

源码：https://www.hboehm.info/gc/gc_source/

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

https://zhuanlan.zhihu.com/p/381859536

https://cloud.tencent.com.cn/developer/ask/sof/115718737

官方文档称具有分代回收功能，但也有论坛帖子明确说它不支持分代

### Deepseek 的分析

Boehm GC 对分代回收的支持是“有条件的、非传统的”。虽然官方文档宣称支持，但其实现方式非常特殊，并且由于性能和维护问题，在现代版本中这一特性几乎被废弃。

⚙️ 特殊实现的机制与限制
Boehm GC 的“分代回收”并非通常意义上将对象划分为年轻代和老年代的做法，而是通过写屏障（write barrier） 技术，并依赖操作系统的虚拟内存保护机制来实现的。
- 依赖虚拟内存支持：这种实现方式对操作系统有严格的要求，这就是官方描述中强调“需要适当虚拟内存支持”的原因。
- 几乎废弃的现状：由于性能和维护上的复杂性，这种基于虚拟内存的实现方式在当代已基本不再使用。例如，在 GCC 的文档中就提到，默认配置是增量分代的，但实际使用中问题很多。

🚫 为何传统分代难以实现：保守式GC的限制
之所以 Boehm GC 无法像 Java 等语言的 GC 那样实现标准的分代回收，其根本原因在于它的保守式垃圾回收（Conservative GC）本质。
- 无法移动对象：保守式 GC 的核心是无法精确区分内存中的值是“指针”还是“数据”（如整数）。因此，为了安全起见，它不能移动任何对象。而移动对象，特别是将存活对象从“年轻代”晋升到“老年代”，是传统分代回收的必要环节。
- 导致技术不兼容：由于无法移动对象，保守式收集器天然就无法与需要移动对象的技术（如内存压缩和标准的分代回收）兼容。这就是许多资料断定 Boehm GC “不支持分代”的理论依据。

## 黑名单
https://www.hboehm.info/gc/papers/pldi93.ps.Z

## 多线程支持

## 线程各自分配

