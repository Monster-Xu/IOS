//
//  MyTabBarControllerViewController.h
//  AIToys
//
//  Created by 乔不赖 on 2025/6/18.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MyTabBarController : UITabBarController

- (BOOL)at_selectTabAtIndex:(NSUInteger)index popToRoot:(BOOL)popToRoot;

@end

NS_ASSUME_NONNULL_END
