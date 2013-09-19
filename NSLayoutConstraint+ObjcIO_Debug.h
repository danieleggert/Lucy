//
//  NSLayoutConstraint+ObjcIO_Debug.h
//
//
//  Created by Daniel Eggert on 19/09/13.
//
//

#import <UIKit/UIKit.h>



@interface NSLayoutConstraint (ObjcIO_Debug)

- (void)objcio_associateSourceCodeString:(NSString *)sourceCodeString;
- (void)objcio_associateSourceCodeFileAndLine:(NSString *)sourceCodeFileAndLine;

@property (readonly, nonatomic, copy) NSString *sourceCodeFileAndLine;

@end
