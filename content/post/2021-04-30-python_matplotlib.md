---
title: "python生成matplotlib的统计图"
date: 2021-04-30T00:29:47+08:00
tag : [ "python", "pandas", "matplotlib" ]
description: "python生成matplotlib统计图"
categories: [ "python", "pandas", "matplotlib" ]
toc: true
---

## 前言
记录下python生成统计图的一些常规使用，主要是2D的统计图，3D的暂不涉及

## 1、准备工作
### 1.1 安装pandas和matplotlib
```shell
pip install pandas
pip install matplotlib
```

### 1.2 安装numpy
```shell
pip install numpy
```

### 1.3 中文字体
中文字体名|英文字体名
-|-
宋体|SimSun
黑体|SimHei
微软雅黑|Microsoft YaHei
微软正黑体|Microsoft JhengHei
新宋体|NSimSun
新细明体|PMingLiU
细明体|MingLiU
标楷体|DFKai-SB
仿宋|FangSong
楷体|KaiTi
隶书|LiSu
幼圆|YouYuan
华文细黑|STXihei
华文楷体|STKaiti
华文宋体|STSong
华文中宋|STZhongsong
华文仿宋|STFangsong
方正舒体|FZShuTi
方正姚体|FZYaoti
华文彩云|STCaiyun
华文琥珀|STHupo
华文隶书|STLiti
华文行楷|STXingkai
华文新魏|STXinwei

### 1.4 pyplot支持中文的参数和字体样式
```python
import matplotlib.pyplot as plt

# 设置黑体，支持中文
plt.rcParams['font.sans-serif'] = ['SimHei']
# 设置字体样式
plt.rcParams['font.family'] = 'sans-serif'
# 设置字体大小
plt.rcParams['font.size'] = '16'
# 伸展字体，很少用
plt.rcParams['font.stretch'] = 'normal'
# 字体样式
plt.rcParams['font.style'] = 'normal'
# 小型大写字母，大写字母大一号，小写字母全部大写但是比大写小一号；中文没影响
plt.rcParams['font.variant'] = 'normal'
# 字体粗细，比如加粗bold
plt.rcParams['font.weight'] = 'normal'
```

这里的字体样式基本跟CSS的font一样  
具体可以参考CSS的font说明: <https://www.w3school.com.cn/cssref/pr_font_font.asp>

### 1.5 支持负号
```python
# 解决负号'-'显示为方块的问题
plt.rcParams['axes.unicode_minus'] = False
```

### 1.6 其他常用参数介绍
#### 1.6.1 线条样式：lines
函数|说明
-|-
plt.rcParams['lines.linestyle'] = '-.'|线条样式
plt.rcParams['lines.linewidth'] = 3|线条宽度
plt.rcParams['lines.color'] = 'blue'|线条颜色
plt.rcParams['lines.marker'] = None|默认标记
plt.rcParams['lines.markersize'] = 6|标记大小
plt.rcParams['lines.markeredgewidth'] = 0.5|标记附近的线宽

#### 1.6.2 横、纵轴：xtick、ytick
函数|说明
-|-
plt.rcParams['xtick.labelsize']|横轴字体大小
plt.rcParams['ytick.labelsize']|纵轴字体大小
plt.rcParams['xtick.major.size']|x轴最大刻度
plt.rcParams['ytick.major.size']|y轴最大刻度

#### 1.6.3 figure中的子图：axes
函数|说明
-|-
plt.rcParams['axes.titlesize']|子图的标题大小
plt.rcParams['axes.labelsize']|子图的标签大小

#### 1.6.4 图像、图片：figure、savefig
函数|说明
-|-
plt.rcParams['figure.dpi']|图像分辨率
plt.rcParams['figure.figsize']|图像显示大小
plt.rcParams['savefig.dpi']|图片像素

## 2、pandas解析数据
常规用法，具体详细参数请参考官方: <https://pandas.pydata.org/docs/user_guide/index.html#user-guide>

### 2.1 导入数据
函数|说明
-|-
pd.DataFrame()|自己创建数据框，用于练习
pd.read_csv(filename)|从CSV⽂件导⼊数据
pd.read_table(filename)|从限定分隔符的⽂本⽂件导⼊数据
pd.read_excel(filename)|从Excel⽂件导⼊数据
pd.read_sql(query,connection_object)|从SQL表/库导⼊数据
pd.read_json(json_string)|从JSON格式的字符串导⼊数据
pd.read_html(url)|解析URL、字符串或者HTML⽂件，抽取其中的tables表格

