//
//  MediaFullScreenAnimator.h
//  Blocstagram
//
//  Created by Andrew Carvajal on 3/7/15.
//  Copyright (c) 2015 graffme, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MediaFullScreenAnimator : NSObject <UIViewControllerAnimatedTransitioning>

@property (nonatomic, assign) BOOL presenting;
@property (nonatomic, weak) UIImageView *cellImageView;

@end
