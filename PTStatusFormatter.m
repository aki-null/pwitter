//
//  PTStatusFormatter.m
//  Pwitter
//
//  Created by Akihiro Noguchi on 4/01/09.
//  Copyright 2009 Aki. All rights reserved.
//

#import "PTStatusFormatter.h"
#import "PTURLUtils.h"

@interface NSAttributedString (Hyperlink)
+(id) hyperlinkFromString:(NSString*)inString URL:(NSURL*)aURL attributes:(NSDictionary*)attributes;
@end

@implementation NSAttributedString (Hyperlink)
+(id) hyperlinkFromString:(NSString*)inString URL:(NSURL*)aURL attributes:(NSDictionary*)attributes {
    NSMutableAttributedString* attrString = [[[NSMutableAttributedString alloc] initWithString:inString] autorelease];
    NSRange range = NSMakeRange(0, [attrString length]);
    [attrString addAttributes:attributes range:range];
    [attrString addAttribute:NSLinkAttributeName value:[aURL absoluteString] range:range];
    return attrString;
}
@end

@implementation PTStatusFormatter

+ (NSDictionary *)defaultLinkFontAttributes {
	return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:NSSingleUnderlineStyle], NSUnderlineStyleAttributeName, 
			[NSColor whiteColor], NSForegroundColorAttributeName, 
			[NSFont fontWithName:@"Helvetica" size:12.0], NSFontAttributeName, 
			nil];
}

+ (NSDictionary *)defaultFontAttributes {
	return [NSDictionary dictionaryWithObjectsAndKeys:[NSColor whiteColor], NSForegroundColorAttributeName, 
			[NSFont fontWithName:@"Helvetica" size:12.0], NSFontAttributeName, 
			nil];
}

+ (NSMutableAttributedString *)processLinks:(NSString *)aTargetString forBox:(PTStatusBox *)aBox {
	PTURLUtils *lUtils = [PTURLUtils utils];
    NSArray *lTokens = [lUtils tokenizeByAll:aTargetString];
    NSMutableAttributedString* lProcessedString = [[[NSMutableAttributedString alloc] init] autorelease];
    int i;
    for (i = 0; i < [lTokens count]; i++) {
        NSString *lToken = [lTokens objectAtIndex:i];
        if ([lUtils isURLToken:lToken]) {
			NSURL *lUrl = [NSURL URLWithString:lToken];
            [lProcessedString appendAttributedString:[NSAttributedString hyperlinkFromString:lToken 
																						 URL:lUrl 
																				  attributes:[self defaultLinkFontAttributes]]];
			if (!aBox.statusLink) aBox.statusLink = lUrl;
        } else if ([lUtils isIDToken:lToken]) {
            [lProcessedString appendAttributedString:
			 [NSAttributedString hyperlinkFromString:lToken
												 URL:[NSURL URLWithString:
													  [NSString stringWithFormat:@"http://twitter.com/%@", [lToken substringFromIndex:1]]]
										  attributes:[self defaultLinkFontAttributes]]];
        } else {
            NSMutableAttributedString *lAttrStr = [[[NSMutableAttributedString alloc] initWithString:lToken] autorelease];
            [lAttrStr setAttributes:[self defaultFontAttributes] range:NSMakeRange(0, [lAttrStr length])];
            [lProcessedString appendAttributedString:lAttrStr];
        }
    }
	return lProcessedString;
}

+ (NSMutableAttributedString *)formatStatusMessage:(NSString *)aMessage forBox:(PTStatusBox *)aBox {
	NSString *lUnescaped = (NSString *)CFXMLCreateStringByUnescapingEntities(nil, (CFStringRef)aMessage, nil);
	NSMutableAttributedString *lProcessedString = [PTStatusFormatter processLinks:lUnescaped forBox:aBox];
	[lUnescaped release];
	return lProcessedString;
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
	NSString *lErrorMessage;
	switch ([aError code]) {
		case 400:
			lErrorMessage = @"You have exceeded your rate limit.";
			break;
		case 401:
			lErrorMessage = @"Either you need to provide authentication credentials, or the credentials provided aren't valid.";
			break;
		case 404:
			lErrorMessage = @"Invalid resource requested.";
			break;
		case 500:
			lErrorMessage = @"Twitter server error.";
			break;
		case 502:
			lErrorMessage = @"Twitter servers are down or being upgraded";
			break;
		case 503:
			lErrorMessage = @"Twitter servers are up, but are overloaded with requests.";
			break;
		default:
			lErrorMessage = [aError localizedDescription];
			break;
	}
	if (!lErrorMessage) lErrorMessage = @"unknown error";
	NSMutableAttributedString *lFinalString = [[NSMutableAttributedString alloc] initWithString:lErrorMessage];
	[lFinalString beginEditing];
	[lFinalString addAttributes:[self defaultFontAttributes] range:NSMakeRange(0, [lFinalString length])];
	[lFinalString endEditing];
	return [lFinalString autorelease];
}

@end