### 2.2 数据选取
函数|说明
-|-
df[col]|根据列名，并以Series的形式返回列
df[["col1","col2"]\]|以DataFrame形式返回多列
s.iloc[0]|按位置选取数据
s.loc['index_one']|按索引选取数据
df.iloc[0,:]|返回第⼀⾏
df.iloc[0,0]|返回第⼀列的第⼀个元素
df.loc[0,:]|返回第⼀⾏（索引为默认的数字时，⽤法同df.iloc），但需要注意的是loc是按索引,iloc参数只接受数字参数
df.ix[[:5],["col1","col2"]\]|返回字段为col1和col2的前5条数据，可以理解为loc和iloc的结合体。
df.at[5,"col1"]|选择索引名称为5，字段名称为col1的数据
df.iat[5,0]|选择索引排序为5，字段排序为0的数据

### 2.3 数据处理
函数|说明
-|-
df.columns=['a','b','c']|重命名列名（需要将所有列名列出，否则会报错）
pd.isnull()|检查DataFrame对象中的空值，并返回⼀个Boolean数组
pd.notnull()|检查DataFrame对象中的⾮空值，并返回⼀个Boolean数组
df.dropna()|删除所有包含空值的⾏
df.dropna(axis=1)|删除所有包含空值的列
df.dropna(axis=1,thresh=n)|删除所有⼩于n个⾮空值的⾏
df.fillna(value=x)|⽤x替换DataFrame对象中所有的空值，⽀持df[column_name].fillna(x)
s.astype(float)|将Series中的数据类型更改为float类型
s.replace(1,'one')|⽤‘one’代替所有等于1的值
s.replace([1,3],['one','three'])|⽤'one'代替1，⽤'three'代替3
df.rename(columns=lambdax:x+1)|批量更改列名
df.rename(columns={'old_name':'new_ name'})|选择性更改列名
df.set_index('column_one')|将某个字段设为索引，可接受列表参数，即设置多个索引
df.reset_index("col1")|将索引设置为col1字段，并将索引新设置为0,1,2...
df.rename(index=lambdax:x+1)|批量重命名索引

### 2.4 分组、排序、透视
函数|说明
-|-
df.sort_index().loc[:5]|对前5条数据进⾏索引排序
df.sort_values(col1)|按照列col1排序数据，默认升序排列
df.sort_values(col2,ascending=False)|按照列col1降序排列数据
df.sort_values([col1,col2],ascending=[True,False])|先按列col1升序排列，后按col2降序排列数据
df.groupby(col)|返回⼀个按列col进⾏分组的Groupby对象
df.groupby([col1,col2])|返回⼀个按多列进⾏分组的Groupby对象
df.groupby(col1)[col2].agg(mean)|返回按列col1进⾏分组后，列col2的均值,agg可以接受列表参数，agg([len,np.mean])
df.pivot_table(index=col1,values=[col2,col3],aggfunc={col2:max,col3:[ma,min]})|创建⼀个按列col1进⾏分组，计算col2的最⼤值和col3的最⼤值、最⼩值的数据透视表
df.groupby(col1).agg(np.mean)|返回按列col1分组的所有列的均值,⽀持df.groupby(col1).col2.agg(['min','max'])
data.apply(np.mean)|对DataFrame中的每⼀列应⽤函数np.mean
data.apply(np.max,axis=1)|对DataFrame中的每⼀⾏应⽤函数np.max
df.groupby(col1).col2.transform("sum")|通常与groupby连⽤，避免索引更改

### 2.5 数据合并
函数|说明
-|-
df1.append(df2)|将df2中的⾏添加到df1的尾部
df.concat([df1,df2],axis=1,join='inner')|将df2中的列添加到df1的尾部,值为空的对应⾏与对应列都不要
df1.join(df2.set_index(col1),on=col1,how='inner')|对df1的列和df2的列执⾏SQL形式的join，默认按照索引来进⾏合并，如果df1和df2有共同字段时，会报错，可通过设置lsuffix,rsuffix来进⾏解决，如果需要按照共同列进⾏合并，就要⽤到set_index(col1)
pd.merge(df1,df2,on='col1',how='outer')|对df1和df2合并，按照col1，⽅式为outer
pd.merge(df1,df2,left_index=True,right_index=True,how='outer')|与 df1.join(df2, how='outer')效果相同

### 2.6 数据导出
函数|说明
-|-
df.to_csv(filename)|导出数据到CSV⽂件
df.to_excel(filename)|导出数据到Excel⽂件
df.to_sql(table_name,connection_object)|导出数据到SQL表
df.to_json(filename)|以Json格式导出数据到⽂本⽂件
writer=pd.ExcelWriter('test.xlsx',index=False)|写入excel
df1.to_excel(writer,sheet_name='单位')和writer.save()|将多个数据帧写⼊同⼀个⼯作簿的多个sheet(⼯作表)

### 2.7 查看数据
函数|说明
-|-
df.head(n)|查看DataFrame对象的前n⾏
df.tail(n)|查看DataFrame对象的最后n⾏
df.shape()|查看⾏数和列数
df.info()|查看索引、数据类型和内存信息
df.columns()|查看字段（⾸⾏）名称
df.describe()|查看数值型列的汇总统计
s.value_counts(dropna=False)|查看Series对象的唯⼀值和计数
df.apply(pd.Series.value_counts)|查看DataFrame对象中每⼀列的唯⼀值和计数
df.isnull().any()|查看是否有缺失值
df[df[column_name].duplicated()]|查看column_name字段数据重复的数据信息
df[df[column_name].duplicated()].count()|查看column_name字段数据重复的个数

