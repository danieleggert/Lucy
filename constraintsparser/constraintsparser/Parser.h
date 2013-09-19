//
//  Parser.h
//  TwoDimensionalParser
//
//  Created by Chris Eidhof on 9/18/13.
//  Copyright (c) 2013 Chris Eidhof. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

@class Tokenizer;
@class LayoutConstraint;

@interface Parser : NSObject

- (LayoutConstraint*)parse:(NSString*)string;

@end
