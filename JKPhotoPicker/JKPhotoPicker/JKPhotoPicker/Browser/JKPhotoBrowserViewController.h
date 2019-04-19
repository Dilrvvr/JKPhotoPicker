//
//  JKPhotoBrowserViewController.h
//  JKPhotoPicker
//
//  Created by albert on 2016/12/30.
//  Copyright © 2016年 安永博. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JKPhotoItem, PHAsset;

@interface JKPhotoBrowserViewController : UIViewController

//+ (void)showWithViewController:(UIViewController *)viewController allPhotos:(NSArray *)allPhotos selectedItems:(NSArray *)selectedItems maxSelectCount:(NSUInteger)maxSelectCount indexPath:(NSIndexPath *)indexPath imageView:(UIImageView *)imageView completion:(void(^)(NSArray *seletedPhotos))completion;

+ (void)showWithViewController:(UIViewController *)viewController dataDict:(NSDictionary *)dataDict completion:(void(^)(NSArray <JKPhotoItem *> *seletedPhotos, NSArray<PHAsset *> *selectedAssetArray, NSArray <NSIndexPath *> *indexPaths, NSMutableDictionary *selectedPhotosIdentifierCache))completion;
@end
