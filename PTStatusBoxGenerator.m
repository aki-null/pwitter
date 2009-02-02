//
//  PTStatusBoxGenerator.m
//  Pwitter
//
//  Created by Akihiro Noguchi on 4/01/09.
//  Copyright 2009 Aki. All rights reserved.
//

#import "PTStatusBoxGenerator.h"
#import "PTStatusFormatter.h"
#import "PTMain.h"


@implementation PTStatusBoxGenerator

- (void)awakeFromNib {
	fWarningImage = [NSImage imageNamed:@"console.png"];
}

- (PTStatusBox *)constructStatusBox:(NSDictionary *)aStatusInfo isReply:(BOOL)aIsReply {
	PTStatusBox *lNewBox = [[PTStatusBox alloc] init];
	lNewBox.userID = [[aStatusInfo objectForKey:@"user"] objectForKey:@"screen_name"];
	lNewBox.userName = [PTStatusFormatter createUserLabel:[[aStatusInfo objectForKey:@"user"] objectForKey:@"screen_name"] 
													 name:[[aStatusInfo objectForKey:@"user"] objectForKey:@"name"]];
	NSDate *lReceivedTime = [aStatusInfo objectForKey:@"created_at"];
	lNewBox.time = lReceivedTime;
	lNewBox.strTime = [lReceivedTime descriptionWithCalendarFormat:@"%H:%M:%S" 
														  timeZone:[NSTimeZone systemTimeZone] 
															locale:nil];
	lNewBox.statusMessage = [PTStatusFormatter formatStatusMessage:[aStatusInfo objectForKey:@"text"]];
	lNewBox.statusMessageLarge = [PTStatusFormatter enlargeStatusMessage:lNewBox];
	lNewBox.userImage = [fMainController requestUserImage:[[aStatusInfo objectForKey:@"user"] objectForKey:@"profile_image_url"]
												   forBox:lNewBox];
	NSString *lUrlStr = [[aStatusInfo objectForKey:@"user"] objectForKey:@"url"];
	if ([lUrlStr length] != 0) {
		lNewBox.userHome = [NSURL URLWithString:lUrlStr];
	} else {
		lNewBox.userHome = nil;
	}
	if (aIsReply) {
		lNewBox.entityColor = [NSColor colorWithCalibratedRed:0.8 green:0.28 blue:0.28 alpha:0.7];
		lNewBox.sType = ReplyMessage;
	} else {
		lNewBox.entityColor = [NSColor colorWithCalibratedRed:0.4 green:0.4 blue:0.4 alpha:0.7];
		lNewBox.sType = NormalMessage;
	}
	lNewBox.searchString = [NSString stringWithFormat:@"%@ %@ %@",
							[[aStatusInfo objectForKey:@"user"] objectForKey:@"screen_name"], 
							[[aStatusInfo objectForKey:@"user"] objectForKey:@"name"], 
							[aStatusInfo objectForKey:@"text"]];
	lNewBox.updateId = [[aStatusInfo objectForKey:@"id"] intValue];
	return [lNewBox autorelease];
}

- (PTStatusBox *)constructErrorBox:(NSError *)aError {
	PTStatusBox *lNewBox = [[PTStatusBox alloc] init];
	lNewBox.userName = [PTStatusFormatter createErrorLabel];
	lNewBox.userID = [NSString stringWithString:@"Twitter Error:"];
	lNewBox.statusMessage = [PTStatusFormatter createErrorMessage:aError];
	lNewBox.statusMessageLarge = [PTStatusFormatter enlargeStatusMessage:lNewBox];
	lNewBox.userImage = fWarningImage;
	lNewBox.entityColor = [NSColor colorWithCalibratedRed:0.4 green:0.4 blue:0.4 alpha:0.7];
	lNewBox.time = [NSDate date];
	lNewBox.strTime = [lNewBox.time descriptionWithCalendarFormat:@"%H:%M:%S" 
					   timeZone:[NSTimeZone systemTimeZone] 
					   locale:nil];
	lNewBox.userHome = nil;
	lNewBox.sType = ErrorMessage;
	lNewBox.searchString = [NSString stringWithFormat:@"Twitter Error: %@", 
							[aError localizedDescription]];
	return [lNewBox autorelease];
}

- (PTStatusBox *)constructMessageBox:(NSDictionary *)aStatusInfo {
	PTStatusBox *lNewBox = [[PTStatusBox alloc] init];
	lNewBox.userName = [PTStatusFormatter createUserLabel:[[aStatusInfo objectForKey:@"sender"] objectForKey:@"screen_name"] 
													 name:[[aStatusInfo objectForKey:@"sender"] objectForKey:@"name"]];
	lNewBox.userID = [[aStatusInfo objectForKey:@"sender"] objectForKey:@"screen_name"];
	lNewBox.time = [aStatusInfo objectForKey:@"created_at"];
	lNewBox.strTime = [lNewBox.time descriptionWithCalendarFormat:@"%H:%M:%S" 
					   timeZone:[NSTimeZone systemTimeZone] 
					   locale:nil];
	lNewBox.statusMessage = [PTStatusFormatter formatStatusMessage:[aStatusInfo objectForKey:@"text"]];
	lNewBox.statusMessageLarge = [PTStatusFormatter enlargeStatusMessage:lNewBox];
	lNewBox.userImage = [fMainController requestUserImage:[[aStatusInfo objectForKey:@"sender"] objectForKey:@"profile_image_url"]
												   forBox:lNewBox];
	NSString *lUrlStr = [[aStatusInfo objectForKey:@"sender"] objectForKey:@"url"];
	if ([lUrlStr length] != 0) {
		lNewBox.userHome = [NSURL URLWithString:lUrlStr];
	} else {
		lNewBox.userHome = nil;
	}
	lNewBox.entityColor = [NSColor colorWithCalibratedRed:0.4 green:0.5 blue:0.7 alpha:0.8];
	lNewBox.sType = DirectMessage;
	lNewBox.searchString = [NSString stringWithFormat:@"%@ %@ %@",
							[[aStatusInfo objectForKey:@"sender"] objectForKey:@"screen_name"], 
							[[aStatusInfo objectForKey:@"sender"] objectForKey:@"name"], 
							[aStatusInfo objectForKey:@"text"]];
	return [lNewBox autorelease];
}

@end
