//
//  THNAbandonedImageFinder+MyProject.m
//  THNAbandonedImageFinder
//
//  Created by ZhangHonglin on 2017/8/12.
//  Copyright © 2017年 h. All rights reserved.
//

#import "THNAbandonedImageFinder+MyProject.h"
#import "THNFinderUtility.h"

static NSString * const kCHDShoppingModule              = @"Pods/CHDShoppingModule";
static NSString * const kCHDStatisticsModule            = @"Pods/CHDStatisticsModule";
static NSString * const kXKSPaymentModule               = @"Pods/XKSPaymentModule";
static NSString * const kCHDCommonModule                = @"Pods/CHDCommonModule";
static NSString * const kCHDOrderModule                 = @"Pods/CHDOrderModule";
static NSString * const kXKSVipModule                   = @"Pods/XKSVipModule";
static NSString * const kCHDAreaModule                  = @"Pods/CHDAreaModule";
static NSString * const kCHDAccessibilitySettingsModule = @"Pods/CHDAccessibilitySettingsModule";
static NSString * const kCHDRechargeCardModule          = @"Pods/CHDRechargeCardModule";
static NSString * const kCHDVerificationModule          = @"Pods/CHDVerificationModule";
static NSString * const kCHDShiftExchangeModule         = @"Pods/CHDShiftExchangeModule";
static NSString * const kCHDCommodityMgrModule          = @"Pods/CHDCommodityMgrModule";
static NSString * const kCHDMessageModule               = @"Pods/CHDMessageModule";
static NSString * const kXKSCommonSDKBundleName         = @"Pods/XKSCommonSDK";


@implementation THNAbandonedImageFinder (MyProject)

+ (NSDictionary *)getAbandonedImageInEachBundleWithProjectPath:(NSString *)path {
    
    // 需要解析的模块
    NSArray *needPraseModulePathArray = @[kCHDShoppingModule,
                                          kCHDStatisticsModule,
                                          kXKSPaymentModule,
                                          kCHDCommonModule,
                                          kCHDOrderModule,
                                          kXKSVipModule,
                                          kCHDAreaModule,
                                          kCHDAccessibilitySettingsModule,
                                          kCHDRechargeCardModule,
                                          kCHDVerificationModule,
                                          kCHDShiftExchangeModule,
                                          kCHDCommodityMgrModule,
                                          kCHDMessageModule
                                          ];
    
    // 本地模块图片资源
    NSMutableDictionary *local_bundleAndImageDic = [self getLocalImageWithPath:path bundleArray:needPraseModulePathArray];
    // xib中引用的图片资源
    NSMutableDictionary *code_bundleAndImageDic = [self getXibImageWithPath:path bundleArray:needPraseModulePathArray];
    // +.m中引用的图片资源
    code_bundleAndImageDic = [self getCodeImageWithPath:path codeBundleImageDic:code_bundleAndImageDic];
    
    
    // 白名单图片加入code_bundleAndImageDic
    for (NSString *module in needPraseModulePathArray) {
        NSMutableSet *imageSet = code_bundleAndImageDic[module];
        NSArray *whiteListArray = [self getWhiteListImageWithBundleName:module];
        [imageSet addObjectsFromArray:whiteListArray];
    }
    
    // local_bundleAndImageDic 与 code_bundleAndImageDic 的相同模块的图片做差集比较，得到废弃的图片集合
    NSMutableDictionary *unused_bundleAndImageDic = [NSMutableDictionary dictionary];
    for (NSString *module in local_bundleAndImageDic.allKeys) {
        
        NSMutableSet *local_moduleImageSet = local_bundleAndImageDic[module];
        NSMutableSet *code_moduleImageSet = code_bundleAndImageDic[module];
        
        if (!local_moduleImageSet) {
            local_moduleImageSet = [NSMutableSet set];
        }
        
        if (!code_moduleImageSet) {
            code_moduleImageSet = [NSMutableSet set];
        }
        
        NSMutableSet *minus_imageSet = [NSMutableSet setWithSet:local_moduleImageSet];
        [minus_imageSet minusSet:code_moduleImageSet];
        [unused_bundleAndImageDic setObject:minus_imageSet forKey:module];
    }
    
    
    // 格式化输出，便于排版
    NSMutableDictionary *outputDic = [NSMutableDictionary dictionary];
    for (NSString *key in unused_bundleAndImageDic.allKeys) {
        NSSet *value = unused_bundleAndImageDic[key];
        [outputDic setObject:value.allObjects forKey:key];
    }
        
    return outputDic;
}

