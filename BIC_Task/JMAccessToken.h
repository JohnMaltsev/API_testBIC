//
//  JMAccessToken.h
//  BIC_Task
//
//  Created by John Maltsev on 01.04.17.
//  Copyright © 2017 JMCorp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface JMAccessToken : NSObject

@property (strong, nonatomic) NSString *token;
@property (strong, nonatomic) NSString *tokenType;
@property (assign, nonatomic) NSTimeInterval actionTime;

- (instancetype) initWithServerResponse:(NSDictionary*) responseToken;


@end
