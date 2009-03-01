#import "PTURLUtils.h"

// derived from natsulion
// Copyright (c) 2007-2008, Akira Ueda

@implementation PTURLUtils

+ (id) utils {
    return [[[[self class] alloc] init] autorelease];
}

- (NSArray*) tokenize:(NSString*)aString acceptedChars:(NSCharacterSet*)acceptedChars prefix:(NSArray*)prefixes {
    
    NSMutableArray *back = [NSMutableArray arrayWithCapacity:10];
	
    NSString *prefix;
    
    NSRange startRange = NSMakeRange(NSNotFound, 0);
    for (NSString *p in prefixes) {
        NSRange r = [aString rangeOfString:p];
        if (r.location != NSNotFound && (startRange.location == NSNotFound || r.location < startRange.location)) {
            startRange = r;
            prefix = p;
        }
    }
    
    if (startRange.location == NSNotFound) {
        if ([aString length] > 0) {
            [back addObject:aString];
        }
        return back;
    }
	
    if (startRange.location > 0) {
        [back addObject:[aString substringWithRange:NSMakeRange(0, startRange.location)]];
    }
    
    NSRange searchRange = NSMakeRange(startRange.location + [prefix length], 1);
    while (searchRange.location < [aString length]) {
        NSRange r = [aString rangeOfCharacterFromSet:acceptedChars options:0 range:searchRange];
        if (r.location == NSNotFound) {
            break;
        }
        searchRange.location += r.length;
    }
    
    NSRange targetRange = NSMakeRange(startRange.location, searchRange.location - startRange.location);
    NSString *extracted = [aString substringWithRange:targetRange];
	//    NSLog(@"extracted: %@", [aString substringWithRange:targetRange]);
    [back addObject:extracted];
    
    NSArray *subBack = [self tokenize:[aString substringWithRange:
                                       NSMakeRange(targetRange.location + targetRange.length, [aString length] - (targetRange.location + targetRange.length))]
						acceptedChars:acceptedChars
							   prefix:prefixes];
    
    [back addObjectsFromArray:subBack];
    
    return back;
}

- (NSArray*) tokenizeByURL:(NSString*)aString {
    
    NSCharacterSet *acceptedCharacterSet = [NSCharacterSet characterSetWithCharactersInString:
                                            @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789;/?:@&=+$,-_.!~*'%"];
    
    NSMutableArray *back = [NSMutableArray arrayWithCapacity:10];
    NSArray *tokens = [self tokenize:aString 
                       acceptedChars:acceptedCharacterSet
                              prefix:[NSArray arrayWithObjects:NTLN_URLEXTRACTOR_PREFIX_HTTP, NTLN_URLEXTRACTOR_PREFIX_HTTPS, NTLN_URLEXTRACTOR_PREFIX_FTP, nil]];
    
    // last dot in URL should not a part of URL, so devide it to an other token.
    for (NSString *s in tokens) {
        if (([s rangeOfString:NTLN_URLEXTRACTOR_PREFIX_HTTP].location == 0 || 
			 [s rangeOfString:NTLN_URLEXTRACTOR_PREFIX_HTTPS].location == 0 || 
			 [s rangeOfString:NTLN_URLEXTRACTOR_PREFIX_FTP].location == 0) &&
            [s characterAtIndex:([s length] - 1)] == '.') {
            [back addObject:[s substringToIndex:([s length] - 1)]];
            [back addObject:@"."];
        } else {
            [back addObject:s];
        }
    }
    
    return back;
}

- (NSArray*) tokenizeByID:(NSString*)aString {
	
    NSCharacterSet *acceptedCharacterSet = [NSCharacterSet characterSetWithCharactersInString:
                                            @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_"];
	
    return [self tokenize:aString 
            acceptedChars:acceptedCharacterSet
                   prefix:[NSArray arrayWithObject:NTLN_URLEXTRACTOR_PREFIX_ID]];
    
}

- (NSArray*) tokenizeByAll:(NSString*)aString {
    NSMutableArray *back = [NSMutableArray arrayWithCapacity:100];
	
    NSArray *tokensById = [self tokenizeByID:aString];
    
    int i;
    for (i = 0; i < [tokensById count]; i++) {
        [back addObjectsFromArray:[self tokenizeByURL:[tokensById objectAtIndex:i]]];
    }
    
    return back;
}

- (BOOL) isURLToken:(NSString*)token {
    if (([token rangeOfString:NTLN_URLEXTRACTOR_PREFIX_HTTP].location == 0 && [token length] > [NTLN_URLEXTRACTOR_PREFIX_HTTP length])
        || ([token rangeOfString:NTLN_URLEXTRACTOR_PREFIX_HTTPS].location == 0 && [token length] > [NTLN_URLEXTRACTOR_PREFIX_HTTPS length])
		|| ([token rangeOfString:NTLN_URLEXTRACTOR_PREFIX_FTP].location == 0 && [token length] > [NTLN_URLEXTRACTOR_PREFIX_FTP length])) {
        return TRUE;
    }
    return FALSE;
}

- (BOOL) isIDToken:(NSString*)token {
    if ([token rangeOfString:NTLN_URLEXTRACTOR_PREFIX_ID].location == 0  && [token length] > [NTLN_URLEXTRACTOR_PREFIX_ID length]) {
        return TRUE;
    }
    return FALSE;
}

- (BOOL) isWhiteSpace:(NSString*)aString {
    unichar space = [@" " characterAtIndex:0];
    int i;
    for (i = 0; i < [aString length]; i++) {
        unichar c = [aString characterAtIndex:i];
        if (c != space) {
            break;
        }
    }
    
    if (i == [aString length]) {
        return TRUE;
    }
    return FALSE;
}

@end