## 3、matplotlib生成统计图
只是简单介绍常见用法和参数  
架构图
![](/posts/matplotlib/anatomy.png)

中文架构图
![](/posts/matplotlib/anatomy_zh.png)

其他详细用法请参考官方手册: <https://matplotlib.org/stable/tutorials/index.html>

下面示例的源码参考github: <https://github.com.anTtutu/anttu.code.learn.python.git>

### 3.1 折线图
说明|描述
-|-
适用场景|折线图适合二维的大数据集，还适合多个二维数据集的比较。一般用来表示趋势的变化，横轴一般为日期字段。
优势|容易反应出数据变化的趋势。

#### 示例：
```python
plt.plot(x_data, y_data, '*-', label=u'请求攻击统计', linewidth=1)
```

#### demo:
```python
# -*- coding:utf-8 -*-

import pandas as pd
import matplotlib.pyplot as plt
import os

plt.rcParams['font.sans-serif'] = ['SimHei']
plt.rcParams['font.family'] = 'sans-serif'
# 解决负号'-'显示为方块的问题
plt.rcParams['axes.unicode_minus'] = False

# 相对路径
project_dir = os.path.abspath('.')

path = project_dir + "\\request.csv"
out_path = project_dir + "\\request_line.jpg"

# 全路径
# path = "D:\\request.csv"
# out_path = "D:\\request.jpg"


def main():
    # 使用python下pandas库读取csv文件
    data = pd.read_csv(path, encoding='gbk')
    # 读取列名为距离误差和时间点的所有行数据
    y_data = data.loc[:, 'error_count']
    x_data = data.loc[:, 'error_request_url']
    # 设置画布
    plt.figure(num=1, dpi=100, figsize=(24, 32))
    # 点线图
    plt.plot(x_data, y_data, '*-', label=u'请求攻击统计', linewidth=1)
    # 为了让x轴的内容适配展示的长度，请求路径字段比较长，有几十个字符
    plt.xticks(rotation=270)
    # 统计图的标题
    plt.title(u"请求攻击统计", size=20)
    # 显示图例
    plt.legend()
    # X坐标-横坐标标题
    plt.xlabel(u'请求名称', size=14)
    # Y坐标-纵坐标标题
    plt.ylabel(u'请求次数', size=14)
    # 在展示图片前可以将画出的曲线保存到自己路径下的文件夹中
    plt.savefig(out_path)
    # 显示图像
    plt.show()
    print("all picture is starting")


if __name__ == "__main__":
    main()
```

### 3.2 柱状图
说明|描述
-|-
适用场景|适用场合是二维数据集（每个数据点包括两个值x和y），但只有一个维度需要比较，用于显示一段时间内的数据变化或显示各项之间的比较情况。适用于枚举的数据，比如地域之间的关系，数据没有必然的连续性。
优势|柱状图利用柱子的高度，反映数据的差异，肉眼对高度差异很敏感。
劣势|柱状图的局限在于只适用中小规模的数据集。

#### 示例：
```python
plt.bar(np.arange(len(name_list)), height_list, label=u'请求攻击统计', tick_label=name_list, fc='r')
```

#### demo:
```python
# -*- coding:utf-8 -*-

import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
import os

plt.rcParams['font.sans-serif'] = ['SimHei']
plt.rcParams['font.family'] = 'sans-serif'
# 解决负号'-'显示为方块的问题
plt.rcParams['axes.unicode_minus'] = False

# 相对路径
project_dir = os.path.abspath('.')

path = project_dir + "\\request.csv"
out_path = project_dir + "\\request_bar.jpg"

# 全路径
# path = "D:\\request.csv"
# out_path = "D:\\request.jpg"


def main():
    # 使用python下pandas库读取csv文件
    data = pd.read_csv(path, encoding='gbk')
    # 读取列名为距离误差和时间点的所有行数据
    height_list = data.loc[:, 'error_count']
    name_list = data.loc[:, 'error_request_url']
    # 设置画布
    plt.figure(num=1, dpi=100, figsize=(24, 32))
    # 柱状图
    plt.bar(np.arange(len(name_list)), height_list, label=u'请求攻击统计', tick_label=name_list, fc='r')
    # 添加数据标签，也就是给柱子顶部添加标签
    x = np.arange(len(height_list))
    y = np.array(list(height_list.values))
    for a, b in zip(x, y):
        plt.text(a, b + 0.05, '%.0f' % b, ha='center', va='bottom', fontsize=10)
    # 为了让x轴的内容适配展示的长度，请求路径字段比较长，有几十个字符
    plt.xticks(rotation=270)
    # 统计图的标题
    plt.title(u"请求攻击统计", size=20)
    # 显示图例
    plt.legend()
    # X坐标-横坐标标题
    plt.xlabel(u'请求名称', size=14)
    # Y坐标-纵坐标标题
    plt.ylabel(u'请求次数', size=14)
    # 在展示图片前可以将画出的曲线保存到自己路径下的文件夹中
    plt.savefig(out_path)
    # 显示图像
    plt.show()
    print("all picture is starting")


if __name__ == "__main__":
    main()
```

