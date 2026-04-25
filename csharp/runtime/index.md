# 脚本

## GC

https://cloud.tencent.cn/developer/article/1026103?from=15425

### Boehm-Demers-Wiser, Boehm

Boehm 是 Mono 最初使用的 GC，这是一种保守设计的GC算法，它无法确定给定值到底是指针还是标量，因此它总是假设给定值是指针，并且将相关联的对象标记为存活状态。不仅会错误导致大块内存无法分配，同时还使得压缩可用空间这项工作变得异常艰难。


### Simple Generational GC, SGen

Mono 3 默认 GC 是 SGen，它使用精确的分代式垃圾收集器，类似于 .NET 版本的 CLR。SGen垃圾收集器使用两生代而非 .NET 中的三个，但像 .NET 一样对于大对象使用独立的堆。

**目前 SGen 仅对小游戏平台适配。**

### Boehm vs SGen

https://docs.unity.cn/cn/tuanjiemanual/Manual/MiniGameSGenGC.html

|     | SGen | Boehm |
| --- | --- | --- |
| 并发性 | 支持高并发，可以同时进行垃圾收集和应用程序线程的执行。 | 不支持并发执行。 |
| 内存扫描精度 | 大部分是精确扫描（堆栈和寄存器是保守扫描）。 | 采用保守扫描，所以不能 copy 。 |
| 内存碎片 | 因为大部分是精确扫描内存，所以可以进行 copy ，减少内存碎片。 | 不能避免内存碎片。 |
| 内存管理 | 针对 Nursery 年轻代使用复制回收算法，针对 Major Heap 老年代使用标记清除算法。 | 采用基于标记清除的算法。 |
| 性能 | 采用分代回收，大部分只需处理 Nursery 年轻代的回收，停顿时间比较短，内存使用率比较稳定，帧率也更加稳定。 | 会定期 Stop the world，做全量 GC，内存使用率和帧率都会有上下波动的过程。大部分情况下，两者帧率的差异不大。 |
| 内存预分配 | 会预先分配大约 40M–50M 的内存，用作 Nursery 和 Major Heap ，同时可能根据对 LOS 的分配需求上涨到 90M 左右。 | 基本不需要。|


## IL2CPP

IL2CPP 是脚本后端，用来取代 Mono 后端。IL2CPP 支持的平台比 Mono 更多。IL2CPP 的编译方式属于 AOT, 而 Mono 属于 JIT