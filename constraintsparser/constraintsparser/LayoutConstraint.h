//
// Created by chris on 9/18/13.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

@interface LayoutConstraint : NSObject


@property (strong) id firstItem;
@property (assign) NSLayoutAttribute firstAttribute;
@property (assign) NSLayoutRelation relation;
@property (strong) id secondItem;
@property (assign) NSLayoutAttribute secondAttribute;
@property (assign) CGFloat multiplier;
@property (assign) CGFloat constant;

+ (instancetype)constraintWithItem:(id)firstItem attribute:(NSLayoutAttribute)firstAttribute relatedBy:(NSLayoutRelation)relation toItem:(id)secondItem attribute:(NSLayoutAttribute)secondAttribute multiplier:(CGFloat)multiplier constant:(CGFloat)constant;

- (BOOL)isEqualToConstraint:(LayoutConstraint*)constraint;

@end
