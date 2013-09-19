//
// Created by Florian on 18.09.13.
//
// To change the template use AppCode | Preferences | File Templates.
//



#import "CommentReplacer.h"


@interface AutoLayoutCommentProcessor : NSObject <CommentParser>

- (id)codeForAddingConstraintsToSuperview;
@end
