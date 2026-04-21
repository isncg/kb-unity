# SGen

https://www.mono-project.com/docs/advanced/garbage-collector/sgen/
https://www.mono-project.com/docs/advanced/garbage-collector/sgen/working-with-sgen/

## 三个堆
- Nursery: Young Generation
- Major Heap: Old Generation
- Large Object Space

### Nursery
- 对象初始分配
- 大小为 4MB
- 内存耗尽时开始 GC

GC: 停止所有线程，存活对象移动到 Major Heap，清空 Nursery

### Major Heap
- 对象大小不超过 SGEN_MAX_SMALL_OBJ_SIZE （8KB）
- 对象使用 buckets 存放，避免碎片
- buckets 碎片率达到 66% 是开始压缩拷贝（copying evacuation）, 通过 evacuation-threshold 设置
- 使用标记、清扫复制 GC
- 内存耗尽时开始 GC, 无法释放足够内存时可向系统申请更多内存

## 并发

SGen 默认并发，标记和清扫阶段都可以并发执行。

### 并发标记

两次暂停：
- 初始暂停：标记所有根对象，然后恢复。启动一个worker线程继续标记整个 major heap
- worker 结束后暂停（没说暂停时做了什么）

### 并发清扫

并发清扫期间，未完成清扫的内存块不可用于新分配

