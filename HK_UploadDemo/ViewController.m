//
//  ViewController.m
//  HK_UploadDemo
//
//  Created by houke on 2018/1/15.
//  Copyright © 2018年 houke. All rights reserved.
//

#import "ViewController.h"

#define Boundary @"3g"
#define NewLine @"\r\n"
#define Encode(str) [str dataUsingEncoding:NSUTF8StringEncoding] //URL编码

/*
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
 
 文件上传实现
 
 
 */
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self upload];
    // Do any additional setup after loading the view, typically from a nib.
}

-(void)upload
{
    //1、获取网络请求的服务器地址
    NSURL * url = [NSURL URLWithString:@""];
    
    //2、创建一个POST请求
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"post";//指定请求的方式是 post请求
    
    //3、设置请求体
    NSMutableData *body = [NSMutableData data];
    
    //设置非文件的其他信息参数（包括用户名、密码、devicetoken 等）
    NSDictionary *param = @{@"name":@"小明", @"age":@"18"};
    
    //文件参数
    [body appendData:Encode(@"--")];//body添加分界线
    [body appendData:Encode(Boundary)];//body 添加分隔符
    [body appendData:Encode(NewLine)];//body 添加换行
    
    //获取上传文件的格式
    //获取本地文件路径，同时转换成 URL 编码
    NSURL *urlPath = [[NSBundle mainBundle] URLForResource:@"filename" withExtension:@"txt"];
    //创建请求
    NSURLRequest *requestPath = [NSURLRequest requestWithURL:urlPath];
    //发送请求
    NSURLResponse *response = nil;
    //通过发送本地的路径来获取到本地文件的 MIMEType,通过这个 type 跟服务器进行通讯
    [NSURLConnection sendSynchronousRequest:requestPath returningResponse:&response error:nil];
    //定义一个字符串去接收 type
    NSString *MIMEType = response.MIMEType;
    
    //声明上传文件的格式
    NSString *type = [NSString stringWithFormat:@"Content-Type:%@",MIMEType];
    //将 type拼接到 body里
    [body appendData:Encode(type)];
    //拼接换行符
    [body appendData:Encode(NewLine)];
    
    
    //将本地文件转换成 data数据类型，拼接到 body
    NSData *fileData = [NSData dataWithContentsOfURL:urlPath];
    [body appendData:fileData];
    [body appendData:Encode(@"--")];
    
    //添加字段名称
    NSString *disposition = [NSString stringWithFormat:@"Content-Disposition:form-data;name=\"%@\";filename=\"%@\"",@"参数名",@"文件名"];
    [body appendData:Encode(disposition)];
    [body appendData:Encode(NewLine)];
    
    //非文件参数
    [param enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [body appendData:Encode(@"--")];
        [body appendData:Encode(Boundary)];
        [body appendData:Encode(NewLine)];
        
        //二进制编码
         NSString *disposition = [NSString stringWithFormat:@"Content-Disposition:form-data;name=\"%@\"", key];
        [body appendData:Encode(disposition)];
        [body appendData:Encode(NewLine)];
        
        [body appendData:Encode(NewLine)];
        [body appendData:Encode([obj description])];
        [body appendData:Encode(NewLine)];
    }];
    
    //设置结束标记
    [body appendData:Encode(@"--")];
    [body appendData:Encode(Boundary)];
    [body appendData:Encode(@"--")];
    [body appendData:Encode(NewLine)];
    
    //设置 HTTPBody
    request.HTTPBody = body;
    
    //4、设置请求头(告诉服务器这次上传的是一个文件数据,同时是一个上传的请求)
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data;boundary=%@",Boundary];
    [request setValue:contentType forHTTPHeaderField:@"Content-Type"];
    
    //5、发送请求
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
        
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
























