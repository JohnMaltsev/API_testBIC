//
//  JMUpLoadFile.h
//  BIC_Task
//
//  Created by John Maltsev on 03.04.17.
//  Copyright © 2017 JMCorp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JMPreviewsObject.h"

@interface JMUpLoadFile : NSObject

@property (assign, nonatomic) NSInteger errorCode;
@property (strong, nonatomic) NSString *idFile;
@property (strong, nonatomic) NSString *link;
@property (strong, nonatomic) JMPreviewsObject *preview;

@end
