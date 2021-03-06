//
//  JKPhotoPickerEngine.m
//  JKPhotoPicker
//
//  Created by albert on 2019/10/22.
//  Copyright © 2019 安永博. All rights reserved.
//

#import "JKPhotoPickerEngine.h"
#import "JKPhotoResultModel.h"
#import "JKPhotoAlbumItem.h"
#import <Photos/Photos.h>
#import "JKPhotoItem.h"

/** 队列 */
static dispatch_queue_t engineQueue_;

@implementation JKPhotoPickerEngine

#pragma mark
#pragma mark - 队列

+ (dispatch_queue_t)engineQueue {
    if (!engineQueue_) {
        engineQueue_ = dispatch_queue_create("com.albert.JKPhotoPickerEngine", DISPATCH_QUEUE_CONCURRENT);
    }
    return engineQueue_;
}

+ (void)destroyEngineQueue {
    
    if (!engineQueue_) { return; }
    
    engineQueue_ = nil;
}

#pragma mark
#pragma mark - 获取相册列表

/// 获取所有相册
+ (void)fetchAllAlbumCollectionIncludeHiddenAlbum:(BOOL)includeHiddenAlbum
                                         complete:(void(^)(NSArray <PHAssetCollection *> *albumCollectionList))complete{
    
    dispatch_async([self engineQueue], ^{
        
        NSArray *dataArray = [self getAllAlbumCollectionIncludeHiddenAlbum:includeHiddenAlbum];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            !complete ? : complete(dataArray);
        });
    });
}

/// 获取所有相册 JKPhotoAlbumItem
+ (void)fetchAllAlbumItemIncludeHiddenAlbum:(BOOL)includeHiddenAlbum
                                   complete:(void(^)(NSArray <PHAssetCollection *> *albumCollectionList, NSArray <JKPhotoAlbumItem *> *albumItemList, NSCache *albumItemCache))complete{
    
    [self fetchAllAlbumCollectionIncludeHiddenAlbum:includeHiddenAlbum complete:^(NSArray<PHAssetCollection *> * _Nonnull albumCollectionList) {
        
        dispatch_async([self engineQueue], ^{
            
            NSMutableArray *albumItemArray = [NSMutableArray arrayWithCapacity:albumCollectionList.count];
            
            NSCache *cache = [[NSCache alloc] init];
            
            [albumCollectionList enumerateObjectsUsingBlock:^(PHAssetCollection * _Nonnull assetCollection, NSUInteger index, BOOL * _Nonnull stop) {
                
                PHFetchResult *result = [PHAsset fetchAssetsInAssetCollection:assetCollection options:nil];
                
                if (index > 0 && result.count <= 0) { return; }
                
                JKPhotoAlbumItem *albumItem = [[JKPhotoAlbumItem alloc] init];
                
                albumItem.assetCollection = assetCollection;
                albumItem.fetchResult = result;
                albumItem.imagesCount = result.count;
                albumItem.thumbAsset = result.lastObject;
                
                [albumItemArray addObject:albumItem];
                
                if (cache == nil || albumItem.localIdentifier == nil) { return; }
                
                [cache setObject:albumItem forKey:albumItem.localIdentifier];
            }];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                !complete ? : complete(albumCollectionList, [albumItemArray copy], cache);
            });
        });
    }];
}

#pragma mark
#pragma mark - 获取相册中照片集

/// 获取相册PHAsset合集
+ (void)fetchPhotoAssetListWithCollection:(PHAssetCollection *)collection
                                 complete:(void(^)(NSArray <PHAsset *> *assetList))complete{
    
    if (!collection) {
        
        !complete ? : complete(nil);
        
        return;
    }
    
    dispatch_async([self engineQueue], ^{
        
        PHFetchResult *result = [PHAsset fetchAssetsInAssetCollection:collection options:nil];
        
        NSMutableArray *dataArray = [NSMutableArray arrayWithCapacity:result.count];
        
        [result enumerateObjectsUsingBlock:^(PHAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            if (!obj) { return; }
            
            [dataArray addObject:obj];
        }];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            !complete ? : complete([dataArray copy]);
        });
    });
}

