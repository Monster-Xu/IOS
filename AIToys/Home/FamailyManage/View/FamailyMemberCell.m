//
//  FamailyMemberCell.m
//  AIToys
//
//  Created by qdkj on 2025/6/23.
//

#import "FamailyMemberCell.h"

@implementation FamailyMemberCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.nameLabel.numberOfLines = 1;
    self.nameLabel.adjustsFontSizeToFitWidth = YES;
    self.nameLabel.minimumScaleFactor = 0.75;
    self.nameLabel.lineBreakMode = NSLineBreakByClipping;
    self.phoneLabel.numberOfLines = 1;
    self.phoneLabel.adjustsFontSizeToFitWidth = YES;
    self.phoneLabel.minimumScaleFactor = 0.8;
    self.phoneLabel.lineBreakMode = NSLineBreakByClipping;
    self.roleLabel.numberOfLines = 1;
    self.roleLabel.adjustsFontSizeToFitWidth = YES;
    self.roleLabel.minimumScaleFactor = 0.7;
    self.roleLabel.lineBreakMode = NSLineBreakByClipping;
}

-(void)setIsExpire:(BOOL)isExpire{
    _isExpire = isExpire;
    self.roleLabel.textColor = isExpire? UIColorHex(F04C4C):UIColorFromRGBA(000000, 0.5);
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
