# 设计模式

## 单例模式

### 实现方式
1. 常规 C# 类: private 构造函数 + public static 属性
2. MonoBehaviour 子类：使用 GameObject.FindObjectsOfType<T> 获取实例，排除多余实例
3. Lazy<T>: 懒加载，线程安全

### 常见应用
- 各 Manager，如资源、配置、场景、UI、音频、网络、事件等全局管理器

## 工厂模式

### 种类
- 简单工厂：提供一个创建对象的函数，函数参数决定返回对象
- 工厂方法：提供一个创建对象的接口，接口实例决定返回对象
- 抽象工厂：提供一系列创建对象的接口，接口实例的组合决定返回对象的组合

### 常见应用
在一些跨平台库种比较常见

- 资源加载：从 AssetBundle、AssetDataBase、Resources 以不同方式加载资源

## 观察者模式
对象间存在一对多的依赖关系，当一个对象改变状态时，所有依赖于它的对象都得到通知并被自动更新。

又称为 发布-订阅模式

### 特点
降低目标与观察者之间的耦合度

### 构成
- 抽象主题（Subject）：IEvent，提供添加、删除、通知观察者的方法声明
- 具体主题（ConcreteSubject）：xxxEvent 派生类，某个具体的事件
- 抽象观察者（Observer）：IEventListener，提供更新方法声明
- 具体观察者（ConcreteObserver）： xxxEventListener 派生类，某个具体事件对应的监听器   


## 装饰器模式
允许向一个现有的对象添加新的功能，同时又不改变其结构。

### 常见应用
- 包装 API 打印日志