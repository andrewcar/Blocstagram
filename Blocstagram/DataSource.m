//
//  DataSource.m
//  Blocstagram
//
//  Created by Andrew Carvajal on 1/16/15.
//  Copyright (c) 2015 graffme, Inc. All rights reserved.
//

#import "LoginViewController.h"
#import "DataSource.h"
#import "User.h"
#import "Media.h"
#import "Comment.h"
#import <UICKeyChainStore.h>
#import <AFNetworking/AFNetworking.h>

@interface DataSource() {
    NSMutableArray *_mediaItems;
}

@property (nonatomic, strong) NSMutableArray *mediaItems;
@property (nonatomic, assign) BOOL isRefreshing;
@property (nonatomic, assign) BOOL isLoadingOlderItems;
@property (nonatomic, assign) BOOL thereAreNoMoreOlderMessages;
@property (nonatomic, strong) NSString *accessToken;
@property (nonatomic, strong) AFHTTPRequestOperationManager *instagramOperationManager;

@end

@implementation DataSource

+ (instancetype)sharedInstance {
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    
    if (self) {
        NSURL *baseURL = [NSURL URLWithString:@"https://api.instagram.com/v1/"];
        self.instagramOperationManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:baseURL];
        
        AFJSONResponseSerializer *jsonSerializer = [AFJSONResponseSerializer serializer];
        
        AFImageResponseSerializer *imageSerializer = [AFImageResponseSerializer serializer];
        imageSerializer.imageScale = 1.0;
        
        AFCompoundResponseSerializer *serializer = [AFCompoundResponseSerializer compoundSerializerWithResponseSerializers:@[jsonSerializer, imageSerializer]];
        self.instagramOperationManager.responseSerializer = serializer;
        
        self.accessToken = [UICKeyChainStore stringForKey:@"access token"];
        
        // if there is no access token...
        if (!self.accessToken) {
            // get an access token
            [self registerForAccessTokenNotification];
            // if there is access token...
        } else {
            // make a side queue of default priority
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                // make a string of the path for mediaItems
                NSString *fullPath = [self pathForFilename:NSStringFromSelector(@selector(mediaItems))];
                // make an array for the string path to mediaItems
                NSArray *storedMediaItems = [NSKeyedUnarchiver unarchiveObjectWithFile:fullPath];
                
                // go back to main queue
                dispatch_async(dispatch_get_main_queue(), ^{
                    // if storedMediaItems is not empty...
                    if (storedMediaItems.count > 0) {
                        // make a mutable array for the storedMediaItems
                        NSMutableArray *mutableMediaItems = [storedMediaItems mutableCopy];
                        
                        // check for new items
                        [self requestNewItemsWithCompletionHandler:nil];
                        
                        // inform self for KVO that mediaItems will change
                        [self willChangeValueForKey:@"mediaItems"];
                        // set mediaItems to the content of the mutable array
                        self.mediaItems = mutableMediaItems;
                        // inform self for KVO that mediaItems did change
                        [self didChangeValueForKey:@"mediaItems"];
                        // if storedMediaItems is empty...
                    } else {
                        // populate it
                        [self populateDataWithParameters:nil completionHandler:nil];
                    }
                });
            });
        }
    }
    return self;
}

