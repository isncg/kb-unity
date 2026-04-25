# 函数调用

## Lua 栈
Lua 栈是 Lua 虚拟机与 C API 之间传递数据的数据结构。Lua栈的每个元素是 Lua 值，可以是任意类型。

Lua 栈可以通过索引访问， 1表示栈底， -1表示栈顶。当栈中存在n个元素时，-n也可以表示栈底，n也可以表示栈顶。以下是Lua提供的、通过下标访问栈的API:

| 类别             | 函数示例                                                                                                                                                                                                                                                 |
| ---------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 类型查询         | lua_type, lua_isnil, lua_isboolean, lua_isnumber, lua_isstring, lua_istable, lua_isfunction, lua_isthread, lua_isuserdata                                                                                                                                |
| 值读取           | lua_toboolean, lua_tonumber, lua_tointeger, lua_tostring, lua_tolstring, lua_topointer, lua_tothread, lua_touserdata                                                                                                                                     |
| 值比较           | lua_equal, lua_rawequal, lua_compare                                                                                                                                                                                                                     |
| 栈操作（带下标） | lua_pushvalue（复制指定位置的值到栈顶）<br>lua_remove（删除指定位置，上方元素下移）<br>lua_insert（将栈顶元素移动到指定位置）<br>lua_replace（弹出栈顶元素并覆盖指定位置）<br>lua_copy（复制一个位置的值到另一个位置）<br>lua_rotate（旋转栈中一段元素） |
| 表访问           | lua_gettable, lua_settable（需要键在栈顶，并指定表的位置）<br>lua_getfield, lua_setfield（用字符串键访问，指定表的位置）<br>lua_geti, lua_seti（用整数键访问，指定表的位置）<br>lua_rawget, lua_rawset（原始访问，无元方法）                             |
| 辅助函数         | lua_absindex（将任何有效索引转换为绝对正索引）                                                                                                                                                                                                           |

Lua 也提供了这么几个函数，它们返回栈下标：

| 函数                           | 描述                                                                                                                                                                                 |
| ------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| lua_gettop                     | 返回栈顶元素的索引，也等于栈中元素的总数。                                                                                                                                           |
| lua_absindex                   | 将一个索引（允许使用负数）转换为等效的绝对正索引，这样在栈顶变化后该索引依然有效。                                                                                                   |
| luaL_ref                       | 弹出栈顶元素，将其存储到指定的表中（通常为注册表 LUA_REGISTRYINDEX），并返回一个唯一的整数键作为后续访问该元素的引用。                                                               |
| lua_checkstack luaL_checkstack | 这两个函数不是用于获取下标，而是用于确保栈有足够的空间（lua_checkstack 返回布尔值，而 luaL_checkstack 失败时会直接抛出错误）。luaL_checkstack 在栈上保存并验证参数，而不是返回索引。 |

在函数调用时，首先压栈的值是函数，然后函数的参数从左到右依次压栈，栈底指针指向第一个参数。栈顶指针指向最后一个参数的下一个位置。

```
栈地址（低 → 高）：
+---------+   <--- L->stack (栈底)
| ...     |
+---------+   <--- L->base - 1: 函数对象 foo
| foo     |
+---------+   <--- L->base: 第一个参数 (10)
| 10      |
+---------+   <--- L->base + 1: 第二个参数 ("hello")
| "hello" |
+---------+   <--- L->top: 空闲槽位 (下一个压栈位置)
|         |
+---------+
```

示例：遍历参数
```c
#include <stdio.h>
#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>

static int print_args(lua_State *L) {
    int nargs = lua_gettop(L);  // 获取参数个数
    printf("参数个数: %d\n", nargs);

    for (int i = 1; i <= nargs; i++) {
        int type = lua_type(L, i);
        const char *type_name = lua_typename(L, type);
        printf("参数 %d: 类型 = %s", i, type_name);

        // 可选：打印部分类型的值以便观察
        switch (type) {
            case LUA_TNIL:
                printf(", 值 = nil");
                break;
            case LUA_TBOOLEAN:
                printf(", 值 = %s", lua_toboolean(L, i) ? "true" : "false");
                break;
            case LUA_TNUMBER:
                printf(", 值 = %g", lua_tonumber(L, i));
                break;
            case LUA_TSTRING:
                printf(", 值 = \"%s\"", lua_tostring(L, i));
                break;
            case LUA_TTABLE:
                printf(", 值 = (table)");
                break;
            case LUA_TFUNCTION:
                printf(", 值 = (function)");
                break;
            case LUA_TTHREAD:
                printf(", 值 = (thread)");
                break;
            case LUA_TLIGHTUSERDATA:
            case LUA_TUSERDATA:
                printf(", 值 = (userdata)");
                break;
        default:
                printf(", 值 = (unknown)");
        }
        printf("\n");
    }
    return 0;  // 该函数没有返回值给 Lua
}
```

## 函数调用
**1、调用前**
函数及参数压栈

