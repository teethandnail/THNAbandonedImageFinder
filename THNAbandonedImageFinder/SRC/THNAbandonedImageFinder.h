//
//  THNAbandonedImageFinder.h
//  THNAbandonedImageFinder
//
//  Created by ZhangHonglin on 2017/8/12.
//  Copyright © 2017年 h. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface THNAbandonedImageFinder : NSObject

/**
 *
 * 查找工程中的废弃图片，按以下格式查找
 * 格式：[UIImage imageNamed:@"icon_lowSpeed"]
 *
 * @param path 工程主目录
 * @return 废弃的图片
 */
+ (NSArray *)getAbandonedImageInProjectPath:(NSString *)path;

@end
