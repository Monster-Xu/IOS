//
//  DeviceHavenFindItem.m
//  AIToys
//
//  Created by 乔不赖 on 2025/6/28.
//

#import "DeviceHavenFindItem.h"
#import "ATLanguageHelper.h"
#import "ATFontManager.h"

@implementation DeviceHavenFindItem

- (void)awakeFromNib {
    [super awakeFromNib];
    [self configureAddDeviceButtonTitle];
    self.addDeviceBtn.titleLabel.numberOfLines = 1;
    self.addDeviceBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.addDeviceBtn.titleLabel.minimumScaleFactor = 0.55;
    self.addDeviceBtn.titleLabel.lineBreakMode = NSLineBreakByClipping;
    self.addDeviceBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.addDeviceBtn.contentEdgeInsets = UIEdgeInsetsMake(0, 12, 0, 12);
}

- (void)configureAddDeviceButtonTitle {
    NSString *title = LocalString(@"添加此设备");
    UIFont *font = [ATFontManager systemFontOfSize:[self addDeviceButtonFontSizeForCurrentLanguage]];
    NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:title
                                                                          attributes:@{
        NSFontAttributeName: font,
        NSForegroundColorAttributeName: UIColor.whiteColor
    }];
    [self.addDeviceBtn setAttributedTitle:attributedTitle forState:UIControlStateNormal];
}

- (CGFloat)addDeviceButtonFontSizeForCurrentLanguage {
    NSString *languageCode = [[ATLanguageHelper currentLanguageCode] lowercaseString] ?: @"";
    if ([languageCode hasPrefix:@"zh"] || [languageCode hasPrefix:@"en"]) {
        return 13.0;
    }
    if ([languageCode hasPrefix:@"de"] || [languageCode hasPrefix:@"fr"] || [languageCode hasPrefix:@"es"] || [languageCode hasPrefix:@"ar"]) {
        return 13.0;
    }
    return 12.0;
}

- (IBAction)addDeviceBtnClick:(id)sender {
    if (self.clickItemBlock) {
        self.clickItemBlock();
    }
    
}



@end