**2、luaD_precall**

   调用发生时，luaD_precall 函数负责准备新的栈帧： 

   1. 保存当前状态：将当前的 base 和 top 等信息保存到当前的 CallInfo 中。
   2. 创建新 CallInfo：为被调函数分配一个新的 CallInfo 结构，并链接到调用链上。若 CallInfo 链表不够用，会通过 luaE_extendCI 扩展。
   3. 为新函数设置 base：新帧的 base 指向函数对象所在的位置 (func)。
   4. 调整 top：新帧的 top 会根据函数定义和参数数量进行设置。
   5. 设置 lua_State 的 base 和 ci：更新 L->base 和新 L->ci，使虚拟机指向新帧。

**对于 Lua 函数：** 
   
   luaD_precall 设置好环境后，会通过 luaV_execute 开始执行字节码。在 luaV_execute 中，会定义 base = ci->func.p + 1（指向第一个参数位置），并进入主循环逐条执行指令。

**对于 C 函数：** 

   luaD_precall 直接调用该 C 函数，C 函数执行完毕后的返回值已位于栈上，等待 luaD_poscall 处理。

**3、luaD_poscall**

   函数执行完毕后，luaD_poscall 函数负责清理并恢复调用者的栈帧：

   1. 获取返回结果的位置和数量
   2. 将返回值移动到调用者的栈上，覆盖之前的函数和参数位置
   3. 恢复调用者的 CallInfo (L->ci = ci->previous)
   4. 将 L->top 设置为调用者栈帧的新栈顶 (ci->top)
   5. 返回 nres (返回值的数量)

## Tail Call
尾调用（Tail Call） 是一种特殊的函数调用优化，当函数 f 的最后一条语句是调用另一个函数 g 并直接返回 g 的结果时，虚拟机可以复用当前栈帧，避免创建新的 CallInfo 结构。其核心实现在 ldo.c 的 luaD_pretailcall 函数中。

1. 编译阶段：生成 OP_TAILCALL 指令

    Lua 编译器在解析函数时，如果发现一个调用位于 return 语句的尾部（例如 return f(...)），且没有需要保留的局部变量或额外操作，就会生成 OP_TAILCALL 字节码，而非普通的 OP_CALL。

2. 运行阶段：luaD_pretailcall 复用栈帧

    当虚拟机执行到 OP_TAILCALL 时，会调用 luaD_pretailcall（位于 ldo.c）。其核心逻辑如下：

```c 
// ldo.c 中的简化逻辑:
int luaD_pretailcall (lua_State *L, CallInfo *ci, StkId func, int narg1, int delta) {
    // 1. 检查当前函数是否满足尾调用条件（如没有被调试钩子锁定等）
    if ((ci->callstatus & CIST_TAIL) &&  // 已经是尾调用链
    /* ... 其他检查 ... */) {
        // 2. 复用当前 CallInfo：仅更新 func 和 top 指针
        ci->func = func;                     // 新函数的起始位置
        ci->top = func + ((narg1) & ~1);     // 新的栈顶（考虑固定参数）
        ci->callstatus |= CIST_TAIL;         // 标记为尾调用
        L->base = func + 1;                  // 新基址指向第一个参数
        L->top = ci->top;                    // 更新栈顶
        return 1;  // 表示尾调用成功，继续执行新函数
    }
    return 0;  // 不能复用，回退到普通调用
}
```

如果 luaD_pretailcall 返回 1，则虚拟机直接跳转到新函数的入口，不再执行 luaD_precall 中创建新 CallInfo 的代码。

**尾调用优化的必要条件**
1. 必须是 return f(...) 形式

| 错误形式                      | 原因                                                                                          |
| ----------------------------- | --------------------------------------------------------------------------------------------- |
| `return foo(x) + 1`           | 有额外运算                                                                                    |
| `local r = foo(x); return r;` | 先赋值再返回，中间有操作                                                                      |
| `return (foo(x))`             | 括号虽然不影响值，但会阻止尾调用优化？实际上 Lua 5.4 中括号不会阻止，但为保险起见避免多余括号 |

1. 调用必须是函数的最后一个动作

    例如：

```lua
function f(n)
    if n <= 0 then return g(n) end
    return h(n)   -- 尾调用
end
```

2. 返回值不能是多个调用的结果

    不可以是 `return f(x), g(x)`，但被调用的函数可以返回多个值

3. 仅对 Lua 函数有效

    Lua 只能优化对 Lua 函数 的尾调用。对 C 函数的调用（如 table.insert、print）不会被优化。

## 普通调用vs尾调用
| 特性            | 普通调用 (OP_CALL)              | 尾调用 (OP_TAILCALL)                 |
| --------------- | ------------------------------- | ------------------------------------ |
| 栈帧 (CallInfo) | 创建新帧，压入调用链            | 复用当前帧，不增加链长               |
| 栈内存          | 为新帧分配栈空间（L->top 增长） | 在原有栈空间上直接替换参数           |
| 返回处理        | 需要 luaD_poscall 恢复调用者    | 无需返回，直接由被调函数返回最终结果 |
| 递归深度        | 每递归一层增加一个帧，易溢出    | 尾递归不增加帧，理论上可无限深度     |


@date 2026-4-3