/// 获取相册JKPhotoItem合集
+ (void)fetchPhotoItemListWithCollection:(PHAssetCollection *)collection
                      reverseResultArray:(BOOL)reverseResultArray
                       selectedItemCache:(NSCache *)selectedItemCache
                       showTakePhotoIcon:(BOOL)showTakePhotoIcon
                         completeHandler:(void(^)(JKPhotoResultModel *resultModel))completeHandler{
    
    if (!collection) {
        
        !completeHandler ? : completeHandler(nil);
        
        return;
    }
    
    dispatch_async([self engineQueue], ^{
        
        PHFetchResult *result = [PHAsset fetchAssetsInAssetCollection:collection options:nil];
        
        NSInteger resultCount = result.count;
        
        NSMutableArray *assetList = [NSMutableArray arrayWithCapacity:resultCount];
        
        NSMutableArray *itemList = [NSMutableArray arrayWithCapacity:resultCount];
        
        NSCache *itemCache = [[NSCache alloc] init];
        
        NSMutableArray *seletedNewItems = nil;
        NSMutableArray *seletedNewAssets = nil;
        NSCache *seletedNewCache = nil;
        
        if (selectedItemCache) {
            
            seletedNewItems = [NSMutableArray array];
            seletedNewAssets = [NSMutableArray array];
            seletedNewCache = [[NSCache alloc] init];
        }
        
        __block NSInteger index = (reverseResultArray ? resultCount - 1 : 0);
        
        [result enumerateObjectsUsingBlock:^(PHAsset * _Nonnull asset, NSUInteger idx, BOOL * _Nonnull stop) {
            
            JKPhotoItem *item = [[JKPhotoItem alloc] init];
            
            item.photoAsset = asset;
            
            item.browserIndexPath = [NSIndexPath indexPathForItem:index inSection:0];
            
            item.currentIndexPath = (showTakePhotoIcon ? [NSIndexPath indexPathForItem:index + 1 inSection:0] : item.browserIndexPath);
            
            if (reverseResultArray) {
                
                index--;
                
            } else {
                
                index++;
            }
            
            if (itemCache && item.assetLocalIdentifier) {
                
                [itemCache setObject:item forKey:item.assetLocalIdentifier];
            }
            
            if (selectedItemCache &&
                [selectedItemCache objectForKey:item.assetLocalIdentifier]) {
                
                [seletedNewItems addObject:item];
                [seletedNewAssets addObject:item.photoAsset];
                [seletedNewCache setObject:item forKey:item.assetLocalIdentifier];
            }
            
            // 反转数组
            if (reverseResultArray) {
                
                [assetList insertObject:asset atIndex:0];
                
                [itemList insertObject:item atIndex:0];
                
                return;
            }
            
            [assetList addObject:asset];
            
            [itemList addObject:item];
        }];
        
        JKPhotoResultModel *resultModel = [JKPhotoResultModel new];
        
        resultModel.assetList = [assetList copy];
        resultModel.itemList = [itemList copy];
        resultModel.itemCache = itemCache;
        
        resultModel.selectedItemList = seletedNewItems;
        resultModel.selectedAssetList = seletedNewAssets;
        resultModel.selectedItemCache = seletedNewCache;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            !completeHandler ? : completeHandler(resultModel);
        });
    });
}

#pragma mark
#pragma mark - Private

