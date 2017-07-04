//
//  GRArticleInputBarViewController.m
//  GRArticleDemo
//
//  Created by liangzhimy on 2017/7/4.
//  Copyright © 2017年 LA. All rights reserved.
//

#import "GRArticleInputBarViewController.h"
#import "GRArticleInputTextView.h"

static void *__GRMessagesKeyValueObservingContext = "__GRMessagesKeyValueObservingContext";
static const CGFloat __GRMinInputTextViewHeight = 37.f;
static const CGFloat __GRMaxInputTextViewHeight = 100.f;

@interface GRArticleInputBarViewController ()

@property (weak, nonatomic) IBOutlet UIView *inputView;
@property (weak, nonatomic) IBOutlet UIView *waitSendView;
@property (weak, nonatomic) IBOutlet UIButton *commentButton;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (weak, nonatomic) IBOutlet GRArticleInputTextView *articleInputTextView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *inputTextViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *inputTextViewBottomMarginConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *inputTextViewTopMarginConstraint;

@property (assign, nonatomic, getter=isEnableEditing) BOOL enableEditing;
@property (assign, nonatomic, getter=isObserving) BOOL observing;
@property (assign, nonatomic) CGSize keyboardSize;
@property (assign, nonatomic) CGFloat defaultInputViewHeight;

@property (strong, nonatomic) NSNotificationCenter *notificationCenter;

@end

@implementation GRArticleInputBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.notificationCenter = [NSNotificationCenter defaultCenter];
    [self __addObserver];
    self.enableEditing = NO;
    self.defaultInputViewHeight = self.inputTextViewHeightConstraint.constant;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    [self __removeObserver]; 
}

#pragma mark - property
- (void)setEnableEditing:(BOOL)enableEditing {
    _enableEditing = enableEditing;
    self.waitSendView.hidden = enableEditing;
    self.inputView.hidden = !enableEditing;
    if (enableEditing) {
        [self.articleInputTextView becomeFirstResponder];
    } else {
        [self.view endEditing:YES];
    } 
} 

#pragma mark - event
- (IBAction)sendButtonPressed:(id)sender {
}

- (IBAction)commentButtonPressed:(id)sender {
}

- (IBAction)inputButtonPressed:(id)sender {
    self.enableEditing = YES; 
}


#pragma mark - observer
- (void)__addObserver {
    [self.notificationCenter addObserver:self
                                selector:@selector(keyboardWillShowNotification:)
                                    name:UIKeyboardWillShowNotification
                                  object:nil];
    
    [self.notificationCenter addObserver:self
                                selector:@selector(keyboardWillHideNotification:)
                                    name:UIKeyboardWillHideNotification
                                  object:nil];
    
    if (self.isObserving) {
        return;
    }
    
    [self.articleInputTextView addObserver:self
                         forKeyPath:NSStringFromSelector(@selector(contentSize))
                            options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
                            context:__GRMessagesKeyValueObservingContext];
    
    self.observing = YES;
}

- (void)__removeObserver {
    [self.notificationCenter removeObserver:self];
    if (!self.isObserving) {
        return;
    }
    
    @try {
        [self.articleInputTextView removeObserver:self
                                forKeyPath:NSStringFromSelector(@selector(contentSize))
                                   context:__GRMessagesKeyValueObservingContext];
    }
    @catch (NSException * __unused exception) {
    }
    
    self.observing = NO;
}

- (void)__updateDefaultContainerViewHeight {
    self.articleInputTextView.text = @"";
    self.inputTextViewHeightConstraint.constant = self.defaultInputViewHeight;
    [self __updateContainerViewHeight];
} 

- (void)__updateContainerViewHeight {
    CGFloat height = self.inputTextViewTopMarginConstraint.constant + self.inputTextViewBottomMarginConstraint.constant + self.inputTextViewHeightConstraint.constant;
    if (self.delegate && [self.delegate respondsToSelector:@selector(articleInputBarViewController:didChangeHeight:)]) {
        [self.delegate articleInputBarViewController:self didChangeHeight:height]; 
    }
}

- (void)__updateContainerViewWithRaise:(BOOL)raise height:(CGFloat)height {
    if (self.delegate && [self.delegate respondsToSelector:@selector(articleInputBarViewController:didRaise:bottomHeight:)]) {
        [self.delegate articleInputBarViewController:self didRaise:raise bottomHeight:height];
    }
}

#pragma mark - keyboard
- (void)keyboardWillShowNotification:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    self.keyboardSize = keyboardSize;
    [self __updateContainerViewWithRaise:YES height:keyboardSize.height];
}

- (void)keyboardWillHideNotification:(NSNotification *)notification {
    self.keyboardSize = CGSizeZero;
    [self __updateContainerViewWithRaise:NO height:0];
    [self __updateDefaultContainerViewHeight];
    self.enableEditing = NO;
}

#pragma mark - textView observer
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context == __GRMessagesKeyValueObservingContext) {
        if (object == self.articleInputTextView
            && [keyPath isEqualToString:NSStringFromSelector(@selector(contentSize))]) {
            [self __updateInputTextViewHeightConstraint];
        }
    }
}

- (void)__updateInputTextViewHeightConstraint {
    CGFloat originalHeight = self.inputTextViewHeightConstraint.constant;
    self.inputTextViewHeightConstraint.constant = MAX(__GRMinInputTextViewHeight, MIN(__GRMaxInputTextViewHeight, self.articleInputTextView.contentSize.height));
    [self.articleInputTextView setContentOffset:self.articleInputTextView.contentOffset animated:NO];
    if (originalHeight != self.inputTextViewHeightConstraint.constant) {
        [self __updateContainerViewHeight];
        [self.view layoutIfNeeded];
    }
}

#pragma mark - UITextViewDelegate
- (void)__cancelSelectMenuButton {
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    [self __cancelSelectMenuButton];
}

- (void)textViewDidChange:(UITextView *)textView {
    [self __updateSendButtonState];
}

- (void)__updateSendButtonState {
    NSString *text = [self.articleInputTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    BOOL hidden = text.length > 0 ? NO : YES;
    if (self.sendButton.hidden != hidden) {
        [self __updateSendButtonStateWithHidden:hidden animation:YES];
    }
}

- (void)__updateSendButtonStateWithHidden:(BOOL)hidden animation:(BOOL)animation {
}

@end