- (void)populateDataWithParameters:(NSDictionary *)parameters completionHandler:(NewItemCompletionBlock)completionHandler {
    if (self.accessToken) {
        // only try to get the data if there's an access token
        
        NSMutableDictionary *mutableParameters = [@{@"access_token": self.accessToken} mutableCopy];
        
        [mutableParameters addEntriesFromDictionary:parameters];
        
        [self.instagramOperationManager GET:@"users/self/feed"
                                 parameters:mutableParameters
                                    success:^(AFHTTPRequestOperation *operation, id responseObject) {
            if ([responseObject isKindOfClass:[NSDictionary class]]) {
                [self parseDataFromFeedDictionary:responseObject fromRequestWithParameters:parameters];
                
                if (completionHandler) {
                    completionHandler(nil);
                }
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            if (completionHandler) {
                completionHandler(error);
            }
        }];
    }
}

- (void)parseDataFromFeedDictionary:(NSDictionary *)feedDictionary fromRequestWithParameters:(NSDictionary *)parameters {
    
    // create an array called mediaArray from the feedDictionary
    NSArray *mediaArray = feedDictionary[@"data"];
    
    // create an empty mutable array called tmpMediaItems
    NSMutableArray *tmpMediaItems = [NSMutableArray array];
    
    // for a dictionary called mediaDictionary in mediaArray...
    for (NSDictionary *mediaDictionary in mediaArray) {
        
        // create a mediaItem, allocate it, initialize it with mediaDictionary
        Media *mediaItem = [[Media alloc] initWithDictionary:mediaDictionary];
        
        // if mediaItem exists...
        if (mediaItem) {
            
            // add it to tmpMediaItems mutable array
            [tmpMediaItems addObject:mediaItem];
            
            // download the image for mediaItem
//            [self downloadImageForMediaItem:mediaItem];
        }
    }
    
    // create a mutable array with KVO
    NSMutableArray *mutableArrayWithKVO = [self mutableArrayValueForKey:@"mediaItems"];
    
    // if it was a pull-to-refresh request...
    if (parameters[@"min_id"]) {

        // create an NSRange called rangeOfIndexes from 0 to the count of tmpMediaItems
        NSRange rangeOfIndexes = NSMakeRange(0, tmpMediaItems.count);
        
        // create an NSIndexSet called indexSetOfNewObjects with rangeOfIndexes
        NSIndexSet *indexSetOfNewObjects = [NSIndexSet indexSetWithIndexesInRange:rangeOfIndexes];
        
        // insert tmpMediaItems at the indexSetOfNewObjects in the mutable array with KVO
        [mutableArrayWithKVO insertObjects:tmpMediaItems atIndexes:indexSetOfNewObjects];
        
        // else if it was an infinite scroll request...
    } else if (parameters[@"max_id"]) {

        // if tmpMediaItems is empty...
        if (tmpMediaItems.count == 0) {
            
            // disable infinite scroll, since there are no more older messages
            self.thereAreNoMoreOlderMessages = YES;
        }
        
        // add all tmpMediaItems to the mutable array with KVO
        [mutableArrayWithKVO addObjectsFromArray:tmpMediaItems];
    } else {
        
        // else, notify KVO that self.mediaItems will be set to tmpMediaItems, then notify KVO that it happened
        [self willChangeValueForKey:@"mediaItems"];
        self.mediaItems = tmpMediaItems;
        [self didChangeValueForKey:@"mediaItems"];
    }
    
    // if tmpMediaItems is not empty...
    if (tmpMediaItems.count > 0) {
        
        // Write the changes to disk
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSUInteger numberOfItemsToSave = MIN(self.mediaItems.count, 50);
            NSArray *mediaItemsToSave = [self.mediaItems subarrayWithRange:NSMakeRange(0, numberOfItemsToSave)];
            
            NSString *fullPath = [self pathForFilename:NSStringFromSelector(@selector(mediaItems))];
            NSData *mediaItemData = [NSKeyedArchiver archivedDataWithRootObject:mediaItemsToSave];
            
            NSError *dataError;
            BOOL wroteSuccessfully = [mediaItemData writeToFile:fullPath options:NSDataWritingAtomic | NSDataWritingFileProtectionCompleteUnlessOpen error:&dataError];
            
            if (!wroteSuccessfully) {
                NSLog(@"Couldn't write file: %@", dataError);
            }
        });
    }
}

- (void)downloadImageForMediaItem:(Media *)mediaItem {
    if (mediaItem.mediaURL && !mediaItem.image) {
        mediaItem.downloadState = MediaDownloadStateDownloadInProgress;
        [self.instagramOperationManager GET:mediaItem.mediaURL.absoluteString
                                 parameters:nil
                                    success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                        if ([responseObject isKindOfClass:[UIImage class]]) {
                                            mediaItem.image = responseObject;
                                            mediaItem.downloadState = MediaDownloadStateHasImage;
                                            NSMutableArray *mutableArrayForKVO = [self mutableArrayValueForKey:@"mediaItems"];
                                            NSUInteger index = [mutableArrayForKVO indexOfObject:mediaItem];
                                            [mutableArrayForKVO replaceObjectAtIndex:index withObject:mediaItem];
                                        } else {
                                            mediaItem.downloadState = MediaDownloadStateNonRecoverableError;
                                        }
                                    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                        NSLog(@"Error downloading image: %@", error);
                                        
                                        mediaItem.downloadState = MediaDownloadStateNonRecoverableError;
                                        
                                        if ([error.domain isEqualToString:NSURLErrorDomain]) {
                                            // A networking problem
                                            if (error.code == NSURLErrorTimedOut ||
                                                error.code == NSURLErrorCancelled ||
                                                error.code == NSURLErrorCannotConnectToHost ||
                                                error.code == NSURLErrorNetworkConnectionLost ||
                                                error.code == NSURLErrorNotConnectedToInternet ||
                                                error.code == kCFURLErrorInternationalRoamingOff ||
                                                error.code == kCFURLErrorCallIsActive ||
                                                error.code == kCFURLErrorDataNotAllowed ||
                                                error.code == kCFURLErrorRequestBodyStreamExhausted) {
                                                
                                                // It might work if we try again
                                                mediaItem.downloadState = MediaDownloadStateNeedsImage;
                                            }
                                        }
                                    }];
    }
}

