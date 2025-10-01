//
//  DeviceManuallyAddCell.h
//  AIToys
//
//  Created by 乔不赖 on 2025/6/28.
//

#import <UIKit/UIKit.h>
#import "FindDollModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface DeviceManuallyAddCell : UITableViewCell
@property (nonatomic, strong) NSArray <FindDollModel *> *dataArr;
@property (nonatomic, copy) void(^itemClickBlock)(NSInteger index);
@end

NS_ASSUME_NONNULL_END