/** 获取全部相册 数组中是PHAssetCollection对象 */
+ (NSArray *)getAllAlbumCollectionIncludeHiddenAlbum:(BOOL)includeHiddenAlbum{
    
    NSMutableArray *dataArray = [NSMutableArray array];
    
    // 获取资源时的参数，为nil时则是使用系统默认值
    PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init];
    
    // 列出所有的智能相册
    PHFetchResult *smartAlbumsFetchResult = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAny options:fetchOptions];
    
    for (PHAssetCollection *sub in smartAlbumsFetchResult) {
        
        if (sub.assetCollectionSubtype == PHAssetCollectionSubtypeSmartAlbumUserLibrary) {
            
            [dataArray insertObject:sub atIndex:0];
            
            continue;
            
        } else if (sub.assetCollectionSubtype == PHAssetCollectionSubtypeSmartAlbumAllHidden &&
                   !includeHiddenAlbum) {
            
            // 隐藏相册 不展示
            
            continue;
        }
        
        [dataArray addObject:sub];
    }
    
    // 列出所有用户创建的相册
    PHFetchResult *smartAlbumsFetchResult1 = [PHAssetCollection fetchTopLevelUserCollectionsWithOptions:fetchOptions];
    
    // 遍历
    for (PHAssetCollection *sub in smartAlbumsFetchResult1) {
        
        if ([sub isKindOfClass:[PHCollectionList class]]) {
            
            [dataArray addObjectsFromArray:[self getAlbumListFromCollectionList:(PHCollectionList *)sub]];
            
            continue;
        }
        
        [dataArray addObject:sub];
    }
    
    return [dataArray copy];
}

/** 获取文件夹中的相册 */
+ (NSArray *)getAlbumListFromCollectionList:(PHCollectionList *)collectionList{
    
    PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init];
    
    PHFetchResult *result = [PHAssetCollection fetchCollectionsInCollectionList:collectionList options:fetchOptions];
    
    NSMutableArray *dataArray = [NSMutableArray array];
    
    for (PHAssetCollection *sub in result) {
        
        if ([sub isKindOfClass:[PHCollectionList class]]) {
            
            [dataArray addObjectsFromArray:[self getAlbumListFromCollectionList:(PHCollectionList *)sub]];
            
            continue;
        }
        
        [dataArray addObject:sub];
    }
 
    return [dataArray copy];
}

/** 获取全部相册 数组中是JKPhotoItem对象 */
+ (NSMutableArray *)getAlbumItemListWithCache:(NSCache *)cache{
    
    NSArray *arr = [JKPhotoPickerEngine getAllAlbumCollectionIncludeHiddenAlbum:NO];
    
    NSMutableArray *albumItemArray = [NSMutableArray array];
    
    NSInteger index = 0;
    
    for (PHAssetCollection *assetCollection in arr) {
        
        PHFetchResult *result = [JKPhotoPickerEngine getFetchResultWithAssetCollection:assetCollection];
        
        if (index > 0 && result.count <= 0) continue;
        
        JKPhotoAlbumItem *albumItem = [[JKPhotoAlbumItem alloc] init];
        
        albumItem.assetCollection = assetCollection;
        albumItem.fetchResult = result;
        albumItem.imagesCount = result.count;
        albumItem.thumbAsset = result.lastObject;
        
        [albumItemArray addObject:albumItem];
        
        index++;
        
        if (cache == nil || albumItem.localIdentifier == nil) { continue; }
        
        [cache setObject:albumItem forKey:albumItem.localIdentifier];
    }
    
    return albumItemArray;
}

/** 获取相机胶卷所有照片对象 倒序 数组中是PHAsset对象 */
+ (NSMutableArray *)getCameraRollAssets{
    
    return [self getPhotoAssetsWithFetchResult:[self getCameraRollFetchResult]];
}

/** 获取某一个相册的所有照片对象 倒序 数组中是PHAsset对象 */
+ (NSMutableArray *)getPhotoAssetsWithAssetCollection:(PHAssetCollection *)assetCollection{
    
    return [self getPhotoAssetsWithFetchResult:[self getFetchResultWithAssetCollection:assetCollection]];
}

/** 获取某一个相册的结果集 */
+ (PHFetchResult *)getFetchResultWithAssetCollection:(PHAssetCollection *)assetCollection{
    
    return [PHAsset fetchAssetsInAssetCollection:assetCollection options:nil];
}

/** 从某一个相册结果集中获取图片实体，并把图片结果存放到数组中，返回值数组中是PHAsset对象 */
+ (NSMutableArray *)getPhotoAssetsWithFetchResult:(PHFetchResult *)fetchResult{
    
    return [self getPhotoAssetsWithFetchResult:fetchResult optionDict:nil complete:nil];
}

