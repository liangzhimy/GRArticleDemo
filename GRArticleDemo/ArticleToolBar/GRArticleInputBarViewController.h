//
//  GRArticleInputBarViewController.h
//  GRArticleDemo
//
//  Created by liangzhimy on 2017/7/4.
//  Copyright © 2017年 LA. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class GRArticleInputBarViewController;

@protocol GRArticleInputBarViewControllerDelegate <NSObject>

- (void)articleInputBarViewController:(GRArticleInputBarViewController *)articleInputBarViewController didRaise:(BOOL)isRaise bottomHeight:(CGFloat)height;
- (void)articleInputBarViewController:(GRArticleInputBarViewController *)articleInputBarViewController didChangeHeight:(CGFloat)height;

@end

@interface GRArticleInputBarViewController : UIViewController

@property (weak, nonatomic, nullable) id<GRArticleInputBarViewControllerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
