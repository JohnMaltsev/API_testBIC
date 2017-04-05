//
//  JMServerManager.h
//  BIC_Task
//
//  Created by John Maltsev on 01.04.17.
//  Copyright © 2017 JMCorp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JMErrorObject.h"
#import "JMAccessToken.h"

@interface JMServerManager : NSObject

@property (strong, nonatomic) NSString * saltValue;

+ (JMServerManager*) sharedManager;

- (void)getSaltForUserLogin:(NSString*) userLogin
                  onSuccess:(void(^)(NSString *salt))success
                  onFailure:(void(^)(NSArray *errors)) failure;

- (void) getAccessTokenForUserPassword:(NSString*) password
                           useUserName:(NSString*) enteredLogin
                             onSuccess:(void(^)(JMAccessToken *token))success
                             onFailure:(void(^)(NSArray *errors)) failure;

- (void) uploadVideo:(NSURL*) videoData
           onSuccess:(void(^)(JMAccessToken *token))success
           onFailure:(void(^)(NSArray *errors)) failure;
@end
