/*
 *  Copyright (c) 2014, Parse, LLC. All rights reserved.
 *
 *  You are hereby granted a non-exclusive, worldwide, royalty-free license to use,
 *  copy, modify, and distribute this software in source code or binary form for use
 *  in connection with the web services and APIs provided by Parse.
 *
 *  As with any software that integrates with the Parse platform, your use of
 *  this software is subject to the Parse Terms of Service
 *  [https://www.parse.com/about/terms]. This copyright notice shall be
 *  included in all copies or substantial portions of the software.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
 *  FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
 *  COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
 *  IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 *  CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 *
 */

#import "GLAuthenticationButton.h"

#import "UIImage+GLImage.h"
#import "GLRect.h"
#import "UIColor+GLColor.h"

static const UIEdgeInsets GLAuthenticationButtonContentEdgeInsets = { .top = 0.0f, .left = 12.0f, .bottom = 0.0f, .right = 0.0f };

@interface GLAuthenticationButton () {
    UIActivityIndicatorView *_activityIndicatorView;
}
@property (nonatomic) NSDictionary *names;
@property (nonatomic) NSDictionary *images;
@property (nonatomic) GLAuthenticationMethod method;
@end

@implementation GLAuthenticationButton

#pragma mark - Init

- (instancetype)initWithMethod:(GLAuthenticationMethod)method {
    if (self = [super initWithFrame:CGRectZero]) {
        self.method = method;
        self.backgroundColor = [UIColor clearColor];
        self.titleLabel.font = [UIFont systemFontOfSize:16.0f];
        
        self.contentEdgeInsets = UIEdgeInsetsZero;
        self.imageEdgeInsets = UIEdgeInsetsZero;
        
        UIImage *backgroundImage = [UIImage imageWithColor:self.images[[self objectForEnum:method]] cornerRadius:4.0f];
        [self setBackgroundImage:backgroundImage forState:UIControlStateNormal];
        
        if (method == GLAuthenticationMethodFacebook || method == GLAuthenticationMethodTwitter) {
            UIImage *image = [UIImage imageNamed:method == GLAuthenticationMethodFacebook ? @"facebook" : @"twitter"];
            [self setImage:image forState:UIControlStateNormal];
        }
        
        [self setTitle:self.names[[self objectForEnum:method]] forState:UIControlStateNormal];
    }
    
    return self;
}

#pragma mark - Layout

- (void)layoutSubviews {
    [super layoutSubviews];

    _activityIndicatorView.center = self.imageView.center;
    self.imageView.alpha = (self.loading ? 0.0f : 1.0f);
}

- (CGSize)sizeThatFits:(CGSize)boundingSize {
    if (self.method == GLAuthenticationMethodSignUp || self.method == GLAuthenticationMethodLogIn) {
        return [super sizeThatFits:boundingSize];
    }
    
    CGSize size = CGSizeZero;
    size.width = MAX([super sizeThatFits:boundingSize].width, boundingSize.width);
    size.height = MIN(44.0f, boundingSize.height);
    return size;
}

- (CGRect)imageRectForContentRect:(CGRect)contentRect {
    if (self.method == GLAuthenticationMethodSignUp || self.method == GLAuthenticationMethodLogIn) {
        return [super imageRectForContentRect:contentRect];
    }
    
    CGRect imageRect = GLRectMakeWithSize([self imageForState:UIControlStateNormal].size);
    imageRect.origin.x = GLAuthenticationButtonContentEdgeInsets.left;
    imageRect.origin.y = CGRectGetMidY(contentRect) - CGRectGetMidY(imageRect);
    return imageRect;
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect {
    if (self.method == GLAuthenticationMethodSignUp || self.method == GLAuthenticationMethodLogIn) {
        return [super titleRectForContentRect:contentRect];
    }
    
    contentRect.origin.x = CGRectGetMaxX([self imageRectForContentRect:contentRect]);
    contentRect.size.width = CGRectGetWidth(self.bounds) - CGRectGetMaxX([self imageRectForContentRect:contentRect]);

    CGSize size = [super titleRectForContentRect:contentRect].size;
    CGRect rect = GLRectMakeWithSizeCenteredInRect(size, contentRect);
    return rect;
}

#pragma mark -
#pragma mark Accessors

- (void)setLoading:(BOOL)loading {
    if (self.loading != loading) {
        if (loading) {
            if (!_activityIndicatorView) {
                _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
            }

            [_activityIndicatorView startAnimating];
            [self addSubview:_activityIndicatorView];
            [self setNeedsLayout];
        } else {
            [_activityIndicatorView stopAnimating];
            [_activityIndicatorView removeFromSuperview];
        }

        self.imageView.alpha = (loading ? 0.0f : 1.0f);
    }
}

- (BOOL)isLoading {
    return [_activityIndicatorView isAnimating];
}

- (NSDictionary *)names
{
    if (!_names) {
        _names = @{[self objectForEnum:GLAuthenticationMethodFacebook] : @"Facebook",
                   [self objectForEnum:GLAuthenticationMethodTwitter] : @"Twitter",
                   [self objectForEnum:GLAuthenticationMethodLogInPrompt] : @"I Have An Account",
                   [self objectForEnum:GLAuthenticationMethodSignUp] : @"Sign Up",
                   [self objectForEnum:GLAuthenticationMethodLogIn] : @"Log In"};
    }
    return _names;
}

- (NSDictionary *)images
{
    if (!_images) {
        _images = @{[self objectForEnum:GLAuthenticationMethodFacebook] : [UIColor facebookButtonBackgroundColor],
                    [self objectForEnum:GLAuthenticationMethodTwitter] : [UIColor twitterButtonBackgroundColor],
                    [self objectForEnum:GLAuthenticationMethodLogInPrompt] : [UIColor blueBlackgroundColor],
                    [self objectForEnum:GLAuthenticationMethodLogIn] : [UIColor blueBlackgroundColor],
                    [self objectForEnum:GLAuthenticationMethodSignUp] : [UIColor blueBlackgroundColor]};
    }
    return _images;
}


- (NSNumber *)objectForEnum:(GLAuthenticationMethod)method {
    return [NSNumber numberWithInt:method];
}


@end
