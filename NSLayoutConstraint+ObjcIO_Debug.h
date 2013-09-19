//
//  NSLayoutConstraint+ObjcIO_Debug.h
//
//
//  Created by Daniel Eggert on 19/09/13.
//
//

#import <UIKit/UIKit.h>



@interface NSLayoutConstraint (ObjcIO_Debug)

- (void)objcio_associateSourceCodeLine:(NSString *)sourceCode;

@end
