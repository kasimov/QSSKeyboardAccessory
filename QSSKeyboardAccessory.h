//
//  QSSKeyboardAccessory.h
//  autocarma
//
//  Created by Maksim Kasimov on 7/29/14.
//  Copyright (c) 2014 autocarma.org. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol QSSKeyboardAccessoryDelegate;


@interface QSSKeyboardAccessory : UIToolbar
@property (weak, nonatomic) IBOutlet id<QSSKeyboardAccessoryDelegate> toolbarDelegate;

- (void)updateNextPreviousControls;

@end




@protocol QSSKeyboardAccessoryDelegate <NSObject>

@optional
- (BOOL)hasNextInputForKeyboardAccessory:(QSSKeyboardAccessory *)keyboardAccessory;
- (BOOL)hasBackInputForKeyboardAccessory:(QSSKeyboardAccessory *)keyboardAccessory;

- (void)keyboardAccessoryDidPressDone:(QSSKeyboardAccessory *)keyboardAccessory;
- (void)keyboardAccessoryDidPressNext:(QSSKeyboardAccessory *)keyboardAccessory;
- (void)keyboardAccessoryDidPressBack:(QSSKeyboardAccessory *)keyboardAccessory;

@end