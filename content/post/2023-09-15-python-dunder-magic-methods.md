---
title: "Python双下划线详解：__name__与魔术方法/属性全面整理（含版本限制）"
date: 2023-09-15T08:00:00+08:00
tags: [ "python", "基础" ]
description: "Python 双下划线全面整理：__name__ 的判断与包内行为、__file__/__all__/__slots__ 等常用属性、类魔术方法按用途分类速查（构造/比较/容器/上下文/描述符）、名称改写 name mangling 机制，附各特性版本要求"
categories: [ "python" ]
toc: true
---

## 前言

Python 里到处都是双下划线：`__name__`、`__init__`、`__all__`、`__getattr__`……刚学的时候只知道 `if __name__ == '__main__'` 这么抄，不清楚背后的整套设计。这篇把双下划线家族（俗称 dunder，double underscore 的缩写）按用途全面整理一遍，每个都带小样例，有版本要求的标明版本。

先给个总原则（PEP 8 的原话）：**`__xxx__` 这种前后双下划线的命名权属于 Python 解释器，自己写类不要发明这种名字**，想表达内部属性用单下划线 `_foo` 或者双下划线前缀 `__foo`（后面讲它的改写机制）。

## 1、__name__：模块的身份牌

每个模块被导入时都有 `__name__` 属性，值取决于它**怎么被使用**：

```python
# mymod.py
print(f"我的 __name__ 是: {__name__}")

if __name__ == "__main__":
    print("被直接运行，执行测试代码")
```

```bash
$ python mymod.py
我的 __name__ 是: __main__       # 直接运行 → __main__
$ python -c "import mymod"
我的 __name__ 是: mymod          # 被导入 → 模块名
```

这就是 `if __name__ == "__main__":` 的意义：**直接运行时执行入口逻辑，被导入时只提供定义不执行**。

几个容易忽略的行为：

```bash
# 用 -m 方式运行（把模块当脚本跑）
$ python -m mymod
我的 __name__ 是: __main__

# 包里的模块被导入，__name__ 带包前缀
$ python -c "from pkg import mymod"
我的 __name__ 是: pkg.mymod
```

所以包内模块里写 `if __name__ == "__main__"` 的测试代码，用 `python -m pkg.mymod` 方式也能触发。另外 Flask/Django 的 debug 模式也是靠判断主模块来决定行为的。

## 2、常用的模块级双下划线属性

### 2.1 __file__：当前模块的文件路径

```python
import os
print(__file__)
print(os.path.dirname(os.path.abspath(__file__)))   # 模块所在目录，拼配置路径常用
```

**版本注意**：Python 3.9 起 `__file__` 保证是绝对路径；3.8 及以前是「执行 python 命令时的相对路径」，脚本里拼路径前必须先 `abspath`，老版本不处理的话换个工作目录就找不到文件。

### 2.2 __doc__：文档字符串

模块/类/函数的第一个字符串会被存进 `__doc__`，`help()` 就是读它：

```python
def add(a, b):
    """两数相加"""
    return a + b

print(add.__doc__)    # 两数相加
```

### 2.3 __all__：from xxx import * 的白名单

```python
# mylib.py
__all__ = ["public_func"]        # 只允许导出这一个

def public_func(): ...
def _internal(): ...
def another(): ...
```

```python
from mylib import *      # 只导入 public_func
# another 只是没进白名单，显式 from mylib import another 依然可以用
```

它只是约定不是强制隔离，但对库作者来说，写 `__all__` 是明确告诉使用者「这些才是公开 API」。

### 2.4 __debug__：解释器内置常量

```python
if __debug__:
    do_heavy_assert()     # 调试断言逻辑

# python -O 运行时 __debug__ 为 False，上面的块整体不执行
```

`assert` 语句在 `-O` 模式下也会被整体剔除，生产脚本可以用 `-O` 提速（前提是 assert 里没有业务逻辑）。

### 2.5 其他常遇到的

