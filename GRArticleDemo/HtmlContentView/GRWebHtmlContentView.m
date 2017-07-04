//
//  GRWebHtmlContentView.m
//  GRArticleDemo
//
//  Created by liangzhimy on 2017/6/29.
//  Copyright © 2017年 LA. All rights reserved.
//

#import "GRWebHtmlContentView.h"
#import <WebKit/WebKit.h>
#import <NSData+Base64Additions.h>

static NSString *const __GRObserverName = @"WKObserver";

@interface GRWebHtmlContentView () <WKScriptMessageHandler, WKNavigationDelegate, UIGestureRecognizerDelegate>

@property (strong, nonatomic) WKWebView *webView; 

@end

@implementation GRWebHtmlContentView

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

- (void)__config {
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    WKUserContentController *userContentController = [[WKUserContentController alloc] init];
    NSString *script = @"var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-widthi,initial-scale=1.0,maximum-scale=1.0, minimum-scale=1.0,user-scalable=no'); document.getElementsByTagName('head')[0].appendChild(meta);";
    WKUserScript *wkUserScript = [[WKUserScript alloc] initWithSource:script injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
    [userContentController addScriptMessageHandler:self name:__GRObserverName];
    [userContentController addUserScript:wkUserScript];
    [self __addJavaScriptWithUserContentController:userContentController];
    configuration.userContentController = userContentController;
    
    _webView = [[WKWebView alloc] initWithFrame:self.bounds configuration:configuration];
    _webView.navigationDelegate = self;
    _webView.scrollView.scrollEnabled = NO;
    [self addSubview:_webView];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _webView.frame = self.bounds; 
} 

- (void)loadHtml:(NSString *)html baseURL:(NSURL *)baseURL {
    [_webView loadHTMLString:html baseURL:baseURL];
}

- (void)setNeedsLayout {
    [super setNeedsLayout];
    [_webView setNeedsLayout];
}

#pragma mark - method 
- (void)__addJavaScriptWithUserContentController:(WKUserContentController *)userContentController {
    NSString *clickScript =
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
    img.setAttribute('crossOrigin', 'anonymous');\
    var canvas = document.createElement(\"canvas\"); \
    var context = canvas.getContext(\"2d\"); \
    canvas.width = img.width; canvas.height=img.height; \
    context.drawImage(img,0,0,img.width,img.height); \
    return canvas.toDataURL(\"image/png\") \
    }";
    WKUserScript *wkUserScript = [[WKUserScript alloc] initWithSource:clickScript injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
    [userContentController addUserScript:wkUserScript];
}

#pragma mark - WKScriptMessageHandler
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    // script message 
}

#pragma mark - WKNavigationDelegate
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    if ([navigationAction.request.URL.scheme isEqualToString:@"imagehost"]) {
        NSArray<NSString *> *imageList = [navigationAction.request.URL.absoluteString componentsSeparatedByString:@"::"];
        if (imageList.count == 6) {
            NSInteger index = [imageList[1] integerValue];
            float x = [imageList[2] floatValue];
            float y = [imageList[3] floatValue];
            float w = [imageList[4] floatValue];
            float h = [imageList[5] floatValue];
            CGRect frame = CGRectMake(x, y, w, h);
            CGRect realFrame = [_webView convertRect:frame toView:self];
            [_webView evaluateJavaScript:@"getAllImageUrl();" completionHandler:^(id _Nullable stringData, NSError * _Nullable error) {
                NSArray<NSString *> *imageList = [stringData componentsSeparatedByString:@","];
                if (imageList.count > index && self.delegate && [self.delegate respondsToSelector:@selector(htmlContentVeiw:imageURLStrings:imageDidPressedAtIndex:frame:image:)]) {
                    [self.delegate htmlContentVeiw:self imageURLStrings:imageList imageDidPressedAtIndex:index frame:realFrame image:nil];
                }
            }];
        }
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    decisionHandler(WKNavigationActionPolicyAllow);
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    [webView evaluateJavaScript:@"setImage();" completionHandler:nil];
    [webView evaluateJavaScript:@"document.body.scrollHeight" completionHandler:^(id _Nullable response, NSError * _Nullable error) {
        CGFloat webViewHeight = [response floatValue];
        if ([self.delegate respondsToSelector:@selector(htmlContentVeiw:heightDidChanged:)]) {
            [self.delegate htmlContentVeiw:self heightDidChanged:webViewHeight]; 
        }
    }];
}

@end
