//
//  UIHtmlContentTableViewCell.m
//  GRArticleDemo
//
//  Created by 赵亮 on 2017/6/30.
//  Copyright © 2017年 LA. All rights reserved.
//

#import "UIHtmlContentTableViewCell.h"

@implementation UIHtmlContentTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.htmlContentView.frame = CGRectMake(0, 0, self.frame.size.width, 2000);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setDelegate:(id<GRHtmlContentViewDelegate>)delegate {
    self.htmlContentView.delegate = delegate;
    _delegate = delegate; 
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.htmlContentView.frame = self.bounds;
    NSLog(@"htmlContentView.frame = %@ %@", NSStringFromCGRect(self.htmlContentView.frame), NSStringFromSelector(_cmd));
}

@end
