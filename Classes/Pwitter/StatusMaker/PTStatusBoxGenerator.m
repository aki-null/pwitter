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
#import "PTDateToStringTransformer.h"
#import "PTReadStatusTransformer.h"
#import "PTTooltipTransformer.h"
#import "PTReadManager.h"
#import "PTColorManager.h"


@implementation PTStatusBoxGenerator

+ (void)initialize {
	PTDateToStringTransformer *lTransformer = [[[PTDateToStringTransformer alloc] init] autorelease];
	[NSValueTransformer setValueTransformer:lTransformer forName:@"DateToStringTransformer"];
	PTReadStatusTransformer *lReadTrans = [[[PTReadStatusTransformer alloc] init] autorelease];
	[NSValueTransformer setValueTransformer:lReadTrans forName:@"ReadImageTransformer"];
	PTTooltipTransformer *lToolTrans = [[[PTTooltipTransformer alloc] init] autorelease];
	[NSValueTransformer setValueTransformer:lToolTrans forName:@"TooltipTransformer"];
}

- (PTStatusBox *)constructStatusBox:(NSDictionary *)aStatusInfo isReply:(BOOL)aIsReply {
	NSLog(@"1");
	PTStatusBox *lNewBox = [[PTStatusBox alloc] init];
	NSLog(@"2");
	lNewBox.userId = [[aStatusInfo objectForKey:@"user"] objectForKey:@"screen_name"];
	NSLog(@"3");
	lNewBox.userName = [NSString stringWithFormat:@"%@ / %@", [[aStatusInfo objectForKey:@"user"] objectForKey:@"screen_name"], [[aStatusInfo objectForKey:@"user"] objectForKey:@"name"]];
	NSLog(@"4");
	NSDate *lReceivedTime = [aStatusInfo objectForKey:@"created_at"];
	NSLog(@"5");
	lNewBox.time = lReceivedTime;
	NSLog(@"6");
	lNewBox.statusMessage = [PTStatusFormatter formatStatusMessage:[aStatusInfo objectForKey:@"text"] forBox:lNewBox];
	NSLog(@"7");
	lNewBox.statusMessageString = [aStatusInfo objectForKey:@"text"];
	NSLog(@"8");
	lNewBox.userImage = [fMainController requestUserImage:[[aStatusInfo objectForKey:@"user"] objectForKey:@"profile_image_url"]
												   forBox:lNewBox];
	NSLog(@"9");
	NSString *lUrlStr = [[aStatusInfo objectForKey:@"user"] objectForKey:@"url"];
	NSLog(@"10");
	if ([lUrlStr length] != 0) {
		lNewBox.userHome = [NSURL URLWithString:lUrlStr];
	} else {
		lNewBox.userHome = nil;
	}
	NSLog(@"11");
	if (lNewBox.sType == NormalMessage) {
		if (aIsReply) {
			lNewBox.entityColor = [[PTColorManager sharedSingleton] replyColor];
			lNewBox.sType = ReplyMessage;
		} else {
			lNewBox.entityColor = [[PTColorManager sharedSingleton] tweetColor];
			lNewBox.sType = NormalMessage;
		}
	}
	NSLog(@"12");
	if ([[aStatusInfo objectForKey:@"favorited"] boolValue]) {
		lNewBox.entityColor = [[PTColorManager sharedSingleton] favoriteColor];
		lNewBox.fav = YES;
	}
	NSLog(@"13");
	lNewBox.searchString = [NSString stringWithFormat:@"%@ %@ %@",
							[[aStatusInfo objectForKey:@"user"] objectForKey:@"screen_name"], 
							[[aStatusInfo objectForKey:@"user"] objectForKey:@"name"], 
							[aStatusInfo objectForKey:@"text"]];
	NSLog(@"14");
	lNewBox.updateId = [[NSDecimalNumber decimalNumberWithString:[aStatusInfo valueForKeyPath:@"id"]] longLongValue];
	NSLog(@"15");
	lNewBox.replyId = [[NSDecimalNumber decimalNumberWithString:[aStatusInfo valueForKeyPath:@"in_reply_to_status_id"]] longLongValue];
	NSLog(@"16");
	lNewBox.replyUserId = [aStatusInfo objectForKey:@"in_reply_to_screen_name"];
	NSLog(@"17");
	lNewBox.readFlag = [[PTReadManager getInstance] isUpdateRead:lNewBox.updateId];
	NSLog(@"18");
	return [lNewBox autorelease];
}

- (PTStatusBox *)constructErrorBox:(NSError *)aError {
	PTStatusBox *lNewBox = [[PTStatusBox alloc] init];
	lNewBox.userName = @"Error:";
	lNewBox.userId = [NSString stringWithString:@"Error"];
	lNewBox.statusMessage = [PTStatusFormatter createErrorMessage:aError];
	lNewBox.statusMessageString = [lNewBox.statusMessage string];
	lNewBox.userImage = [NSImage imageNamed:@"console.png"];
	lNewBox.entityColor = [[PTColorManager sharedSingleton] errorColor];
	lNewBox.time = [NSDate date];
	lNewBox.userHome = nil;
	lNewBox.sType = ErrorMessage;
	lNewBox.searchString = [NSString stringWithFormat:@"Twitter Error: %@", 
							[aError localizedDescription]];
	lNewBox.readFlag = YES;
	return [lNewBox autorelease];
}

- (PTStatusBox *)constructMessageBox:(NSDictionary *)aStatusInfo {
	PTStatusBox *lNewBox = [[PTStatusBox alloc] init];
	lNewBox.userName = [NSString stringWithFormat:@"%@ / %@", [[aStatusInfo objectForKey:@"sender"] objectForKey:@"screen_name"], [[aStatusInfo objectForKey:@"sender"] objectForKey:@"name"]];
	lNewBox.userId = [[aStatusInfo objectForKey:@"sender"] objectForKey:@"screen_name"];
	lNewBox.time = [aStatusInfo objectForKey:@"created_at"];
	lNewBox.statusMessage = [PTStatusFormatter formatStatusMessage:[aStatusInfo objectForKey:@"text"] forBox:lNewBox];
	lNewBox.statusMessageString = [aStatusInfo objectForKey:@"text"];
	lNewBox.userImage = [fMainController requestUserImage:[[aStatusInfo objectForKey:@"sender"] objectForKey:@"profile_image_url"]
												   forBox:lNewBox];
	NSString *lUrlStr = [[aStatusInfo objectForKey:@"sender"] objectForKey:@"url"];
	if ([lUrlStr length] != 0) {
		lNewBox.userHome = [NSURL URLWithString:lUrlStr];
	} else {
		lNewBox.userHome = nil;
	}
	lNewBox.entityColor = [[PTColorManager sharedSingleton] messageColor];
	lNewBox.sType = DirectMessage;
	lNewBox.searchString = [NSString stringWithFormat:@"%@ %@ %@",
							[[aStatusInfo objectForKey:@"sender"] objectForKey:@"screen_name"], 
							[[aStatusInfo objectForKey:@"sender"] objectForKey:@"name"], 
							[aStatusInfo objectForKey:@"text"]];
	lNewBox.updateId = [[NSDecimalNumber decimalNumberWithString:[aStatusInfo valueForKeyPath:@"id"]] longLongValue];
	lNewBox.readFlag = [[PTReadManager getInstance] isUpdateRead:lNewBox.updateId];
	return [lNewBox autorelease];
}

@end
