//
//  PTStatusFormatter.m
//  Pwitter
//
//  Created by Akihiro Noguchi on 4/01/09.
//  Copyright 2009 Aki. All rights reserved.
//

#import "PTStatusFormatter.h"
#import <AutoHyperlinks/AHHyperlinkScanner.h>
#import <AutoHyperlinks/AHMarkedHyperlink.h>


@implementation PTStatusFormatter

+ (void)processLinks:(NSMutableAttributedString *)aTargetString {
//	NSString *lString = [aTargetString string];
//	NSRange lSearchRange = NSMakeRange(0, [lString length]);
//	NSRange lFoundRange;
//	lFoundRange = [lString rangeOfString:@"http://" options:0 range:lSearchRange];
//	if (lFoundRange.length > 0) {
//		NSURL* lUrl;
//		NSDictionary* lLinkAttributes;
//		NSRange lEndOfURLRange;
//		lSearchRange.location = lFoundRange.location + lFoundRange.length;
//		lSearchRange.length = [lString length] - lSearchRange.location;
//		lEndOfURLRange = [lString rangeOfCharacterFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet] 
//												  options:0 range:lSearchRange];
//		if (lEndOfURLRange.length == 0)
//			lEndOfURLRange.location = [lString length] - 1;
//		lFoundRange.length = lEndOfURLRange.location - lFoundRange.location + 1;
//		lUrl = [NSURL URLWithString:[lString substringWithRange:lFoundRange]];
//		lLinkAttributes = [NSDictionary dictionaryWithObjectsAndKeys:lUrl, NSLinkAttributeName,
//						   [NSNumber numberWithInt:NSSingleUnderlineStyle], NSUnderlineStyleAttributeName,
//						   [NSColor cyanColor], NSForegroundColorAttributeName,
//						   nil];
//		[aTargetString addAttributes:lLinkAttributes range:lFoundRange];
//	}
	AHHyperlinkScanner *lScanner = [AHHyperlinkScanner hyperlinkScannerWithAttributedString:aTargetString];
	[aTargetString setAttributedString:[lScanner linkifiedString]];
	AHMarkedHyperlink *lCurrentURI = [lScanner nextURI];
	while (lCurrentURI != nil) {
		NSDictionary *lLinkAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:NSSingleUnderlineStyle], NSUnderlineStyleAttributeName,
										 [NSColor cyanColor], NSForegroundColorAttributeName,
										 nil];
		[aTargetString addAttributes:lLinkAttributes range:[lCurrentURI range]];
		lCurrentURI = [lScanner nextURI];
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
	NSMutableAttributedString *lNewMessage = [[NSMutableAttributedString alloc] initWithString:lUnescaped];
	[lUnescaped release];
	[lNewMessage beginEditing];
	NSDictionary *lMessageAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[NSColor whiteColor], NSForegroundColorAttributeName, 
										[NSFont fontWithName:@"Helvetica" size:12.0], NSFontAttributeName, 
										nil];
	[lNewMessage addAttributes:lMessageAttributes range:NSMakeRange(0, [lNewMessage length])];
	[PTStatusFormatter processLinks:lNewMessage];
	[PTStatusFormatter detectReplyLinks:lNewMessage];
	[lNewMessage endEditing];
	return [lNewMessage autorelease];
}

+ (NSMutableAttributedString *)createUserLabel:(NSString *)aScreenName name:(NSString *)aName {
	NSString *lTempUserLabel = [NSString stringWithFormat:@"%@ / %@", aScreenName, aName];
	NSMutableAttributedString *lUserLabel = [[NSMutableAttributedString alloc] initWithString:lTempUserLabel];
	[lUserLabel beginEditing];
	NSURL *lUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://twitter.com/%@", aScreenName]];
	NSDictionary *lLinkAttributes = [NSDictionary dictionaryWithObjectsAndKeys:lUrl, NSLinkAttributeName,
									 [NSNumber numberWithInt:NSSingleUnderlineStyle], NSUnderlineStyleAttributeName,
									 [NSColor whiteColor], NSForegroundColorAttributeName,
									 nil];
	[lUserLabel addAttributes:lLinkAttributes range:NSMakeRange(0, [lUserLabel length])];
	[lUserLabel endEditing];
	return [lUserLabel autorelease];
}

+ (NSMutableAttributedString *)createErrorLabel {
	NSMutableAttributedString *lErrorLabel = [[NSMutableAttributedString alloc] initWithString:@"Twitter Error:"];
	[lErrorLabel beginEditing];
	NSDictionary *lMessageAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[NSColor whiteColor], NSForegroundColorAttributeName, 
										[NSNumber numberWithInt:NSSingleUnderlineStyle], NSUnderlineStyleAttributeName, 
										nil];
	[lErrorLabel addAttributes:lMessageAttributes range:NSMakeRange(0, [lErrorLabel length])];
	[lErrorLabel endEditing];
	return [lErrorLabel autorelease];
}

+ (NSMutableAttributedString *)createErrorMessage:(NSError *)aError {
	NSMutableAttributedString *lFinalString = [[NSMutableAttributedString alloc] initWithString:[aError localizedDescription]];
	[lFinalString beginEditing];
	NSDictionary *lMessageAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[NSColor whiteColor], NSForegroundColorAttributeName, 
										[NSFont fontWithName:@"Helvetica" size:12.0], NSFontAttributeName, 
										nil];
	[lFinalString addAttributes:lMessageAttributes range:NSMakeRange(0, [lFinalString length])];
	[lFinalString endEditing];
	return [lFinalString autorelease];
}

@end
