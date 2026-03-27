//
//  DeviceManuallyAddCell.m
//  AIToys
//
//  Created by 乔不赖 on 2025/6/28.
//

#import "DeviceManuallyAddCell.h"
#import "DeviceManuallyAddItem.h"

@interface DeviceManuallyAddCell()




@property (strong, nonatomic) UICollectionView *collectionView;

@end
@implementation DeviceManuallyAddCell




- (void)awakeFromNib {
    [super awakeFromNib];
    self.titleLabel.text = LocalString(@"搜索设备时间过长仍未发现设备，请参考");
    self.subTitleLabel.text = LocalString(@"请参考");
    [self.devicebtnClick setTitle:LocalString(@"设备重置指南") forState:UIControlStateNormal];
}





- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)deviceBtnClick:(id)sender {
    if (self.devicebtnClick) {
        self.devicebtnClickClickBlock();
    }
}

@end
