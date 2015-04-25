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
#import "PFUser+GLUser.h"
#import "UIView+GLView.h"
#import "PFFacebookUtils+GLFacebookUtils.h"

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
    
    self.signUp.enabled = YES;
    
    RAC(self.signUp, enabled) = [[[self.username.rac_textSignal zipWith:self.password.rac_textSignal] reduceEach:^id(NSString *username, NSString *password) {
        return @(username.length > 4 && password.length > 4);
    }] doNext:^(id x) {
        self.signUp.alpha = [x boolValue] ? 1 : 0.5;
        [self.signUp setNeedsDisplay];
    }];
    
    [[[[self.facebook rac_signalForControlEvents:UIControlEventTouchUpInside] doNext:^(id x) {
        NSLog(@"Pressed facebook button");
    }] flattenMap:^RACStream *(id value) {
        return [PFFacebookUtils logInWithSignalWithReadPermissions:@[@"public_profile", @"user_friends", @"email"]];
    }] subscribeNext:^(PFUser *user) {
        NSLog(@"Logged in user with name %@", user);
    }];
    
    [[[[[[self.signUp rac_signalForControlEvents:UIControlEventTouchUpInside] doNext:^(id x) {
        [self.view endEditing:YES];
    }] map:^id(id value) {
        PFUser *user = [PFUser currentUser];
        user.username = self.username.text;
        user.password = self.password.text;
        return user;
    }] flattenMap:^RACStream *(PFUser *user) {
        return [user signUpInBackgroundWithSignal];
    }] catch:^RACSignal *(NSError *error) {
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            NSLog(@"There was an error signing up...");
            [self.signUp animateError];
            [subscriber sendCompleted];
            return nil;
        }];
    }] subscribeNext:^(PFUser *x) {
        [x saveInBackground];
        [self.signUp animateSuccess];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self didTapDismissButton:nil];
        });
        
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

- (IBAction)didTapInBackground:(id)sender {
    [self.view endEditing:YES];
}

- (IBAction)didTapDismissButton:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
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
