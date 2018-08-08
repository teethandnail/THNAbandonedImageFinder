//
//  ViewController.m
//  THNAbandonedImageFinder
//
//  Created by ZhangHonglin on 2017/8/12.
//  Copyright © 2017年 h. All rights reserved.
//

#import "ViewController.h"
#import "THNAbandonedImageFinder.h"
#import "THNAbandonedImageFinder+MyProject.h"

@interface ViewController ()

@property (nonatomic, weak) IBOutlet NSTextField *textField;
@property (nonatomic, weak) IBOutlet NSTextView *textView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.textView.editable = NO;
    
    self.textField.stringValue = @"Input project path";
    self.textView.string = @"";
}

- (IBAction)clickAction:(id)sender {
    NSString *path = self.textField.stringValue;
    NSDate *beginDate = [NSDate date];
    
    NSMutableSet *result = [THNAbandonedImageFinder getAbandonedImageInEachBundleWithProjectPath:path];
    CGFloat runTime = [NSDate date].timeIntervalSince1970 - beginDate.timeIntervalSince1970;
    
    NSString *desc = [NSString stringWithFormat:@"耗时[%.3lf秒]", runTime];
    self.textView.string = [NSString stringWithFormat:@"%@，废弃的图片有[%ld]：\n%@", desc, result.count, result];
}

@end
