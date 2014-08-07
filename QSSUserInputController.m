//
//  QSSUserInputController.m
//  autocarma
//
//  Created by Maksim Kasimov on 8/7/14.
//  Copyright (c) 2014 autocarma.org. All rights reserved.
//

#import "QSSUserInputController.h"
#import "QSSKeyboardAccessory.h"
#import "UITableViewCell+UITableView.h"


@interface QSSUserInputController ()<UITextFieldDelegate, UITextViewDelegate, QSSKeyboardAccessoryDelegate>
@property (strong, nonatomic) IBOutlet QSSKeyboardAccessory *keyboardAccessory;
@property (weak, nonatomic) UIResponder *currentResponder;
@property (strong, nonatomic) NSArray *responders;

@end

@implementation QSSUserInputController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self updateResponders];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Accessors
- (QSSKeyboardAccessory *)keyboardAccessory
{
    if (!_keyboardAccessory)
    {
        _keyboardAccessory = [[QSSKeyboardAccessory alloc] initWithFrame:
                              CGRectMake(0, 0, self.view.frame.size.width, 44)];
        _keyboardAccessory.toolbarDelegate = self;
    }
    
    return _keyboardAccessory;
}

#pragma mark - UIScrollViewDelegate

- (void)updateResponders
{
    self.responders = [self.tableView findTextInputs];
    [self.keyboardAccessory updateNextPreviousControls];
    
    
    if (self.currentResponder &&
        [self.responders indexOfObject:self.currentResponder] == NSNotFound)
    {
        [self.currentResponder resignFirstResponder];
    }
    
    
    for (id obj in self.responders)
    {
        if ([obj isKindOfClass:[UITextField class]])
        {
            ((UITextField *)obj).delegate = self;
        }
        else if ([obj isKindOfClass:[UITextView class]])
        {
            ((UITextView *)obj).delegate = self;
        }
    }

    
    /*
     // ...
     self.currentResponder = textFiled
     NSIdexPath *indexPath = [self indexPathOfTableRowWhereTheResponderIsLocated];
     self.currentResponder.inndexPath = indexPath;
     self.currentResponderIndexPath = indexPath;
     // ...
     if (self.currentResponderIndexPath != self.currentResponder.inndexPath)
     {
     [self.currentResponder resignFirstResponder];
     }
     */
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate)
    {
        [self updateResponders];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self updateResponders];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    self.currentResponder = nil;
    
    return NO;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField.inputAccessoryView == nil)
    {
        textField.inputAccessoryView = self.keyboardAccessory;
    }
    
    self.responders = [self.tableView findTextInputs];
    [self.keyboardAccessory updateNextPreviousControls];
    self.currentResponder = textField;
    
    return YES;
}

#pragma mark - UITextViewDelegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)aTextView
{
    if (aTextView.inputAccessoryView == nil)
    {
        aTextView.inputAccessoryView = self.keyboardAccessory;
    }
    
    self.responders = [self.tableView findTextInputs];
    [self.keyboardAccessory updateNextPreviousControls];
    self.currentResponder = aTextView;
    
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)aTextView
{
    [aTextView resignFirstResponder];
    self.currentResponder = nil;

    return YES;
}

#pragma mark - QSSKeyboardAccessoryDelegate

- (void)keyboardAccessoryDidPressDone:(QSSKeyboardAccessory *)keyboardAccessory
{
    [self.currentResponder resignFirstResponder];
    
    [self.tableView scrollToNearestSelectedRowAtScrollPosition:UITableViewScrollPositionNone
                                                      animated:NO];
}

- (BOOL)hasNextInputForKeyboardAccessory:(QSSKeyboardAccessory *)keyboardAccessory
{
    NSUInteger index = [self.responders indexOfObject:self.currentResponder];
    if (index == NSNotFound)
    {
        return NO;
    }
    
    if (index+1 >= [self.responders count])
    {
        return NO;
    }
    
    return YES;
}

- (BOOL)hasBackInputForKeyboardAccessory:(QSSKeyboardAccessory *)keyboardAccessory
{
    NSUInteger index = [self.responders indexOfObject:self.currentResponder];
    if (index == NSNotFound)
    {
        return NO;
    }
    
    if (index == 0)
    {
        return NO;
    }
    
    return YES;
}

- (void)keyboardAccessoryDidPressNext:(QSSKeyboardAccessory *)keyboardAccessory
{
    NSUInteger index = [self.responders indexOfObject:self.currentResponder];
    
    index++;
    if (index >= [self.responders count])
    {
        return;
    }
    
    UIResponder *responder = [self.responders objectAtIndex:index];
    [responder becomeFirstResponder];
}

- (void)keyboardAccessoryDidPressBack:(QSSKeyboardAccessory *)keyboardAccessory
{
    NSUInteger index = [self.responders indexOfObject:self.currentResponder];
    
    if (index == 0)
    {
        return;
    }
    index--;
    
    UIResponder *responder = [self.responders objectAtIndex:index];
    [responder becomeFirstResponder];
}

@end
