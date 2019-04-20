//
//  JKPhotoItem.h
//  JKPhotoPicker
//
//  Created by albert on 2016/12/21.
//  Copyright © 2016年 安永博. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JKPhotoConst.h"

@class PHAsset, PHAssetCollection, PHFetchResult;

@interface JKPhotoItem : NSObject

/****************************照片相关****************************/

/* 是否可以选中 */
@property (nonatomic, assign, readonly) BOOL shouldSelected;

/* 是否可以播放gif */
@property (nonatomic, assign, readonly) BOOL shouldPlayGif;

/** 数据类型描述 */
@property (nonatomic, copy) NSString *dataTypeDescription;

/* 媒体类型 */
@property (nonatomic, assign, readonly) JKPhotoPickerMediaDataType dataType;

/* 是否选中 */
@property (nonatomic, assign) BOOL isSelected;

/** 在所有照片中的索引 因为有个拍照，所以 +1  */
@property (nonatomic, strong) NSIndexPath *currentIndexPath;

/* 是否显示相机图标 */
@property (nonatomic, assign) BOOL isShowCameraIcon;

/* 当前显示的Image */
@property (nonatomic, strong) PHAsset *photoAsset;

/** 高清缩略图 */
@property (nonatomic, strong, readonly) UIImage *thumImage;

/** 原图 */
@property (nonatomic, strong, readonly) UIImage *originalImage;

/** 照片的标识 */
@property (nonatomic, copy, readonly) NSString *assetLocalIdentifier;



/****************************相册相关****************************/

/** 相册 */
@property (nonatomic, strong) PHAssetCollection *albumAssetCollection;

/** 相册的结果集 */
@property (nonatomic, strong) PHFetchResult *albumFetchResult;

/** 相册的标识 */
@property (nonatomic, copy, readonly) NSString *albumLocalIdentifier;

/* 相册的缩略图asset */
@property (nonatomic, strong) PHAsset *albumThumAsset;

/** 相册缩略图 */
@property (nonatomic, strong, readonly) UIImage *albumThumImage;

/** 相册标题 */
@property (nonatomic, copy, readonly) NSString *albumTitle;

/** 相册图片数量 */
@property (nonatomic, assign) NSInteger albumImagesCount;



/****************************视频相关****************************/

/** 视频缓存的路径 */
@property (nonatomic, copy, readonly) NSString *videoPath;






+ (void)setSelectDataType:(JKPhotoPickerMediaDataType)selectDataType;

+ (JKPhotoPickerMediaDataType)selectDataType;
@end