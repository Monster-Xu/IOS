//
//  HomeExploreToysCell.m
//  AIToys
//
//  Created by qdkj on 2025/6/26.
//

#import "HomeExploreToysCell.h"
#import "ATLanguageHelper.h"

@implementation HomeExploreToysCell

- (void)awakeFromNib {
    [super awakeFromNib];
    BOOL isRTL = [ATLanguageHelper isRTLLanguage];
    NSTextAlignment contentAlignment = isRTL ? NSTextAlignmentRight : NSTextAlignmentLeft;
    self.playBtn.hidden = YES;
    [self.playBtn setTitle:LocalString(@"试听一下") forState:0];
    self.playBtn.semanticContentAttribute = isRTL ? UISemanticContentAttributeForceRightToLeft : UISemanticContentAttributeForceLeftToRight;
    self.playBtn.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    self.playBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.playBtn.titleLabel.minimumScaleFactor = 0.75;
    self.playBtn.contentEdgeInsets = UIEdgeInsetsMake(0, 12.0, 0, 12.0);
    [self applyPlayButtonLayout];
    UIImage *playImage = [self.playBtn imageForState:UIControlStateNormal];
    if (playImage && @available(iOS 9.0, *)) {
        [self.playBtn setImage:[playImage imageFlippedForRightToLeftLayoutDirection] forState:UIControlStateNormal];
    }
    self.nameLabel.textAlignment = contentAlignment;
    self.introduceLabel.textAlignment = contentAlignment;
    self.storyLab.textAlignment = contentAlignment;
    self.durationLab.textAlignment = contentAlignment;
    self.storyNumLabel.textAlignment = contentAlignment;
    self.hoursLabel.textAlignment = contentAlignment;
    self.horsNameLabel.textAlignment = contentAlignment;
    self.playBtn.titleLabel.textAlignment = contentAlignment;
    self.storyLab.text = LocalString(@"故事");
    self.durationLab.text = LocalString(@"时长");


}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self applyPlayButtonLayout];
}

- (void)applyPlayButtonLayout {
    BOOL isRTL = [ATLanguageHelper isRTLLanguage];
    CGFloat spacing = 4.0;
    NSString *title = [self.playBtn titleForState:UIControlStateNormal] ?: @"";
    UIImageView *imageView = self.playBtn.imageView;
    UILabel *titleLabel = self.playBtn.titleLabel;
    UIImage *image = imageView.image ?: [self.playBtn imageForState:UIControlStateNormal];
    CGFloat imageWidth = image.size.width;
    CGFloat imageHeight = image.size.height;
    CGFloat buttonWidth = CGRectGetWidth(self.playBtn.bounds);
    CGFloat buttonHeight = CGRectGetHeight(self.playBtn.bounds);
    CGFloat availableTitleWidth = buttonWidth - self.playBtn.contentEdgeInsets.left - self.playBtn.contentEdgeInsets.right - imageWidth - spacing;

    self.playBtn.titleEdgeInsets = UIEdgeInsetsZero;
    self.playBtn.imageEdgeInsets = UIEdgeInsetsZero;

    if (availableTitleWidth <= 0 || buttonWidth <= 0 || buttonHeight <= 0 || !imageView || !titleLabel) {
        return;
    }
    
    NSDictionary *attributes = @{NSFontAttributeName: self.playBtn.titleLabel.font ?: [UIFont systemFontOfSize:14]};
    CGFloat naturalTitleWidth = ceil([title sizeWithAttributes:attributes].width);
    CGFloat titleWidth = MIN(naturalTitleWidth, availableTitleWidth);
    CGFloat titleHeight = MIN(ceil(titleLabel.intrinsicContentSize.height), buttonHeight);
    CGFloat groupWidth = titleWidth + spacing + imageWidth;
    CGFloat groupX = MAX(self.playBtn.contentEdgeInsets.left, floor((buttonWidth - groupWidth) * 0.5));
    CGFloat centerY = buttonHeight * 0.5;
    
    if (isRTL) {
        titleLabel.frame = CGRectMake(groupX, floor(centerY - titleHeight * 0.5), titleWidth, titleHeight);
        imageView.frame = CGRectMake(CGRectGetMaxX(titleLabel.frame) + spacing, floor(centerY - imageHeight * 0.5), imageWidth, imageHeight);
    } else {
        imageView.frame = CGRectMake(groupX, floor(centerY - imageHeight * 0.5), imageWidth, imageHeight);
        titleLabel.frame = CGRectMake(CGRectGetMaxX(imageView.frame) + spacing, floor(centerY - titleHeight * 0.5), titleWidth, titleHeight);
    }
}

