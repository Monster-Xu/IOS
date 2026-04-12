//
//  SwitchFamailyCell.m
//  AIToys
//
//  Created by qdkj on 2025/6/26.
//

#import "SwitchFamailyCell.h"

@implementation SwitchFamailyCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.statusLabel.text = LocalString(@"待加入");
    self.nameLabel.numberOfLines = 1;
    self.nameLabel.adjustsFontSizeToFitWidth = YES;
    self.nameLabel.minimumScaleFactor = 0.75;
    self.nameLabel.lineBreakMode = NSLineBreakByClipping;
    self.statusLabel.numberOfLines = 1;
    self.statusLabel.adjustsFontSizeToFitWidth = YES;
    self.statusLabel.minimumScaleFactor = 0.8;
    self.statusLabel.lineBreakMode = NSLineBreakByClipping;
}
- (void)setIsSel:(BOOL)isSel{
    _isSel = isSel;
    self.chooseImgView.highlighted = isSel;
    self.chooseImgView.hidden = !isSel;
    self.homeImgView.highlighted = isSel;
    self.nameLabel.highlighted = isSel;
}

-(void)setModel:(ThingSmartHomeModel *)model{
    _model = model;
    self.nameLabel.text = model.name;
    if(model.dealStatus == 1){
        self.statusLabel.hidden = NO;
        CGFloat statusWidth = ceil([self.statusLabel sizeThatFits:CGSizeMake(CGFLOAT_MAX, CGRectGetHeight(self.statusLabel.bounds))].width);
        self.nameTrailing.constant = statusWidth + 36;
    }else{
        self.statusLabel.hidden = YES;
        self.nameTrailing.constant = 20;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
