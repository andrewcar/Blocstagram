//
//  DataSource.h
//  Blocstagram
//
//  Created by Andrew Carvajal on 1/16/15.
//  Copyright (c) 2015 graffme, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Media;

@interface DataSource : NSObject

@property (nonatomic, strong, readonly) NSMutableArray *mediaItems;

+ (instancetype)sharedInstance;
- (void)deleteMediaItem:(Media *)item;

@end
