//
//  VoiceManagementTableViewCell.h
//  AIToys
//
//  Created by xuxuxu on 2025/10/13.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class VoiceModel;

@interface VoiceManagementTableViewCell : UITableViewCell

/// 配置cell显示声音数据
/// @param voice VoiceModel 数据模型
- (void)configureWithVoiceModel:(VoiceModel *)voice;

@end

NS_ASSUME_NONNULL_END
