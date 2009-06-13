//
//  PTReadManager.h
//  Pwitter
//
//  Created by Akihiro Noguchi on 7/02/09.
//  Copyright 2009 Aki. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PTReadManager : NSObject {
	NSDictionary *fUnreads;
}
+ (PTReadManager *)getInstance;
- (void)setUnreadDict:(NSDictionary *)aDict;
- (BOOL)isUpdateRead:(unsigned long)aId;

@end
