//
//  DGHHomeCollectionViewCell.h
//  DeviceGH
//
//  Created by Sreelash S on 21/12/14.
//  Copyright (c) 2014 Sreelal H. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProductCategory.h"

@interface DGHHomeCollectionViewCell : UICollectionViewCell

@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UIView      *bgView;
@property (strong, nonatomic) IBOutlet UILabel     *nameLabel;

- (void)setupBg;
- (void)loadCategoryImageForCategory:(ProductCategory *)category;

@end
