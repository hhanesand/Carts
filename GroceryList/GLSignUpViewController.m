//
//  GLSignUpViewController.m
//  GroceryList
//
//  Created by Hakon Hanesand on 4/22/15.

#import <ReactiveCocoa/ReactiveCocoa.h>
#import <Parse/Parse.h>
#import <MRProgress/MRActivityIndicatorView.h>
#import <pop/POP.h>

#import "GLSignUpViewController.h"
#import "GLAuthenticationButton.h"
#import "GLTransitionDelegate.h"
#import "GLPullToCloseTransitionManager.h"
#import "GLPullToCloseTransitionPresentationController.h"
#import "GLLogInViewController.h"
#import "GLUser.h"
#import "PFUser+GLUser.h"
#import "UIView+GLView.h"

@interface GLSignUpViewController ()
@property (weak, nonatomic) IBOutlet UITextField *username;
@property (weak, nonatomic) IBOutlet UITextField *password;

@property (weak, nonatomic) IBOutlet GLAuthenticationButton *facebook;
@property (weak, nonatomic) IBOutlet GLAuthenticationButton *twitter;
@property (weak, nonatomic) IBOutlet GLAuthenticationButton *signUp;

@property (weak, nonatomic) IBOutlet MRActivityIndicatorView *activityIndicatorView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *signInButtonLayoutConstraint;

@property (nonatomic) GLTransitionDelegate *transitionDelegate;
@end

@implementation GLSignUpViewController

+ (instancetype)instance {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:NSStringFromClass([self class]) bundle:nil];
    return [storyboard instantiateInitialViewController];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self configureModalPresentation];
    }
    
    return self;
}

- (void)configureModalPresentation {
    self.modalPresentationStyle = UIModalPresentationCustom;
    self.transitioningDelegate = self.transitionDelegate;
    self.modalPresentationCapturesStatusBarAppearance = YES;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.signUp.enabled = NO;
    
    RAC(self.signUp, enabled) = [[[self.username.rac_textSignal zipWith:self.password.rac_textSignal] reduceEach:^id(NSString *username, NSString *password) {
        return @(username.length > 4 && password.length > 4);
    }] doNext:^(id x) {
        self.signUp.alpha = [x boolValue] ? 1 : 0.5;
        [self.signUp setNeedsDisplay];
    }];
    
    [[[[[[self.signUp rac_signalForControlEvents:UIControlEventTouchUpInside] doNext:^(id x) {
        [self.view endEditing:YES];
    }] map:^id(id value) {
        GLUser *user = [GLUser GL_currentUser];
        user.username = self.username.text;
        user.password = self.password.text;
        return user;
    }] flattenMap:^RACStream *(GLUser *user) {
        return [user signUpInBackgroundWithSignal];
    }] catch:^RACSignal *(NSError *error) {
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            NSLog(@"There was an error signing up...");
            [subscriber sendCompleted];
            return nil;
        }];
    }] subscribeNext:^(id x) {
        NSLog(@"Successful signup");
    }];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    [self.username setMaskToRoundedCorners:(UIRectCornerTopRight | UIRectCornerTopLeft) withRadii:4.0];
    [self.password setMaskToRoundedCorners:(UIRectCornerBottomRight | UIRectCornerBottomLeft) withRadii:4.0];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.username) {
        [self.password becomeFirstResponder];
    } else if (textField == self.password) {
        [textField resignFirstResponder];
        [self.signUp sendActionsForControlEvents:UIControlEventTouchUpInside];
    }
    
    return NO;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    
   
}

- (IBAction)didTapAlreadyHaveAccountButton:(id)sender {
    GLLogInViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"GLLogInViewController"];
    vc.delegate = self.delegate;
    [self presentViewController:vc animated:YES completion:nil];
}

- (GLTransitionDelegate *)transitionDelegate
{
    if (!_transitionDelegate) {
        _transitionDelegate = [[GLTransitionDelegate alloc] initWithController:self presentationController:[GLPullToCloseTransitionPresentationController class] transitionManager:[GLPullToCloseTransitionManager class]];
    }
    
    return _transitionDelegate;
}

@end
