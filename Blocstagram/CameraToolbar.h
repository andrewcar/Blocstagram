//
//  CameraToolbar.h
//  Blocstagram
//
//  Created by Andrew Carvajal on 4/12/15.
//  Copyright (c) 2015 graffme, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CameraToolbar;

@protocol CameraToolbarDelegate <NSObject>

- (void)leftButtonPressedOnToolbar:(CameraToolbar *)toolbar;
- (void)rightButtonPressedOnToolbar:(CameraToolbar *)toolbar;
- (void)cameraButtonPressedOnToolbar:(CameraToolbar *)toolbar;

@end

@interface CameraToolbar : UIView

@property (nonatomic, weak) NSObject <CameraToolbarDelegate> *delegate;

- (instancetype)initWithImageNames:(NSArray *)imageNames;

@end
