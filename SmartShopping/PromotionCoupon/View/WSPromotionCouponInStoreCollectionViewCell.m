//
//  HomeCollectionViewCell.m
//  SmartShopping
//
//  Created by wrs on 15/4/12.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import "WSPromotionCouponInStoreCollectionViewCell.h"
#import "CollectSucView.h"
#import "WSProductDetailViewController.h"
#import "WSLocationDetailViewController.h"

@implementation WSPromotionCouponInStoreCollectionViewCell

@synthesize dic;

- (void)setModel:(NSMutableDictionary *)modelDic
{
    self.dic = modelDic;
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
        if (image) {
            _bigImageView.contentMode = UIViewContentModeScaleAspectFit;
        } else {
            _bigImageView.contentMode = UIViewContentModeScaleToFill;
        }
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
    
//    [self.leftBut addTarget:self action:@selector(leftButAction:) forControlEvents:UIControlEventTouchUpInside];
//    [self.rightBut addTarget:self action:@selector(rightButAction:) forControlEvents:UIControlEventTouchUpInside];

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

- (IBAction)prodcutButAction:(id)sender
{
    WSProductDetailViewController *productDetailVC = [[WSProductDetailViewController alloc] init];
    NSString *goodsId = [dic stringForKey:@"goodsId"];
    productDetailVC.goodsId = goodsId;
    productDetailVC.shopId = [dic stringForKey:@"shopId"];
    [self.viewController.navigationController pushViewController:productDetailVC animated:YES];
}

- (IBAction)collectButAction:(id)sender
{
    NSString *shopId = [dic stringForKey:@"shopId"];
    WSUser *user = [WSRunTime sharedWSRunTime].user;
    if (user) {
        NSString *isCollect = [dic stringForKey:@"isCollect"];
        // 没有收藏  白色安心
        if ([isCollect isEqualToString:@"N"]) {
            NSString *goodsid = [dic stringForKey:@"goodsId"];
            NSDictionary *param = @{@"uid": user._id, @"goodsid":  goodsid, @"shopid": shopId};
            [SVProgressHUD show];
            [WSService post:[WSInterfaceUtility getURLWithType:WSInterfaceTypeCollectGoods] data:param tag:WSInterfaceTypeCollectGoods sucCallBack:^(id result) {
                BOOL flag = [WSInterfaceUtility validRequestResult:result];
                if (flag) {
                    [dic setValue:@"Y" forKey:@"isCollect"];
                    [_leftBut setBackgroundImage:[UIImage imageNamed:@"collected"] forState:UIControlStateNormal];
                    [CollectSucView showCollectSucView];
                }
                
            } failCallBack:^(id error) {
                [SVProgressHUD dismissWithError:@"收藏失败！" afterDelay:TOAST_VIEW_TIME];
            } showMessage:YES];
            // 已收藏 取消收藏
        } else {
            [dic setValue:@"N" forKey:@"isCollect"];
            [_leftBut setBackgroundImage:[UIImage imageNamed:@"uncollect"] forState:UIControlStateNormal];
        }
    } else {
        [WSUserUtil actionAfterLogin:^{
            if (_refreshPage) {
                _refreshPage();
            }
        }];
    }

}

- (IBAction)shareButAction:(id)sender
{
}
@end
