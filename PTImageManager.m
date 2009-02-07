//
//  PTImageManager.m
//  Pwitter
//
//  Created by Akihiro Noguchi on 4/02/09.
//  Copyright 2009 Aki. All rights reserved.
//

#import "PTImageManager.h"


@implementation PTImageManager

- (id)init
{
	if ((self = [super init])) {
		[self initResource];
	}
	return self;
}

- (void)dealloc {
	[self clearResource];
	[super dealloc];
}

- (void)initResource {
	fImageLocationForReq = [[NSMutableDictionary alloc] init];
	fImageReqForLocation = [[NSMutableDictionary alloc] init];
	fStatusBoxesForReq = [[NSMutableDictionary alloc] init];
	fUserImageCache = [[NSMutableDictionary alloc] init];
}

- (void)clearResource {
	if (fImageLocationForReq) [fImageLocationForReq release];
	if (fImageReqForLocation) [fImageReqForLocation release];
	if (fStatusBoxesForReq) [fStatusBoxesForReq release];
	if (fUserImageCache) [fUserImageCache release];
}

- (void)requestFailed:(NSString *)aIdentifier {
	[fStatusBoxesForReq removeObjectForKey:aIdentifier];
	[fImageReqForLocation removeObjectForKey:[fImageLocationForReq objectForKey:aIdentifier]];
	[fImageLocationForReq removeObjectForKey:aIdentifier];
}

- (NSImage *)maskImage:(NSImage *)aImage {
	NSImage *lNewImage = [[NSImage imageNamed:@"icon_mask"] copy];
	[lNewImage lockFocus];
	[aImage drawInRect: NSMakeRect(0, 0, 48, 48) 
			  fromRect: NSMakeRect(0, 0, [aImage size].width, [aImage size].height) 
			 operation: NSCompositeSourceIn 
			  fraction: 1.0];
	[lNewImage unlockFocus];
	return [lNewImage autorelease];
}

- (void)addImage:(NSImage *)aImage forRequest:(NSString *)aIdentifier {
	NSImage *lNewImage = [self maskImage:aImage];
	PTStatusBox *lCurrentBox;
	for (lCurrentBox in [fStatusBoxesForReq objectForKey:aIdentifier]) {
		lCurrentBox.userImage = lNewImage;
	}
	NSString *lImageLocation = [fImageLocationForReq objectForKey:aIdentifier];
	[fUserImageCache setObject:lNewImage forKey:lImageLocation];
	[fStatusBoxesForReq removeObjectForKey:aIdentifier];
	[fImageReqForLocation removeObjectForKey:lImageLocation];
	[fImageLocationForReq removeObjectForKey:aIdentifier];
}

- (void)requestUserImage:(NSString *)aImageLocation forRequest:(NSString *)aIdentifier {
	[fImageReqForLocation setObject:aIdentifier forKey:aImageLocation];
	[fImageLocationForReq setObject:aImageLocation forKey:aIdentifier];
	[fStatusBoxesForReq setObject:[[[NSMutableArray alloc] init] autorelease] forKey:aIdentifier];
}

- (void)registerStatusBox:(PTStatusBox *)aBox forLocation:(NSString *)aImageLocation {
	NSMutableArray *lRequestedBoxes = [fStatusBoxesForReq objectForKey:[fImageReqForLocation objectForKey:aImageLocation]];
	[lRequestedBoxes addObject:aBox];
}

- (NSImage *)fetchImage:(NSString *)aImageLocation {
	return [fUserImageCache objectForKey:aImageLocation];
}

- (BOOL)isRequestedImage:(NSString *)aImageLocation {
	return [fImageReqForLocation objectForKey:aImageLocation] != nil;
}

@end
