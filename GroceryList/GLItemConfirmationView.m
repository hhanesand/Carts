//
//  GLItemConfirmationView.m
//  GroceryList
//
//  Created by Hakon Hanesand on 2/24/15.
//
//

#import "GLItemConfirmationView.h"

@implementation GLItemConfirmationView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self linkToNibFile];
    }
    
    return self;
}

- (void)awakeFromNib {
    [self linkToNibFile];
}

- (void)linkToNibFile {
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"GLItemConfirmationView" owner:self options:nil];
    ((UIView *)[nib objectAtIndex:0]).frame = CGRectMake(0, 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
    [self addSubview:[nib objectAtIndex:0]];
    NSLog(@"bounds %@", NSStringFromCGRect(((UIView *)[nib objectAtIndex:0]).frame));
}

@end
