//
//  KKKeychainSampleItemViewController.h
//  KeychainKitSample
//
//  Created by david on 17/02/15.
//  Copyright (c) 2015 David Live Org. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KKSDataModel;

@interface KKSItemViewController : UIViewController

- (instancetype)initWithModel:(KKSDataModel *)model;

@end
