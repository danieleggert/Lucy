//
//  DemoWithLotsOfCodeViewController.m
//  AutoLayoutApp
//
//  Created by Chris Eidhof on 9/19/13.
//  Copyright (c) 2013 objc.io. All rights reserved.
//

#import "DemoWithLotsOfCodeViewController.h"

@interface DemoWithLotsOfCodeViewController ()

@property  (nonatomic,strong) NSLayoutConstraint* constraint;

@end

@implementation DemoWithLotsOfCodeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    UISlider* slider = [[UISlider alloc] init];
    slider.minimumValue = 0;
    slider.maximumValue = 320;
    slider.value = 10;
    [slider addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:slider];
    
    UIView* blueView = [self addViewWithColor:[UIColor blueColor]];
    UIView* redView = [self addViewWithColor:[UIColor redColor]];
    UIView* yellowView = [self addViewWithColor:[UIColor yellowColor]];
    CGFloat inset = 20;    NSLayoutConstraint *constraint0 = [NSLayoutConstraint constraintWithItem:blueView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1 constant:[UIApplication sharedApplication].statusBarFrame.size.height];
    NSLayoutConstraint *constraint1 = [NSLayoutConstraint constraintWithItem:blueView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:slider.value];
    self.constraint = constraint1;
    NSLayoutConstraint *constraint2 = [NSLayoutConstraint constraintWithItem:blueView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:100];
    NSLayoutConstraint *constraint3 = [NSLayoutConstraint constraintWithItem:blueView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1 constant:0];
    NSLayoutConstraint *constraint4 = [NSLayoutConstraint constraintWithItem:redView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:blueView attribute:NSLayoutAttributeWidth multiplier:0.5 constant:0];
    NSLayoutConstraint *constraint5 = [NSLayoutConstraint constraintWithItem:redView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:blueView attribute:NSLayoutAttributeHeight multiplier:1 constant:0];
    NSLayoutConstraint *constraint6 = [NSLayoutConstraint constraintWithItem:redView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:blueView attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
    NSLayoutConstraint *constraint7 = [NSLayoutConstraint constraintWithItem:redView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:blueView attribute:NSLayoutAttributeLeft multiplier:1 constant:0];
    NSLayoutConstraint *constraint8 = [NSLayoutConstraint constraintWithItem:yellowView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:blueView attribute:NSLayoutAttributeWidth multiplier:1 constant:0];
    NSLayoutConstraint *constraint9 = [NSLayoutConstraint constraintWithItem:yellowView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:100];
    NSLayoutConstraint *constraint10 = [NSLayoutConstraint constraintWithItem:yellowView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1 constant:0];
    constraint10.priority = 750;
    NSLayoutConstraint *constraint11 = [NSLayoutConstraint constraintWithItem:yellowView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:blueView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
    constraint11.priority = 500;
    NSLayoutConstraint *constraint12 = [NSLayoutConstraint constraintWithItem:yellowView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:redView attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
    NSLayoutConstraint *constraint13 = [NSLayoutConstraint constraintWithItem:slider attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
    NSLayoutConstraint *constraint14 = [NSLayoutConstraint constraintWithItem:slider attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1 constant:inset];
    NSLayoutConstraint *constraint15 = [NSLayoutConstraint constraintWithItem:slider attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1 constant:-inset];
    redView.translatesAutoresizingMaskIntoConstraints = NO;
    yellowView.translatesAutoresizingMaskIntoConstraints = NO;
    blueView.translatesAutoresizingMaskIntoConstraints = NO;
    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    slider.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addConstraints:@[constraint0, constraint1, constraint2, constraint3, constraint4, constraint5, constraint6, constraint7, constraint8, constraint9, constraint10, constraint11, constraint12, constraint13, constraint14, constraint15]];
    
    NSLog(@"%@", self.view.constraints);

}

- (UIView*)addViewWithColor:(UIColor*)color
{
    UIView* blueView = [[UIView alloc] init];
    blueView.backgroundColor = color;
    [self.view addSubview:blueView];
    blueView.layer.borderWidth = 2;
    blueView.layer.borderColor = [UIColor purpleColor].CGColor;
    return blueView;
}

- (void)valueChanged:(UISlider*)sender
{
    self.constraint.constant = sender.value;
}


@end
