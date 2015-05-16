//
//  HomeCollectionViewCell.m
//  SmartShopping
//
//  Created by wrs on 15/4/12.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import "WSPromotionCouponInStoreCollectionViewCell.h"

@implementation WSPromotionCouponInStoreCollectionViewCell

- (void)setModel:(NSDictionary *)dic
{
    NSString *goodsScan = [dic stringForKey:@"goodsScan"];
    if ([goodsScan isEqualToString:@"1"]) {
        _scanImageView.hidden = NO;
    } else {
        _scanImageView.hidden = YES;
    }
    
    NSString *goodsEndDate = [dic objectForKey:@"goodsEndDate"];
    NSString *formatDate = [WSProjUtil converDateWithDateStr:goodsEndDate];
    _validDateLabel.text = formatDate;
    
    NSString *goodsLogo = [dic objectForKey:@"goodsLogo"];
    NSString *goodsLogoURL = [WSInterfaceUtility getImageURLWithStr:goodsLogo];
    [_bigImageView sd_setImageWithURL:[NSURL URLWithString:goodsLogoURL] placeholderImage:[UIImage imageNamed:[NSString stringWithFormat:@"radom_%d", [WSProjUtil gerRandomColor]]] options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        
    }];

    
    NSString *isCollect = [dic stringForKey:@"isCollect"];
    // 没有收藏  白色安心
    if ([isCollect isEqualToString:@"N"]) {
        [_leftBut setBackgroundImage:[UIImage imageNamed:@"colleation-011"] forState:UIControlStateNormal];
    // 已收藏
    } else {
        [_leftBut setBackgroundImage:[UIImage imageNamed:@"collected"] forState:UIControlStateNormal];
    }
}

- (void)awakeFromNib
{
    // Initialization code
    [_conView setBorderCornerWithBorderWidth:1 borderColor:[UIColor colorWithRed:0.706 green:0.710 blue:0.714 alpha:1.000] cornerRadius:5];
    
    [self.leftBut addTarget:self action:@selector(leftButAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.rightBut addTarget:self action:@selector(rightButAction:) forControlEvents:UIControlEventTouchUpInside];
   // [_distanceBut setEnlargeEdgeWithTop:13 right:0 bottom:0 left:10];
    [_leftBut setEnlargeEdgeWithTop:5 right:23 bottom:5 left:23];
    [_rightBut setEnlargeEdgeWithTop:5 right:23 bottom:5 left:23];
}

- (void)leftButAction:(UIButton *)but
{
    if ([_delegate respondsToSelector:@selector(WSPromotionCouponInStoreCollectionViewCellDidClickLeftBut:)]) {
        [_delegate WSPromotionCouponInStoreCollectionViewCellDidClickLeftBut:self];
    }
}

- (void)rightButAction:(UIButton *)but
{
    if ([_delegate respondsToSelector:@selector(WSPromotionCouponInStoreCollectionViewCellDidClickRightBut:)]) {
        [_delegate WSPromotionCouponInStoreCollectionViewCellDidClickRightBut:self];
    }
}

@end
