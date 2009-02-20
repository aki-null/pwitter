//
//  PTStatusFormatter.h
//  Pwitter
//
//  Created by Akihiro Noguchi on 4/01/09.
//  Copyright 2009 Aki. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PTStatusBox.h"


@interface PTStatusFormatter : NSObject {

}
+ (NSMutableAttributedString *)formatStatusMessage:(NSString *)aMessage forBox:(PTStatusBox *)aBox;
+ (NSMutableAttributedString *)createUserLabel:(NSString *)aScreenName name:(NSString *)aName;
+ (NSMutableAttributedString *)createErrorLabel;
+ (NSMutableAttributedString *)createErrorMessage:(NSError *)aError;

@end
