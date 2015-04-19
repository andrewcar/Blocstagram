//
//  UIImage+BLCImageUtilities.h
//  Blocstagram
//
//  Created by Andrew Carvajal on 4/15/15.
//  Copyright (c) 2015 graffme, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (BLCImageUtilities)

- (UIImage *)imageWithFixedOrientation;
- (UIImage *)imageResizedToMatchAspectRatioOfSize:(CGSize)size;
- (UIImage *)imageCroppedToRect:(CGRect)cropRect;
- (UIImage *)imageByScalingToSize:(CGSize)size andCroppingWithRect:(CGRect)rect;

@end
