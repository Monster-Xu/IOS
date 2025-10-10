//
//  VoiceStoryTableViewCell.h
//  AIToys
//
//  Created by xuxuxu on 2025/10/1.
//

#import <UIKit/UIKit.h>
@class VoiceStoryModel;
NS_ASSUME_NONNULL_BEGIN

@interface VoiceStoryTableViewCell : UITableViewCell

@property (nonatomic, strong) UIView *cardView;
@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UILabel *storyNameLabel;
@property (nonatomic, strong) UILabel *voiceLabel;
@property (nonatomic, strong) UIButton *settingsButton;
@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) VoiceStoryModel *model;
@property (nonatomic, copy) void(^settingsButtonTapped)(void);
@property (nonatomic, copy) void(^playButtonTapped)(void);

// 根据设计图新增的属性
@property (nonatomic, strong) UIImageView *coverImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subtitleLabel;
@property (nonatomic, strong) UIButton *editButton;
@property (nonatomic, strong) UIView *badgeView;       // 修改：newBadge -> badgeView
@property (nonatomic, strong) UILabel *badgeLabel;     // 修改：newLabel -> badgeLabel
@property (nonatomic, strong) UIView *statusView;

@end

NS_ASSUME_NONNULL_END
