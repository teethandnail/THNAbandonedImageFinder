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
 * 查找废弃的图片
 *
 * @param path 工程主目录
 * @return 废弃的图片
 */
+ (NSMutableSet *)getAbandonedImageInEachBundleWithProjectPath:(NSString *)path;

@end
