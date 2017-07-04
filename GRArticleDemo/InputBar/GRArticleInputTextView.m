//
//  GRArticleInputTextView.m
//  XXX
//
//  Created by liangzhimy on 17/3/2.
//  Copyright © 2017年 XXX. All rights reserved.
//

#import "GRArticleInputTextView.h"

#define __GRDefaultPlaceHolder 0x666666
#define __GRBackgroundColor 0x2c2c2f
#define __GRTextContainerInset UIEdgeInsetsMake(8.0f, 2.0f, 8.0f, 2.0f)
#define __GRTextContentInset UIEdgeInsetsMake(1.0f, 0.0f, 1.0f, 0.0f)
#define __GRScrollIndicatorInsets UIEdgeInsetsMake(0, 0.0f, 0, 0.0f)

static NSString *const __GRNotificationPasteKey = @"GRNotificationPaste";
static NSString *const __GRContentSize = @"contentSize";
static NSString *const __GRFontName = @"HelveticaNeue";
static const CGFloat __GRPlaceHolderLeftMargin = 7.f;
static const CGFloat __GRHalf = 0.5f;
static const CGFloat __GRFontSize = 16.F;

@implementation GRArticleInputTextView

- (instancetype)initWithFrame:(CGRect)frame textContainer:(NSTextContainer *)textContainer {
    if (self = [super initWithFrame:frame textContainer:textContainer]) {
        [self __configUI];
        [self __addObserver];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self __configUI];
        [self __addObserver];
    }
    return self; 
} 

- (void)dealloc {
    [self __removeTextViewNotificationObservers];
    [self __removeObserver];
}

- (void)__configUI {
    self.backgroundColor = UIColorFromRGBWithAlpha(__GRBackgroundColor, 1.0);
    self.scrollIndicatorInsets = __GRScrollIndicatorInsets;
    self.textContainerInset = __GRTextContainerInset;
    self.contentInset = __GRTextContentInset;
    self.scrollEnabled = YES;
    self.scrollsToTop = NO;
    self.userInteractionEnabled = YES;
    self.font = [UIFont fontWithName:__GRFontName size:__GRFontSize];
    self.textColor = [UIColor whiteColor];
    self.textAlignment = NSTextAlignmentNatural;
    
    self.contentMode = UIViewContentModeRedraw;
    self.dataDetectorTypes = UIDataDetectorTypeNone;
    self.keyboardAppearance = UIKeyboardAppearanceDefault;
    self.keyboardType = UIKeyboardTypeDefault;
    self.returnKeyType = UIReturnKeyDefault;
    
    self.text = nil;
    
    _placeHolder = GRLocalString(@"Say something…");
    _placeHolderTextColor = UIColorFromRGBWithAlpha(__GRDefaultPlaceHolder, 1.0);
    
    [self __addTextViewNotificationObservers];
}

- (BOOL)hasText {
    return [[self.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] > 0;
}

#pragma mark - setters
- (void)setPlaceHolder:(NSString *)placeHolder {
    if ([placeHolder isEqualToString:_placeHolder]) {
        return;
    }
    
    _placeHolder = [placeHolder copy];
    [self setNeedsDisplay];
}

- (void)setPlaceHolderTextColor:(UIColor *)placeHolderTextColor {
    if ([placeHolderTextColor isEqual:_placeHolderTextColor]) {
        return;
    }
    
    _placeHolderTextColor = placeHolderTextColor;
    [self setNeedsDisplay];
}

#pragma mark - UITextView overrides
- (void)setText:(NSString *)text {
    [super setText:text];
    [self.delegate textViewDidChange:self];
    [self setNeedsDisplay];
}

- (void)setAttributedText:(NSAttributedString *)attributedText {
    [super setAttributedText:attributedText];
    [self setNeedsDisplay];
}

- (void)setFont:(UIFont *)font {
    [super setFont:font];
    [self setNeedsDisplay];
}

- (void)setTextAlignment:(NSTextAlignment)textAlignment {
    [super setTextAlignment:textAlignment];
    [self setNeedsDisplay];
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    if (self.overrideNextResponder != nil) {
        return NO;
    }
    
    if (self.text.length > 0) {
        if (action == @selector(select:)) {
            return YES; 
        }
        
        if (action == @selector(selectAll:)) {
            return YES; 
        }
    } 
    
    if (action == @selector(paste:)) {
        return YES;
    }
    
    return [super canPerformAction:action withSender:sender];
}

- (void)paste:(id)sender {
    if (self.menuDelegate && [self.menuDelegate respondsToSelector:@selector(inputTextViewDidPaste:)]) {
        [self.menuDelegate inputTextViewDidPaste:self];
    } 
}

#pragma mark - Drawing
- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    if ([self.text length] == 0 && self.placeHolder) {
        [self.placeHolderTextColor set];
        CGSize size = [self.placeHolder sizeWithAttributes:[self __placeholderTextAttributes]];
        CGRect needRect = CGRectMake(rect.origin.x + __GRPlaceHolderLeftMargin,
                              rect.origin.y + (rect.size.height - size.height) * __GRHalf,
                              rect.size.width,
                              size.height);
        [self.placeHolder drawInRect:CGRectInset(needRect, 0.f, 0.f) withAttributes:[self __placeholderTextAttributes]];
    }
}

#pragma mark - Notifications
- (void)__addTextViewNotificationObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveTextViewNotification:)
                                                 name:UITextViewTextDidChangeNotification
                                               object:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveTextViewNotification:)
                                                 name:UITextViewTextDidBeginEditingNotification
                                               object:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveTextViewNotification:)
                                                 name:UITextViewTextDidEndEditingNotification
                                               object:self];
}

- (void)__removeTextViewNotificationObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UITextViewTextDidChangeNotification
                                                  object:self];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UITextViewTextDidBeginEditingNotification
                                                  object:self];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UITextViewTextDidEndEditingNotification
                                                  object:self];
}

- (void)didReceiveTextViewNotification:(NSNotification *)notification {
    [self setNeedsDisplay];
}

#pragma mark - Utilities
- (NSDictionary *)__placeholderTextAttributes {
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle.alignment = NSTextAlignmentLeft;
    return @{ NSFontAttributeName : self.font,
              NSForegroundColorAttributeName : self.placeHolderTextColor,
              NSParagraphStyleAttributeName : paragraphStyle };
}

- (UIResponder *)nextResponder {
    if (self.overrideNextResponder != nil) {
        return self.overrideNextResponder;
    } else {
        return [super nextResponder];
    }
}

- (void)__addObserver {
    [self addObserver:self forKeyPath:__GRContentSize options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)__removeObserver {
    [self removeObserver:self forKeyPath:__GRContentSize];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:__GRContentSize]) {
        UITextView *textView = object;
        CGFloat deadSpace = ([textView bounds].size.height - [textView contentSize].height);
        CGFloat inset = MAX(0, deadSpace * __GRHalf);
        textView.contentInset = UIEdgeInsetsMake(inset, textView.contentInset.left, inset, textView.contentInset.right);
    }
}

@end
