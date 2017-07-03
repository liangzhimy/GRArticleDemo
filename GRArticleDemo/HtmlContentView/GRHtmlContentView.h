//
//  GRHtmlContentView.h
//  GRArticleDemo
//
//  Created by liangzhimy on 2017/6/29.
//  Copyright © 2017年 LA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@class GRHtmlContentView; 

@protocol GRHtmlContentViewDelegate <NSObject>

@optional
- (void)htmlContentVeiw:(GRHtmlContentView *)htmlContentView heightDidChanged:(CGFloat)height;
- (void)htmlContentVeiw:(GRHtmlContentView *)htmlContentView imageDidPressed:(NSString *)imageURLString;
- (void)htmlContentVeiw:(GRHtmlContentView *)htmlContentView imageURLStrings:(NSArray<NSString *> *)imageURLStrings imageDidPressedAtIndex:(NSInteger)index frame:(CGRect)frame image:(nullable UIImage *)image;

@end

@interface GRHtmlContentView : UIView

@property (weak, nonatomic) id<GRHtmlContentViewDelegate> delegate;

- (void)loadHtml:(NSString *)html;
- (void)loadHtml:(NSString *)html baseURL:(NSURL *)baseURL;

@end

NS_ASSUME_NONNULL_END
