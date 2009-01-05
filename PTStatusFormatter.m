//
//  PTStatusFormatter.m
//  Pwitter
//
//  Created by Akihiro Noguchi on 4/01/09.
//  Copyright 2009 Aki. All rights reserved.
//

#import "PTStatusFormatter.h"


@implementation PTStatusFormatter

+ (void)processLinks:(NSMutableAttributedString *)aTargetString {
	NSString* lString = [aTargetString string];
	NSRange lSearchRange = NSMakeRange(0, [lString length]);
	NSRange lFoundRange;
	lFoundRange = [lString rangeOfString:@"http://" options:0 range:lSearchRange];
	if (lFoundRange.length > 0) {
		NSURL* lUrl;
		NSDictionary* lLinkAttributes;
		NSRange lEndOfURLRange;
		lSearchRange.location = lFoundRange.location + lFoundRange.length;
		lSearchRange.length = [lString length] - lSearchRange.location;
		lEndOfURLRange = [lString rangeOfCharacterFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet] 
												  options:0 range:lSearchRange];
		if (lEndOfURLRange.length == 0)
			lEndOfURLRange.location = [lString length] - 1;
		lFoundRange.length = lEndOfURLRange.location - lFoundRange.location + 1;
		lUrl = [NSURL URLWithString:[lString substringWithRange:lFoundRange]];
		lLinkAttributes = [NSDictionary dictionaryWithObjectsAndKeys:lUrl, NSLinkAttributeName,
						   [NSNumber numberWithInt:NSSingleUnderlineStyle], NSUnderlineStyleAttributeName,
						   [NSColor cyanColor], NSForegroundColorAttributeName,
						   nil];
		[aTargetString addAttributes:lLinkAttributes range:lFoundRange];
	}
}

+ (void)detectReplyLinks:(NSMutableAttributedString *)aMessage {
	NSArray *lSeparated = [[aMessage string] componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	NSString *lCurrentString;
	int lCurrentIndex = 0;
	int lReplyCount = 0;
	for (lCurrentString in lSeparated) {
		if ([lCurrentString length] > 0 && [lCurrentString characterAtIndex:0] == '@') {
			lReplyCount++;
			NSString *lReplyTarget = [lCurrentString substringFromIndex:1];
			NSURL *lUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://twitter.com/%@", lReplyTarget]];
			NSDictionary *lLinkAttributes = [NSDictionary dictionaryWithObjectsAndKeys:lUrl, NSLinkAttributeName,
											 [NSNumber numberWithInt:NSSingleUnderlineStyle], NSUnderlineStyleAttributeName,
											 [NSColor cyanColor], NSForegroundColorAttributeName,
											 nil];
			[aMessage addAttributes:lLinkAttributes range:NSMakeRange(lCurrentIndex, [lCurrentString length])];
		}
		lCurrentIndex += [lCurrentString length] + 1;
	}
}

+ (NSMutableAttributedString *)formatStatusMessage:(NSString *)aMessage {
	NSString *lUnescaped = (NSString *)CFXMLCreateStringByUnescapingEntities(nil, (CFStringRef)aMessage, nil);
	NSMutableAttributedString *lNewMessage = [[[NSMutableAttributedString alloc] initWithString:lUnescaped] autorelease];
	[lNewMessage addAttribute:NSForegroundColorAttributeName 
						value:[NSColor whiteColor] 
						range:NSMakeRange(0, [lNewMessage length])];
	[lNewMessage addAttribute:NSFontAttributeName 
						value:[NSFont fontWithName:@"Helvetica" size:10.0] 
						range:NSMakeRange(0, [lNewMessage length])];
	[PTStatusFormatter processLinks:lNewMessage];
	[PTStatusFormatter detectReplyLinks:lNewMessage];
	return lNewMessage;
}

+ (NSMutableAttributedString *)createUserLabel:(NSString *)aScreenName name:(NSString *)aName {
	NSString *lTempUserLabel = [NSString stringWithFormat:@"%@ / %@", aScreenName, aName];
	NSMutableAttributedString *lUserLabel = [[[NSMutableAttributedString alloc] initWithString:lTempUserLabel] autorelease];
	NSURL *lUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://twitter.com/%@", aScreenName]];
	NSDictionary *lLinkAttributes = [NSDictionary dictionaryWithObjectsAndKeys:lUrl, NSLinkAttributeName,
									 [NSNumber numberWithInt:NSSingleUnderlineStyle], NSUnderlineStyleAttributeName,
									 [NSColor whiteColor], NSForegroundColorAttributeName,
									 nil];
	[lUserLabel addAttributes:lLinkAttributes range:NSMakeRange(0, [lUserLabel length])];
	return lUserLabel;
}

+ (NSMutableAttributedString *)createErrorLabel {
	NSMutableAttributedString *lErrorLabel = [[[NSMutableAttributedString alloc] initWithString:@"Twitter Error:"] autorelease];
	[lErrorLabel addAttribute:NSForegroundColorAttributeName 
						value:[NSColor whiteColor] 
						range:NSMakeRange(0, [lErrorLabel length])];
	[lErrorLabel addAttribute:NSUnderlineStyleAttributeName 
						value:[NSNumber numberWithInt:NSSingleUnderlineStyle] 
						range:NSMakeRange(0, [lErrorLabel length])];
	return lErrorLabel;
}

+ (NSMutableAttributedString *)createErrorMessage:(NSError *)aError {
	NSMutableAttributedString *lFinalString = [[[NSMutableAttributedString alloc] initWithString:[aError localizedDescription]] autorelease];
	[lFinalString addAttribute:NSForegroundColorAttributeName 
						 value:[NSColor whiteColor] 
						 range:NSMakeRange(0, [lFinalString length])];
	[lFinalString addAttribute:NSFontAttributeName 
						 value:[NSNumber numberWithInt:NSSingleUnderlineStyle] 
						 range:NSMakeRange(0, [lFinalString length])];
	[lFinalString addAttribute:NSFontAttributeName 
						 value:[NSFont fontWithName:@"Helvetica" size:10.0] 
						 range:NSMakeRange(0, [lFinalString length])];
	return lFinalString;
}

@end