### 3.3 堆积柱状图
说明|描述
-|-
适用场景|显示各个项目之间的比较情况，和柱状图类似的作用。不仅可以直观的看出每个系列的值，还能够反映出系列的总和，尤其是当需要看某一单位的综合以及各系列值的比重时，最适合。
优势|每个条都清晰表示数据，直观。

#### demo：
```python
# -*- coding:utf-8 -*-

import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
import os

plt.rcParams['font.sans-serif'] = ['SimHei']
plt.rcParams['font.family'] = 'sans-serif'
# 解决负号'-'显示为方块的问题
plt.rcParams['axes.unicode_minus'] = False
plt.rcParams['axes.labelsize'] = 32
plt.rcParams['xtick.labelsize'] = 24
plt.rcParams['ytick.labelsize'] = 24
plt.rcParams['legend.fontsize'] = 20

# 相对路径
project_dir = os.path.abspath('.')

path = project_dir + "\\stack.csv"
out_path = project_dir + "\\request_stack_bar.jpg"

# 全路径
# path = "D:\\request.csv"
# out_path = "D:\\request.jpg"


def main():
    # 使用python下pandas库读取csv文件
    data = pd.read_csv(path, encoding='utf-8')
    # 读取列名为距离误差和时间点的所有行数据
    name_list = data.loc[:, '姓名']
    january_list = data.loc[:, '一月']
    february_list = data.loc[:, '二月']
    march_list = data.loc[:, '三月']
    april_list = data.loc[:, '四月']
    may_list = data.loc[:, '五月']
    june_list = data.loc[:, '六月']
    july_list = data.loc[:, '七月']
    august_list = data.loc[:, '八月']
    september_list = data.loc[:, '九月']
    october_list = data.loc[:, '十月']
    november_list = data.loc[:, '十一月']
    december_list = data.loc[:, '十二月']
    # 设置画布
    plt.figure(num=1, dpi=100, figsize=(24, 32))
    # 柱状图
    plt.bar(np.arange(len(name_list)), january_list, label=u'1月业绩', tick_label=name_list, fc='r')
    plt.bar(np.arange(len(name_list)), february_list, label=u'2月业绩', bottom=january_list, tick_label=name_list, fc='b')
    plt.bar(np.arange(len(name_list)), march_list, label=u'3月业绩', bottom=january_list+february_list, tick_label=name_list, fc='g')
    plt.bar(np.arange(len(name_list)), april_list, label=u'4月业绩', bottom=january_list+february_list+march_list, tick_label=name_list, fc='c')
    plt.bar(np.arange(len(name_list)), may_list, label=u'5月业绩', bottom=january_list+february_list+march_list+april_list, tick_label=name_list, fc='y')
    plt.bar(np.arange(len(name_list)), june_list, label=u'6月业绩', bottom=january_list+february_list+march_list+april_list+may_list, tick_label=name_list, fc='m')
    plt.bar(np.arange(len(name_list)), july_list, label=u'7月业绩', bottom=january_list+february_list+march_list+april_list+may_list+june_list, tick_label=name_list, fc='WhiteSmoke')
    plt.bar(np.arange(len(name_list)), august_list, label=u'8月业绩', bottom=january_list+february_list+march_list+april_list+may_list+june_list+july_list, tick_label=name_list, fc='pink')
    plt.bar(np.arange(len(name_list)), september_list, label=u'9月业绩', bottom=january_list+february_list+march_list+april_list+may_list+june_list+july_list+august_list, tick_label=name_list, fc='olive')
    plt.bar(np.arange(len(name_list)), october_list, label=u'10月业绩', bottom=january_list+february_list+march_list+april_list+may_list+june_list+july_list+august_list+september_list, tick_label=name_list, fc='navy')
    plt.bar(np.arange(len(name_list)), november_list, label=u'11月业绩', bottom=january_list+february_list+march_list+april_list+may_list+june_list+july_list+august_list+september_list+october_list, tick_label=name_list, fc='linen')
    plt.bar(np.arange(len(name_list)), december_list, label=u'12月业绩', bottom=january_list+february_list+march_list+april_list+may_list+june_list+july_list+august_list+september_list+october_list+november_list, tick_label=name_list, fc='teal')
    # 添加数据标签，也就是给柱子顶部添加标签
    x = np.arange(len(name_list))
    y1 = np.array(list(january_list.values))
    for a, b in zip(x, y1):
        plt.text(a, b + 0.05, '%.0f' % b, ha='center', va='bottom', fontsize=24)

    y2 = np.array(list((january_list+february_list).values))
    for a, b in zip(x, y2):
        plt.text(a, b + 0.05, '%.0f' % b, ha='center', va='bottom', fontsize=24)

    y3 = np.array(list((january_list+february_list+march_list).values))
    for a, b in zip(x, y3):
        plt.text(a, b + 0.05, '%.0f' % b, ha='center', va='bottom', fontsize=24)

    y4 = np.array(list((january_list+february_list+march_list+april_list).values))
    for a, b in zip(x, y4):
        plt.text(a, b + 0.05, '%.0f' % b, ha='center', va='bottom', fontsize=24)

    y5 = np.array(list((january_list+february_list+march_list+april_list+may_list).values))
    for a, b in zip(x, y5):
        plt.text(a, b + 0.05, '%.0f' % b, ha='center', va='bottom', fontsize=24)

    y6 = np.array(list((january_list+february_list+march_list+april_list+may_list+june_list).values))
    for a, b in zip(x, y6):
        plt.text(a, b + 0.05, '%.0f' % b, ha='center', va='bottom', fontsize=24)

    y7 = np.array(list((january_list+february_list+march_list+april_list+may_list+june_list+july_list).values))
    for a, b in zip(x, y7):
        plt.text(a, b + 0.05, '%.0f' % b, ha='center', va='bottom', fontsize=24)

    y8 = np.array(list((january_list+february_list+march_list+april_list+may_list+june_list+july_list+august_list).values))
    for a, b in zip(x, y8):
        plt.text(a, b + 0.05, '%.0f' % b, ha='center', va='bottom', fontsize=24)

    y9 = np.array(list((january_list+february_list+march_list+april_list+may_list+june_list+july_list+august_list+september_list).values))
    for a, b in zip(x, y9):
        plt.text(a, b + 0.05, '%.0f' % b, ha='center', va='bottom', fontsize=24)

    y10 = np.array(list((january_list+february_list+march_list+april_list+may_list+june_list+july_list+august_list+september_list+october_list).values))
    for a, b in zip(x, y10):
        plt.text(a, b + 0.05, '%.0f' % b, ha='center', va='bottom', fontsize=24)

    y11 = np.array(list((january_list+february_list+march_list+april_list+may_list+june_list+july_list+august_list+september_list+october_list+november_list).values))
    for a, b in zip(x, y11):
        plt.text(a, b + 0.05, '%.0f' % b, ha='center', va='bottom', fontsize=24)

    y12 = np.array(list((january_list+february_list+march_list+april_list+may_list+june_list+july_list+august_list+september_list+october_list+november_list+december_list).values))
    for a, b in zip(x, y12):
        plt.text(a, b + 0.05, '%.0f' % b, ha='center', va='bottom', fontsize=24, color='AliceBlue')
    # 为了让x轴的内容适配展示的长度，请求路径字段比较长，有几十个字符
    plt.xticks(np.arange(len(name_list)), name_list)
    # 统计图的标题
    plt.title(u"XX公司部门每月销售额", size=32)
    # 显示图例
    plt.legend()
    # X坐标-横坐标标题
    plt.xlabel(u'部门名称', size=24)
    # Y坐标-纵坐标标题
    plt.ylabel(u'销售额', size=24)
    # 在展示图片前可以将画出的曲线保存到自己路径下的文件夹中
    plt.savefig(out_path)
    # 显示图像
    plt.show()
    print("all picture is starting")


if __name__ == "__main__":
    main()
```

