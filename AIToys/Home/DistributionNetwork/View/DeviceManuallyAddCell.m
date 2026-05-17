//
//  DeviceManuallyAddCell.m
//  AIToys
//
//  Created by 乔不赖 on 2025/6/28.
//

#import "DeviceManuallyAddCell.h"
#import "DeviceManuallyAddItem.h"
#import "ATLanguageHelper.h"

@interface DeviceManuallyAddCell()




@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) UIFont *baseGuideFont;

@end
@implementation DeviceManuallyAddCell

+ (CGFloat)preferredRowHeight {
    return 96.0;
}




- (void)awakeFromNib {
    [super awakeFromNib];
    [self applyLocalizedGuideText];
    if (@available(iOS 15.0, *)) {
        self.devicebtnClick.configuration.title = [self.devicebtnClick titleForState:UIControlStateNormal];
    }
    self.baseGuideFont = self.subTitleLabel.font;
    self.titleLabel.font = self.baseGuideFont;
    self.devicebtnClick.titleLabel.font = self.baseGuideFont;
    self.titleLabel.numberOfLines = 2;
    self.titleLabel.adjustsFontSizeToFitWidth = NO;
    self.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.subTitleLabel.font = self.baseGuideFont;
    self.subTitleLabel.numberOfLines = 1;
    self.subTitleLabel.adjustsFontSizeToFitWidth = NO;
    self.subTitleLabel.textAlignment = [ATLanguageHelper isRTLLanguage] ? NSTextAlignmentRight : NSTextAlignmentLeft;
    [self removeLayoutConstraintsForView:self.subTitleLabel];
    [self removeLayoutConstraintsForView:self.devicebtnClick];
    self.subTitleLabel.translatesAutoresizingMaskIntoConstraints = YES;
    self.devicebtnClick.translatesAutoresizingMaskIntoConstraints = YES;
}

