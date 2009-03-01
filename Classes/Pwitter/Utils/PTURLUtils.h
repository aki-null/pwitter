#import <Cocoa/Cocoa.h>

// derived from natsulion
// Copyright (c) 2007-2008, Akira Ueda

#define NTLN_URLEXTRACTOR_PREFIX_HTTP @"http://"
#define NTLN_URLEXTRACTOR_PREFIX_HTTPS @"https://"
#define NTLN_URLEXTRACTOR_PREFIX_FTP @"ftp://"
#define NTLN_URLEXTRACTOR_PREFIX_ID @"@"

@interface PTURLUtils : NSObject {
	
}
+ (id) utils;
- (NSArray*) tokenizeByAll:(NSString*)aString;
- (NSArray*) tokenizeByURL:(NSString*)aString;
- (NSArray*) tokenizeByID:(NSString*)aString;
- (BOOL) isURLToken:(NSString*)token;
- (BOOL) isIDToken:(NSString*)token;
- (BOOL) isWhiteSpace:(NSString*)aString;
@end