### 3.4 饼状图
说明|描述
-|-
适用场景|显示各项的大小与各项总和的比例。适用简单的占比比例图，在不要求数据精细的情况适用。
优势|明确显示数据的比例情况，尤其合适渠道来源等场景。
劣势|不会具体的数值，只是整体的占比情况。

#### 示例：
```python
plt.pie(money_list, explode=explode, labels=label_list, autopct='%1.1f%%', textprops={'fontsize': 43, 'color': 'k'}, shadow=True, startangle=90)
```

#### demo:
```python
# -*- coding:utf-8 -*-

import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
import os

plt.rcParams['font.sans-serif'] = ['SimHei']
plt.rcParams['font.family'] = 'sans-serif'
# 解决负号'-'显示为方块的问题
plt.rcParams['axes.unicode_minus'] = False

# 相对路径
project_dir = os.path.abspath('.')

path = project_dir + "\\pie.csv"
out_path = project_dir + "\\request_pie.jpg"

# 全路径
# path = "D:\\request.csv"
# out_path = "D:\\request.jpg"


def main():
    # 使用python下pandas库读取csv文件
    data = pd.read_csv(path, encoding='utf-8')
    # 读取列名为距离误差和时间点的所有行数据
    label_list = data.loc[:, '月份']
    money_list = data.loc[:, '销售']

    # 设定各项距离圆心n个半径
    explode = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]

    # 设置画布
    plt.figure(num=1, dpi=100, figsize=(24, 32))
    # 饼状图
    plt.pie(money_list, explode=explode, labels=label_list, autopct='%1.1f%%', textprops={'fontsize': 43, 'color': 'k'}, shadow=True, startangle=90)
    # 显示图例
    plt.legend()
    # 统计图的标题
    plt.title(u"XX公司部门每月销售额", size=32)
    # 在展示图片前可以将画出的曲线保存到自己路径下的文件夹中
    plt.savefig(out_path)
    # 显示图像
    plt.show()
    print("all picture is starting")


if __name__ == "__main__":
    main()
```

