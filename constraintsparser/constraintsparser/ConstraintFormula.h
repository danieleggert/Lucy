//
// Created by Florian on 18.09.13.
//
// To change the template use AppCode | Preferences | File Templates.
//



@interface ConstraintFormula : NSObject

@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, copy) NSString *targetIdentifier;
@property (nonatomic, copy) NSString *line;
@property (nonatomic, copy) NSString *view1;
@property (nonatomic, copy) NSString *view2;
@property (nonatomic) NSInteger attribute1;
@property (nonatomic) NSInteger attribute2;
@property (nonatomic) NSInteger relation;
@property (nonatomic) id priority;
@property (nonatomic) id multiplier;
@property (nonatomic) id constant;

- (instancetype)initWithLine:(NSString *)line;
- (void)parse:(NSError **)error;
- (NSString *)layoutConstraintCode;

@end
