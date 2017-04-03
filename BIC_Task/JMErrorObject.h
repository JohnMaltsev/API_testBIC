//
//  JMErrorObject.h
//  BIC_Task
//
//  Created by John Maltsev on 01.04.17.
//  Copyright © 2017 JMCorp. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JMErrorObject : NSObject

@property (strong, nonatomic) NSString* message;
@property (assign, nonatomic) NSInteger errorCode;

- (instancetype) initWithServerResponse:(NSDictionary*) responseObject;

@end
