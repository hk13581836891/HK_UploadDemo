# HK_UploadDemo
上传文件（图片、音视频、文本）--MultipartFormData

*MultipartFormData 格式的数据上传

文件上传请求格式
1 Content-Type : multipart/form-data; boundary=hkBoundary
2
3 --hkBoundary
4 Content-Disposition : form-data; name="参数名"
5
6 Hello world!(参数值)
7 --hkBoundary
8 Content-Disposition : form-data; name="参数名"; filename="上传文件名"
9 Content-Type : image/png
10
11 ... contents of image.png ...
12 --hkBoundary

line1 指定了 http请求的编码方式为：multipar/form-data,在 ios 中必须用这种方式去编码;指定 hkBoundary 为分界线/分隔符,也叫标识字符串(不能使用中文)
line3 line7 line13 是分界线,分界线必须单独一行，是用来分割不同的字段
line4 声明了一个字段的名称 field1
line6 Hello world! 是field1这个字段的值
line8 声明了一个变量 pic,就是要上传的文件;上传文件的时候需要在后面指定 filename,并且需要在下一行指定文件格式
line11 二进制的内容

文件上传方法
-- 1、文件上传的基础方法是 POST,是由 POST 方法组合实现的
2、文件上传与 POST请求的不同之处在于:POST有请求体就可以请求数据，但文件上传必须有 请求头+请求体
3、文件上传的请求头必须包含一个特殊的头信息：Content-Type,而且其值必须是multipart/form-data；同时还要规定一个内容分隔符来分割请求体中的的多个 POST 内容,具体头信息Content-Type:multipart/form-data, boundary=hkBoundary

常用文件MIMEType
-- 说明上传文件的格式跟服务器通讯时需要编码的格式
图片:
png  image/png
jpg/jpeg image/jpeg
gif  image/gif
bmp  image/bmp
多媒体:
mp3 audio/mpeg
mp4 video/mp4
文本：
js   application/javascript
pdf  application/pdf
text/txt text/plain
json application/json
xml  text/xml
