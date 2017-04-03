//
//  JMUpLoadFile.m
//  BIC_Task
//
//  Created by John Maltsev on 03.04.17.
//  Copyright © 2017 JMCorp. All rights reserved.
//

#import "JMUpLoadFile.h"

@implementation JMUpLoadFile

- (instancetype) initWithServerResponse:(NSDictionary*) responseObject;

{
    self = [super init];
    if (self) {
        
        self.idFile = [responseObject objectForKey:@"idFile"];
        self.link = [responseObject objectForKey:@"link"];
        self.preview.link = [responseObject objectForKey:@"previews.link"];
        self.preview.idFile = [responseObject objectForKey:@"previews.idFile"];
    }
    
    return self;
}


@end