| 属性 | 含义 |
| - | - |
| `__package__` | 模块所属包名 |
| `__spec__` | 模块的导入规格（importlib 元数据，3.4+） |
| `__module__` | 类或函数定义所在的模块名 |
| `__qualname__` | 限定名，含外层作用域路径（3.3+），嵌套类/函数里和 `__name__` 有区别 |
| `__dict__` | 对象/模块的属性字典 |
| `__version__` | 惯例上的库版本号（非语言机制，纯约定） |

```python
def outer():
    def inner(): ...
    print(inner.__name__)      # inner
    print(inner.__qualname__)  # outer.<locals>.inner   # 3.3+
```

## 3、类的魔术方法：按用途分类

魔术方法（magic methods）不需要手动调用，解释器在特定语法下自动触发。按用途分组记最省力。

### 3.1 构造与销毁：__new__ / __init__ / __del__

```python
class Singleton:
    _instance = None
    def __new__(cls, *args, **kwargs):        # 创建实例（真正干活的）
        if cls._instance is None:
            cls._instance = super().__new__(cls)
        return cls._instance
    def __init__(self, value):                # 初始化实例（__new__ 之后调用）
        self.value = value
```

`__new__` 负责创建并返回实例（单例、不可变类型子类必须用它），`__init__` 只负责初始化已创建的实例。`__del__` 是对象被回收时的钩子，但回收时机依赖 GC，别在里面写关键逻辑（关文件请用 with）。

### 3.2 展示：__repr__ / __str__

```python
class Point:
    def __repr__(self):                       # 给开发者看，进调试器和容器
        return f"Point({self.x!r}, {self.y!r})"
    def __str__(self):                        # 给用户看，print/str() 触发
        return f"({self.x}, {self.y})"
```

只写一个的话写 `__repr__`——`str()` 找不到 `__str__` 会兜底用 `__repr__`，而 `repr()` 不会反向兜底。

### 3.3 比较与哈希：__eq__ / __hash__

```python
class User:
    def __init__(self, uid): self.uid = uid
    def __eq__(self, other):                  # == 触发
        return isinstance(other, User) and self.uid == other.uid
    def __hash__(self):                       # 可哈希才能放进 set/dict key
        return hash(self.uid)
```

规则：`__eq__` 定义后 `__hash__` 会被置 None（实例变不可哈希），要放集合里就必须同时定义 `__hash__`，且「相等的对象哈希值必须相等」。懒人方案是 `@functools.total_ordering`——只写 `__eq__` 和 `__lt__`，自动补全其余比较。

### 3.4 运算符：__add__ 及其两兄弟

```python
class Money:
    def __init__(self, cents): self.cents = cents
    def __add__(self, other):                 # a + b
        return Money(self.cents + other.cents)
    def __radd__(self, other):                # 反向：1 + b 时左操作数不认识自己
        return self.__add__(Money(other * 100)) if isinstance(other, int) else NotImplemented
    def __iadd__(self, other):                # a += b（就地）
        self.cents += other.cents
        return self
```

每个运算符都有三个版本：普通 `__add__`、反向 `__radd__`（左边不是本类型时先试它）、就地 `__iadd__`（不定义时 += 退回 __add__）。

### 3.5 让对象像容器：len / getitem / iter / contains

```python
class Playlist:
    def __init__(self, songs): self._songs = songs
    def __len__(self):            return len(self._songs)      # len(p)
    def __getitem__(self, i):     return self._songs[i]        # p[0]、切片 p[1:3]、甚至 for 遍历
    def __contains__(self, s):    return s in self._songs      # x in p
    def __iter__(self):           return iter(self._songs)     # for s in p
    def __reversed__(self):       return reversed(self._songs)
```

只要实现了 `__getitem__`，for 循环和切片就自动可用；实现 `__iter__` + `__next__`（`__next__` 没数据时 raise `StopIteration`）就是标准迭代器协议。

### 3.6 可调用对象：__call__