/** 从某一个相册结果集中获取图片实体，并把图片结果存放到数组中，返回值数组中是PHAsset对象 */
+ (NSMutableArray *)getPhotoAssetsWithFetchResult:(PHFetchResult *)fetchResult
                                       optionDict:(NSDictionary *)optionDict
                                         complete:(void(^)(NSDictionary *resultDict))complete {
    
    NSCache *allCache = [[NSCache alloc] init];
    NSDictionary *seletedCache = optionDict[@"seletedCache"];
    
    BOOL showTakePhotoIcon = [optionDict[@"showTakePhotoIcon"] boolValue];
    
    NSMutableArray *seletedNewItems = [NSMutableArray array];
    NSMutableArray *seletedNewAssets = [NSMutableArray array];
    NSMutableDictionary *seletedNewCache = [NSMutableDictionary dictionary];
    
    NSMutableArray *dataArray = [NSMutableArray array];
    
    __block NSInteger i = ((showTakePhotoIcon && seletedCache != nil) ? 0 : -1);
    
    [fetchResult enumerateObjectsWithOptions:(NSEnumerationReverse) usingBlock:^(PHAsset * _Nonnull asset, NSUInteger idx, BOOL * _Nonnull stop) {
        
        i++;
        
        JKPhotoItem *item = [[JKPhotoItem alloc] init];
        item.photoAsset = asset;
        item.currentIndexPath = [NSIndexPath indexPathForItem:i inSection:0];
        
        if (allCache != nil) {
            
            [allCache setObject:item forKey:item.assetLocalIdentifier];
        }
        
        if ([seletedCache objectForKey:item.assetLocalIdentifier] != nil) {
            
            [seletedNewItems addObject:item];
            [seletedNewAssets addObject:item.photoAsset];
            [seletedNewCache setObject:item forKey:item.assetLocalIdentifier];
        }
        
        [dataArray addObject:item];
    }];
    
    NSMutableDictionary *dictM = [NSMutableDictionary dictionary];
    
    dictM[@"allPhotos"] = dataArray;
    dictM[@"allCache"] = allCache;
    dictM[@"seletedItems"] = seletedNewItems;
    dictM[@"seletedAssets"] = seletedNewAssets;
    dictM[@"seletedCache"] = seletedNewCache;
    
    !complete ? : complete(dictM);
    
    return dataArray;
}

/** 只获取相机胶卷结果集 */
+ (PHFetchResult *)getCameraRollFetchResult{
    
    // 获取系统相册CameraRoll 的结果集
    PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init];
    
    PHFetchResult *smartAlbumsFetchResult = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:fetchOptions];
    
    PHFetchResult *fetch = [PHAsset fetchAssetsInAssetCollection:[smartAlbumsFetchResult objectAtIndex:0] options:fetchOptions];
    
    return fetch;
}
@end

/* 参数说明
 1、asset，图像对应的 PHAsset。
 
 2、targetSize，需要获取的图像的尺寸，如果输入的尺寸大于资源原图的尺寸，则只返回原图。需要注意在 PHImageManager 中，所有的尺寸都是用 Pixel 作为单位（Note that all sizes are in pixels），因此这里想要获得正确大小的图像，需要把输入的尺寸转换为 Pixel。如果需要返回原图尺寸，可以传入 PhotoKit 中预先定义好的常量?PHImageManagerMaximumSize，表示返回可选范围内的最大的尺寸，即原图尺寸。
 
 3、contentMode，图像的剪裁方式，与?UIView 的 contentMode 参数相似，控制照片应该以按比例缩放还是按比例填充的方式放到最终展示的容器内。注意如果 targetSize 传入?PHImageManagerMaximumSize，则 contentMode 无论传入什么值都会被视为?PHImageContentModeDefault。
 
 4、options，一个?PHImageRequestOptions 的实例，可以控制的内容相当丰富，包括图像的质量、版本，也会有参数控制图像的剪裁，下面再展开说明。
 
 5、resultHandler，请求结束后被调用的 block，返回一个包含资源对于图像的 UIImage 和包含图像信息的一个 NSDictionary，在整个请求的周期中，这个 block 可能会被多次调用，关于这点连同 options 参数在下面展开说明。
 */
