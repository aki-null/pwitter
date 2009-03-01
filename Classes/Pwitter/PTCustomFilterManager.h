//
//  PTCustomFilterManager.h
//  Pwitter
//
//  Created by Akihiro Noguchi on 28/02/09.
//  Copyright 2009 Aki. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PTCustomFilterManager : NSObject {
    IBOutlet id fAttribute;
    IBOutlet id fCaseSensitive;
    IBOutlet id fKeywords;
    IBOutlet id fName;
    IBOutlet id fSelectedFilter;
    IBOutlet id fActivateFilter;
    IBOutlet id fFilterMenu;
    IBOutlet id fFilterMenuAlt;
    IBOutlet id fStatusController;
    IBOutlet id fMainActionHandler;
    IBOutlet id fFilterWindow;
    IBOutlet id fORFilter;
    IBOutlet id fUserIds;
    IBOutlet id fORBetweenIDsAndWords;
	NSMutableDictionary *fFilterSet;
	int fCurrentSelection;
}
- (IBAction)selectedFilterChanged:(id)sender;
- (IBAction)finishedEditing:(id)sender;
- (IBAction)selectCustomFilter:(id)sender;
- (void)loadFilters;
- (void)saveCurrentFilter;
- (void)loadCurrentFilter;
- (void)setupMenuItems:(NSMenuItem *)aMenu;
@end
