//
//  ASCircularMenu.h
//
//  Created by André Silva on 06/06/13.
//

#import <UIKit/UIKit.h>
#import "ASCircularOverlayView.h"

@class ASCircularMenu;

@protocol ASCircularMenuDelegate <NSObject>

@required
-(NSInteger)numberOfItemsInCircularMenu;
-(UIButton*)circularMenu:(ASCircularMenu *)circularMenu buttonForMenuItemAtIndex:(NSInteger)index;
@optional
-(void)circularMenu:(ASCircularMenu *)circularMenu didSelectMenuItemAtIndex:(NSInteger) index;

@end


@interface ASCircularMenu : UIView

@property (nonatomic,weak) IBOutlet id<ASCircularMenuDelegate> delegate;
@property (nonatomic) BOOL isMenuOpen;
@property (nonatomic) BOOL isMenuVisible;

-(void)reloadButtons;

-(void)showMenu:(BOOL)animated;
-(void)hideMenu:(BOOL)animated;

-(void)openMenu:(BOOL)animated;
-(void)closeMenu:(BOOL)animated;
@end