//试玩一下
- (IBAction)playBtnClick:(id)sender {
    if(self.playBlock){
        self.playBlock();
    }
}

-(void)setModel:(FindDollModel *)model{
    
    self.storyNumImage.hidden = NO;
    self.stroyTimeImage.hidden  = NO;
    self.storyNumLabel.hidden = NO;
    self.hoursLabel.hidden  =NO;
    self.horsNameLabel.hidden = NO;
    _model = model;
    self.nameLabel.text = model.name;
    self.introduceLabel.text = model.desc;
    [self.bgImgView sd_setImageWithURL:[NSURL URLWithString:model.backgroundImg] placeholderImage:[UIImage imageNamed:@"Toys_back"]];
    self.storyNumLabel.text = [NSString stringWithFormat:@"%ld",(long)model.virtualStoryNum];

    // 检查总时长是否为0
    if (model.virtualStoryDuration == 0) {
        // 0秒时显示0s
        self.hoursLabel.text = @"0";
        self.horsNameLabel.text = LocalString(@"分钟");
    } else {
        // 计算分钟数（向上取整）
        CGFloat minutesFloat = model.virtualStoryDuration / 60.0;
        NSInteger totalMinutes = ceil(minutesFloat);
        
        // 确保至少1分钟
        if (totalMinutes < 1) {
            totalMinutes = 1;
        }
        
        self.hoursLabel.text = [NSString stringWithFormat:@"%ld", (long)totalMinutes];
        self.horsNameLabel.text = LocalString(@"分钟");
    }

    // 隐藏其他所有时间标签（我们只需要一个标签显示分钟）
    self.minutesLabel.hidden = YES;
    self.minNameLabel.hidden = YES;
    self.sLabel.hidden = YES;
    self.sNamelabel.hidden = YES;
    
    if (model.totalStoryNum>0) {
        self.playBtn.hidden = NO;
    }
    
    if (model.virtualStoryNum==0&&model.virtualStoryDuration==0) {
        self.storyNumImage.hidden = YES;
        self.stroyTimeImage.hidden  = YES;
        self.storyNumLabel.hidden = YES;
        self.hoursLabel.hidden  =YES;
        self.horsNameLabel.hidden = YES;
        self.storyLab.hidden  =YES;
        self.durationLab.hidden = YES;
    }else if (model.virtualStoryNum>0&&model.virtualStoryDuration==0){
        self.stroyTimeImage.hidden  = YES;
        self.hoursLabel.hidden  =YES;
        self.horsNameLabel.hidden = YES;
        self.storyLab.hidden = NO;
        self.durationLab.hidden = YES;
        
    }else if (model.virtualStoryNum==0&&model.virtualStoryDuration>0){
        self.storyNumImage.image = [UIImage imageNamed:@"explore_toys_sounds"];
        self.storyNumLabel.text = [NSString stringWithFormat:@"%@ %@", self.hoursLabel.text, LocalString(@"分钟")];
        self.stroyTimeImage.hidden  = YES;
        self.hoursLabel.hidden  =YES;
        self.horsNameLabel.hidden = YES;
        self.storyLab.hidden = NO;
        self.durationLab.hidden = YES;
        self.storyLab.text = LocalString(@"时长");
    }
    
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
