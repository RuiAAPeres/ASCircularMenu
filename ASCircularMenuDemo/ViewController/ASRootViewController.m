//
//  ASRootViewController.m
//  ASCircularMenuDemo
//
//  Created by André Silva on 20/11/13.
//  Copyright (c) 2013 AFMS. All rights reserved.
//

#import "ASRootViewController.h"

@interface ASRootViewController ()

@end

@implementation ASRootViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"ASCircularMenuDemo";
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    // init here because we need the window
    if (!_menu) {
        _menu = [[ASCircularMenu alloc]init];
        _menu.delegate = self;
        [_menu reloadButtons];
    }
}

#pragma mark - Circular Menu delegate

-(NSInteger)numberOfItemsInCircularMenu {
    return _stepper.value;
}

-(UIButton *)circularMenu:(ASCircularMenu *)circularMenu buttonForMenuItemAtIndex:(NSInteger)index {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btn.backgroundColor = [UIColor whiteColor];
    btn.layer.cornerRadius = 18.0;
    [btn setTitle:[NSString stringWithFormat:@"%ld",(long)index+1] forState:UIControlStateNormal];
    return btn;
}

-(void)circularMenu:(ASCircularMenu *)circularMenu didSelectMenuItemAtIndex:(NSInteger)index {
    NSLog(@"Menu item %ld",(long)index+1);
    [_menu closeMenu:YES];
}

- (IBAction)switchValueChanged:(UISwitch *)sender {
    if (sender.isOn) {
        [_menu showMenu:YES];
    }else {
        [_menu hideMenu:YES];
    }
}

- (IBAction)stepperValueChanged:(UIStepper *)sender {
    [_menu reloadButtons];
}

@end
