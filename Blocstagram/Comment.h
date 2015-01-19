//
//  Comment.h
//  Blocstagram
//
//  Created by Andrew Carvajal on 1/16/15.
//  Copyright (c) 2015 graffme, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class User;

@interface Comment : NSObject

@property (nonatomic, strong) NSString *idNumber;
@property (nonatomic, strong) User *from;
@property (nonatomic, strong) NSString *text;

@end
