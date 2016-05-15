//
//  ViewController.m
//  DataEncryption
//
//  Created by lanouhn on 16/5/14.
//  Copyright © 2016年 lanouhn. All rights reserved.
//

#import "ViewController.h"
//MD5
#import <CommonCrypto/CommonCrypto.h>
//复杂对象
#import "Person.h"
//第三方base64加密
#import "GTMBase64.h"
//RSA 公钥解密（解密），私钥加密（解密）
#import "RSA.h"
//钥匙串加密
#import "KeychainItemWrapper.h"

@interface ViewController ()

@end

//MD5属于非对称性加密，不能解密，MD5就是把数据按照一定的编码格式转换为16个16进制位（每个字节可以存储两个16进制数）。所以最终加密结果就是由0-9、A-F组成的32位的字符串。
//MD5只能对NSString和NSData加密，所以其他想要加密的数据可以转为NSData再进行加密。

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //MD5对字符串进行加密
    [self md5WithString:@"hehe"];
    
    //MD5对图片进行加密
    [self imageTransformToData];
    
    //MD5对数组进行加密
    [self systemToData];
    
    //base64加密
    [self base64WithString:@"加密"];
    
    //使用第三方进行加密
    //MD5加密
    [GTMBase64 md5_base64:@"hello"];
    //base64对字符串加密
    [GTMBase64 encodeBase64String:@"hello"];
    //base64对字符串解密
    [GTMBase64 decodeBase64String:@"hello"];
    
    //RSA进行加密解密
    [self RSAEncoderWithString:@"hello"];
    
    NSLog(@"今天星期天");
    NSLog(@"今天天气不错");
    NSLog(@"今天中午吃什么");
}

#pragma mark - MD5对字符串进行加密
//使用MD5对字符串进行加密
- (void)md5WithString:(NSString *)str{
    //MD5加密方式使用的是C语言函数
    //所以，1.要将OC字符串对象转化为C语言中字符串
    const char *cStr = [str UTF8String];
    //2.创建c数组，用来接收MD5加密后得值
    unsigned char result [CC_MD5_DIGEST_LENGTH];
    //3.计算MD5的值，进行加密
    CC_MD5(cStr, (CC_LONG)strlen(cStr), result);
    //参数1：加密的C字符串
    //参数2：字符串长度（转为CC_LONG类型）
    //参数3：存储密文的数组首地址（数组就是首地址）
    NSLog(@"%s", result);
    //4.获取摘要
    NSMutableString *resultStr = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [resultStr appendFormat:@"%02x",result[i]];
    }
    NSLog(@"%@", resultStr);

}

//图片转化为data
- (void)imageTransformToData{
    //1.获取图片路径
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"img" ofType:@"png"];
    //2.根据路径将图片转为data
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    //3.对data进行加密（此方法在下面进行封装）
    [self md5WithData:data];
}


//将数组转化为data进行加密
- (void)systemToData{
    //1.创建数组（简单对象）
    NSArray *array = @[@"呵呵", @123];
    //2.转为data
    NSData *data = [NSJSONSerialization dataWithJSONObject:array options:(NSJSONWritingPrettyPrinted) error:nil];
    //3.加密
    [self md5WithData:data];
}

//复杂对象转为data
- (void)personToData{
    //1.创建Person对象
    Person *person = [[Person alloc] init];
    person.name = @"小黄";
    person.gender = @"boy";
    person.age = @13;
    //2.对复杂对象进行归档转化为data
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:person];
    //3.调用加密方法
    [self md5WithData:data];
}

#pragma mark - MD5对data进行加密
- (void)md5WithData:(NSData *)data{
    //1.创建MD5变量
    CC_MD5_CTX md5;
    //2.初始化变量
    CC_MD5_Init(&md5);
    //3.md5加密
    CC_MD5_Update(&md5, data.bytes, (CC_LONG)data.length);
    //参数1：md5变量的首地址
    //参数2：将OC中的data转为C语言的指针
    //参数3：data的长度（CC_LONG）类型
    
    //4.创建字符串数组接收结果
    unsigned char result [CC_MD5_DIGEST_LENGTH];
    //5.结束加密，存储密文
    CC_MD5_Final(result, &md5);
    //6.获取结果
    NSMutableString *string = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [string appendFormat:@"%02x", result[i]];
    }
    NSLog(@"%@", string);
}

//****************************Base64加密**********************************
//iOS7正式版推出后，苹果增加的Base64编码
//可以加密、解密（对象方法类型）--NSString&NSData
//调用base64加密方法的对象为data，返回值可以为NSString或者NSData
#pragma mark - Base64加密

