//
//  MediaFullScreenViewController.h
//  Blocstagram
//
//  Created by Andrew Carvajal on 3/7/15.
//  Copyright (c) 2015 graffme, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Media;

@interface MediaFullScreenViewController : UIViewController

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *imageView;

- (instancetype)initWithMedia:(Media *)media;

- (void)centerScrollView;

@end
