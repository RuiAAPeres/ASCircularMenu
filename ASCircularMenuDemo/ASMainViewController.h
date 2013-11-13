//
//  ASMainViewController.h
//  ASCircularMenuDemo
//
//  Created by André Silva on 12/11/13.
//  Copyright (c) 2013 AFMS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASCircularMenu.h"

@interface ASMainViewController : UIViewController <ASCircularMenuDelegate>

@property (nonatomic,strong) ASCircularMenu *menu;

@end
