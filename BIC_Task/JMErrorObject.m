//
//  JMErrorObject.m
//  BIC_Task
//
//  Created by John Maltsev on 01.04.17.
//  Copyright © 2017 JMCorp. All rights reserved.
//

#import "JMErrorObject.h"

@implementation JMErrorObject

- (instancetype) initWithServerResponse:(NSDictionary*) responseObject;

{
    self = [super init];
    if (self) {
        
        self.message = [responseObject objectForKey:@"message"];
        self.errorCode = [[responseObject objectForKey:@"code"] intValue];
        
    }
    return self;
}

@end
