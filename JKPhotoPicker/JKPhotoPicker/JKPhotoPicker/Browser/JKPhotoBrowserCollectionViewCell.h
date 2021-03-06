//
//  JKPhotoBrowserCollectionViewCell.h
//  JKPhotoPicker
//
//  Created by albert on 2016/12/30.
//  Copyright © 2016年 安永博. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JKPhotoItem, PHCachingImageManager, AVPlayerItem, PHLivePhotoView, WKWebView, JKPhotoBrowserViewController;

@interface JKPhotoBrowserCollectionViewCell : UICollectionViewCell

/** 缓存管理对象 */
@property (nonatomic, weak) PHCachingImageManager *cachingImageManager;

/** 照片模型 */
@property (nonatomic, strong) JKPhotoItem *photoItem;

/** 索引 */
@property (nonatomic, strong) NSIndexPath *indexPath;

/** 照片 */
@property (nonatomic, weak) UIImageView *photoImageView;

/** livePhotoView */
@property (nonatomic, weak) PHLivePhotoView *livePhotoView;

/** 播放gif的webView */
@property (nonatomic, weak) WKWebView *gifWebView;

/** collectionView */
@property (nonatomic, weak) UICollectionView *collectionView;

/** controller */
@property (nonatomic, weak) JKPhotoBrowserViewController *controller;

/** controllerView */
@property (nonatomic, weak) UIView *controllerView;

/** browserContentView */
@property (nonatomic, weak) UIView *browserContentView;

/** 监听点击选中照片的block */
@property (nonatomic, copy) BOOL(^selectBlock)(BOOL selected, JKPhotoBrowserCollectionViewCell *currentCell);

/** 监听单击缩小照片的block */
@property (nonatomic, copy) void(^dismissBlock)(JKPhotoBrowserCollectionViewCell *currentCell, CGRect dismissFrame);

/** 监听图片加载完成的block */
@property (nonatomic, copy) void(^imageLoadFinishBlock)(JKPhotoBrowserCollectionViewCell *currentCell);

/** 监听点击播放视频的block */
@property (nonatomic, copy) void (^playVideoBlock)(AVPlayerItem *item);

/** imageRequestID */
@property (nonatomic, assign) int imageRequestID;

/** livePhotoRequestID */
@property (nonatomic, assign) int livePhotoRequestID;

/** gifRequestID */
@property (nonatomic, assign) int gifRequestID;
@end