#pragma mark - utility

//! 查找本地模块图片资源
+ (NSMutableDictionary *)getLocalImageWithPath:(NSString *)path bundleArray:(NSArray *)bundleArray {
    
    NSMutableDictionary *local_bundleAndImageDic = [NSMutableDictionary dictionary];
    for (NSString *module in bundleArray) {
        NSString *bundlePath = [NSString stringWithFormat:@"%@/%@", path, module];
        NSMutableSet *imageSet = [THNFinderUtility getLocalImageNameInPath:bundlePath];
        [local_bundleAndImageDic setObject:imageSet forKey:module];
    }
    
    return local_bundleAndImageDic;
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
+ (NSMutableDictionary *)getCodeImageWithPath:(NSString *)path codeBundleImageDic:(NSMutableDictionary *) code_bundleAndImageDic{
    
    // 解析格式 [UIImage xks_imageNamed:kImageName_clear_fork fromBundle:orderBundle]
    // 解析格式 [UIImage xks_imageNamed:@"clear_fork" fromBundle:orderBundle]
    // 解析格式 [UIImage xks_imageNamed:@"clear_fork" fromBundle:@"orderBundle"]
    
    NSArray *filesArray = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:path error:nil];
    NSPredicate *m_predicate = [NSPredicate predicateWithFormat:@"SELF ENDSWITH[c] '.m'"];
    NSArray *m_fileArray = [filesArray filteredArrayUsingPredicate:m_predicate];
    
    NSMutableSet *needFixedImageSet = [NSMutableSet set]; // 未按解析格式书写的图片（供细节分析用）
    NSMutableSet *noBundleImageSet = [NSMutableSet set];  // 未指定bundle的图片（供细节分析用）
    
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
            
            NSString *mayImageName = [THNFinderUtility getSubStringFromTarget:line start:@"xks_imageNamed:" end:@" "];
            if (!mayImageName) {
                continue;
            }
            
            NSString *imageName = [THNFinderUtility getSubStringFromTarget:line start:@"xks_imageNamed:@\"" end:@"\""];
            if (!imageName) {
                NSDictionary *dic = @{mayImageName:mFile};
                [needFixedImageSet addObject:dic];
                continue;
            }
            
            NSString *bundleName = [THNFinderUtility getSubStringFromTarget:line start:@"fromBundle:" end:@"]"];
            if (!bundleName) {
                NSDictionary *dic = @{mayImageName:mFile};
                [noBundleImageSet addObject:dic];
                continue;
            }
            
            NSString *module = [self getModuleKeyNameByBundleInCode:bundleName];
            if (!module) {
                continue;
            }
            
            NSMutableSet *imageSet = code_bundleAndImageDic[module];
            if (!imageSet) {
                imageSet = [NSMutableSet set];
                [code_bundleAndImageDic setObject:imageSet forKey:module];
            }
            
            [imageSet addObject:imageName];
        }
    }
    
    return code_bundleAndImageDic;
}

#pragma mark - Configure