- (void)requestNewItemsWithCompletionHandler:(NewItemCompletionBlock)completionHandler {
    // if pull to refresh is not happening...
    if (self.isRefreshing == NO) {
        // tell self that pull to refresh is happening
        self.isRefreshing = YES;
        
        // make a string called minID of the idNumber of the first object in mediaItems
        NSString *minID = [[self.mediaItems firstObject] idNumber];
        // make a dictionary called parameters and set it to nil
        NSDictionary *parameters = nil;
        
        // if mediaItems is not empty...
        if (self.mediaItems.count) {
            // set parameters up for minID
            parameters = @{@"min_id": minID};
        }
        
        // populate with items using parameters
        [self populateDataWithParameters:parameters completionHandler:^(NSError *error) {
            // tell self that pull to refresh is no longer happening
            self.isRefreshing = NO;
            
            if (completionHandler) {
                completionHandler(error);
            }
        }];
    }
    // tell self that there are older messages
    self.thereAreNoMoreOlderMessages = NO;
}

- (void)requestOldItemsWithCompletionHandler:(NewItemCompletionBlock)completionHandler {
    if (self.isLoadingOlderItems == NO && self.thereAreNoMoreOlderMessages == NO) {
        self.isLoadingOlderItems = YES;
        
        NSString *maxID = [[self.mediaItems lastObject] idNumber];
        NSDictionary *parameters = @{@"max_id": maxID};
        
        [self populateDataWithParameters:parameters completionHandler:^(NSError *error) {
            self.isLoadingOlderItems = NO;
            
            if (completionHandler) {
                completionHandler(error);
            }
        }];
    }
}

- (void)deleteMediaItem:(Media *)item {
    NSMutableArray *mutableArrayWithKVO = [self mutableArrayValueForKey:@"mediaItems"];
    [mutableArrayWithKVO removeObject:item];
}

#pragma mark - Key/Value Observing

- (NSUInteger)countOfMediaItems {
    return self.mediaItems.count;
}

- (id)objectInMediaItemsAtIndex:(NSUInteger)index {
    return [self.mediaItems objectAtIndex:index];
}

- (NSArray *)mediaItemsAtIndexes:(NSIndexSet *)indexes {
    return [self.mediaItems objectsAtIndexes:indexes];
}

- (void)insertObject:(Media *)object inMediaItemsAtIndex:(NSUInteger)index {
    [_mediaItems insertObject:object atIndex:index];
}

- (void)removeObjectFromMediaItemsAtIndex:(NSUInteger)index {
    [_mediaItems removeObjectAtIndex:index];
}

- (void)replaceObjectInMediaItemsAtIndex:(NSUInteger)index withObject:(id)object {
    [_mediaItems replaceObjectAtIndex:index withObject:object];
}

#pragma mark - Miscellaneous

+ (NSString *)instagramClientID {
    return @"7d72f847a9a94b0cb53bbc93b456a630";
}

- (void)registerForAccessTokenNotification {
    [[NSNotificationCenter defaultCenter] addObserverForName:LoginViewControllerDidGetAccessTokenNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        self.accessToken = note.object;
        [UICKeyChainStore setString:self.accessToken forKey:@"access token"];
        
        // Get a token, populate the initial data
        [self populateDataWithParameters:nil completionHandler:nil];
    }];
}

- (NSString *)pathForFilename:(NSString *)filename {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths firstObject];
    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:filename];
    return dataPath;
}

@end
