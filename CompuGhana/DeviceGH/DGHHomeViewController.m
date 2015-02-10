//
//  DGHHomeViewController.m
//  DeviceGH
//
//  Created by Sreelal H on 07/12/14.
//  Copyright (c) 2014 Sreelal H. All rights reserved.
//

#import "DGHHomeViewController.h"
#import "AOScrollerView.h"
#import "WebHandler.h"
#import "Constants.h"
#import "ProductCategory.h"
#import "Banner.h"
#import "AppDelegate.h"
#import "HelperClass.h"
#import "CacheManager.h"
#import "DGHHomeCollectionViewCell.h"
#import "DGHProductViewController.h"
#import "DGHEnquireViewController.h"

#import <QuartzCore/QuartzCore.h>

@interface DGHHomeViewController ()<ValueClickDelegate>{
   

}

@property (strong, nonatomic) NSMutableArray  *searchProducts;

@end

@implementation DGHHomeViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"device_nav_logo.png"]];
    
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8];
    shadow.shadowOffset = CGSizeMake(0, 1);
    NSDictionary *rightBarButtonTextAttributes = [[NSDictionary alloc] initWithObjectsAndKeys:[UIColor whiteColor]
                                                                                               , NSForegroundColorAttributeName,
                                                                                               shadow, NSShadowAttributeName,
                                                  [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:13.0], NSFontAttributeName, nil];

    [self.navigationItem.rightBarButtonItem setTitleTextAttributes:rightBarButtonTextAttributes forState:UIControlStateNormal];
    
    //[self startMarqueeScrolling];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [self loadCategories];
    [self loadBannerImages];
    [self loadFooterText];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Webservice Implementations

- (void)loadCategories {
    
    [[AppDelegate instance] showBusyView:@"Loading..."];
    
    [WebHandler getCategoriesWithCallback:^(id object, NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSMutableArray *categories = self.homeCategories = (NSMutableArray *)object;
            
            if (categories.count) {                
                [categoiesCollectionView reloadData];
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_REFRESH_MENU object:categories];
            }
            
            [[AppDelegate instance] hideBusyView];
        });
    }];
}

- (void)loadBannerImages {
    
    [WebHandler getBannerImagesWithCallback:^(id object, NSError *error) {
        
        NSMutableArray *banners      = (NSMutableArray *)object;
        
        if (banners.count) {
            NSMutableArray *bannerImages = [[NSMutableArray alloc] init];
            
            [banners enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                Banner *banner = (Banner *)obj;
                [bannerImages addObject:banner.bannerImageUrl];
            }];
            
            NSLog(@"Bnner Images : %@", bannerImages);
            
            if (bannerImages.count) {                
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIView *removingView = [self.view viewWithTag:222];
                    [removingView removeFromSuperview];
                    
                    AOScrollerView *aSV = [[AOScrollerView alloc]initWithNameArr:bannerImages titleArr:nil height:120
                                                                           width: self.view.frame.size.width];
                    aSV.vDelegate=self;
                    aSV.frame = CGRectMake(0, 110, self.view.frame.size.width, 120);
                    aSV.tag = 222;
                    
                    [self.view addSubview:aSV];
                });
            }            
        }
    }];
}

- (void)loadFooterText {
    
    [WebHandler getFooterTextWithCallback:^(id object, NSError *error) {
        if (object != nil) [[CacheManager sharedInstance] saveFooterText:object];
        else object = [[CacheManager sharedInstance] footerText];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (object != nil) [self startMarqueeScrollingWithText:object];
        });
    }];
}

#pragma mark - AOScrollViewDelegate

- (void)buttonClick:(int)vid {
    
    NSLog(@"%d",vid);
}

#pragma mark - Button Actions

- (IBAction)equireListClicked:(id)sender {
    
    UINavigationController *enquireVCNav = [self.storyboard instantiateViewControllerWithIdentifier:@"EnquireViewNavigation"];
    
    [self.sideMenuViewController setContentViewController:enquireVCNav];
    [self.sideMenuViewController hideMenuViewController];
}

