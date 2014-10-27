@import ObjectiveC.runtime;
#import "UITextView+Placeholder.h"

#define OFFSET 6

static char placeholderKey;

@interface UITextView ()
@property (nonatomic, strong) UILabel *lblPlaceholder;
@end

@implementation UITextView (Placeholder)

#pragma mark -
#pragma mark NSObject

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"text"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -
#pragma mark UIView

- (void)layoutSubviews {
    [self configurePlaceholderFrame];
}

#pragma mark -
#pragma mark UITextView+Placeholder

- (void)setPlaceholder:(NSString *)placeholder {
    self.lblPlaceholder.text = placeholder;
    self.lblPlaceholder.hidden = self.text.length > 0;
    [self configurePlaceholderFrame];
}

- (NSString *)placeholder {
    return self.lblPlaceholder.text;
}

#pragma mark -
#pragma mark UITextView+Placeholder Private Methods

- (UILabel *)lblPlaceholder {
    UILabel *lbl = objc_getAssociatedObject(self, &placeholderKey);
    
    if (!lbl)
       lbl = [self configurePlaceholder];
    
    return lbl;
}

- (void)setLblPlaceholder:(UILabel *)lblPlaceholder {
    objc_setAssociatedObject(self, &placeholderKey, lblPlaceholder, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)configurePlaceholderFrame {
    CGRect frame = CGRectMake(OFFSET, OFFSET, CGRectGetWidth(self.bounds) - 2 * OFFSET, CGRectGetHeight(self.bounds) - 2 * OFFSET);
    CGSize size = CGSizeMake(CGRectGetWidth(frame), CGRectGetHeight(frame));
    
    size = [self.placeholder boundingRectWithSize:size
                                           options:NSStringDrawingUsesLineFragmentOrigin
                                       attributes:@{ NSFontAttributeName : self.font }
                                           context:NULL].size;
    frame.size.height = size.height;
    self.lblPlaceholder.frame = frame;
}

- (UILabel *)configurePlaceholder {
    self.lblPlaceholder = [[UILabel alloc] init];
    self.lblPlaceholder.numberOfLines = 0;
    self.lblPlaceholder.font = self.font;
    self.lblPlaceholder.backgroundColor = [UIColor clearColor];
    self.lblPlaceholder.textColor = [UIColor lightGrayColor];
    self.lblPlaceholder.textAlignment = self.textAlignment;
    [self addSubview:self.lblPlaceholder];
    [[NSNotificationCenter defaultCenter] addObserverForName:UITextViewTextDidChangeNotification
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note) {
                                                      self.lblPlaceholder.hidden = self.text.length > 0;
                                                  }];
    [self addObserver:self forKeyPath:@"text" options:NSKeyValueObservingOptionNew context:NULL];
    return self.lblPlaceholder;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"text"])
        [[NSNotificationCenter defaultCenter] postNotificationName:UITextViewTextDidChangeNotification object:nil];
}

@end

