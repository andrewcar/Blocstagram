//
//  CropImageViewController.h
//  Blocstagram
//
//  Created by Andrew Carvajal on 4/19/15.
//  Copyright (c) 2015 graffme, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MediaFullScreenViewController.h"

@class CropImageViewController;

@protocol CropImageViewControllerDelegate <NSObject>

- (void)cropControllerFinishedWithImage:(UIImage *)croppedImage;

@end

@interface CropImageViewController : MediaFullScreenViewController

- (instancetype)initWithImage:(UIImage *)sourceImage;
@property (nonatomic, strong) NSObject <CropImageViewControllerDelegate> *delegate;

@end
