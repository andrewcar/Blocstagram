//
//  DataSource.h
//  Blocstagram
//
//  Created by Andrew Carvajal on 1/16/15.
//  Copyright (c) 2015 graffme, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Media;

typedef void (^NewItemCompletionBlock)(NSError *error);

@interface DataSource : NSObject

@property (nonatomic, strong, readonly) NSMutableArray *mediaItems;
@property (nonatomic, strong, readonly) NSString *accessToken;

+ (instancetype)sharedInstance;

- (void)deleteMediaItem:(Media *)item;

- (void)requestNewItemsWithCompletionHandler:(NewItemCompletionBlock)completionHandler;

- (void)requestOldItemsWithCompletionHandler:(NewItemCompletionBlock)completionHandler;

- (void)downloadImageForMediaItem:(Media *)mediaItem;

- (void)toggleLikeOnMediaItem:(Media *)mediaItem;

- (void)commentOnMediaItem:(Media *)item withText:(NSString *)commentText;

+ (NSString *)instagramClientID;

@end
