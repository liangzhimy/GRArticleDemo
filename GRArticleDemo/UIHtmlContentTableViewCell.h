//
//  UIHtmlContentTableViewCell.h
//  GRArticleDemo
//
//  Created by 赵亮 on 2017/6/30.
//  Copyright © 2017年 LA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GRHtmlContentView.h"
#import "GRWebHtmlContentView.h"

@interface UIHtmlContentTableViewCell : UITableViewCell

@property (weak, nonatomic) id<GRHtmlContentViewDelegate> delegate; 
@property (weak, nonatomic) IBOutlet GRWebHtmlContentView *htmlContentView;

@end
