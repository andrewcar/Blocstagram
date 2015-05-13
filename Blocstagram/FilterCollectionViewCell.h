//
//  FilterCollectionViewCell.h
//  Blocstagram
//
//  Created by Andrew Carvajal on 5/7/15.
//  Copyright (c) 2015 graffme, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FilterCollectionViewCellDelegate <NSObject>

@end

@interface FilterCollectionViewCell : UICollectionViewCell

@property (nonatomic, weak) id <FilterCollectionViewCellDelegate> delegate;

@end
