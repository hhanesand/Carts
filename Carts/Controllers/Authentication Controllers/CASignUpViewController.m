//
//  CASignUpViewController.m
//  GroceryList
//
//  Created by Hakon Hanesand on 4/22/15.

#import <ReactiveCocoa/ReactiveCocoa.h>
#import <Parse/Parse.h>
#import <MRProgress/MRActivityIndicatorView.h>
#import <pop/POP.h>

#import "CASignUpViewController.h"
#import "CAAuthenticationButton.h"
#import "CATransitionDelegate.h"
#import "CAPullToCloseTransitionManager.h"
#import "CAPullToCloseTransitionPresentationController.h"
#import "CALogInViewController.h"
#import "PFUser+CAUser.h"
#import "UIView+CAView.h"
#import "PFFacebookUtils+CAFacebookUtils.h"

#import <FBSDKCoreKit/FBSDKGraphRequest.h>
#import "PFTwitterUtils+CATwitterUtils.h"
#import <AFNetworking/AFNetworking.h>
#import "CATwitterSessionManager.h"

@interface CASignUpViewController ()
@property (weak, nonatomic) IBOutlet UITextField *username;
@property (weak, nonatomic) IBOutlet UITextField *password;

@property (weak, nonatomic) IBOutlet CAAuthenticationButton *facebook;
@property (weak, nonatomic) IBOutlet CAAuthenticationButton *twitter;
@property (weak, nonatomic) IBOutlet CAAuthenticationButton *signUp;

@property (weak, nonatomic) IBOutlet MRActivityIndicatorView *activityIndicatorView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *signInButtonLayoutConstraint;

@property (nonatomic) CATransitionDelegate *transitionDelegate;
@end

@implementation CASignUpViewController

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
    
    [[[[[self.facebook rac_signalForControlEvents:UIControlEventTouchUpInside] doNext:^(id x) {
        NSLog(@"Pressed facebook button");
    }] flattenMap:^RACStream *(id value) {
        return [PFFacebookUtils logInWithSignalWithReadPermissions:@[@"public_profile", @"user_friends", @"email"]];
    }] catch:^RACSignal *(NSError *error) {
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            NSLog(@"There was an error signing up...");
            [self.facebook animateError];
            [subscriber sendCompleted];
            return nil;
        }];
    }] subscribeNext:^(PFUser *user) {
        NSLog(@"Logged in user with name %@", user);
        
        [self.facebook animateSuccess];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self didTapDismissButton:nil];
        });
        
        FBSDKGraphRequestConnection *connection = [[FBSDKGraphRequestConnection alloc] init];
        
        FBSDKGraphRequest *picture = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me/picture" parameters:@{@"redirect" : @"false"}];
        FBSDKGraphRequest *profile = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me/" parameters:nil];
        
        __block BOOL done = NO;
        
        [connection addRequest:picture completionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
            user[@"picture"] = [result valueForKeyPath:@"data.url"];
            
            if (done) {
                [user saveInBackground];
            } else {
                done = YES;
            }
        }];
        
        [connection addRequest:profile completionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
            [user bindWithFacebookGraphRequest:result];
            
            if (done) {
                [user saveInBackground];
            } else {
                done = YES;
            }
        }];
        
        [connection start];
    }];
    
    [[[[[self.twitter rac_signalForControlEvents:UIControlEventTouchUpInside] doNext:^(id x) {
        NSLog(@"Pressed twitter button");
    }] flattenMap:^RACStream *(id value) {
        return [PFTwitterUtils logInWithSignal];
    }] catch:^RACSignal *(NSError *error) {
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            NSLog(@"There was an error signing up...");
            [self.twitter animateError];
            [subscriber sendCompleted];
            return nil;
        }];
    }] subscribeNext:^(PFUser *user) {
        NSLog(@"Successful! Username %@", user.username);
        [self.twitter animateSuccess];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self didTapDismissButton:nil];
        });
        
        CATwitterSessionManager *sess = [CATwitterSessionManager manager];
        
        [[sess requestTwitterUserWithID:[PFTwitterUtils twitter].userId] subscribeNext:^(id x) {
            [user bindWithTwitterResponse:x];
            [user saveInBackground];
        }];
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
    CALogInViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"CALogInViewController"];
    vc.delegate = self.delegate;
    [self presentViewController:vc animated:YES completion:nil];
}

- (CATransitionDelegate *)transitionDelegate
{
    if (!_transitionDelegate) {
        _transitionDelegate = [[CATransitionDelegate alloc] initWithController:self presentationController:[CAPullToCloseTransitionPresentationController class] transitionManager:[CAPullToCloseTransitionManager class]];
    }
    
    return _transitionDelegate;
}

@end