### 3.5 散点图
说明|描述
-|-
适用场景|显示若干数据系列中各数值之间的关系，类似XY轴，判断两变量之间是否存在某种关联。散点图适用于三维数据集，但其中只有两维数据是需要比较的。另外，散点图还可以看出极值的分布情况。
优势|对于处理值的分布和数据点的分簇区域（通过设置横纵项的辅助线），散点图都很理想。如果数据集中包含非常多的点，那么散点图便是最佳图表类型。
劣势|在点状图中显示多个序列看上去非常混乱。

#### demo:
```python
# !/usr/bin/python3
# -*- coding: utf-8 -*-
"""
@Description    :  散点图
@Author         :  Anttu
@Version        :  v1.0
@File           :  testScatter.py
@CreateTime     :  15/5/2021 21:28
"""

import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
import os
import platform

# 系统
print(platform.system())

# 相对路径
project_dir = os.path.abspath('.')
print(project_dir)
fileName = "scatter.csv"
outFileName = "request_scatter.jpg"

fontName = "SimHei"
if platform.system() == 'Windows':
    print('Windows系统')
    fontName = ["SimHei"]
elif platform.system() == 'Linux':
    print('Linux系统')
    fontName = ["SimHei"]
elif platform.system() == 'Darwin':
    print('MacOS系统')
    fontName = ["PingFang HK"]
else:
    print('其他')

# Mac字体 PingFang HK
# win字体 SimHei
plt.rcParams['font.sans-serif'] = fontName
plt.rcParams['font.family'] = 'sans-serif'
# 解决负号'-'显示为方块的问题
plt.rcParams['axes.unicode_minus'] = False

filePath = os.sep.join([project_dir, fileName])
outPath = os.sep.join([project_dir, outFileName])

# 全路径
# filePath = "D:\\request.csv"
# outPath = "D:\\request.jpg"


def main():
    # 使用python下pandas库读取csv文件
    data = pd.read_csv(filePath, encoding='utf-8')
    # 读取列名
    height = data.loc[:, ['性别', '身高']]
    weight = data.loc[:, ['性别', '体重']]
    # 身高
    male_height = height.loc[height['性别'] == 1]
    female_height = height.loc[height['性别'] == 0]
    # 体重
    male_weight = weight.loc[weight['性别'] == 1]
    female_weight = weight.loc[weight['性别'] == 0]

    # 设置画布
    plt.figure(dpi=100, figsize=(24, 32))
    # 散点图
    plt.scatter(male_height, male_weight, marker='x', color='b', alpha=0.5)
    plt.scatter(female_height, female_weight, color='r', alpha=0.5)
    # 显示图例
    plt.legend(('Male', 'Female'))
    # X坐标-横坐标标题
    plt.xlabel(u'身高/Height(厘米)', size=24)
    # Y坐标-纵坐标标题
    plt.ylabel(u'体重/Weight(公斤)', size=24)
    # 统计图的标题
    plt.title(u"XX公司男女身高/体重分布", size=32)
    # 网格
    plt.grid(True)
    # 在展示图片前可以将画出的曲线保存到自己路径下的文件夹中
    plt.savefig(outPath)
    # 显示图像
    plt.show()
    print("all picture is starting")


if __name__ == "__main__":
    main()

```

### 3.6 漏斗图
说明|描述
-|-
适用场景|漏斗图适用于业务流程多的流程分析，显示各流程的转化率。
优势|在网站分析中，通常用于转化率比较，它不仅能展示用户从进入网站到实现购买的最终转化率，还可以展示每个步骤的转化率，能够直观地发现和说明问题所在。
劣势|单一漏斗图无法评价网站某个关键流程中各步骤转化率的好坏。

#### demo:
```python
```

### 3.7 雷达图
说明|描述
-|-
适用场景|雷达图适用于多维数据（四维以上），一般是用来表示某个数据字段的综合情况，数据点一般6个左右，太多的话辨别起来有困难。
优势|主要用来了解公司各项数据指标的变动情形及其好坏趋向。
劣势|理解成本较高。