- (void)base64WithString:(NSString *)str{
    //1.字符串转data
    NSData *strData = [str dataUsingEncoding:NSUTF8StringEncoding];
    //2.base64编码
    //(1)返回值为字符串
    NSString *encodeStr = [strData base64EncodedStringWithOptions:0];
    //(2)返回值为data
//    [strData base64EncodedDataWithOptions:0];
    NSLog(@"%@", encodeStr);
    
    //3.解码解密
    NSData *decondeData = [[NSData alloc] initWithBase64EncodedString:encodeStr options:0];
    NSString *string = [[NSString alloc] initWithData:decondeData encoding:NSUTF8StringEncoding];
    NSLog(@"%@", string);
}


//***********************************************************************
//RSA
- (void)RSAEncoderWithString:(NSString *)string {
    //公钥  证书的描述信息
    NSString *publicKey = @"MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDEChqe80lJLTTkJD3X3Lyd7Fj+\nzuOhDZkjuLNPog3YR20e5JcrdqI9IFzNbACY/GQVhbnbvBqYgyql8DfPCGXpn0+X\nNSxELIUw9Vh32QuhGNr3/TBpechrVeVpFPLwyaYNEk1CawgHCeQqf5uaqiaoBDOT\nqeox88Lc1ld7MsfggQIDAQAB";
    //私钥证书描述信息
    NSString *privateKey = @"MIICdwIBADANBgkqhkiG9w0BAQEFAASCAmEwggJdAgEAAoGBAMQKGp7zSUktNOQk\nPdfcvJ3sWP7O46ENmSO4s0+iDdhHbR7klyt2oj0gXM1sAJj8ZBWFudu8GpiDKqXw\nN88IZemfT5c1LEQshTD1WHfZC6EY2vf9MGl5yGtV5WkU8vDJpg0STUJrCAcJ5Cp/\nm5qqJqgEM5Op6jHzwtzWV3syx+CBAgMBAAECgYEApSzqPzE3d3uqi+tpXB71oY5J\ncfB55PIjLPDrzFX7mlacP6JVKN7dVemVp9OvMTe/UE8LSXRVaFlkLsqXC07FJjhu\nwFXHPdnUf5sanLLdnzt3Mc8vMgUamGJl+er0wdzxM1kPTh0Tmq+DSlu5TlopAHd5\nIqF3DYiORIen3xIwp0ECQQDj6GFaXWzWAu5oUq6j1msTRV3mRZnx8Amxt1ssYM0+\nJLf6QYmpkGFqiQOhHkMgVUwRFqJC8A9EVR1eqabcBXbpAkEA3DQfLVr94vsIWL6+\nVrFcPJW9Xk28CNY6Xnvkin815o2Q0JUHIIIod1eVKCiYDUzZAYAsW0gefJ49sJ4Y\niRJN2QJAKuxeQX2s/NWKfz1rRNIiUnvTBoZ/SvCxcrYcxsvoe9bAi7KCMdxObJkn\nhNXFQLav39wKbV73ESCSqnx7P58L2QJABmhR2+0A5EDvvj1WpokkqPKmfv7+ELfD\nHQq33LvU4q+N3jPn8C85ZDedNHzx57kru1pyb/mKQZANNX10M1DgCQJBAMKn0lEx\nQH2GrkjeWgGVpPZkp0YC+ztNjaUMJmY5g0INUlDgqTWFNftxe8ROvt7JtUvlgtKC\nXdXQrKaEnpebeUQ=";
    
    //公钥加密(解密)
    NSString *encoderStr = [RSA encryptString:string publicKey:publicKey];
    NSLog(@"%@", encoderStr);
    
    //私钥解密(加密)
    NSString *decoderStr = [RSA decryptString:encoderStr privateKey:privateKey];
    NSLog(@"%@", decoderStr);
    
}


//*******************************钥匙串********************************
- (void)keyChainEncoderWithUserName:(NSString *)userName password:(NSString *)password {
    //创建钥匙串内容的打包对象
    //参数1：唯一标示
    //参数2：群组共享设置
    KeychainItemWrapper *wrapperItem = [[KeychainItemWrapper alloc] initWithIdentifier:@"wrapper" accessGroup:nil];
    //加密用户名
    [wrapperItem setObject:userName forKey:(id)kSecAttrAccount];
    //加密密码
    [wrapperItem setObject:password forKey:(id)kSecValueData];
    
}
//钥匙串解密
- (void)keyChainDecoder{
    KeychainItemWrapper *wrapperItem = [[KeychainItemWrapper alloc] initWithIdentifier:@"wrapper" accessGroup:nil];
    //用户名
    NSString *userName = [wrapperItem objectForKey:(id)kSecAttrAccount];
    //密码
    NSString *password = [wrapperItem objectForKey:(id)kSecValueData];
}

//钥匙串属于对称性加密，主要用于账号密码加密
//RSA（公钥、私钥）主要用于我们和后台都需要查看的数据，但是传输过程中需要保证安全的时候
//MD5（没有解密，非对称性）和base64（加，解）可用于向后台传输账号密码信息


@end
