//
//  THNAbandonedImageFinder+MyProject.m
//  THNAbandonedImageFinder
//
//  Created by ZhangHonglin on 2017/8/12.
//  Copyright © 2017年 h. All rights reserved.
//

#import "THNAbandonedImageFinder+MyProject.h"
#import "THNFinderUtility.h"

@implementation THNAbandonedImageFinder (MyProject)

+ (NSMutableSet *)getAbandonedImageInEachBundleWithProjectPath:(NSString *)path {
    
    // 本地模块图片资源
    NSMutableSet *local_ImageSet = [self getLocalImageWithPath:path];
   
    // +.m中引用的图片资源
    NSMutableSet *code_ImageSet = [self getCodeImageWithPath:path];
    
    
    
    NSMutableSet *minus_imageSet = [NSMutableSet setWithSet:local_ImageSet];
    [minus_imageSet minusSet:code_ImageSet];
        
    return minus_imageSet;
}

#pragma mark - utility

//! 查找本地模块图片资源
+ (NSMutableSet *)getLocalImageWithPath:(NSString *)path {
    NSMutableSet *imageSet = [THNFinderUtility getLocalImageNameInPath:path];
    return imageSet;
}

//! 查找 xib storyboard 中引用的图片资源
+ (NSMutableDictionary *)getXibImageWithPath:(NSString *)path bundleArray:(NSArray *)bundleArray {
    
    NSMutableDictionary *code_bundleAndImageDic = [NSMutableDictionary dictionary];
    for (NSString *module in bundleArray) {
        NSString *bundlePath = [NSString stringWithFormat:@"%@/%@", path, module];
        NSMutableSet *imageSet = [THNFinderUtility parseImageNameFromXibAndStoryboardInPath:bundlePath];
        [code_bundleAndImageDic setObject:imageSet forKey:module];
    }
    
    return code_bundleAndImageDic;
}

//! 查找 .m 中引用的图片资源
+ (NSMutableSet *)getCodeImageWithPath:(NSString *)path {
    
    // 解析格式 [UIImage imageNamed:kClearFork]
    // 解析格式 [UIImage imageNamed:@"ClearFork"]
    
    NSArray *filesArray = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:path error:nil];
    NSPredicate *m_predicate = [NSPredicate predicateWithFormat:@"SELF ENDSWITH[c] '.m'"];
    NSArray *m_fileArray = [filesArray filteredArrayUsingPredicate:m_predicate];
    
    NSMutableSet *findImageSet = [NSMutableSet set];
    NSMutableSet *needFixedImageSet = [NSMutableSet set]; // 未按解析格式书写的图片（供细节分析用）
    NSMutableSet *wrongFormatImageSet = [NSMutableSet set];
    
    for (NSString *mFile in m_fileArray) {
        
        NSError *error = nil;
        NSString *mPath = [NSString stringWithFormat:@"%@/%@", path, mFile];
        NSString *fileData = [NSString stringWithContentsOfFile:mPath encoding:NSUTF8StringEncoding error:&error];
        if (error) {
            NSLog(@"error : %@", error);
            continue;
        }
        
        NSArray *lineArray = [fileData componentsSeparatedByString:@"\n"];
        for (NSString *line in lineArray) {
            
            if ([line containsString:@"bh_payment_redenvelopes_highlighted"]) {
                NSLog(@"");
            }
            
            NSString *mayImageName = [THNFinderUtility getSubStringFromTarget:line start:@"imageNamed:" end:@"]"];
            if (!mayImageName) {
                continue;
            }
            
            NSString *imageName = [THNFinderUtility getSubStringFromTarget:line start:@"imageNamed:@\"" end:@"\""];
            if (!imageName) {
                NSDictionary *dic = @{line:mFile};
                [needFixedImageSet addObject:dic];
                continue;
            }
            
            if ([imageName containsString:@".png"] || [imageName containsString:@".jpg"]) {
                NSDictionary *dic = @{line:mFile};
                [wrongFormatImageSet addObject:dic];
            }
            
            NSArray *appearArray = [line componentsSeparatedByString:@"[UIImage imageNamed:"];
            if (appearArray.count > 2) {
                NSLog(@"\n.m 一行出现多个图片:[%@][%@]\n", line, mFile);
            }
            
            [findImageSet addObject:imageName];
        }
    }
    
    NSLog(@"\n\n需修复的图片有：\n%@", needFixedImageSet);
    NSLog(@"\n\n格式有问题的图片：\n%@", wrongFormatImageSet);
    
    return findImageSet;
}

@end
