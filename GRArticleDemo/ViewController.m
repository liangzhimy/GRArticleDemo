//
//  ViewController.m
//  GRArticleDemo
//
//  Created by liangzhimy on 2017/6/29.
//  Copyright © 2017年 LA. All rights reserved.
//

#import "ViewController.h"
#import "GRWebHtmlContentView.h"
#import "UIHtmlContentTableViewCell.h"
#import "UICommentTableViewCell.h"
#import <IDMPhotoBrowser/IDMPhotoBrowser.h>
#import <UIImageView+WebCache.h>

@interface ViewController () <GRHtmlContentViewDelegate, UITableViewDelegate, UITableViewDataSource, IDMPhotoBrowserDelegate>

@property (strong, nonatomic) NSArray *datas;
@property (strong, nonatomic) NSArray<NSString *> *imageURLs;
@property (weak, nonatomic) IBOutlet GRHtmlContentView *contentView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (assign, nonatomic) CGFloat htmlContentHeight;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self __configTableView];
    [self __loadData]; 
}

- (void)__configTableView {
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.htmlContentHeight = self.view.bounds.size.height; 
}

- (void)__loadData {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"arcticle326" ofType:@"html"];
    NSString *body = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    NSString *html = [self __htmlWithHtmlBody:body];
    self.datas = @[ html, @[ @"comment1", @"comment2", @"comment3" ] ];
    [self.tableView reloadData];
    self.imageURLs = [self __parseImageURLsWithHtml:html];
}

- (NSArray<NSString *> *)__parseImageURLsWithHtml:(NSString *)html {
    NSError *error;
    NSString *regexString = @"<img\\s*src\\s*=\\s*\"([^\"]*)\"";
    NSRegularExpression *regular = [NSRegularExpression regularExpressionWithPattern:regexString options:NSRegularExpressionCaseInsensitive error:&error];
    if (error) {
        return nil;
    }
    
    NSMutableArray<NSString *> *images = [[NSMutableArray alloc] init];
    
    [regular enumerateMatchesInString:html options:NSMatchingReportCompletion range:NSMakeRange(0, html.length) usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
        NSRange matchRange = [result rangeAtIndex:1];
        NSString *imageString = [html substringWithRange:matchRange];
        if (imageString && imageString.length > 0) {
            [images addObject:imageString];
        }
    }];
    
    return images;
}

- (NSString *)__htmlWithHtmlBody:(NSString *)htmlBody {
    NSString *html = [htmlBody stringByReplacingOccurrencesOfString:@"\t" withString:@""];
    NSString *cssName = @"News.css";
    NSMutableString *htmlString =[[NSMutableString alloc]initWithString:@"<html>"];
    [htmlString appendString:@"<head><meta charset=\"UTF-8\">"];
    [htmlString appendString:@"<link rel =\"stylesheet\" href = \""];
    [htmlString appendString:cssName];
    [htmlString appendString:@"\" type=\"text/css\" />"];
    [htmlString appendString:@"</head>"];
    [htmlString appendString:@"<body>"];
    [htmlString appendString:html];
    [htmlString appendString:@"</body>"];
    [htmlString appendString:@"</html>"];
    return htmlString;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - GRHtmlContentViewDelegate
- (void)htmlContentVeiw:(GRHtmlContentView *)htmlContentView heightDidChanged:(CGFloat)height {
    if (fabs(self.htmlContentHeight - height) > CGFLOAT_MIN) {
        self.htmlContentHeight = height;
        [self.tableView reloadData];
        NSLog(@"height : %f", height);
    }
}

- (void)htmlContentVeiw:(GRHtmlContentView *)htmlContentView imageURLStrings:(NSArray<NSString *> *)imageURLStrings imageDidPressedAtIndex:(NSInteger)index frame:(CGRect)frame image:(nullable UIImage *)image {
    NSMutableArray *photos = [NSMutableArray new];
    for (NSString *urlString in imageURLStrings) {
        IDMPhoto *photo = [IDMPhoto photoWithURL:[NSURL URLWithString:urlString]];
        [photos addObject:photo];
    }
    
    CGRect frameAtView = [htmlContentView convertRect:frame toView:self.view];
    
    if (!image) {
        UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, YES, 0);
        [self.view drawViewHierarchyInRect:self.view.bounds afterScreenUpdates:YES];
        UIImage *snapImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        image = [self __cropImage:snapImage toRect:frameAtView];
    }
    
    UIImageView *placeView = [[UIImageView alloc] initWithFrame:frameAtView];
    placeView.image = image; 
    [self.view addSubview:placeView];
    
    IDMPhotoBrowser *browser = [[IDMPhotoBrowser alloc] initWithPhotos:photos animatedFromView:placeView];
    [browser setInitialPageIndex:index];
    browser.delegate = self;
    browser.displayDoneButton = NO;
    browser.displayActionButton = NO;
    browser.displayArrowButton = YES;
    browser.displayCounterLabel = YES;
    browser.usePopAnimation = YES;
    browser.dismissOnTouch = NO;
    [self presentViewController:browser animated:YES completion:^{
        [placeView removeFromSuperview];
    }];
}

