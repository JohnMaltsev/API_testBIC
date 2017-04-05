//
//  JMServerManager.m
//  BIC_Task
//
//  Created by John Maltsev on 01.04.17.
//  Copyright © 2017 JMCorp. All rights reserved.
//

#import "JMServerManager.h"
#import "AFNetworking.h"
#include <CommonCrypto/CommonDigest.h>
#import "JMUpLoadFile.h"

@interface JMServerManager ()

@property (strong, nonatomic) AFHTTPSessionManager *requestOperationManager;               
@property (strong, nonatomic) NSURL *url;
@property (strong, nonatomic) NSString *token;

@end

@implementation JMServerManager
//JMServerManager делает все запросы на сервер
+ (JMServerManager*) sharedManager {
    
    //cоздание сингл тона
    static JMServerManager *manager = nil;
    
    //гарантирует что код вызовется один раз
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ //Это нужно чтобы если много потоков не вызвали этот метод разные потоки одновременно
        manager = [[JMServerManager alloc] init];
    });
    
    return manager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.url = [NSURL URLWithString:@"https://api.smiber.com/v4.005"];
        
        AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc]initWithBaseURL:self.url];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        self.requestOperationManager  = manager;
    }
    return self;
}

#pragma mark - GET Salt post

- (void) getSaltForUserLogin:(NSString*) userLogin
                   onSuccess:(void(^)(NSString *salt))success
                   onFailure:(void(^)(NSArray *errors)) failure {
    
    
    NSDictionary *dict = @{@"login":userLogin};//создали dict где login это ключ параметра, а userLogin это значение/ Затем передаем как параметры в запрос POST
    
    //задаем параметр заголовка header
    [self.requestOperationManager.responseSerializer.acceptableContentTypes setByAddingObject:@"application/json"];
    
    NSLog(@"Sent parameter to server : %@",dict);
    
    [self.requestOperationManager
     POST:@"salt"
     parameters:dict
     progress:nil
     success:^(NSURLSessionTask *task, id responseObject) {
         NSLog(@"JSON: %@", responseObject);
         
         //создаем строку и вытаскиваем значение соли
         NSString* salt = [responseObject valueForKeyPath:@"data.salt"];
         
         //Проверка что значение существует а не nil
         if (salt) {
             self.saltValue = salt;
             success(salt);
         }else {
             //если соли нет, смотрим на наличие ошибок
             
             //получили массив ошибок
             NSArray* dictArray = [responseObject objectForKey:@"errors"];
             
             
             //создали пустой  массив
             NSMutableArray *errorList = [NSMutableArray array];
             //проходим по каждому элементу из массива ошибок
             for (NSDictionary *dict in dictArray)  {
                 //из икшнари конструируем объект
                 JMErrorObject *error = [[JMErrorObject alloc]initWithServerResponse:dict];
                 //добавляем объект в пустой массив
                 [errorList addObject:error];
             }
          // передаем блоку массив ошибок /потом вызовем блок во VC
             failure(errorList);
         }
         
     } failure:^(NSURLSessionTask *operation, NSError *error) {
         NSLog(@"Error: %@", error);
         //в случае failure в блок приходит operation и error /создаем объек и присваиваем проперти объекта error code и error localizedDescription /  затем передаем объект в блок failure которы принимает массив ошибок
         JMErrorObject *errorObj = [JMErrorObject new];
         errorObj.errorCode = [error code];
         errorObj.message = [error localizedDescription];
         
         failure(@[errorObj]);
     }];
}

#pragma mark - Token post

- (void) getAccessTokenForUserPassword:(NSString*) password
                           useUserName:(NSString*) enteredLogin
                             onSuccess:(void(^)(JMAccessToken *token))success
                             onFailure:(void(^)(NSArray *errors)) failure {
  
    NSString* sha256pwd = [self sha256:password];
    NSString* value = [NSString stringWithFormat:@"%@%@",sha256pwd, self.saltValue];
    NSString* sha256pwdSalt = [self sha256:value];
    
    NSDictionary *tokenDict = @{@"grant_type":@"password",
                                @"username":enteredLogin, @"password":sha256pwdSalt};
    
    
    NSLog(@"Sent parameter to server : %@",tokenDict);
    
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:self.url sessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    [manager.requestSerializer setValue:@"application/x-www-form-urlencoded; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    
    self.requestOperationManager = manager;
    
    [self.requestOperationManager
     POST:@"oauth/token"
     parameters:tokenDict
     progress:nil
     success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
         
         NSLog(@"JSON TOKEN: %@", responseObject);
         
         NSDictionary* keyValues = (NSDictionary*) responseObject;
         JMAccessToken *aToken = [[JMAccessToken alloc] initWithServerResponse:keyValues];
         self.token = aToken.token;
         if (aToken.token != nil) {
             success(aToken);
         }
     }
     failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
         
         NSLog(@"Ошибка сервера!");
         NSLog(@"error code: %ld", (long)[error code]);
     }];
    
}

#pragma mark - sha256 generateKeyMethod

-(NSString*) sha256:(NSString *)stringValue {
    const char *s=[stringValue cStringUsingEncoding:NSASCIIStringEncoding];
    NSData *keyData=[NSData dataWithBytes:s length:strlen(s)];
    uint8_t digest[CC_SHA256_DIGEST_LENGTH]={0};
    CC_SHA256(keyData.bytes, (int)keyData.length, digest);
    NSData *out=[NSData dataWithBytes:digest length:CC_SHA256_DIGEST_LENGTH];
    NSString *hash=[out description];
    hash = [hash stringByReplacingOccurrencesOfString:@" " withString:@""];
    hash = [hash stringByReplacingOccurrencesOfString:@"<" withString:@""];
    hash = [hash stringByReplacingOccurrencesOfString:@">" withString:@""];
    return hash;
}

#pragma mark - Video Methods

- (void) uploadVideo:(NSURL*) videoData
           onSuccess:(void(^)(JMAccessToken *token))success
           onFailure:(void(^)(NSArray *errors)) failure {
    
    NSDictionary *tokenDict = @{@"type_file":@"video"};
    
    NSLog(@"Sent parameter to server : %@",tokenDict);
    
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:self.url sessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    [manager.requestSerializer setValue:@"multipart/form-data" forHTTPHeaderField:@"Content-Type"];
    
    NSString *authValue = [NSString stringWithFormat:@"Bearer %@", self.token];
    [manager.requestSerializer setValue:authValue forHTTPHeaderField:@"Authorization"];
    
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    
    self.requestOperationManager = manager;
    
    [self.requestOperationManager POST:@"file/upload" parameters:tokenDict constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileURL:videoData name:@"video" error:nil];
    } progress:nil success:^(NSURLSessionDataTask *operation, id responseObject) {
        NSLog(@"Success: %@", responseObject);
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    
}

@end