- (void)applyLocalizedGuideText {
    NSString *fullText = LocalString(@"搜索设备中，若长时间未搜索到设备，可查看\"设备复位引导\"");
    NSString *guideText = LocalString(@"设备复位引导");
    NSRange guideRange = [fullText rangeOfString:guideText];
    if (guideRange.location == NSNotFound) {
        self.titleLabel.text = fullText;
        self.subTitleLabel.text = @"";
        [self.devicebtnClick setTitle:guideText forState:UIControlStateNormal];
        return;
    }

    NSString *prefix = [fullText substringToIndex:guideRange.location];
    NSRange prefixMarkerRange = [self guideActionRangeInPrefix:prefix];
    if (prefixMarkerRange.location != NSNotFound) {
        self.subTitleLabel.text = [prefix substringFromIndex:prefixMarkerRange.location];
        prefix = [prefix substringToIndex:prefixMarkerRange.location];
    } else {
        self.subTitleLabel.text = @"";
    }
    prefix = [[prefix stringByReplacingOccurrencesOfString:@"\"" withString:@""] stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
    self.subTitleLabel.text = [[self.subTitleLabel.text stringByReplacingOccurrencesOfString:@"\"" withString:@""] stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
    self.titleLabel.text = prefix;
    [self.devicebtnClick setTitle:guideText forState:UIControlStateNormal];
}

- (NSRange)guideActionRangeInPrefix:(NSString *)prefix {
    NSArray<NSString *> *actionMarkers = @[
        @"可查看",
        @"check the",
        @"consultez le",
        @"consulta",
        @"sehen Sie in der",
        @"يمكنك الاطلاع على"
    ];
    for (NSString *marker in actionMarkers) {
        NSRange range = [prefix rangeOfString:marker options:NSBackwardsSearch | NSCaseInsensitiveSearch];
        if (range.location != NSNotFound) {
            return range;
        }
    }

    NSArray<NSString *> *separators = @[@"，", @",", @"،"];
    NSRange lastSeparatorRange = NSMakeRange(NSNotFound, 0);
    for (NSString *separator in separators) {
        NSRange range = [prefix rangeOfString:separator options:NSBackwardsSearch];
        if (range.location != NSNotFound && (lastSeparatorRange.location == NSNotFound || range.location > lastSeparatorRange.location)) {
            lastSeparatorRange = range;
        }
    }
    if (lastSeparatorRange.location != NSNotFound && NSMaxRange(lastSeparatorRange) < prefix.length) {
        return NSMakeRange(NSMaxRange(lastSeparatorRange), prefix.length - NSMaxRange(lastSeparatorRange));
    }
    return NSMakeRange(NSNotFound, 0);
}





- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat contentWidth = CGRectGetWidth(self.contentView.bounds);
    CGFloat horizontalInset = 16.0;
    CGFloat gap = 10.0;
    CGFloat availableWidth = MAX(0.0, contentWidth - horizontalInset * 2.0);
    UIFont *baseFont = self.baseGuideFont ?: [UIFont systemFontOfSize:12.0];
    NSString *titleText = self.titleLabel.text ?: @"";
    NSString *subTitleText = self.subTitleLabel.text ?: @"";
    NSString *buttonText = [self.devicebtnClick titleForState:UIControlStateNormal] ?: self.devicebtnClick.currentTitle ?: @"";
    NSDictionary *baseAttributes = @{NSFontAttributeName: baseFont};
    CGFloat subTitleNaturalWidth = ceil([subTitleText sizeWithAttributes:baseAttributes].width);
    CGFloat buttonHorizontalPadding = 8.0;
    CGFloat buttonNaturalWidth = ceil([buttonText sizeWithAttributes:baseAttributes].width) + buttonHorizontalPadding;
    CGFloat groupNaturalWidth = subTitleNaturalWidth + gap + buttonNaturalWidth;
    CGFloat commonScale = 1.0;
    if (groupNaturalWidth > 0.0) {
        commonScale = MIN(commonScale, availableWidth / groupNaturalWidth);
    }
    commonScale = MAX(0.62, MIN(1.0, commonScale));

    CGFloat scaledPointSize = floor(baseFont.pointSize * commonScale * 10.0) / 10.0;
    UIFont *scaledFont = [UIFont fontWithDescriptor:baseFont.fontDescriptor size:scaledPointSize];
    self.titleLabel.font = scaledFont;
    self.subTitleLabel.font = scaledFont;
    self.devicebtnClick.titleLabel.font = scaledFont;

    CGFloat titleWidth = MAX(0.0, contentWidth - horizontalInset * 2.0);
    CGFloat titleMaxHeight = ceil(scaledFont.lineHeight * 2.0);
    CGRect titleRect = [titleText boundingRectWithSize:CGSizeMake(titleWidth, titleMaxHeight)
                                               options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                            attributes:@{NSFontAttributeName: scaledFont}
                                               context:nil];
    CGFloat titleHeight = MIN(titleMaxHeight, ceil(titleRect.size.height));
    CGFloat titleY = 8.0;
    self.titleLabel.frame = CGRectMake(horizontalInset, titleY, titleWidth, titleHeight);

    CGSize buttonSize = [self.devicebtnClick sizeThatFits:CGSizeMake(CGFLOAT_MAX, 27.0)];
    CGFloat maxButtonWidth = MAX(80.0 * commonScale, availableWidth - MIN(subTitleNaturalWidth * commonScale, availableWidth * 0.32) - gap);
    CGFloat buttonWidth = MIN(ceil(MAX(buttonSize.width, self.devicebtnClick.intrinsicContentSize.width)), maxButtonWidth);
    CGFloat labelAvailableWidth = MAX(44.0 * commonScale, availableWidth - buttonWidth - gap);
    CGSize subTitleSize = [self.subTitleLabel sizeThatFits:CGSizeMake(labelAvailableWidth, ceil(scaledFont.lineHeight))];
    self.subTitleLabel.frame = CGRectMake(0.0, 0.0, MIN(labelAvailableWidth, ceil(subTitleSize.width)), ceil(subTitleSize.height));
    CGFloat groupWidth = CGRectGetWidth(self.subTitleLabel.bounds) + gap + buttonWidth;
    CGFloat startX = floor((contentWidth - groupWidth) * 0.5);
    CGFloat centerY = CGRectGetMaxY(self.titleLabel.frame) + 18.0;
    CGFloat labelHeight = ceil(CGRectGetHeight(self.subTitleLabel.bounds));
    CGFloat buttonHeight = 27.0;
    self.subTitleLabel.frame = CGRectMake(startX, centerY - labelHeight * 0.5, ceil(CGRectGetWidth(self.subTitleLabel.bounds)), labelHeight);
    self.devicebtnClick.frame = CGRectMake(CGRectGetMaxX(self.subTitleLabel.frame) + gap, centerY - buttonHeight * 0.5, buttonWidth, buttonHeight);
}

- (void)removeLayoutConstraintsForView:(UIView *)view {
    NSMutableArray<NSLayoutConstraint *> *constraintsToRemove = [NSMutableArray array];
    for (NSLayoutConstraint *constraint in self.contentView.constraints) {
        if (constraint.firstItem == view || constraint.secondItem == view) {
            [constraintsToRemove addObject:constraint];
        }
    }
    [self.contentView removeConstraints:constraintsToRemove];
}

- (IBAction)deviceBtnClick:(id)sender {
    if (self.devicebtnClick) {
        self.devicebtnClickClickBlock();
    }
}

@end
