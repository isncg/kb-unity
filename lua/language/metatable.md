# 元表和元方法

## 元表
元表用于改变表的行为

- setmetatable 
- getmetatable
  
## 运算元方法
- __add
- __sub
- __mul
- __div
- __mod
- __pow
- __unm
- __band
- __bor
- __bxor
- __bnot
- __shl
- __shr

## 关系元方法
- __eq
- __lt
- __le

## 库定义的元方法
- __tostring

## 表访问元方法
- __index：当表中不存在索引时，会调用这个方法
- __newindex：当尝试给表中不存在的索引赋值时，会调用这个方法

### 原始访问
- rawget
- rawset

### 默认值
### 跟踪表访问
### 只读表