```python
class Adder:
    def __init__(self, n): self.n = n
    def __call__(self, x):                    # 实例可以像函数一样被调用
        return self.n + x

add3 = Adder(3)
add3(10)        # 13 —— 装饰器带参数、类当配置化工厂都是靠它
```

### 3.7 布尔与类型转换：__bool__ / __index__

```python
class Queue:
    def __bool__(self):                       # if queue: 触发
        return len(self._items) > 0           # 不定义则默认恒为 True
    def __index__(self):                      # 被当索引用时触发：lst[q]
        return len(self._items)
```

### 3.8 属性访问三件套：__getattr__ / __getattribute__ / __setattr__

```python
class Lazy:
    def __getattribute__(self, name):         # 所有属性访问都经过这（慎重写，容易无限递归）
        return super().__getattribute__(name)
    def __getattr__(self, name):              # 只在常规查找失败后才调用（安全，做代理常用）
        if name.startswith("get_"):
            return lambda: f"动态生成 {name}"
        raise AttributeError(name)
```

记住分工：`__getattribute__` 无条件拦截，`__getattr__` 是兜底。动态代理、ORM 的字段懒加载都是 `__getattr__` 的典型应用。

### 3.9 上下文管理器：__enter__ / __exit__

```python
class Timer:
    def __enter__(self):                      # with 进入时
        self.start = time.time()
        return self                            # as 后面拿到的对象
    def __exit__(self, exc_type, exc_val, tb):  # 退出时必调，异常时拿三件套
        print(f"耗时 {time.time() - self.start:.2f}s")
        return False                           # True 表示吞掉异常

with Timer():
    do_something()
```

异步版本 `__aenter__` / `__aexit__` 配合 `async with` 使用，**Python 3.5+**。

### 3.10 描述符协议：__get__ / __set__（property 的底层）

```python
class Positive:
    def __set_name__(self, owner, name):      # 3.6+，类创建时自动拿到属性名
        self.name = name
    def __get__(self, obj, objtype=None):
        return obj.__dict__[self.name]
    def __set__(self, obj, value):
        if value <= 0:
            raise ValueError(f"{self.name} 必须为正数")
        obj.__dict__[self.name] = value

class Order:
    price = Positive()                        # price = Positive() 触发 __set_name__
    count = Positive()
```

`property`、ORM 字段、`@classmethod` 的底层全是描述符。`__set_name__` 是 **3.6+** 新增，省掉了以前手写属性名的样板。

### 3.11 子类定制钩子：__init_subclass__ / __class_getitem__

```python
class Plugin:
    registry = {}
    def __init_subclass__(cls, **kwargs):     # 3.6+，任何子类定义时自动触发
        super().__init_subclass__(**kwargs)
        Plugin.registry[cls.__name__] = cls

class ExportPlugin(Plugin): pass
print(Plugin.registry)     # {'ExportPlugin': <class ...>}，插件自动注册
```

`__class_getitem__` 是 **3.7+** 的，`list[int]`、`dict[str, int]` 这种泛型下标语法就靠它（`__class_getitem__ = classmethod(GenericAlias)` 的写法见 typing 源码）。

### 3.12 结构化模式匹配：__match_args__

```python
class Point:
    __match_args__ = ("x", "y")               # 3.10+，match-case 位置匹配的依据
    def __init__(self, x, y): self.x, self.y = x, y

def handle(p):
    match p:
        case Point(0, 0): print("原点")
        case Point(x, 0): print(f"x 轴上, x={x}")
```

**Python 3.10+** 才有 match 语句，`__match_args__` 指定按位置解构时的属性顺序。

### 3.13 序列化与内存：__getstate__ / __setstate__ / __sizeof__

```python
class Conn:
    def __getstate__(self):                   # pickle 时剔除不可序列化的连接对象
        state = self.__dict__.copy()
        del state["_sock"]
        return state
    def __setstate__(self, state):            # 反序列化时重建
        self.__dict__.update(state)
        self._sock = reconnect()
```

