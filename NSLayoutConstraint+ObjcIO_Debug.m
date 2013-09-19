//
//  NSLayoutConstraint+ObjcIO_Debug.m
//  
//
//  Created by Daniel Eggert on 19/09/13.
//
//

#import "NSLayoutConstraint+ObjcIO_Debug.h"

#import <objc/runtime.h>


static int const SourceCodeKey;
static void MethodSwizzle(Class c, SEL origSEL, SEL overrideSEL);


@implementation NSLayoutConstraint (ObjcIO_Debug)

// We're doing some nasty method swizzling here to make debugging of constraints easier.
+ (void)load;
{
    MethodSwizzle(self, @selector(description), @selector(objcioOverride_description));
}

- (void)objcio_associateSourceCodeLine:(NSString *)sourceCode;
{
    objc_setAssociatedObject(self, &SourceCodeKey, sourceCode, OBJC_ASSOCIATION_COPY);
}

- (NSString *)objcioOverride_description
{
    // call through to the original, really
    NSString *description = [self objcioOverride_description];
    NSString *sourceCode = objc_getAssociatedObject(self, &SourceCodeKey);
    if (sourceCode == nil) {
        return description;
    }
    return [description stringByAppendingFormat:@" '%@'", sourceCode];
}

@end



// C.f. <http://www.mikeash.com/pyblog/friday-qa-2010-01-29-method-replacement-for-fun-and-profit.html>
static void MethodSwizzle(Class c, SEL origSEL, SEL overrideSEL)
{
    Method origMethod = class_getInstanceMethod(c, origSEL);
    Method overrideMethod = class_getInstanceMethod(c, overrideSEL);
    if(class_addMethod(c, origSEL, method_getImplementation(overrideMethod), method_getTypeEncoding(overrideMethod))) {
        class_replaceMethod(c, overrideSEL, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
    } else {
        method_exchangeImplementations(origMethod, overrideMethod);
    }
}