//! 代码中出现的模块，转换成字典中对应的key
+ (NSString *)getModuleKeyNameByBundleInCode:(NSString *)name {
    
    // shopping
    if ([@[@"CHDShoppingModuleBundleName",
           @"@\"CHDShoppingModule\""] containsObject:name]) {
        return kCHDShoppingModule;
    }
    
    // statics
    if ([@[@"kStaticsModule",
           @"@\"CHDStatisticsModule\""] containsObject:name]) {
        return kCHDStatisticsModule;
    }
    
    // payment
    if ([@[@"XKSPaymentInterfaceBundleName",
           @"@\"XKSPaymentModule\""] containsObject:name]) {
        return kXKSPaymentModule;
    }
    
    // common
    if ([@[@"CHDCommonModuleBundleName",
           @"@\"CHDCommonModule\"",
           @"@\"CHDCommonModule.bundle\""] containsObject:name]) {
        return kCHDCommonModule;
    }
    
    // order
    if ([@[@"orderModuleBundle",
           @"@\"CHDOrderModule\"",
           @"@\"CHDOrderModule.bundle\""] containsObject:name]) {
        return kCHDOrderModule;
    }
    
    // vip
    if ([@[@"XKSVipModuleBundleName"] containsObject:name]) {
        return kXKSVipModule;
    }
    
    // area
    if ([@[@"CHDAreaModuleInterfaceBundleName"] containsObject:name]) {
        return kCHDAreaModule;
    }
    
    // accessibility
    if ([@[@"@\"AccessibilitySettingsModule\"",
           @"AccessibilitySettingsModule"] containsObject:name]) {
        return kCHDAccessibilitySettingsModule;
    }
    
    // recharge
    if ([@[@"@\"CHDRechargeCardModule\"",
           @"CHDRechargeCardModuleBundleName"] containsObject:name]) {
        return kCHDRechargeCardModule;
    }
    
    // CHDVerificationModule
    if ([@[@"@\"CHDVerificationModule\""] containsObject:name]) {
        return kCHDVerificationModule;
    }
    
    // CHDShiftExchangeModule
    if ([@[@"@\"CHDShiftExchangeModule.bundle\""] containsObject:name]) {
        return kCHDShiftExchangeModule;
    }
    
    // XKSCommonSDKBundleName
    if ([@[@"XKSCommonSDKBundleName"] containsObject:name]) {
        return kXKSCommonSDKBundleName;
    }
    
    // CHDCommodityMgrModule
    if ([@[@"@\"CHDCommodityMgrModule\""] containsObject:name]) {
        return kCHDCommodityMgrModule;
    }
    
    // CHDMessageModuleBundleName
    if ([@[@"CHDMessageModuleBundleName"] containsObject:name]) {
        return kCHDMessageModule;
    }
    
    NSLog(@"有遗漏的bundle未加入getBundleName : [%@]", name);
    return nil;
}

