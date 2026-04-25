# 弱表

https://www.lua.org/pil/17.html

### 什么是弱引用

弱引用是不被垃圾回收器考虑的引用

>A weak reference is a reference to an object that is not considered by the garbage collector.

Lua 以弱表的形式实现弱引用

>Lua implements weak references as weak tables: A weak table is a table where all references are weak. That means that, if an object is only held inside weak tables, Lua will collect the object eventually.

### 弱表 mode

Lua 表的 key 可 value 可以是任意类型，常规情况下，一个使用中的表，垃圾回收器不会回收其中对象类型的 key 或 value

表的弱性通过元表 __mode 字段指定，当 key 或 value 是弱引用时，垃圾回收器不考虑表对它们的引用，在回收时移除键值对

| __mode 值 | 弱引用方向       | 垃圾回收触发删除的条件                             |
| --------- | ---------------- | -------------------------------------------- |
| 'k'       | 键是弱引用       | 当键被垃圾回收时，键值对从表中移除                 |
| 'v'       | 值是弱引用       | 当值被垃圾回收时，键值对从表中移除                 |
| 'kv'      | 键和值都是弱引用 | 只要键或值中任意一个被垃圾回收，对应的条目就会被移除。 |

### 字符串
>Strings present a subtlety here: Although strings are collectible, from an implementation point of view, they are not like other collectible objects. Other objects, such as tables and functions, are created explicitly. For instance, whenever Lua evaluates {}, it creates a new table. Whenever it evaluates function () ... end, it creates a new function (a closure, actually). However, does Lua create a new string when it evaluates "a".."b"? What if there is already a string "ab" in the system? Does Lua create a new one? Can the compiler create that string before running the program? It does not matter: These are implementation details. Thus, from the programmer's point of view, strings are values, not objects. Therefore, like a number or a boolean, a string is not removed from weak tables (unless its associated value is collected).

