//
//  GLListItem.m
//  GroceryList
//
//  Created by Hakon Hanesand on 2/19/15.
//
//

#import "GLListObject.h"
#import "GLBarcodeObject.h"

@implementation GLListObject

@dynamic item;
@dynamic owner;
@dynamic userModifications;

+ (instancetype)objectWithCurrentUserAndBarcodeItem:(GLBarcodeObject *)barcodeItem {
    GLListObject *new = [GLListObject objectWithCurrentUser];
    new.item = barcodeItem;
    return new;
}

+ (instancetype)objectWithCurrentUser {
    GLListObject *new = [GLListObject object];
    new.owner = [PFUser currentUser];
    return new;
}

+ (NSString *)parseClassName {
    return @"list";
}

+ (void)load {
    [self registerSubclass];
}

- (void)addUserModification:(NSString *)value forKey:(NSString *)key {
    if (!self.userModifications) {
        self.userModifications = [NSMutableDictionary new];
    }
    
    [self.userModifications setValue:value forKey:key];
}

- (NSString *)getName {
    if (self.userModifications[@"name"]) {
        return self.userModifications[@"name"];
    }
    
    return self.item.name;
}

- (NSString *)getBrand {
    if (self.userModifications[@"brand"]) {
        return self.userModifications[@"brand"];
    }
    
    return self.item.brand;
}

- (NSString *)getCategory {
    if (self.userModifications[@"category"]) {
        return self.userModifications[@"category"];
    }
    
    return self.item.category;
}

- (NSString *)getManufacturer {
    if (self.userModifications[@"manufacturer"]) {
        return self.userModifications[@"manufacturer"];
    }
    
    return self.item.manufacturer;
}

@end
