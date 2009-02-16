#import <Cocoa/Cocoa.h>

#define PT_URLEXTRACTOR_PREFIX_HTTP @"http://"
#define PT_URLEXTRACTOR_PREFIX_HTTPS @"https://"
#define PT_URLEXTRACTOR_PREFIX_FTP @"ftp://"
#define PT_URLEXTRACTOR_PREFIX_ID @"@"

// Derived from NatsuLion

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
