//
//  JMAccessToken.m
//  BIC_Task
//
//  Created by John Maltsev on 01.04.17.
//  Copyright © 2017 JMCorp. All rights reserved.
//

#import "JMAccessToken.h"

@implementation JMAccessToken

- (instancetype) initWithServerResponse:(NSDictionary*) responseToken {
    
    self = [super init];
    if (self) {
        
        self.token = [responseToken objectForKey:@"access_token"];
        self.tokenType = [responseToken objectForKey:@"token_type"];
        self.actionTime = [[responseToken objectForKey:@"expires_i"] doubleValue];
    }
    
    return self;
}

@end
