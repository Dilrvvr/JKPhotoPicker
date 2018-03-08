//
//  JKPhotoBrowserCollectionViewCell.h
//  JKPhotoPicker
//
//  Created by albert on 2016/12/30.
//  Copyright © 2016年 安永博. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JKPhotoItem;

@interface JKPhotoBrowserCollectionViewCell : UICollectionViewCell
/** 照片模型 */
@property (nonatomic, strong) JKPhotoItem *photoItem;

/** 索引 */
@property (nonatomic, strong) NSIndexPath *indexPath;

/** 照片 */
@property (nonatomic, weak) UIImageView *photoImageView;

/** collectionView */
@property (nonatomic, weak) UICollectionView *collectionView;

/** 监听点击选中照片的block */
@property (nonatomic, copy) BOOL(^selectBlock)(BOOL selected, JKPhotoBrowserCollectionViewCell *currentCell);

/** 监听单击缩小照片的block */
@property (nonatomic, copy) void(^dismissBlock)(JKPhotoBrowserCollectionViewCell *currentCell, CGRect dismissFrame);
@end