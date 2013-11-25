//
//  ASRootViewController.h
//  ASCircularMenuDemo
//
//  Created by André Silva on 20/11/13.
//  Copyright (c) 2013 AFMS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASCircularMenu.h"

@interface ASRootViewController : UIViewController<ASCircularMenuDelegate>

@property (nonatomic,strong) IBOutlet UIStepper *stepper;

@property (nonatomic,strong) ASCircularMenu *menu;

- (IBAction)switchValueChanged:(UISwitch *)sender;
- (IBAction)stepperValueChanged:(UIStepper *)sender;

@end
