//
//  HomeExploreToysCell.m
//  AIToys
//
//  Created by qdkj on 2025/6/26.
//

#import "HomeExploreToysCell.h"

@implementation HomeExploreToysCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.playBtn.hidden = YES;
    [self.playBtn setTitle:LocalString(@"试听一下") forState:0];
    [self.playBtn layoutWithStyle:HKBtnImagePosition_Left space:8];
    self.storyLab.text = LocalString(@"故事");
    self.durationLab.text = LocalString(@"时长");
    
    
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
        self.horsNameLabel.text = @"mins";
    } else {
        // 计算分钟数（向上取整）
        CGFloat minutesFloat = model.virtualStoryDuration / 60.0;
        NSInteger totalMinutes = ceil(minutesFloat);
        
        // 确保至少1分钟
        if (totalMinutes < 1) {
            totalMinutes = 1;
        }
        
        self.hoursLabel.text = [NSString stringWithFormat:@"%ld", (long)totalMinutes];
        self.horsNameLabel.text = @"mins";
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
        self.storyNumLabel.text =[NSString stringWithFormat:@"%@ mins", self.hoursLabel.text];
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
