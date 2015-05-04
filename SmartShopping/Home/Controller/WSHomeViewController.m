//
//  HomeViewController.m
//  SmartShopping
//
//  Created by wrs on 15/4/8.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import "WSHomeViewController.h"
#import "HomeHeaderCollectionReusableView.h"
#import "HomeCollectionViewCell.h"
#import "WSInfoListViewController.h"
#import "WSProductDetailViewController.h"
#import "WSAdvertisementDetailViewController.h"
#import "WSLocationDetailViewController.h"
#import "WSNoInStoreViewController.h"
#import "WSInStoreNoSignViewController.h"
#import "WSInStoreNoSignScopeViewController.h"
#import "WSStoreDetailViewController.h"
#import "WSScanNoInStoreViewController.h"
#import "WSInviateFriendViewController.h"
#import "WSSearchHistoryViewController.h"

@interface WSHomeViewController () <NavigationBarButSearchButViewDelegate, WSSlideSwitchViewDelegate, HomeCollectionViewCellDelegate, BMKMapViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, BMKLocationServiceDelegate, BMKGeoCodeSearchDelegate>
{
    NSMutableArray *collectionViewDataArray;
    NSMutableArray *slideImageArray;
    
    BMKLocationService* _locService;
    BMKGeoCodeSearch* _geocodesearch;
    HomeHeaderCollectionReusableView *headerView;
}

@property (weak, nonatomic) IBOutlet WSNavigationBarManagerView *navBarManagerView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation WSHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib
    //[_navBarManagerView.navigationBarButSearchButView.rightBut setBackgroundImage:[UIImage imageNamed:@"navigationBarButSearchButView"] forState:UIControlStateNormal];
    _navBarManagerView.navigationBarButSearchButView.delegate = self;
    _navBarManagerView.navigationBarButSearchButView.leftLabel.text = @"--";
    _navBarManagerView.navigationBarButSearchButView.leftBut.enabled = NO;
    
    collectionViewDataArray = [[NSMutableArray alloc] init];
    slideImageArray = [[NSMutableArray alloc] init];
    
    // 启动百度地区定位
    [self initBMK];
    
    // 注册
    [_collectionView registerNib:[UINib nibWithNibName:@"HomeCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"HomeCollectionViewCell"];
    [_collectionView registerNib:[UINib nibWithNibName:@"HomeHeaderCollectionReusableView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HomeHeaderCollectionReusableView"];
    

    [_collectionView addHeaderWithCallback:^{
    // 模拟延迟加载数据，因此2秒后才调用）
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 结束刷新
        [_collectionView headerEndRefreshing];
    });

    DLog(@"下拉刷新完成！");
    }];
    [_collectionView addFooterWithCallback:^{
        // 模拟延迟加载数据，因此2秒后才调用）
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            // 结束刷新
            [_collectionView footerEndRefreshing];
        });
        
        DLog(@"下拉刷新完成！");
    }];
    
    [self addTestData];
}

- (void)initBMK
{
    // 地理位置反编码
    _geocodesearch = [[BMKGeoCodeSearch alloc]init];
    
    //设置定位精确度，默认：kCLLocationAccuracyBest
    [BMKLocationService setLocationDesiredAccuracy:kCLLocationAccuracyNearestTenMeters];
    //指定最小距离更新(米)，默认：kCLDistanceFilterNone
    [BMKLocationService setLocationDistanceFilter:LOCATION_DISTANCE_FILTER];
    
    //初始化BMKLocationService
    _locService = [[BMKLocationService alloc]init];
   
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    //启动LocationService
    [_locService startUserLocationService];
    _locService.delegate = self;
    _geocodesearch.delegate = self;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //停止LocationService
    //[_locService stopUserLocationService];
    _locService.delegate = nil;
    _geocodesearch.delegate = nil;
}