#### demo：
```python
# !/usr/bin/python3
# -*- coding: utf-8 -*-
"""
@Description    :  雷达图
@Author         :  Anttu
@Version        :  v1.0
@File           :  testRadar.py
@CreateTime     :  8/6/2021 10:00
"""

import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
import os
import platform

# 系统
print(platform.system())

# 相对路径
project_dir = os.path.abspath('.')
print(project_dir)
fileName = "ninjas.csv"
outFileName = "request_radar_ninja_"

fontName = "SimHei"
if platform.system() == 'Windows':
    print('Windows系统')
    fontName = ["SimHei"]
elif platform.system() == 'Linux':
    print('Linux系统')
    fontName = ["SimHei"]
elif platform.system() == 'Darwin':
    print('MacOS系统')
    fontName = ["PingFang HK"]
else:
    print('其他')

# Mac字体 PingFang HK
# win字体 SimHei
plt.rcParams['font.sans-serif'] = fontName
plt.rcParams['font.family'] = 'sans-serif'
# 解决负号'-'显示为方块的问题
plt.rcParams['axes.unicode_minus'] = False

filePath = os.sep.join([project_dir, fileName])
outPath = os.sep.join([project_dir, outFileName])

# 全路径
# filePath = "D:\\request.csv"
# outPath = "D:\\request.jpg"


def main():
    # 使用python下pandas库读取csv文件
    data = pd.read_csv(filePath, encoding='utf-8')
    # 读取列名
    ability_name = data.loc[:, '忍':'印']
    # 名称列
    ability_value = data.loc[:, ]

    # 能力值的名称，需要去掉姓名和合计才可以放到雷达图中
    col_names = data.keys()
    labels = col_names.drop(['姓名', '合计'])
    data_length = len(labels)

    # labels里有几个数据，就把整圆360°分成几份，设置雷达图的角度，用于平分切开一个平面
    angle = np.linspace(0, 2 * np.pi, data_length, endpoint=False)

    # 使雷达图封闭起来
    labels = np.concatenate((labels, [labels[0]]))
    angles = np.concatenate((angle, [angle[0]]))

    for index in range(len(ability_name)):
        # 技能值
        result = ability_name.iloc[index].values
        # 使雷达图封闭起来
        values = np.concatenate((result, [result[0]]))

        # 设置画布
        fig = plt.figure(dpi=100, figsize=(8, 6))

        # 设置为极坐标格式
        ax = fig.add_subplot(111, polar=True)
        # 绘制折线图
        ax.plot(angles, values, 'o-', linewidth=1)
        ax.fill(angles, values, 'r', alpha=0.5)
        # 添加每个特质的标签
        ax.set_thetagrids(angles * 180 / np.pi, labels)
        # 设置极轴范围
        ax.set_rlim(0, 10)
        # 设置雷达图的坐标值显示角度，相对于起始角度的偏移量
        ax.set_rlabel_position(360)

        # 统计图的标题
        title_name = '火影 - ' + ability_value['姓名'][index] + ' === 合计[' + str(ability_value['合计'][index]) + ']'
        plt.title(title_name, size=14)
        # 网格
        plt.grid(True)
        # 在展示图片前可以将画出的曲线保存到自己路径下的文件夹中
        plt.savefig(os.sep.join([project_dir, outFileName + ability_value['姓名'][index] + '.jpg']))
        # 显示图像
        plt.show()
    print("all picture is starting")


if __name__ == "__main__":
    main()
```

### 3.8 数字地图
说明|描述
-|-
适用场景|适用于有空间位置的数据集，一般分成行政地图（气泡图、面积图）和GIS地图。行政地图一般有省份、城市数据就够了（比如福建-泉州）；而GIS地图则需要经纬度数据，更细化到具体区域，只要有数据，可做区域、全国甚至全球的地图。
优劣势|特殊状况下使用，涉及行政区域。

#### demo：
```python
```

### 3.9 热力图
说明|描述
-|-
适用场景|适用于有空间位置的数据集，一般分成行政地图（气泡图、面积图）和GIS地图。行政地图一般有省份、城市数据就够了（比如福建-泉州）；而GIS地图则需要经纬度数据，更细化到具体区域，只要有数据，可做区域、全国甚至全球的地图。
优劣势|特殊状况下使用，涉及行政区域。

