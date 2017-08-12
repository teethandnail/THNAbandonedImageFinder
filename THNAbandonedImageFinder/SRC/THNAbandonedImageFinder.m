//
//  THNAbandonedImageFinder.m
//  THNAbandonedImageFinder
//
//  Created by ZhangHonglin on 2017/8/12.
//  Copyright © 2017年 h. All rights reserved.
//

#import "THNAbandonedImageFinder.h"
#import "THNFinderUtility.h"

@implementation THNAbandonedImageFinder

+ (NSArray *)getAbandonedImageInProjectPath:(NSString *)path {
    // 本地模块图片资源
    NSMutableSet *local_imageSet = [THNFinderUtility getLocalImageNameInPath:path];
    // xib中引用的图片资源
    NSMutableSet *code_imageSet = [THNFinderUtility parseImageNameFromXibAndStoryboardInPath:path];
    // +.m中引用的图片资源
    code_imageSet = [self getCodeImageWithPath:path codeImageSet:code_imageSet];
    // 白名单图片加入 code_imageSet
    [code_imageSet addObjectsFromArray:[self getWhiteListImage]];
    
    // local_imageSet 与 code_imageSet 的图片做差集比较，得到废弃的图片集合
    [local_imageSet minusSet:code_imageSet];
    
    return local_imageSet.allObjects;
}

//! 查找 .m 中引用的图片资源
+ (NSMutableSet *)getCodeImageWithPath:(NSString *)path codeImageSet:(NSMutableSet *)codeImageSet {
    // 解析格式 [UIImage imageNamed:@"icon_lowSpeed"]
    // 解析格式 [UIImage imageNamed:kiIcon_lowSpeed]
    
    NSArray *filesArray = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:path error:nil];
    NSPredicate *m_predicate = [NSPredicate predicateWithFormat:@"SELF ENDSWITH[c] '.m'"];
    NSArray *m_fileArray = [filesArray filteredArrayUsingPredicate:m_predicate];
    
    NSMutableSet *needFixedImageSet = [NSMutableSet set]; // 未按解析格式书写的图片（供细节分析用）
    
    for (NSString *mFile in m_fileArray) {
        
        NSError *error = nil;
        NSString *mPath = [NSString stringWithFormat:@"%@/%@", path, mFile];
        NSString *fileData = [NSString stringWithContentsOfFile:mPath encoding:NSUTF8StringEncoding error:&error];
        if (error) {
            NSLog(@"error: %@", error);
            continue;
        }
        
        NSArray *lineArray = [fileData componentsSeparatedByString:@"\n"];
        for (NSString *line in lineArray) {
            
            NSString *mayImageName = [THNFinderUtility getSubStringFromTarget:line start:@"UIImage imageNamed:" end:@"]"];
            if (!mayImageName) {
                continue;
            }
            
            NSString *imageName = [THNFinderUtility getSubStringFromTarget:line start:@"UIImage imageNamed:@\"" end:@"\""];
            if (!imageName) {
                NSDictionary *dic = @{mayImageName:mFile};
                [needFixedImageSet addObject:dic];
                continue;
            }
            
            [codeImageSet addObject:imageName];
        }
    }
    
    return codeImageSet;
}

+ (NSArray *)getWhiteListImage {
    NSArray *imageArray = @[];
    return imageArray;
}

@end
