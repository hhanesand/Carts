//
//  CALogInViewController.m
//  GroceryList
//
//  Created by Hakon Hanesand on 4/22/15.

#import <ReactiveCocoa/ReactiveCocoa.h>
#import <Parse/Parse.h>
#import <MRProgress/MRActivityIndicatorView.h>

#import "CALogInViewController.h"
#import "CAAuthenticationButton.h"
#import "CATransitionDelegate.h"
#import "CAPullToCloseTransitionManager.h"
#import "CAPullToCloseTransitionPresentationController.h"
#import "PFUser+CAUser.h"
#import "UIView+CAView.h"

@interface CALogInViewController ()
@property (weak, nonatomic) IBOutlet UITextField *username;
@property (weak, nonatomic) IBOutlet UITextField *password;

@property (weak, nonatomic) IBOutlet CAAuthenticationButton *logIn;
@property (weak, nonatomic) IBOutlet MRActivityIndicatorView *activityIndicatorView;


@property (nonatomic) CATransitionDelegate *transitionDelegate;
@end

@implementation CALogInViewController

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
    
    self.activityIndicatorView.layer.opacity = 0;
    self.activityIndicatorView.hidesWhenStopped = YES;
    self.activityIndicatorView.hidden = YES;
    
    self.logIn.enabled = NO;
    
    RAC(self.logIn, enabled) = [[[self.username.rac_textSignal zipWith:self.password.rac_textSignal] reduceEach:^id(NSString *username, NSString *password) {
        return @(username.length > 4 && password.length > 4);
    }] logAll];
    
    [[[[self.logIn rac_signalForControlEvents:UIControlEventTouchUpInside] flattenMap:^RACStream *(id value) {
        return [PFUser logInInBackgroundWithUsername:self.username.text password:self.password.text];
    }] catch:^RACSignal *(NSError *error) {
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            //animate button and let user know his wrongs
            NSLog(@"There was an error");
            [subscriber sendCompleted];
            return nil;
        }];
    }] subscribeCompleted:^{
        NSLog(@"Successful signup!");
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
        [self.logIn sendActionsForControlEvents:UIControlEventTouchUpInside];
    }
    
    return NO;
}

- (IBAction)didTapInBackground:(id)sender {
    [self.view endEditing:YES];
}

- (IBAction)didTapDismissButton:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (CATransitionDelegate *)transitionDelegate {
    if (!_transitionDelegate) {
        _transitionDelegate = [[CATransitionDelegate alloc] initWithController:self presentationController:[CAPullToCloseTransitionPresentationController class] transitionManager:[CAPullToCloseTransitionManager class]];
    }
    
    return _transitionDelegate;
}

@end
