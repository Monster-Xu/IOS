//
//  CreateStoryWithVoiceTableViewCell.h
//  AIToys
//
//  Created by xuxuxu on 2025/10/13.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CreateStoryWithVoiceTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton *selectBtn;
@property (weak, nonatomic) IBOutlet UIImageView *headerImageView;
@property (weak, nonatomic) IBOutlet UIButton *playBtn;

/**
 配置音色数据
 @param voiceModel 音色模型对象
 @param isSelected 是否选中
 */
- (void)configureWithVoiceModel:(id)voiceModel isSelected:(BOOL)isSelected;

@end

NS_ASSUME_NONNULL_END
