//
//  QSSKeyboardAccessory.m
//  autocarma
//
//  Created by Maksim Kasimov on 7/29/14.
//  Copyright (c) 2014 autocarma.org. All rights reserved.
//

#import "QSSKeyboardAccessory.h"


typedef NS_ENUM(NSUInteger, QSSKeyboardAccessoryControl) {
    QSSKeyboardAccessoryControlBack,
    QSSKeyboardAccessoryControlNext,
};


typedef NS_OPTIONS(NSUInteger, QSSKeyboardVisibleControls) {
    QSSKeyboardVisibleControlsNext = 1 << 0,
    QSSKeyboardVisibleControlsDone = 1 << 1,
};

static NSString *kKeyboardAccessory = @"QSSKeyboardAccessory";


@interface QSSKeyboardAccessory ()
@property (nonatomic, strong) UISegmentedControl *segmentedControl;
@property (nonatomic, strong) UIBarButtonItem *leftArrowButton;
@property (nonatomic, strong) UIBarButtonItem *rightArrowButton;
@property (nonatomic, strong) UIBarButtonItem *doneButton;
@property (nonatomic, strong) UIBarButtonItem *segmentedControlItem;

@end


@implementation QSSKeyboardAccessory

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self)
    {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    [self setAutoresizingMask:(UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth)];
    
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1)
    {
        self.leftArrowButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:105
                                                                             target:self
                                                                             action:@selector(selectPreviousField)];
        
        self.rightArrowButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:106
                                                                              target:self
                                                                              action:@selector(selectNextField)];
        
        self.leftArrowButton.enabled = YES;
        self.rightArrowButton.enabled = YES;

    }
    else
    {
        self.barStyle = UIBarStyleBlackTranslucent;
        
        NSArray *segmentItems = @[NSLocalizedStringFromTable(@"Previous", kKeyboardAccessory, @"Previous button title."),
                                  NSLocalizedStringFromTable(@"Next", kKeyboardAccessory, @"Next button title.")];
        
        self.segmentedControl = [[UISegmentedControl alloc] initWithItems:segmentItems];
        
        [self.segmentedControl addTarget:self
                                  action:@selector(segmentedControlValueChanged:)
                        forControlEvents:UIControlEventValueChanged];
        
        self.segmentedControl.momentary = YES;
        [self.segmentedControl setSegmentedControlStyle:UISegmentedControlStyleBar];
        
        [self.segmentedControl setEnabled:YES forSegmentAtIndex:QSSKeyboardAccessoryControlBack];
        [self.segmentedControl setEnabled:YES forSegmentAtIndex:QSSKeyboardAccessoryControlNext];
        
        self.segmentedControlItem = [[UIBarButtonItem alloc] initWithCustomView:self.segmentedControl];
    }
    
    self.doneButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTable(@"Done",
                                                                                        kKeyboardAccessory,
                                                                                        @"Done button title.")
                                                         style:UIBarButtonItemStyleDone
                                                        target:self
                                                        action:@selector(doneButtonPressed:)];
    
    [self updateNextPreviousControls];
}


- (NSArray *)visibleToolbarItems:(QSSKeyboardVisibleControls)visibleControls
{
    NSMutableArray *items = [NSMutableArray arrayWithCapacity:3];
    
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1)
    {
        if (visibleControls & QSSKeyboardVisibleControlsNext)
        {
            UIBarButtonItem *fixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                                        target:nil
                                                                                        action:nil];
            fixedSpace.width = 22.0;
            [items addObjectsFromArray:@[self.leftArrowButton,
                                         fixedSpace,
                                         self.rightArrowButton]];
        }
    }
    else
    {
        if (visibleControls & QSSKeyboardVisibleControlsNext)
        {
            [items addObject:self.segmentedControlItem];
        }
    }
    
    if (visibleControls & QSSKeyboardVisibleControlsDone)
    {
        [items addObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                       target:nil
                                                                       action:nil]];
        [items addObject:self.doneButton];
    }
    
    return items;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)updateNextPreviousControls
{
    BOOL hasNext = NO;
    BOOL hasBack = NO;
    if ([self.toolbarDelegate respondsToSelector:@selector(hasNextInputForKeyboardAccessory:)])
    {
        hasNext = [self.toolbarDelegate hasNextInputForKeyboardAccessory:self];
    }
    
    if ([self.toolbarDelegate respondsToSelector:@selector(hasBackInputForKeyboardAccessory:)])
    {
        hasBack = [self.toolbarDelegate hasBackInputForKeyboardAccessory:self];
    }
    
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1)
    {
        self.leftArrowButton.enabled = hasBack;
        self.rightArrowButton.enabled = hasNext;
    }
    else
    {
        [self.segmentedControl setEnabled:hasBack forSegmentAtIndex:QSSKeyboardAccessoryControlBack];
        [self.segmentedControl setEnabled:hasNext forSegmentAtIndex:QSSKeyboardAccessoryControlNext];
    }
    
    
    if (!hasNext && !hasBack)
    {
        [self setItems:[self visibleToolbarItems:(QSSKeyboardVisibleControlsDone)]];
    }
    else
    {
        [self setItems:[self visibleToolbarItems:(QSSKeyboardVisibleControlsNext | QSSKeyboardVisibleControlsDone)]];
    }

}

- (void)selectPreviousField
{
    if ([self.toolbarDelegate respondsToSelector:@selector(keyboardAccessoryDidPressBack:)])
    {
        [self.toolbarDelegate keyboardAccessoryDidPressBack:self];
    }
    
    [self updateNextPreviousControls];
}

- (void)selectNextField
{
    if ([self.toolbarDelegate respondsToSelector:@selector(keyboardAccessoryDidPressNext:)])
    {
        [self.toolbarDelegate keyboardAccessoryDidPressNext:self];
    }
    
    [self updateNextPreviousControls];
}

- (void)segmentedControlValueChanged:(id)sender
{
	[[UIDevice currentDevice] playInputClick];
	QSSKeyboardAccessoryControl control = self.segmentedControl.selectedSegmentIndex;
    
    switch (control)
    {
        case QSSKeyboardAccessoryControlBack:
            [self selectPreviousField];
            break;
            
        case QSSKeyboardAccessoryControlNext:
            [self selectNextField];
            break;
    }
}

- (void)doneButtonPressed:(id)sender
{
    if ([self.toolbarDelegate respondsToSelector:@selector(keyboardAccessoryDidPressDone:)])
    {
        [self.toolbarDelegate keyboardAccessoryDidPressDone:self];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self updateNextPreviousControls];
}
@end