#pragma mark - Marquee Scrolling Label

- (void)startMarqueeScrollingWithText:(NSString *)text {
    
    self.footerLabel.text = [NSString stringWithFormat:@"%@    %@", text, text];
    //self.footerLabel.text =  @"This is a test of MarqueeLabel - the text is long enough that it needs to scroll to see the whole thing.";
    self.footerLabel.rate = 16.0;
    self.footerLabel.fadeLength = 10.0;
    self.footerLabel.marqueeType = MLContinuous;
    //self.footerLabel.continuousMarqueeExtraBuffer = 10.0f;
    self.footerLabel.animationDelay = 3;
    
    //[self.footerLabel restartLabel];
    
    /*self.footerLabel.marqueeType = MLContinuous;
    self.footerLabel.scrollDuration = 15.0;
    self.footerLabel.animationCurve = UIViewAnimationOptionCurveEaseInOut;
    self.footerLabel.fadeLength = 10.0f;
    self.footerLabel.leadingBuffer = 30.0f;
    self.footerLabel.trailingBuffer = 20.0f;
    self.footerLabel.tag = 101;
    self.footerLabel.text = @"This is a test of MarqueeLabel - the text is long enough that it needs to scroll to see the whole thing.";*/
    
    //[MarqueeLabel controllerViewWillAppear:self];
}

#pragma mark - UICollectionView Delegates

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {

    return self.homeCategories.count;
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    ProductCategory *category = self.homeCategories[indexPath.row];
    
    DGHHomeCollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"HomeCell" forIndexPath:indexPath];
    
    [cell setupBg];
    [cell loadCategoryImageForCategory:category];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UINavigationController *navController;
    
    ProductCategory *selectedCategory = self.homeCategories[indexPath.row];
    
    if (selectedCategory.children > 0) {
        UINavigationController *categoryVCNav = [self.storyboard instantiateViewControllerWithIdentifier:@"ContentViewNavigation"];
        DGHContentViewController *contentView = [[categoryVCNav viewControllers] firstObject];
        
        contentView.category = selectedCategory;
        navController = categoryVCNav;
    }
    else if (selectedCategory.children == 0) {
        UINavigationController *productVCNav = [self.storyboard instantiateViewControllerWithIdentifier:@"ProductViewNavigation"];
        DGHProductViewController *productView = [[productVCNav viewControllers] firstObject];
        
        productView.category = selectedCategory;
        navController = productVCNav;
    }
    
    [self.sideMenuViewController setContentViewController:navController];
    [self.sideMenuViewController hideMenuViewController];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat pixel;
    CGSize size;
    
    if ([HelperClass isIphone6Plus]) pixel = 200;
    else pixel = [UIScreen mainScreen].bounds.size.width/2;
    
    size = CGSizeMake(pixel, pixel);
    
    return size;
}

- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    
    UIEdgeInsets insets = UIEdgeInsetsMake(0, 0, 0, 0);;
    
    return insets;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    
    return 0.0f;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    
    return 0.0f;
}

#pragma mark - Product Search

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    
    [searchBar resignFirstResponder];
    
    if (searchBar.text.length<=0) return;
    
    [[AppDelegate instance] showBusyView:@"Loading..."];
    
    [WebHandler searchProductsWithCriteria:searchBar.text withCallback:^(id object, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            self.searchProducts = (NSMutableArray *)object;
            
            if (self.searchProducts.count > 0) {
                UINavigationController *productVCNav = [self.storyboard instantiateViewControllerWithIdentifier:@"ProductViewNavigation"];
                DGHProductViewController *productView = [[productVCNav viewControllers] firstObject];
                
                productView.isProductSearch = YES;
                productView.products = self.searchProducts;
                
                [self.sideMenuViewController setContentViewController:productVCNav];
                [self.sideMenuViewController hideMenuViewController];
            }
            else {
                [HelperClass showAlertWithMessage:ALERT_NO_SEARCH_RESULT];
            }
            
            [[AppDelegate instance] hideBusyView];
        });
    }];
    
}

@end
