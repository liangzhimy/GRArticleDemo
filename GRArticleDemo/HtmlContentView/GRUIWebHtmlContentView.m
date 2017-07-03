//
//  GRUIWebHtmlContentView.m
//  GRArticleDemo
//
//  Created by 赵亮 on 2017/7/3.
//  Copyright © 2017年 LA. All rights reserved.
//

#import "GRUIWebHtmlContentView.h"
#import <NSData+Base64Additions.h>

@interface GRUIWebHtmlContentView () <UIWebViewDelegate>

@property (strong, nonatomic) UIWebView *webView;

@end

@implementation GRUIWebHtmlContentView

- (instancetype)init {
    if (self = [super init]) {
        [self __config];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self __config];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self __config];
    }
    return self;
}

- (void)dealloc {
    [_webView loadHTMLString:@"" baseURL:nil];
    [_webView stopLoading];
    [_webView removeFromSuperview];
    self.webView = nil;
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    [[NSURLCache sharedURLCache] setDiskCapacity:0];
    [[NSURLCache sharedURLCache] setMemoryCapacity:0];
}

- (void)__config {
    _webView = [[UIWebView alloc] initWithFrame:self.bounds];
    _webView.delegate = self;
    _webView.userInteractionEnabled = YES;
    _webView.scrollView.scrollEnabled = NO;
    _webView.scrollView.bounces = NO;
    [self addSubview:_webView];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _webView.frame = self.bounds;
}

- (void)__addJavaScript {
    NSString *script =
    @"function setImage(){\
    var imgs = document.getElementsByTagName(\"img\");\
    for (var i=0;i<imgs.length;i++){\
    imgs[i].setAttribute(\"onClick\",\"imageClick(\"+i+\")\");\
    }\
    }\
    function imageClick(i){\
    var rect = getImageRect(i);\
    var url=\"imagehost::\"+i+\"::\"+rect;\
    document.location = url;\
    }\
    function getImageRect(i){\
    var imgs = document.getElementsByTagName(\"img\");\
    var rect;\
    rect = imgs[i].getBoundingClientRect().left+\"::\";\
    rect = rect+imgs[i].getBoundingClientRect().top+\"::\";\
    rect = rect+imgs[i].width+\"::\";\
    rect = rect+imgs[i].height;\
    return rect;\
    }\
    function getAllImageUrl(){\
    var imgs = document.getElementsByTagName(\"img\");\
    var urlArray = [];\
    for (var i=0;i<imgs.length;i++){\
    var src = imgs[i].src;\
    urlArray.push(src);\
    }\
    return urlArray.toString();\
    }\
    function getImageData(i){\
    var imgs = document.getElementsByTagName(\"img\");\
    var img=imgs[i]; \
    var canvas=document.createElement(\"canvas\"); \
    var context=canvas.getContext(\"2d\"); \
    canvas.width=img.width; canvas.height=img.height; \
    context.drawImage(img,0,0,img.width,img.height); \
    return canvas.toDataURL(\"image/png\") \
    }";
    [_webView stringByEvaluatingJavaScriptFromString:script];
}

- (void)loadHtml:(NSString *)html baseURL:(NSURL *)baseURL {
    [_webView loadHTMLString:html baseURL:baseURL];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self __addJavaScript];
    [webView stringByEvaluatingJavaScriptFromString:@"setImage();"];
    CGFloat webViewHeight = [[webView stringByEvaluatingJavaScriptFromString:@"document.body.scrollHeight"] floatValue];
    if ([self.delegate respondsToSelector:@selector(htmlContentVeiw:heightDidChanged:)]) {
        [self.delegate htmlContentVeiw:self heightDidChanged:webViewHeight];
    }
    
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"WebKitCacheModelPreferenceKey"];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"WebKitDiskImageCacheEnabled"];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"WebKitOfflineWebApplicationCacheEnabled"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSString *requestString = [[request URL] absoluteString];
    NSArray *imageList = [requestString componentsSeparatedByString:@"::"];
    if ([imageList[0] isEqualToString:@"imagehost"]) {
        if (imageList.count == 6) {
            NSInteger index = [imageList[1] integerValue];
            float x = [imageList[2] floatValue];
            float y = [imageList[3] floatValue];
            float w = [imageList[4] floatValue];
            float h = [imageList[5] floatValue];
            CGRect frame = CGRectMake(x, y, w, h);
            CGRect realFrame = [_webView convertRect:frame toView:self];
            
            NSString *javascript = [NSString stringWithFormat:@"getImageData(%ld);", index];
            NSString *imageData = [webView stringByEvaluatingJavaScriptFromString:javascript];
            imageData = [imageData substringFromIndex:22]; // strip the string "data:image/png:base64,"
            NSData *data = [NSData decodeWebSafeBase64ForString:imageData];
            UIImage *image = [UIImage imageWithData:data];
            NSString *stringData = [_webView stringByEvaluatingJavaScriptFromString:@"getAllImageUrl();"];
            NSArray<NSString *> *imageList = [stringData componentsSeparatedByString:@","];
            if (imageList.count > index) {
                if (self.delegate && [self.delegate respondsToSelector:@selector(htmlContentVeiw:imageURLStrings:imageDidPressedAtIndex:frame:image:)]) {
                    [self.delegate htmlContentVeiw:self imageURLStrings:imageList imageDidPressedAtIndex:index frame:realFrame image:image];
                }
            }
        }
        return NO;
    }
    return YES;
}

@end