#### demo：
```python
# !/usr/bin/python3
# -*- coding: utf-8 -*-
"""
@Description    :  热力图
@Author         :  Anttu
@Version        :  v1.0
@File           :  testHeatMap.py
@CreateTime     :  19/5/2021 01:39
"""


import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
import os
import platform

# 系统
print(platform.system())

# 相对路径
project_dir = os.path.abspath('.')
print(project_dir)
fileName = "heatmap.csv"
outFileName = "request_heatmap.jpg"

fontName = "SimHei"
if platform.system() == 'Windows':
    print('Windows系统')
    fontName = ["SimHei"]
elif platform.system() == 'Linux':
    print('Linux系统')
    fontName = ["SimHei"]
elif platform.system() == 'Darwin':
    print('MacOS系统')
    fontName = ["PingFang HK"]
else:
    print('其他')

# Mac字体 PingFang HK
# win字体 SimHei
plt.rcParams['font.sans-serif'] = fontName
plt.rcParams['font.family'] = 'sans-serif'
# 解决负号'-'显示为方块的问题
plt.rcParams['axes.unicode_minus'] = False

filePath = os.sep.join([project_dir, fileName])
outPath = os.sep.join([project_dir, outFileName])

# 全路径
# filePath = "D:\\request.csv"
# outPath = "D:\\request.jpg"


def main():
    # 使用python下pandas库读取csv文件
    data_nba = pd.read_csv(filePath, encoding='utf-8')
    # 读取列名
    score = data_nba.loc[:, "G":"PF"].values
    # 名称列
    name = data_nba.iloc[:, 0]
    # 技术指标行
    col = data_nba.loc[:, "G":"PF"].columns

    # 设置画布
    fig = plt.figure(dpi=100, figsize=(24, 32))
    # 散点图的变种气泡图
    im = plt.imshow(score, cmap='plasma_r')
    # 设置X轴刻度
    plt.xticks(np.arange(len(col)), col.values)
    # 设置Y轴刻度
    plt.yticks(np.arange(len(name)), name.values)
    # 显示图例
    # plt.legend()
    # 设置颜色条
    fig.colorbar(im, pad=0.03)
    # X坐标-横坐标标题
    plt.xlabel(u'技术指标', size=24)
    # Y坐标-纵坐标标题
    plt.ylabel(u'姓名', size=24)
    # 统计图的标题
    plt.title(u"NBA Average Performance (Top 50 Players)", size=32)
    # 网格
    plt.grid(True)
    # 在展示图片前可以将画出的曲线保存到自己路径下的文件夹中
    plt.savefig(outPath)
    # 显示图像
    plt.show()
    print("all picture is starting")


if __name__ == "__main__":
    main()
```

### 3.10 气泡图
说明|描述
-|-
适用场景|适用于有空间位置的数据集，一般分成行政地图（气泡图、面积图）和GIS地图。行政地图一般有省份、城市数据就够了（比如福建-泉州）；而GIS地图则需要经纬度数据，更细化到具体区域，只要有数据，可做区域、全国甚至全球的地图。
优劣势|特殊状况下使用，涉及行政区域。

#### demo： 
```python
# !/usr/bin/python3
# -*- coding: utf-8 -*-
"""
@Description    :  气泡图
@Author         :  Anttu
@Version        :  v1.0
@File           :  testBubble.py
@CreateTime     :  7/6/2021 15:38
"""

import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
import os
import platform

# 系统
print(platform.system())

# 相对路径
project_dir = os.path.abspath('.')
print(project_dir)
fileName = "bubble.csv"
outFileName = "request_bubble.jpg"

fontName = "SimHei"
if platform.system() == 'Windows':
    print('Windows系统')
    fontName = ["SimHei"]
elif platform.system() == 'Linux':
    print('Linux系统')
    fontName = ["SimHei"]
elif platform.system() == 'Darwin':
    print('MacOS系统')
    fontName = ["PingFang HK"]
else:
    print('其他')

# Mac字体 PingFang HK
# win字体 SimHei
plt.rcParams['font.sans-serif'] = fontName
plt.rcParams['font.family'] = 'sans-serif'
# 解决负号'-'显示为方块的问题
plt.rcParams['axes.unicode_minus'] = False

filePath = os.sep.join([project_dir, fileName])
outPath = os.sep.join([project_dir, outFileName])

# 全路径
# filePath = "D:\\request.csv"
# outPath = "D:\\request.jpg"


def main():
    # 使用python下pandas库读取csv文件
    data = pd.read_csv(filePath, encoding='utf-8')
    # 读取列名
    value = data.loc[:, ]

    x = value['x']
    y = value['y']
    s = value['size']*200
    colors = value['size']

    # 设置画布
    plt.figure(dpi=100, figsize=(24, 32))
    # 散点图的变种气泡图
    plt.scatter(x, y, s=s, c=colors, label='Size值分布', alpha=0.5)
    # 显示图例
    # plt.legend('Size')
    # X坐标-横坐标标题
    plt.xlabel(u'X坐标刻度', size=24)
    # Y坐标-纵坐标标题
    plt.ylabel(u'Y坐标刻度', size=24)
    # 统计图的标题
    plt.title(u"XX值分布气泡图", size=32)
    # 网格
    plt.grid(True)
    # 在展示图片前可以将画出的曲线保存到自己路径下的文件夹中
    plt.savefig(outPath)
    # 显示图像
    plt.show()
    print("all picture is starting")


if __name__ == "__main__":
    main()

```

## 5、demo代码
示例的代码仓库： <https://github.com/anTtutu/anttu.code.learn.python/tree/master/matplotlib>

其他统计图等后续整理补充...