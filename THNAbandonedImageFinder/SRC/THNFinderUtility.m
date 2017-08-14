//
//  THNFinderUtility.m
//  THNAbandonedImageFinder
//
//  Created by ZhangHonglin on 2017/8/12.
//  Copyright © 2017年 h. All rights reserved.
//

#import "THNFinderUtility.h"

@implementation THNFinderUtility

+ (NSMutableSet *)getLocalImageNameInPath:(NSString *)path {
    
    NSArray *filesArray = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:path error:nil];
    NSMutableSet *imageSet = [NSMutableSet set];
    
    if (!filesArray) {
        NSLog(@"查找图片资源出错，path不存在：%@", path);
        return imageSet;
    }
    
    NSPredicate *png_predicate = [NSPredicate predicateWithFormat:@"SELF ENDSWITH[c] '.png'"];
    NSArray *png_fileArray = [filesArray filteredArrayUsingPredicate:png_predicate];
    NSString *imageIdentifier = @".imageset";
    
    for (NSString *item in png_fileArray) {
        NSArray *components = [item componentsSeparatedByString:@"/"];
        NSString *imageName = nil;
        if ([item containsString:imageIdentifier]) {
            // 图片放在Assets.xcassets中，用.imageset中的命名
            for (NSInteger index = components.count-1; index >= 0; index--) {
                imageName = components[index];
                if ([imageName containsString:imageIdentifier]) {
                    imageName = [imageName stringByReplacingOccurrencesOfString:imageIdentifier withString:@""];
                    break;
                }
            }
        } else {
            // 图片不在Assets.xcassets中，则用图片原来的命名
            imageName = components.lastObject;
            imageName = [imageName stringByReplacingOccurrencesOfString:@"@1x" withString:@""];
            imageName = [imageName stringByReplacingOccurrencesOfString:@"@2x" withString:@""];
            imageName = [imageName stringByReplacingOccurrencesOfString:@"@3x" withString:@""];
            imageName = [imageName stringByReplacingOccurrencesOfString:@".png" withString:@""];
        }
        
        [imageSet addObject:imageName];
    }
    
    return imageSet;
}

+ (NSMutableSet *)parseImageNameFromXibAndStoryboardInPath:(NSString *)path {
    
    NSArray *filesArray = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:path error:nil];
    NSMutableSet *imageSet = [NSMutableSet set];
    
    if (!filesArray) {
        NSLog(@"解析XIB出错，path不存在：%@", path);
        return imageSet;
    }
    
    NSPredicate *xib_predicate = [NSPredicate predicateWithFormat:@"(SELF ENDSWITH[c] '.xib') OR (SELF ENDSWITH[c] '.storyboard')"];
    NSArray *xib_fileArray = [filesArray filteredArrayUsingPredicate:xib_predicate];
    
    for (NSString *xibFile in xib_fileArray) {
        
        NSError *error = nil;
        NSString *xibPath = [NSString stringWithFormat:@"%@/%@", path, xibFile];
        NSString *fileData = [NSString stringWithContentsOfFile:xibPath encoding:NSUTF8StringEncoding error:&error];
        
        if (error) {
            NSLog(@"读文件失败 : %@", error);
            continue;
        }
        
        NSArray *lineArray = [fileData componentsSeparatedByString:@"\n"];
        for (NSString *line in lineArray) {
            NSString *imageName = [self getSubStringFromTarget:line start:@"<image name=\"" end:@"\""];
            if (imageName) {
                if ([imageName containsString:@".png"]) {
                    // xib中不该指定“.png”,“@2x”等格式
                    NSLog(@"xib wrong format [%@][%@]", imageName, xibFile);
                }
                
                [imageSet addObject:imageName];
            }
        }
    }
    
    return imageSet;
}

+ (NSString *)getSubStringFromTarget:(NSString *)target start:(NSString *)start end:(NSString *)end {
    
    NSRange startRange = [target rangeOfString:start];
    if (startRange.location == NSNotFound) {
        return nil;
    }
    
    NSUInteger start_end = startRange.location+startRange.length;
    NSRange endRange = [target rangeOfString:end
                                     options:NSLiteralSearch
                                       range:NSMakeRange(start_end, target.length - start_end)];
    
    if (endRange.location == NSNotFound) {
        return nil;
    }
    
    NSRange subRange = NSMakeRange(start_end, endRange.location-start_end);
    NSString *subStr = [target substringWithRange:subRange];
    
    return subStr;
}

@end
