//
// Created by chris on 9/19/13.
//

#import <Foundation/Foundation.h>


@interface Expression : NSObject

@property (nonatomic,strong) NSString* expression;

+ (instancetype)expressionWithExpression:(NSString*)expression;

@end
