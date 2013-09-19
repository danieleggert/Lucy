//
// Created by chris on 9/18/13.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

@interface LayoutConstraint : NSObject


@property (strong) NSArray* firstItem;
@property (assign) NSLayoutAttribute firstAttribute;
@property (assign) NSLayoutRelation relation;
@property (strong) NSArray* secondItem;
@property (assign) NSLayoutAttribute secondAttribute;
@property (assign) id multiplier;
@property (assign) id constant;
@property (strong) NSString* targetIdentifier;
@property (assign) id priority;

+ (instancetype)constraintWithItem:(id)firstItem attribute:(NSLayoutAttribute)firstAttribute relatedBy:(NSLayoutRelation)relation toItem:(id)secondItem attribute:(NSLayoutAttribute)secondAttribute multiplier:(id)multiplier constant:(id)constant targetIdentifier:(NSString*)targetIdentifier;

- (BOOL)isEqualToConstraint:(LayoutConstraint*)constraint;

@end