//! 白名单图片
+ (NSArray *)getWhiteListImageWithBundleName:(NSString *)name {
    if ([name isEqualToString:kCHDAccessibilitySettingsModule]) {
        return @[
                 // Array 中配置
                 @"accessibilitySetting_voice",
                 @"accessibilitySetting_kouibei",
                 @"accessibilitySetting_equipment",
                 @"accessibilitySetting_setcard",
                 @"accessibilitySetting_DiscountShortCut",
                 @"accessibilitySetting_wallpaper",
                 @"accessibilitySetting_MessageCenter",
                 @"BG_ClutterColour",
                 @"BG_CowhideColour",
                 @"BG_WoodColour",
                 @"BG_Thumbnail_ClutterColour",
                 @"BG_Thumbnail_CowhideColour",
                 @"BG_Thumbnail_WoodColour",
                 @"BG_ModelSeat_ClutterColour",
                 @"BG_ModelSeat_CowhideColour",
                 @"BG_ModelSeat_WoodColour",
                 @"BG_ModelNoSeat_ClutterColour",
                 @"BG_ModelNoSeat_CowhideColour",
                 @"BG_ModelNoSeat_WoodColour",
                 // 零散
                 @"BG_SelectTab"
                 ];
    } else if ([name isEqualToString:kXKSPaymentModule]) {
        return @[
                 // .plist 配置
                 @"keyboard_top-cash-icon",
                 @"XKSPayment_scan_normal",
                 @"pay-cash-selected",
                 @"keyboard_top-ali-icon",
                 @"XKSPayment_scan_gray",
                 @"XKSPayment_scan_normal",
                 @"pay-wechat-selected",
                 @"keyboard_top-wechat-icon",
                 @"XKSPayment_scan_gray",
                 @"card",
                 @"pay-card-selected",
                 @"keyboard_top-card-icon",
                 @"XKSPayment_card_gray",
                 @"ticket",
                 @"pay-entityCard-selected",
                 @"vipcard",
                 @"pay-prepaid-selected",
                 @"keyboard_top-prepaid-icon",
                 @"XKSPayment_vipcard_gray",
                 @"shanhui",
                 @"pay-shanhui-selected",
                 @"keyboard_top-shanhui-icon",
                 @"XKSPayment_shanhui_gray",
                 @"pay-ticket-selected",
                 @"keyboard_top-ticket-icon",
                 @"XKSPayment_ticket_gray",
                 @"other",
                 @"pay-quickpass-selected",
                 @"keyboard_top-quickpass-icon",
                 @"XKSPayment_shanfu_gray",
                 @"keyboard_top-RechargeCard-icon",
                 @"XKSPayment_card_chong_gray",
                 @"pay-other-selected",
                 @"keyboard_top-other-icon",
                 @"XKSPayment_other_gray",
                 // 代码中表达式
                 @"payment_finished",
                 @"payment_noFinished",
                 ];
    } else if ([name isEqualToString:kXKSVipModule]) {
        return @[@"bg_integral2",
                 @"bg_integral"];
    } else if ([name isEqualToString:kCHDOrderModule]) {
        return @[
                 // Array 配置
                 @"rf_cash_normal",
                 @"rf_wechat_normal",
                 @"rf_wechat_normal",
                 @"rf_alipay_normal",
                 @"rf_alipay_normal",
                 @"rf_prepaid_normal",
                 @"rf_prepaid_normal",
                 @"rf_card_normal",
                 @"rf_card_normal",
                 @"rf_quick_normal",
                 @"rf_quick_normal",
                 @"rf_shanhui_normal",
                 @"rf_other_normal",
                 @"rf_other_normal",
                 @"rf_recharge_normal",
                 @"rf_other_normal",
                 @"rf_other_normal",
                 @"rf_shanhui_normal",
                 @"rf_prepaid_normal",
                 @"rf_prepaid_normal",
                 @"rf_wechat_normal",
                 @"rf_wechat_normal",
                 @"rf_wechat_normal",
                 @"rf_alipay_normal",
                 @"rf_card_normal",
                 @"rf_card_normal",
                 @"rf_cash_gray",
                 @"rf_wechat_gray",
                 @"rf_wechat_gray",
                 @"rf_alipay_gray",
                 @"rf_alipay_gray",
                 @"rf_prepaid_gray",
                 @"rf_prepaid_gray",
                 @"rf_card_gray",
                 @"rf_card_gray",
                 @"rf_quick_gray",
                 @"rf_quick_gray",
                 @"rf_shanhui_gray",
                 @"rf_other_gray",
                 @"rf_other_gray",
                 @"rf_recharge_gray",
                 // 零散
                 @"order_shouyintai",
                 @"order_weiwaimai",
                 @"order_weidianpu",
                 @"order_elem",
                 @"order_meituan",
                 @"order_koubei",
                 ];
    } else if ([name isEqualToString:kCHDCommodityMgrModule]) {
        return @[
                 // 零散
                 @"menu_icon1",
                 @"pay_scan",
                 @"menu_icon2",
                 @"menu_icon3",
                 @"nav_jibenxinxi",
                 @"nav_hangyexinxi",
                 ];
    }
    
    return @[];
}

+ (NSString *)getModulePathByBundleName:(NSString *)name {
    return name;
}

@end
