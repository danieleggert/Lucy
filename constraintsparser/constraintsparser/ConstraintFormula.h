//
// Created by Florian on 18.09.13.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>


@interface ConstraintFormula : NSObject

@property (nonatomic, strong) NSString *targetIdentifier;
@property (nonatomic, strong) NSString *line;
@property (nonatomic, strong) NSString *view1;
@property (nonatomic, strong) NSString *view2;
@property (nonatomic) NSInteger attribute1;
@property (nonatomic) NSInteger attribute2;
@property (nonatomic) NSInteger relation;
@property (nonatomic) NSInteger priority;
@property (nonatomic) CGFloat multiplier;
@property (nonatomic) CGFloat constant;

- (instancetype)initWithLine:(NSString *)line;
- (void)parse:(NSError **)error;
- (NSString *)layoutConstraintCodeForSuperview:(NSString *)superview;

@end