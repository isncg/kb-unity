# 协变和逆变

https://learn.microsoft.com/en-us/dotnet/csharp/programming-guide/concepts/covariance-contravariance/
 
> 在 C# 中，协变和逆变使数组类型、委托类型和泛型类型参数实现隐式引用转换。 协变会保留赋值兼容性，而逆变会反转赋值兼容性。
 
> In C#, covariance and contravariance enable implicit reference conversion for array types, delegate types, and generic type arguments. Covariance preserves assignment compatibility and contravariance reverses it.
 
https://cloud.tencent.com.cn/developer/article/1507826?from=15425
 
> 协变和逆变都是术语，前者指能够使用比原始指定的派生类型的派生程度更大（更具体的）的类型，后者指能够使用比原始指定的派生类型的派生程度更小（不太具体的）的类型。泛型类型参数支持协变和逆变，可在分配和使用泛型类型方面提供更大的灵活性。 
 
https://www.cnblogs.com/aehyok/p/3737426.html
 
> 协变：返回值类型返回比声明的类型派生程度更大。
 
> 逆变：是指方法的参数可以是委托或泛型接口的参数类型的基类
 
**协变 (Covariant)**
 
  使你能够使用比原始指定的类型派生程度更大的类型。
 
  你可以向 IEnumerable<Derived> 类型的变量分配IEnumerable(Of Derived) （在 Visual Basic 中为 IEnumerable<Base>）的实例。
 
**逆变 (Contravariant)**
 
  使你能够使用比原始指定的类型更泛型（派生程度更小）的类型。
 
  你可以向 Action<Base> 类型的变量分配Action(Of Base) （在 Visual Basic 中为 Action<Derived>）的实例。
 
**不变 (Invariant)**
 
  这意味着，你只能使用原始指定的类型；固定泛型类型参数既不是协变类型，也不是逆变类型。

  你无法向 List<Base> 类型的变量分配 List(Of Base)（在 Visual Basic 中为 List<Derived>）的实例，反之亦然。

@date 2026-4-11