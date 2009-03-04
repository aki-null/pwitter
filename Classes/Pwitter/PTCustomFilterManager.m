//
//  PTCustomFilterManager.m
//  Pwitter
//
//  Created by Akihiro Noguchi on 28/02/09.
//  Copyright 2009 Aki. All rights reserved.
//

#import "PTCustomFilterManager.h"
#import "PTPreferenceManager.h"
#import "PTMainActionHandler.h"


@implementation PTCustomFilterManager

- (void)awakeFromNib {
	NSDictionary *lCustomFilters = [[PTPreferenceManager sharedSingleton] customFilters];
	if (lCustomFilters) {
		fFilterSet = [lCustomFilters mutableCopy];
	} else {
		fFilterSet = [[NSMutableDictionary alloc] init];
	}
	[self loadCurrentFilter];
	[self loadFilters];
	[self setupMenuItems:fFilterMenu];
	[self setupMenuItems:fFilterMenuAlt];
}

- (void)dealloc {
	[super dealloc];
	[fFilterSet release];
}

- (void)loadFilters {
	int i;
	for (i = 1; i < 11; i++) {
		NSDictionary *lFilterDetail = [fFilterSet objectForKey:[NSString stringWithFormat:@"%d", i]];
		if (lFilterDetail && [[lFilterDetail objectForKey:@"name"] length] != 0)
			[[fSelectedFilter itemAtIndex:i - 1] setTitle:[NSString stringWithFormat:@"Filter %d: %@", i, [lFilterDetail objectForKey:@"name"]]];
		else
			[[fSelectedFilter itemAtIndex:i - 1] setTitle:[NSString stringWithFormat:@"Filter %d: Empty", i]];
	}
}

- (void)saveCurrentFilter {
	NSDictionary *lFilterEntry = [NSDictionary dictionaryWithObjectsAndKeys:[fName stringValue], @"name", 
								  [NSNumber numberWithInt:[[fAttribute selectedItem] tag]], @"attribute", 
								  [[fUserIds stringValue] componentsSeparatedByCharactersInSet:[fUserIds tokenizingCharacterSet]], @"userIds", 
								  [[fKeywords stringValue] componentsSeparatedByCharactersInSet:[fKeywords tokenizingCharacterSet]], @"keywords", 
								  [NSNumber numberWithBool:[fActivateFilter state] == NSOnState], @"active", 
								  [NSNumber numberWithBool:[fCaseSensitive state] == NSOnState], @"case_sensitive", 
								  [NSNumber numberWithBool:[fORFilter state] == NSOnState], @"use_OR", 
								  [NSNumber numberWithBool:[fORBetweenIDsAndWords state] == NSOnState], @"use_OR_between_IDs_and_keywords", 
								  nil];
	[fFilterSet setObject:lFilterEntry forKey:[NSString stringWithFormat:@"%d", fCurrentSelection]];
	if ([[fName stringValue] length] != 0)
		[[fSelectedFilter itemAtIndex:fCurrentSelection - 1] setTitle:[NSString stringWithFormat:@"Filter %d: %@", fCurrentSelection, [fName stringValue]]];
	else
		[[fSelectedFilter itemAtIndex:fCurrentSelection - 1] setTitle:[NSString stringWithFormat:@"Filter %d: Empty", fCurrentSelection]];
	[[PTPreferenceManager sharedSingleton] setCustomFilters:fFilterSet];
}

- (void)loadCurrentFilter {
	fCurrentSelection = [[fSelectedFilter selectedItem] tag];
	NSDictionary *lFilterEntry = [fFilterSet objectForKey:[NSString stringWithFormat:@"%d", fCurrentSelection]];
	if (lFilterEntry) {
		[fName setStringValue:[lFilterEntry objectForKey:@"name"]];
		[fAttribute selectItemAtIndex:[[lFilterEntry objectForKey:@"attribute"] intValue] - 1];
		NSString *lCurrentString;
		NSString *lFinalString = nil;
		for (lCurrentString in [lFilterEntry objectForKey:@"userIds"]) {
			if (!lFinalString) {
				lFinalString = lCurrentString;
			} else 
				lFinalString = [lFinalString stringByAppendingString:[NSString stringWithFormat:@",%@", lCurrentString]];
		}
		[fUserIds setStringValue:lFinalString];
		lFinalString = nil;
		for (lCurrentString in [lFilterEntry objectForKey:@"keywords"]) {
			if (!lFinalString) {
				lFinalString = lCurrentString;
			} else 
				lFinalString = [lFinalString stringByAppendingString:[NSString stringWithFormat:@",%@", lCurrentString]];
		}
		[fKeywords setStringValue:lFinalString];
		[fActivateFilter setState:[[lFilterEntry objectForKey:@"active"] boolValue]];
		[fCaseSensitive setState:[[lFilterEntry objectForKey:@"case_sensitive"] boolValue]];
		[fORFilter setState:[[lFilterEntry objectForKey:@"use_OR"] boolValue]];
		[fORBetweenIDsAndWords setState:[[lFilterEntry objectForKey:@"use_OR_between_IDs_and_keywords"] boolValue]];
	} else {
		[fName setStringValue:@""];
		[fAttribute selectItemAtIndex:0];
		[fUserIds setStringValue:@""];
		[fKeywords setStringValue:@""];
		[fActivateFilter setState:NSOffState];
		[fCaseSensitive setState:NSOffState];
		[fORFilter setState:NSOffState];
		[fORBetweenIDsAndWords setState:NSOffState];
	}
}