#pragma mark - 测试数据
- (void)addTestData
{
    [collectionViewDataArray addObjectsFromArray:@[@"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"",@"", @"", @"", @"", @""]];
    [slideImageArray addObjectsFromArray: @[@"http://img0.bdstatic.com/img/image/shouye/bizhi0424.jpg", @"http://img0.bdstatic.com/img/image/shouye/bizhi0424.jpg", @"http://img0.bdstatic.com/img/image/shouye/bizhi0424.jpg", @"http://img0.bdstatic.com/img/image/shouye/bizhi0424.jpg"]];
}

#pragma mark - BMKLocationServiceDelegate
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
     [SVProgressHUD dismiss];
     [_locService stopUserLocationService];
    DLog(@"didUpdateUserLocation lat %f,long %f",userLocation.location.coordinate.latitude, userLocation.location.coordinate.longitude);
    CLLocationCoordinate2D pt = userLocation.location.coordinate;
    BMKReverseGeoCodeOption *reverseGeocodeSearchOption = [[BMKReverseGeoCodeOption alloc]init];
    reverseGeocodeSearchOption.reverseGeoPoint = pt;
    BOOL flag = [_geocodesearch reverseGeoCode:reverseGeocodeSearchOption];
    if(flag)
    {
       
        DLog(@"反geo检索发送成功");
    }
    else
    {
         DLog(@"反地理编码失败");
    }
}

- (void)didFailToLocateUserWithError:(NSError *)error
{
    [_locService stopUserLocationService];
    DLog(@"定位失败！！！");
   // [SVProgressHUD showErrorWithStatus:@"定位失败！" duration:3];
}

#pragma mark - BMKGeoCodeSearchDelegate
- (void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error
{
   
    if (error == 0) {
        BMKAddressComponent *addressCom = result.addressDetail;
        _navBarManagerView.navigationBarButSearchButView.leftLabel.text = addressCom.city;
        DLog(@"%@%@%@%@%@", addressCom.province, addressCom.city, addressCom.district, addressCom.streetName, addressCom.streetNumber);
    } else {
       // [SVProgressHUD showErrorWithStatus:@"地理编码解析失败！" duration:3];
        DLog(@"反地理编码失败");
    }
}

#pragma mark - NavigationBarButSearchButViewDelegate
- (void)navigationBarLeftButClick:(UIButton *)but
{
    DLog(@"navigationBarLeftButClick");
}

- (void)navigationBarRightButClick:(UIButton *)but
{
    WSInfoListViewController *infoListVC = [[WSInfoListViewController alloc] init];
    [self.navigationController pushViewController:infoListVC animated:YES];
}

- (BOOL)navigationBarSearchViewTextFieldShouldBeginEditing:(UITextField *)textField
{
    WSSearchHistoryViewController *searchHistoryVC =[[WSSearchHistoryViewController alloc] init];
    [self.navigationController pushViewController:searchHistoryVC animated:YES];
    return NO;
}

- (void)navigationBarSearchViewTextFieldDidEndEditing:(UITextField *)textField
{
     DLog(@"navigationBarSearchViewTextFieldDidEndEditing:--%@", textField.text);
}

- (BOOL)navigationBarSearchViewTextFieldShouldReturn:(UITextField *)textField
{
    return YES;
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return collectionViewDataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    HomeCollectionViewCell *cell = (HomeCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"HomeCollectionViewCell" forIndexPath:indexPath];
    cell.validDateLabel.text = [NSString stringWithFormat:@"%d,%d", (int)indexPath.section, (int)indexPath.row];
    cell.distanceBut.tag = row;
    [cell.distanceBut addTarget:self action:@selector(distanceButAction:) forControlEvents:UIControlEventTouchUpInside];
    [cell.bigImageView sd_setImageWithURL:[NSURL URLWithString:@"http://img0.bdstatic.com/img/image/shouye/bizhi042"] placeholderImage:[UIImage imageNamed:[NSString stringWithFormat:@"radom_%d", [WSProjUtil gerRandomColor]]] options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        
    }];
    [cell.smallImageView sd_setImageWithURL:[NSURL URLWithString:@"http://img0.bdstatic.com/img/image/shouye/bizhi042g"] placeholderImage:[UIImage imageNamed:[NSString stringWithFormat:@"radom_%d", [WSProjUtil gerRandomColor]]] options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        
    }];
    cell.delegate = self;
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row =indexPath.row;
    CGFloat width = ((collectionView.bounds.size.width - 2 * CELLECTIONVIEW_CONTENT_INSET) - CELLECTIONVIEW_CELL_SPACE) / 2;
 if ((row % 4 == 0) || ((row + 1) % 4 == 0)) {
        return CGSizeMake(width, HOMECOLLECTIONVIEWCELL_HEIGHT);
    } else {
        return CGSizeMake(width, HOMECOLLECTIONVIEWCELL_HEIGHT_SMALL);
    }
}

//- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
//{
//    return -20;
//}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return CELLECTIONVIEW_CELL_SPACE;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, CELLECTIONVIEW_CONTENT_INSET, CELLECTIONVIEW_CONTENT_INSET, CELLECTIONVIEW_CONTENT_INSET);
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
         return CGSizeMake(collectionView.bounds.size.width, HOMEHEADERCOLLECTIONREUSABLEVIEW);
    } else {
        return CGSizeZero;
    }
   
}

