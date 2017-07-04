//
//  GRArticleInputTextView.h
//  XXX
//
//  Created by liangzhimy on 17/3/2.
//  Copyright © 2017年 XXX. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class GRArticleInputTextView;

@protocol GRArticleInputTextViewMenuDelegate <NSObject>

@optional
- (void)inputTextViewDidPaste:(GRArticleInputTextView *)inputTextView;

@end

@interface GRArticleInputTextView : UITextView

@property (copy, nonatomic, nullable) NSString *placeHolder;
@property (strong, nonatomic, nullable) UIColor *placeHolderTextColor;
@property (weak, nonatomic, nullable) UIResponder *overrideNextResponder;
@property (weak, nonatomic, nullable) id<GRArticleInputTextViewMenuDelegate> menuDelegate;

- (BOOL)hasText;

@end

NS_ASSUME_NONNULL_END
