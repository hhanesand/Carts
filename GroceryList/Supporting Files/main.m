//
//  main.m
//  GroceryList
//
//  Created by Hakon Hanesand on 1/18/15.

#import "AppDelegate.h"

CFAbsoluteTime startTime;

int main(int argc, char * argv[]) {
    startTime = CACurrentMediaTime();
    
    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
