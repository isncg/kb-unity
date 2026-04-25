# 装箱

## box 指令
 
- 操作码：box
- 参数：值类型的类型标记（这里是 System.Int32）
- 行为：
    1. 从计算栈弹出一个值类型实例。
    2. 在堆上分配该值类型的装箱对象。
    3. 将值类型的数据复制到对象中。
    4. 将新对象的引用压入计算栈。
 
装箱对应的 IL 指令是 box。box 指令接受一个值类型元数据标记，将其装箱并返回 object 引用。

```csharp
public class BoxingExample
{
    public static void Main()
    {
        int i = 123;
        object o = i;
    }
}
```
 
编译后，Main 方法的 IL 代码（简化版）：

```csharp
.method public hidebysig static void Main() cil managed
{
    .entrypoint
    .maxstack 1
    .locals init (
        [0] int32 i,
        [1] object o
    )

    // int i = 123;
    IL_0000: ldc.i4.s   123        // 将 123 压入计算栈
    IL_0002: stloc.0               // 弹出并存储到局部变量 i

    // object o = i;   // 装箱发生在这里
    IL_0003: ldloc.0               // 将局部变量 i 的值加载到计算栈
    IL_0004: box       [System.Runtime]System.Int32  // 装箱指令
    IL_0009: stloc.1               // 将装箱后的引用存储到局部变量 o

    IL_000a: ret
}
```

## object 内存布局

int 装箱：
```csharp
int i = 123;
object o = i;   // 装箱
```

| 偏移量 | 大小 | 内容 |
|-------|------|------|
| 0     | 4    | 同步块索引（初始 0） |
| 4     | 4    | 方法表指针（指向 System.Int32 的方法表） |
| 8     | 4    | int 值 123 |

结构体装箱：
```csharp
struct Point
{
    public int X;
    public int Y;
}

Point p = new Point { X = 10, Y = 20 };
object o = p;
```
| 偏移量 | 大小 | 内容 |
|-------|------|------|
| 0	    | 4    | 同步块索引 |
| 4	    | 4    | 方法表指针（指向 Point 的装箱类型方法表） |
| 8	    | 4    | X 字段值 |
| 12    | 4    | Y 字段值 |

## 方法表与调用过程

在 C# 代码中，即使是值类型，你也可以直接调用其继承或重写的方法，例如 point.ToString()。对于非虚方法（如 Point.ToString() 被重写），编译器能确定其具体实现，因此调用是静态的，效率很高。

对于虚方法（如 GetType()），调用需要通过方法表进行间接寻址，但这部分逻辑在 CLR 内部处理，对开发者是透明的。关键的区别在于，当你通过一个装箱后的 object 引用来调用 point.ToString() 时，调用过程就完全遵循引用类型的虚方法分派机制，通过对象头中的方法表指针来定位实际要调用的方法地址。

@date 2026-4-11