//
// Created by Florian on 18.09.13.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>


@interface AutoLayoutCommentProcessor : NSObject

- (instancetype)initWithComment:(NSString *)comment;
- (NSString *)process;

- (NSString *)code;
@end
