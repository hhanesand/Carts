//
//  GLLogInViewController.m
//  GroceryList
//
//  Created by Hakon Hanesand on 4/22/15.

#import <ReactiveCocoa/ReactiveCocoa.h>
#import <Parse/Parse.h>

#import "GLLogInViewController.h"
#import "GLAuthenticationButton.h"
#import "GLTransitionDelegate.h"
#import "GLPullToCloseTransitionManager.h"
#import "GLPullToCloseTransitionPresentationController.h"
#import "GLUser.h"
#import "PFUser+GLUser.h"

@interface GLLogInViewController ()
@property (weak, nonatomic) IBOutlet UITextField *username;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UIView *logInContainer;
@property (nonatomic) GLAuthenticationButton *logIn;

@property (nonatomic) GLTransitionDelegate *transitionDelegate;
@end

@implementation GLLogInViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        self.logIn = [[GLAuthenticationButton alloc] initWithMethod:GLAuthenticationMethodLogIn];
        [self configureModalPresentation];
    }
    
    return self;
}

- (void)configureModalPresentation {
    self.modalPresentationStyle = UIModalPresentationCustom;
    self.transitioningDelegate = self.transitionDelegate;
    self.modalPresentationCapturesStatusBarAppearance = YES;
}

- (void)viewDidLoad {
    self.logIn.frame = self.logInContainer.bounds;
    [self.logInContainer addSubview:self.logIn];
    
    RAC(self.logIn, enabled) = [[RACSignal merge:@[self.username.rac_textSignal, self.password.rac_textSignal]] map:^id(NSString *text) {
        return @(text.length >= 5);
    }];
    
    [[[self.logIn rac_signalForControlEvents:UIControlEventTouchUpInside] flattenMap:^RACStream *(id value) {
        return [GLUser logInInBackgroundWithUsername:self.username.text password:self.password.text];
    }] subscribeNext:^(id x) {
        NSLog(@"log in in background complete!");
    }];
}

- (GLTransitionDelegate *)transitionDelegate
{
    if (!_transitionDelegate) {
        _transitionDelegate = [[GLTransitionDelegate alloc] initWithController:self presentationController:[GLPullToCloseTransitionPresentationController class] transitionManager:[GLPullToCloseTransitionManager class]];
    }
    
    return _transitionDelegate;
}

@end
