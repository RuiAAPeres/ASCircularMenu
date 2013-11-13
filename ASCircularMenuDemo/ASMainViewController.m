//
//  ASMainViewController.m
//  ASCircularMenuDemo
//
//  Created by André Silva on 12/11/13.
//  Copyright (c) 2013 AFMS. All rights reserved.
//

#import "ASMainViewController.h"

@interface ASMainViewController ()

@end

@implementation ASMainViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"ASCircularMenuDemo";
    
    _menu = [[ASCircularMenu alloc]init];
    _menu.delegate = self;
    [_menu reloadButtons];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [_menu hideMenu:NO];
    [_menu performSelector:@selector(showMenu:) withObject:[NSNumber numberWithBool:YES] afterDelay:2.0];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


#pragma mark - Circular Menu delegate

-(NSInteger)numberOfItemsInCircularMenu {
    return 6;
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

@end
