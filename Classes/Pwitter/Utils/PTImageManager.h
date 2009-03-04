//
//  PTImageManager.h
//  Pwitter
//
//  Created by Akihiro Noguchi on 4/02/09.
//  Copyright 2009 Aki. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PTStatusBox.h"


@interface PTImageManager : NSObject {
	NSMutableDictionary *fImageLocationForReq;
	NSMutableDictionary *fImageReqForLocation;
	NSMutableDictionary *fStatusBoxesForReq;
	NSMutableDictionary *fUserImageCache;
}
- (void)initResource;
- (void)clearResource;
- (void)requestFailed:(NSString *)aIdentifier;
- (NSImage *)maskImage:(NSImage *)aImage;
- (void)addImage:(NSImage *)aImage forRequest:(NSString *)aIdentifier;
- (void)requestUserImage:(NSString *)aImageLocation forRequest:(NSString *)aIdentifier;
- (void)registerStatusBox:(PTStatusBox *)aBox forLocation:(NSString *)aImageLocation;
- (NSImage *)fetchImage:(NSString *)aImageLocation;
- (BOOL)isRequestedImage:(NSString *)aImageLocation;
- (int)numberOfConnections;

@end
