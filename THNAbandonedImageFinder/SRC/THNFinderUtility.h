//
//  THNFinderUtility.h
//  THNAbandonedImageFinder
//
//  Created by ZhangHonglin on 2017/8/12.
//  Copyright © 2017年 h. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface THNFinderUtility : NSObject

+ (NSMutableSet *)getLocalImageNameInPath:(NSString *)path;

+ (NSMutableSet *)parseImageNameFromXibAndStoryboardInPath:(NSString *)path;

+ (NSString *)getSubStringFromTarget:(NSString *)target start:(NSString *)start end:(NSString *)end;

@end
