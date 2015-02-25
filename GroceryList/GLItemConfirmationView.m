//
//  GLItemConfirmationView.m
//  GroceryList
//
//  Created by Hakon Hanesand on 2/24/15.
//
//

#import "GLItemConfirmationView.h"

@implementation GLItemConfirmationView

- (void)awakeFromNib {
    [self addSubview:[[[NSBundle mainBundle] loadNibNamed:@"GLItemConfirmationView" owner:nil options:nil] objectAtIndex:0]];
}

@end
