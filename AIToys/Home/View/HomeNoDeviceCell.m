//
//  HomeNoDeviceCell.m
//  AIToys
//
//  Created by 乔不赖 on 2025/6/21.
//

#import "HomeNoDeviceCell.h"

@implementation HomeNoDeviceCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.nameLabel.numberOfLines = 0;
    self.nameLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.nameLabel.textAlignment = NSTextAlignmentCenter;
    self.addBtn.titleLabel.numberOfLines = 2;
    self.addBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.addBtn.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.addBtn.contentEdgeInsets = UIEdgeInsetsMake(6, 14, 6, 14);
}

-(void)setType:(CellType)type{
    if(type == CellTypeDevice){
        self.imgView.image = QD_IMG(@"device_empty");
        self.nameLabel.text = LocalString(@"还没有故事机，快添加一个吧！");
        [self.addBtn setTitle:LocalString(@"添加故事机") forState:0];
    }else{
        self.imgView.image = QD_IMG(@"toys_empty");
        self.nameLabel.text = LocalString(@"还没有公仔，快添加一个吧！");
        [self.addBtn setTitle:LocalString(@"添加公仔") forState:0];
    }
}

//添加故事机/公仔
- (IBAction)addBtnClick:(id)sender {
    if(self.addBtnClickBlock){
        self.addBtnClickBlock();
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
