//
//  FilterCollectionViewCell.m
//  Blocstagram
//
//  Created by Andrew Carvajal on 5/7/15.
//  Copyright (c) 2015 graffme, Inc. All rights reserved.
//

#import "FilterCollectionViewCell.h"

@implementation FilterCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.frame = frame;
        static NSInteger imageViewTag = 1000;
        static NSInteger labelTag = 1001;
        
        UIImageView *thumbnail = (UIImageView *)[self.contentView viewWithTag:imageViewTag];
        UILabel *label = (UILabel *)[self.contentView viewWithTag:labelTag];
        
        CGFloat thumbnailEdgeSize = 150;

        if (!thumbnail) {
            thumbnail = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, thumbnailEdgeSize, thumbnailEdgeSize)];
            thumbnail.contentMode = UIViewContentModeScaleAspectFill;
            thumbnail.tag = imageViewTag;
            thumbnail.clipsToBounds = YES;
            
            [self.contentView addSubview:thumbnail];
        }
        
        if (!label) {
            label = [[UILabel alloc] initWithFrame:CGRectMake(0, thumbnailEdgeSize, thumbnailEdgeSize, 20)];
            label.tag = labelTag;
            label.textAlignment = NSTextAlignmentCenter;
            label.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:10];
            [self.contentView addSubview:label];
        }
    }
    return self;
}

@end
