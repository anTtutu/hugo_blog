---
title: "python工具-faker测试数据生成器"
date: 2021-06-05T00:29:47+08:00
tag : [ "python", "test", "faker" ]
description: "python工具-faker测试数据生成器"
categories: [ "python", "test", "faker" ]
toc: true
---

## 1、参考
官方地址： <https://faker.readthedocs.io/>  
ruby 和 java 下都有类似的 faker 工具，但是对比过 java 的，还是 python 这个完善很多。ruby 的暂没测试

## 2、用法示例
```python
from faker import Faker

fake = Faker(locale='zh_CN') 
#为生成数据的文化选项，默认为en_US，只有使用了相关文化，才能生成对应的随机信息
#由于文化差异，设置文化的时候会导致有些字段比如省份等会出现方法报错等问题
```
## 3、常用函数介绍
参数|说明
-|-
city_suffix()|市，县
country()|国家
country_code()|国家编码
district()|区
geo_coordinate()|地理坐标
latitude()|地理坐标(纬度)
longitude()|地理坐标(经度)
lexify()|替换所有问号（“？”）带有随机字母的事件。
numerify()|三位随机数字
postcode()|邮编
province()|省份
street_address()|街道地址
street_name()|街道名
street_suffix()|街、路
random_digit()|0~9随机数
random_digit_not_null()|1~9的随机数
random_element()|随机字母
random_int()|随机数字，默认0~9999，可以通过设置min,max来设置
random_letter()|随机字母
random_number()|随机数字，参数digits设置生成的数字位数
color_name()|随机颜色名
hex_color()|随机HEX颜色
rgb_color()|随机RGB颜色
safe_color_name()|随机安全色名
safe_hex_color()|随机安全HEX颜色
bs()|随机公司服务名
company()|随机公司名（长）
company_prefix()|随机公司名（短）
company_suffix()|公司性质
credit_card_expire()|随机信用卡到期日
credit_card_full()|生成完整信用卡信息
credit_card_number()|信用卡号
credit_card_provider()|信用卡类型
credit_card_security_code()|信用卡安全码
currency_code()|货币编码
am_pm()|AM/PM
century()|随机世纪
date()|随机日期
date_between()|随机生成指定范围内日期，参数|start_date，end_date取值|具体日期或者today,-30d,-30y类似
date_between_dates()|随机生成指定范围内日期，用法同上
date_object()|随机生产从1970-1-1到指定日期的随机日期。
date_this_month()|
date_this_year()|
date_time()|随机生成指定时间（1970年1月1日至今）
date_time_ad()|生成公元1年到现在的随机时间
date_time_between()|用法同dates
future_date()|未来日期
future_datetime()|未来时间
month()|随机月份
month_name()|随机月份（英文）
past_date()|随机生成已经过去的日期
past_datetime()|随机生成已经过去的时间
time()|随机24小时时间
timedelta()|随机获取时间差
time_object()|随机24小时时间，time对象
time_series()|随机TimeSeries对象
timezone()|随机时区
unix_time()|随机Unix时间
year()|随机年份
file_extension()|随机文件扩展名
file_name()|随机文件名（包含扩展名，不包含路径）
file_path()|随机文件路径（包含文件名，扩展名）
mime_type()|随机mime Type
ascii_company_email()|随机ASCII公司邮箱名
ascii_email()|随机ASCII邮箱
ascii_free_email()|
ascii_safe_email()|
company_email()|
domain_name()|生成域名
domain_word()|域词(即，不包含后缀)
email()|
free_email()|
free_email_domain()|
f.safe_email()|安全邮箱
f.image_url()|随机URL地址
ipv4()|随机IP4地址
ipv6()|随机IP6地址
mac_address()|随机MAC地址
tld()|网址域名后缀(.com,.net.cn,等等，不包括.)
uri()|随机URI地址
uri_extension()|网址文件后缀
uri_page()|网址文件（不包含后缀）
uri_path()|网址文件路径（不包含文件名）
url()|随机URL地址
user_name()|随机用户名
isbn10()|随机ISBN（10位）
isbn13()|随机ISBN（13位）
job()|随机职位
paragraph()|随机生成一个段落
paragraphs()|随机生成多个段落，通过参数nb来控制段落数，返回数组
sentence()|随机生成一句话
sentences()|随机生成多句话，与段落类似
text()|随机生成一篇文章（不要幻想着人工智能了，至今没完全看懂一句话是什么意思）
word()|随机生成词语
words()|随机生成多个词语，用法与段落，句子，类似
binary()|随机生成二进制编码
boolean()|True/False
language_code()|随机生成两位语言编码
locale()|随机生成语言/国际 信息
md5()|随机生成MD5
null_boolean()|NULL/True/False
password()|随机生成密码,可选参数：length：密码长度；special_chars：是否能使用特殊字符；digits：是否包含数字；upper_case：是否包含大写字母；lower_case：是否包含小写字母
sha1()|随机SHA1
sha256()|随机SHA256
uuid4()|随机UUID
first_name()|
first_name_female()|女性名
first_name_male()|男性名
first_romanized_name()|罗马名
last_name()|
last_name_female()|女姓
last_name_male()|男姓
last_romanized_name()|
name()|随机生成全名
name_female()|男性全名
name_male()|女性全名
romanized_name()|罗马名
msisdn()|移动台国际用户识别码，即移动用户的ISDN号码
phone_number()|随机生成手机号
phonenumber_prefix()|随机生成手机号段
profile()|随机生成档案信息
simple_profile()|随机生成简单档案信息

## 4、随机生成指定类型数据
参数|说明
-|-
pybool()|布尔类型
pydecimal()|数字
pydict()|字典
pyfloat()|left_digits=5 #生成的整数位数, right_digits=2 #生成的小数位数, positive=True #是否只有正数
pyint()|整型
pyiterable()|迭代器
pylist()|列表
pyset()|集合
pystr()|字符串
pystruct()|结构体
pytuple()|元组

## 5、随机生成常用数据
参数|说明
-|-
ssn()|生成身份证号
chrome()|随机生成Chrome的浏览器user_agent信息
firefox()|随机生成FireFox的浏览器user_agent信息
internet_explorer()|随机生成IE的浏览器user_agent信息
opera()|随机生成Opera的浏览器user_agent信息
safari()|随机生成Safari的浏览器user_agent信息
linux_platform_token()|随机Linux信息
user_agent()|随机user_agent信息