- (IBAction)selectedFilterChanged:(id)sender {
	[self saveCurrentFilter];
	[self loadCurrentFilter];
}

- (IBAction)finishedEditing:(id)sender {
	[self saveCurrentFilter];
	[self setupMenuItems:fFilterMenu];
	[self setupMenuItems:fFilterMenuAlt];
	[fFilterWindow close];
}

- (IBAction)selectCustomFilter:(id)sender {
	NSDictionary *lCustomFilter = [fFilterSet objectForKey:[NSString stringWithFormat:@"%d", [sender tag]]];
	NSString *lFinalPredicateString = nil;
	
	NSString *lCaseSensitive;
	if ([[lCustomFilter objectForKey:@"case_sensitive"] boolValue])
		lCaseSensitive = @"contains";
	else
		lCaseSensitive = @"contains[c]";
	
	NSString *lFilterMethod;
	if ([[lCustomFilter objectForKey:@"use_OR"] boolValue])
		lFilterMethod = @"OR";
	else
		lFilterMethod = @"AND";
	
	NSString *lCurrentId;
	for (lCurrentId in [lCustomFilter objectForKey:@"userIds"]) {
		if ([lCurrentId length] != 0) {
			if (!lFinalPredicateString)
				lFinalPredicateString = [NSString stringWithFormat:@"userId == \"%@\"", lCurrentId];
			else {
				NSString *lNewString = [NSString stringWithFormat:@" OR userId == \"%@\"", lCurrentId];
				lFinalPredicateString = [lFinalPredicateString stringByAppendingString:lNewString];
			}
		}
	}
	
	BOOL lRequiresAND = NO;
	
	if (lFinalPredicateString) {
		lFinalPredicateString = [NSString stringWithFormat:@"(%@)", lFinalPredicateString];
		lRequiresAND = YES;
	}
	
	BOOL lFirst = YES;
	BOOL lKeywordQueryIsBlank = YES;
	
	NSString *lCurrentKeyword;
	for (lCurrentKeyword in [lCustomFilter objectForKey:@"keywords"]) {
		if ([lCurrentKeyword length] != 0) {
			if (!lFinalPredicateString)
				lFinalPredicateString = [NSString stringWithFormat:@"statusMessageString %@ \"%@\"", lCaseSensitive, lCurrentKeyword];
			else {
				if (lFirst && lRequiresAND) {
					NSString *lMethod = [[lCustomFilter objectForKey:@"use_OR_between_IDs_and_keywords"] boolValue] ? @"OR" : @"AND";
					NSString *lNewString = [NSString stringWithFormat:@" %@ (statusMessageString %@ \"%@\"", lMethod, lCaseSensitive, lCurrentKeyword];
					lFinalPredicateString = [lFinalPredicateString stringByAppendingString:lNewString];
					lFirst = NO;
				} else {
					NSString *lNewString = [NSString stringWithFormat:@" %@ statusMessageString %@ \"%@\"", lFilterMethod, lCaseSensitive, lCurrentKeyword];
					lFinalPredicateString = [lFinalPredicateString stringByAppendingString:lNewString];
				}
			}
			lKeywordQueryIsBlank = NO;
		}
	}
	
	NSString *lAttributeCond = nil;
	
	if (lFinalPredicateString && lFilterMethod == @"OR") {
		lFinalPredicateString = [NSString stringWithFormat:@"(%@)", lFinalPredicateString];
	}
	
	if (!lKeywordQueryIsBlank && lRequiresAND) {
		lFinalPredicateString = [NSString stringWithFormat:@"%@)", lFinalPredicateString];
	}
	
	switch ([[lCustomFilter objectForKey:@"attribute"] intValue]) {
		case 2:
			lAttributeCond = @"sType == 0";
			break;
		case 3:
			lAttributeCond = @"sType == 1";
			break;
		case 4:
			lAttributeCond = @"sType == 2";
			break;
		case 5:
			lAttributeCond = @"sType == 3";
			break;
		default:
			break;
	}
	
	if (lAttributeCond)
		if (lFinalPredicateString) {
			NSString *lNewString = [NSString stringWithFormat:@" AND %@", lAttributeCond];
			lFinalPredicateString = [lFinalPredicateString stringByAppendingString:lNewString];
		} else 
			lFinalPredicateString = lAttributeCond;
	
	if (!lFinalPredicateString) return;
		
	NSPredicate *lPredicate = [NSPredicate predicateWithFormat:lFinalPredicateString];
	[fStatusController setFilterPredicate:lPredicate];
	[fMainActionHandler updateCollection];
}

- (void)setupMenuItems:(NSMenuItem *)aMenu {
	int i;
	NSMenu *lSubMenu = [aMenu submenu];
	for (i = 1; i < 11; i++) {
		NSMenuItem* lCurrentItem = [lSubMenu itemAtIndex:i - 1];
		NSDictionary *lFilterDetail = [fFilterSet objectForKey:[NSString stringWithFormat:@"%d", i]];
		if (lFilterDetail && [[lFilterDetail objectForKey:@"name"] length] != 0)
			[lCurrentItem setTitle:[NSString stringWithFormat:@"Filter %d: %@", i, [lFilterDetail objectForKey:@"name"]]];
		else
			[lCurrentItem setTitle:[NSString stringWithFormat:@"Filter %d: Empty", i]];
		if ([[lFilterDetail objectForKey:@"active"] boolValue])
			[lCurrentItem setTarget:self];
		else
			[lCurrentItem setTarget:nil];
	}
}


@end
