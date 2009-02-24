//
//  PTStatusCollectionItem.m
//  Pwitter
//
//  Created by Akihiro Noguchi on 26/12/08.
//  Copyright 2008 Aki. All rights reserved.
//

#import "PTStatusCollectionItem.h"
#import "PTStatusEntityView.h"
#import "PTStatusBox.h"
#import "PTStatusTextField.h"
#import "PTPreferenceManager.h"


@implementation PTStatusCollectionItem

- (void)setSelected:(BOOL)aFlag {
	[super setSelected:aFlag];
	PTStatusEntityView* lView = (PTStatusEntityView* )[self view];
	if([lView isKindOfClass:[PTStatusEntityView class]]) {
		[lView setSelected:aFlag];
		[lView setNeedsDisplay:YES];
	}
}

- (void)setView:(NSView *)aView {
	[(PTStatusEntityView *)aView setColItem:self];
	[super setView:aView];
}

- (void)setRepresentedObject:(id)object
{
	[fEntityColor unbind:@"textColor"];
	[fIconView unbind:@"value"];
	[fStatusMessage unbind:@"value"];
	[fTime unbind:@"value"];
	[fUnreadStatus unbind:@"value"];
	[fUserId unbind:@"value"];
	if (object) {
		[fEntityColor bind:@"textColor" toObject:self withKeyPath:@"representedObject.entityColor" options:nil];
		[fIconView bind:@"value" toObject:self withKeyPath:@"representedObject.userImage" options:nil];
		[fStatusMessage bind:@"value" toObject:self withKeyPath:@"representedObject.statusMessage" options:nil];
		[fTime bind:@"value" toObject:self withKeyPath:@"representedObject.time" options:[NSDictionary dictionaryWithObjectsAndKeys:@"DateToStringTransformer", NSValueTransformerNameBindingOption, 
																						  nil]];
		[fUnreadStatus bind:@"value" toObject:self withKeyPath:@"representedObject.readFlag" options:[NSDictionary dictionaryWithObjectsAndKeys:@"ReadImageTransformer", NSValueTransformerNameBindingOption, 
																									  nil]];
		[fUserId bind:@"value" toObject:self withKeyPath:@"representedObject.userId" options:nil];
	}
	[self willChangeValueForKey:@"representedObject"];
	[super setRepresentedObject:object];
	[self didChangeValueForKey:@"representedObject"];
}

- (NSSize)sizeForViewWithProposedSize:(NSSize)aNewSize
{
	if (![self isAnimated]) {
		NSRect lTempRect = [view frame];
		lTempRect.size.width = aNewSize.width;
		[[self view] setFrame:lTempRect];
	}
	if ([[PTPreferenceManager sharedInstance] useMiniView]) {
		if ([super isSelected]) {
			if (aNewSize.width != fOldWidth || !fIsOpen) {
				NSSize lNewSize = [fStatusMessage minSizeForContent];
				NSRect lNewFrame = [fStatusMessage frame];
				lNewFrame.origin.y -= lNewSize.height - lNewFrame.size.height;
				lNewFrame.size.height = lNewSize.height;
				[fStatusMessage setFrame:lNewFrame];
				fIsOpen = YES;
				fCachedSize = NSMakeSize(aNewSize.width, lNewSize.height + 24);
				fOldWidth = aNewSize.width;
			}
			return fCachedSize;
		} else {
			if (aNewSize.width != fOldWidth || fIsOpen) {
				if (fIsOpen) {
					NSRect lNewFrame = [fStatusMessage frame];
					lNewFrame.origin.y -= 16 - lNewFrame.size.height;
					lNewFrame.size.height = 16;
					[fStatusMessage setFrame:lNewFrame];
					fIsOpen = NO;
				}
				fCachedSize = NSMakeSize(aNewSize.width, 38);
				fOldWidth = aNewSize.width;
			}
			return fCachedSize;
		}
	} else {
		if (aNewSize.width != fOldWidth) {
			NSRect lNewFrame = [fStatusMessage frame];
			NSSize lNewSize = [fStatusMessage minSizeForContent];
			lNewFrame.origin.y -= lNewSize.height - lNewFrame.size.height;
			lNewFrame.size.height = lNewSize.height;
			[fStatusMessage setFrame:lNewFrame];
			float lNewHeight = lNewSize.height + 26.0;
			if (lNewHeight < 76.0) lNewHeight = 76.0;
			fCachedSize = NSMakeSize(aNewSize.width, lNewHeight);
			fOldWidth = aNewSize.width;
		}
		return fCachedSize;
	}
}

- (id)initWithCoder:(NSCoder *)coder
{
	self = [super initWithCoder:coder];
	fIconView = [coder decodeObjectForKey:@"IconView"];
	fStatusMessage = [coder decodeObjectForKey:@"StatusMessage"];
	fUserId = [coder decodeObjectForKey:@"UserId"];
	fTime = [coder decodeObjectForKey:@"Time"];
	fUnreadStatus = [coder decodeObjectForKey:@"Unread"];
	fEntityColor = [coder decodeObjectForKey:@"Color"];
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
	[super encodeWithCoder:coder];
	[coder encodeConditionalObject:fIconView forKey:@"IconView"];
	[coder encodeConditionalObject:fStatusMessage forKey:@"StatusMessage"];
	[coder encodeConditionalObject:fUserId forKey:@"UserId"];
	[coder encodeConditionalObject:fTime forKey:@"Time"];
	[coder encodeConditionalObject:fUnreadStatus forKey:@"Unread"];
	[coder encodeConditionalObject:fEntityColor forKey:@"Color"];
}

@end