**版本注意**：`object.__getstate__` 的默认实现是 **3.11+** 才加的，3.10 及以前 `copyreg` 对带 `__slots__` 对象的处理要自己写。`__sizeof__` 返回对象真实内存占用（`sys.getsizeof` 底层调它），一般不用自己实现。

## 4、__slots__：限制属性、省内存

```python
class Point:
    __slots__ = ("x", "y")                    # 实例不再有 __dict__
    def __init__(self, x, y): self.x, self.y = x, y

p = Point(1, 2)
p.z = 3        # AttributeError: 'Point' object has no attribute 'z'
```

两个用途：防止随手乱加属性；海量小对象（百万级）省内存效果明显——没有 `__dict__` 了。代价：不能动态加属性、和某些多重继承组合冲突。`dataclass` 在 **3.10+** 可以直接 `@dataclass(slots=True)` 自动生成。

## 5、名称改写（name mangling）：__foo 双下划线前缀

前面说的 `__xxx__`（前后都有）是给解释器的；**只有前导双下划线、无尾随**的 `__foo` 是另一种机制——名称改写：

```python
class Account:
    def __init__(self):
        self.__password = "123456"            # 实际存储名为 _Account__password

a = Account()
# print(a.__password)     # AttributeError
print(a._Account__password)                   # 123456，改写后仍可访问，不是真私有
```

目的是**避免子类无意覆盖父类属性**（继承时 `__password` 改写成 `_Account__password`，子类的 `__password` 是 `_Sub__password`，互不干扰），而不是安全加密——真想访问随时能访问，它只是防误用。

单下划线 `_foo` 是纯约定（「内部使用，请勿直接碰」），`from module import *` 不会导入它；交互式解释器里 `_` 表示上一个表达式的结果；i18n 场景 `_ = gettext.gettext` 也是惯用法。

## 6、速查总表

| 名称 | 用途 | 版本 |
| - | - | - |
| `__name__` / `__main__` | 模块身份与入口判断 | 很早 |
| `__file__`（绝对路径保证） | 模块路径 | 绝对路径 3.9+ |
| `__all__` | import * 白名单 | 很早 |
| `__debug__` | -O 优化开关 | 很早 |
| `__qualname__` | 限定名 | 3.3+ |
| `__new__` / `__init__` | 实例创建/初始化 | 很早 |
| `__repr__` / `__str__` | 展示 | 很早 |
| `__eq__` / `__hash__` | 相等与哈希 | 很早 |
| `__add__` / `__radd__` / `__iadd__` | 运算符三兄弟 | 很早 |
| `__len__` / `__getitem__` / `__iter__` / `__contains__` | 容器协议 | 很早 |
| `__call__` | 实例可调用 | 很早 |
| `__getattr__` / `__getattribute__` / `__setattr__` | 属性访问 | 很早 |
| `__enter__` / `__exit__` | with 上下文 | 很早 |
| `__aenter__` / `__aexit__` | async with | 3.5+ |
| `__imatmul__` 等矩阵运算 | @ 运算符 | 3.5+ |
| `__init_subclass__` / `__set_name__` | 子类钩子/描述符命名 | 3.6+ |
| `__class_getitem__` | 泛型下标 `list[int]` | 3.7+ |
| `__match_args__` | match-case 位置匹配 | 3.10+ |
| `object.__getstate__` 默认实现 | pickle | 3.11+ |
| `@dataclass(slots=True)` | dataclass 配 slots | 3.10+ |

## 总结

双下划线家族分三层记：**模块层**（`__name__`、`__file__`、`__all__`，管身份和导出）、**类协议层**（魔术方法，是各种语法糖的底层——`==` 是 `__eq__`、`with` 是 `__enter__`、`for` 是 `__iter__`，理解了这层，很多「语法」其实只是「协议」）、**命名约定层**（`_foo` 靠自觉、`__foo` 有改写、`__foo__` 属于解释器）。写业务代码高频的就那几个（`__init__`/`__repr__`/`__eq__`/`__enter__`），写框架和库才会用到描述符和子类钩子这些高级货，按需查阅上面的速查表即可。
