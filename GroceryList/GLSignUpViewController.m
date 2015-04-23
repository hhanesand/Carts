//
//  GLSignUpViewController.m
//  GroceryList
//
//  Created by Hakon Hanesand on 4/22/15.

#import <ReactiveCocoa/ReactiveCocoa.h>
#import <Parse/Parse.h>

#import "GLSignUpViewController.h"
#import "GLAuthenticationButton.h"
#import "GLTransitionDelegate.h"
#import "GLPullToCloseTransitionManager.h"
#import "GLPullToCloseTransitionPresentationController.h"
#import "GLLogInViewController.h"
#import "GLUser.h"
#import "PFUser+GLUser.h"

@interface GLSignUpViewController ()
@property (weak, nonatomic) IBOutlet UIView *facebookContainer;
@property (weak, nonatomic) IBOutlet UIView *twitterContainer;
@property (weak, nonatomic) IBOutlet UIView *signUpContainer;
@property (weak, nonatomic) IBOutlet UIView *logInContainer;

@property (weak, nonatomic) IBOutlet UITextField *username;
@property (weak, nonatomic) IBOutlet UITextField *password;

@property (nonatomic) GLAuthenticationButton *facebook;
@property (nonatomic) GLAuthenticationButton *twitter;
@property (nonatomic) GLAuthenticationButton *logIn;
@property (nonatomic) GLAuthenticationButton *signUp;

@property (nonatomic) GLTransitionDelegate *transitionDelegate;
@end

@implementation GLSignUpViewController

+ (instancetype)instance {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:NSStringFromClass([self class]) bundle:nil];
    return [storyboard instantiateInitialViewController];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        self.facebook = [[GLAuthenticationButton alloc] initWithMethod:GLAuthenticationMethodFacebook];
        self.twitter = [[GLAuthenticationButton alloc] initWithMethod:GLAuthenticationMethodTwitter];
        self.logIn = [[GLAuthenticationButton alloc] initWithMethod:GLAuthenticationMethodLogInPrompt];
        self.signUp = [[GLAuthenticationButton alloc] initWithMethod:GLAuthenticationMethodSignUp];
        
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
    self.facebook.frame = self.facebookContainer.bounds;
    self.twitter.frame = self.twitterContainer.bounds;
    self.logIn.frame = self.logInContainer.bounds;
    self.signUp.frame = self.signUpContainer.bounds;
    
    [self.facebookContainer addSubview:self.facebook];
    [self.twitterContainer addSubview:self.twitter];
    [self.logInContainer addSubview:self.logIn];
    [self.signUpContainer addSubview:self.signUp];
    
    [self.logIn addTarget:self action:@selector(presentLogInViewController) forControlEvents:UIControlEventTouchUpInside];
    
    RAC(self.signUp, enabled) = [[RACSignal merge:@[self.username.rac_textSignal, self.password.rac_textSignal]] map:^id(NSString *text) {
        return @(text.length >= 5);
    }];
    
    [[[[self.signUp rac_signalForControlEvents:UIControlEventTouchUpInside] map:^id(id value) {
        GLUser *user = [GLUser GL_currentUser];
        user.username = self.username.text;
        user.password = self.password.text;
        return user;
    }] flattenMap:^RACStream *(GLUser *user) {
        return [user signUpInBackgroundWithSignal];
    }] subscribeCompleted:^{
        NSLog(@"sign up in background complete!");
    }];
}

- (void)presentLogInViewController {
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
