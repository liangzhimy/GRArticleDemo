//
//  GRHtmlContentView.m
//  GRArticleDemo
//
//  Created by liangzhimy on 2017/6/29.
//  Copyright © 2017年 LA. All rights reserved.
//

#import "GRHtmlContentView.h"

#define AbstractMethodNotImplemented() \
@throw [NSException exceptionWithName:NSInternalInconsistencyException \
                               reason:[NSString stringWithFormat:@"You must override %@ in a subclass.", NSStringFromSelector(_cmd)] \
                             userInfo:nil]

@implementation GRHtmlContentView

- (instancetype)init {
    NSAssert(![self isMemberOfClass:[GRHtmlContentView class]], @"GRHtmlContentView is an abstract class, you should not instantiate it directly.");
    return [super init];
}

- (void)loadHtml:(NSString *)html {
    [self loadHtml:html baseURL:[NSBundle mainBundle].resourceURL];
}

- (void)loadHtml:(NSString *)html baseURL:(NSURL *)baseURL {
    AbstractMethodNotImplemented();
}

@end
