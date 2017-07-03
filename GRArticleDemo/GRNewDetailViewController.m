//
//  GRNewDetailViewController.m
//  GRArticleDemo
//
//  Created by 赵亮 on 2017/6/30.
//  Copyright © 2017年 LA. All rights reserved.
//

#import "GRNewDetailViewController.h"
#import "GRWebHtmlContentView.h"

@interface GRNewDetailViewController () <UITableViewDelegate, UITableViewDataSource, GRHtmlContentViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *datas;
@property (strong, nonatomic) GRWebHtmlContentView *contentView;
@property (assign, nonatomic) CGFloat htmlContentHeight;
@property (copy, nonatomic) NSString *html;

@end

@implementation GRNewDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self __configTableView];
    [self __loadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)__configTableView {
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.htmlContentHeight = 3126;
    
    self.contentView = [[GRWebHtmlContentView alloc] init];
    self.contentView.delegate = self;
}

- (void)__loadData {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"arcticle326" ofType:@"html"];
    NSString *body = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    NSString *html = [self __htmlWithHtmlBody:body];
    self.html = html;
    self.datas = @[ @"comment1", @"comment2", @"comment3" ];
    [self.tableView reloadData];
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

- (void)htmlContentVeiw:(GRHtmlContentView *)htmlContentView heightDidChanged:(CGFloat)height {
    if (fabs(self.htmlContentHeight - height) > CGFLOAT_MIN) {
        self.htmlContentHeight = height;
        [self.tableView reloadData];
        NSLog(@"height : %f", height);
    }
}

#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.datas.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 500;
//        return self.htmlContentHeight;
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        self.contentView.frame = CGRectMake(0, 0, tableView.bounds.size.width, self.htmlContentHeight);
        [self.contentView loadHtml:self.html];
        return self.contentView;
    } 
    return nil;
} 

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UICommentTableViewCell" forIndexPath:indexPath];
    return cell;
}

//- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    [self.contentView setNeedsLayout];
//}

@end
