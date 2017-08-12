//
//  THNAbandonedImageFinder+MyProject.h
//  THNAbandonedImageFinder
//
//  Created by ZhangHonglin on 2017/8/12.
//  Copyright © 2017年 h. All rights reserved.
//

#import "THNAbandonedImageFinder.h"

@interface THNAbandonedImageFinder (MyProject)

/**
 *
 * 模块化开发的工程，根据下面格式格式查找废弃的图片
 * 格式：[UIImage xks_imageNamed:@"clear_fork" fromBundle:orderBundle]
 * 备注：此方法不通用，为自己的工程专用
 *
 * @param path 工程主目录
 * @return 各模块各自废弃的图片
 */
+ (NSDictionary *)getAbandonedImageInEachBundleWithProjectPath:(NSString *)path;

@end