-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HomeHeaderCollectionReusableView" forIndexPath:indexPath];
        ACImageScrollView *imageScrollView = headerView.imageScrollManagerView.acImageScrollView;
        [imageScrollView setImageData:slideImageArray];
        imageScrollView.callback = ^(int index) {
            DLog(@"广告：%d", index);
            WSAdvertisementDetailViewController *advertisementVC = [[WSAdvertisementDetailViewController alloc] init];
            advertisementVC.url = @"http://www.baidu.com";
            [self.navigationController pushViewController:advertisementVC animated:YES];
        };
        [headerView.storeSignInBut addTarget:self action:@selector(shopSignInAction:) forControlEvents:UIControlEventTouchUpInside];
        [headerView.scanProductBut addTarget:self action:@selector(scanProductAction:) forControlEvents:UIControlEventTouchUpInside];
        [headerView.inviteFriendBut addTarget:self action:@selector(invateFriendAction:) forControlEvents:UIControlEventTouchUpInside];
        [headerView.segmentedControl addTarget:self action:@selector(typeSegmentControlAction:) forControlEvents:UIControlEventTouchUpInside];
        headerView.tag = indexPath.row;
        return headerView;
    } else {
        return nil;
    }
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    WSProductDetailViewController *productDetailVC = [[WSProductDetailViewController alloc] init];
    productDetailVC.hasScan = YES;
    productDetailVC.url = @"http://www.baidu.com";
    [self.navigationController pushViewController:productDetailVC animated:YES];
}

#pragma mark -  距离按钮事件
- (void)distanceButAction:(UIButton *)but
{
    WSLocationDetailViewController *locationDetailVC = [[WSLocationDetailViewController alloc] init];
    [self.navigationController pushViewController:locationDetailVC animated:YES];
}

#pragma mark - HomeCollectionViewCellDelegate
//收藏
- (void)homeCollectionViewCellDidClickLeftBut:(HomeCollectionViewCell *)cell
{
    NSInteger tag = cell.tag;
    DLog(@"收藏：%d", (int)tag);
}

//分享
- (void)homeCollectionViewCellDidClickRightBut:(HomeCollectionViewCell *)cell
{
    NSInteger tag = cell.tag;
    DLog(@"分享：%d", (int)tag);
}

#pragma mark - SlideSwitchViewDelegate
- (void)slideSwitchViewDidSelectedIndex:(int)index
{
    DLog(@"点击了index:%d", index);
}

#pragma mark - 到店签到
- (void)shopSignInAction:(id)sender
{
    //  1. GPS定位不在店内跳到 WSNoInStoreViewController
    //  2. GPS定位在店内但还未签到时跳到 WSInStoreNoSignViewController
    //  3. 在店内已签到 跳到 WSStoreDetailViewController
    
    [self toNoInStoreVC];
    DLog(@"到店签到");
}

#pragma mark 扫描产品
- (void)scanProductAction:(id)sender
{
    // 1. 在店内跳到 WSStoreDetailViewController
    // 2. 不在店内跳到 WSScanNoInStoreViewController
    [self toScanNoInStore];
     DLog(@"扫描产品");
}

#pragma mark 邀请好友
- (void)invateFriendAction:(id)sender
{
    WSInviateFriendViewController *inviateFriendVC = [[WSInviateFriendViewController alloc] init];
    [self.navigationController pushViewController:inviateFriendVC animated:YES];
    DLog(@"邀请好友");
}

#pragma mark - 到店签到 不在店内
- (void)toNoInStoreVC
{
    WSNoInStoreViewController *noInstoreVC = [[WSNoInStoreViewController alloc] init];
    [self.navigationController pushViewController:noInstoreVC animated:YES];
}

#pragma mark 在店内没签到
- (void)toInStoreNoSign
{
    WSInStoreNoSignViewController *inStoreNoSignVC = [[WSInStoreNoSignViewController alloc] init];
    [self.navigationController pushViewController:inStoreNoSignVC animated:YES];
    
}

#pragma mark 在店内已签到
- (void)toStoreDetail
{
    WSStoreDetailViewController *storeDetailVC = [[WSStoreDetailViewController alloc] init];
    [self.navigationController pushViewController:storeDetailVC animated:YES];
}

- (void)toScanNoInStore
{
    WSScanNoInStoreViewController *scanNoInStoreVC = [[WSScanNoInStoreViewController alloc] init];
    [self.navigationController pushViewController:scanNoInStoreVC animated:YES];
}

#pragma mark 
- (void)typeSegmentControlAction:(UISegmentedControl *)segmentedControl
{
    NSInteger index = segmentedControl.selectedSegmentIndex;
    switch (index) {
        //超市
        case 0:
        {
            DLog(@"超市");
        }
            break;
        //百货服装
        case 1:
        {
          DLog(@"百货服装");
        }
            break;
        default:
            break;
    }
}

#pragma mark - BMKMapViewDelegate
- (void)mapView:(BMKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    DLog(@"regionDidChangeAnimated");
}

@end