- (UIImage *)__cropImage:(UIImage*)image toRect:(CGRect)rect {
    CGFloat (^rad)(CGFloat) = ^CGFloat(CGFloat deg) {
        return deg / 180.0f * (CGFloat) M_PI;
    };
    
    CGAffineTransform rectTransform;
    switch (image.imageOrientation) {
        case UIImageOrientationLeft:
            rectTransform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(rad(90)), 0, -image.size.height);
            break;
        case UIImageOrientationRight:
            rectTransform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(rad(-90)), -image.size.width, 0);
            break;
        case UIImageOrientationDown:
            rectTransform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(rad(-180)), -image.size.width, -image.size.height);
            break;
        default:
            rectTransform = CGAffineTransformIdentity;
    };
    
    rectTransform = CGAffineTransformScale(rectTransform, image.scale, image.scale);
    CGRect transformedCropSquare = CGRectApplyAffineTransform(rect, rectTransform);
    CGImageRef imageRef = CGImageCreateWithImageInRect(image.CGImage, transformedCropSquare);
    UIImage *result = [UIImage imageWithCGImage:imageRef scale:image.scale orientation:image.imageOrientation];
    CGImageRelease(imageRef);
    
    return result;
}

- (void)htmlContentVeiw:(GRHtmlContentView *)htmlContentView imageDidPressed:(NSString *)imageURLString {
    if (!imageURLString) {
        return; 
    }
    
    NSInteger index = [self.imageURLs indexOfObject:imageURLString];
    if (index >= 0) {
        NSMutableArray *photos = [NSMutableArray new];
        for (NSString *urlString in self.imageURLs) {
            IDMPhoto *photo = [IDMPhoto photoWithURL:[NSURL URLWithString:urlString]];
            [photos addObject:photo];
        }
        
        IDMPhotoBrowser *browser = [[IDMPhotoBrowser alloc] initWithPhotos:photos];
        [browser setInitialPageIndex:index];
        browser.delegate = self;
        browser.displayDoneButton = NO; 
        browser.displayActionButton = NO;
        browser.displayArrowButton = YES;
        browser.displayCounterLabel = YES;
        browser.usePopAnimation = YES;
        browser.dismissOnTouch = NO;
        [self presentViewController:browser animated:YES completion:nil];
    } 
}

#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }
    return self.datas.count;
} 

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return self.htmlContentHeight;
    } else {
        return 400;
    } 
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UIHtmlContentTableViewCell" forIndexPath:indexPath];
        UIHtmlContentTableViewCell *htmlContentTableViewCell = (UIHtmlContentTableViewCell *)cell;
        htmlContentTableViewCell.delegate = self;
        [htmlContentTableViewCell.htmlContentView loadHtml:self.datas[indexPath.row]];
        self.contentView = htmlContentTableViewCell.htmlContentView; 
        return cell;
    } else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CommentTableViewCell" forIndexPath:indexPath];
        UICommentTableViewCell *commentTableViewCell = (UICommentTableViewCell *)cell;
        return cell;
    } 
    return nil;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.contentView setNeedsLayout];
} 

@end
