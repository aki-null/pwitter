#import <Cocoa/Cocoa.h>

@interface PTMain : NSObject {
    IBOutlet id statusUpdateField;
    IBOutlet id statusController;
    IBOutlet id preferenceWindow;
    IBOutlet id authPanel;
    IBOutlet id mainWindow;
    IBOutlet id authPassword;
    IBOutlet id authUserName;
    IBOutlet id testView;
	MGTwitterEngine *twitterEngine;
}
- (IBAction)updateTimeline:(id)sender;
- (IBAction)postStatus:(id)sender;
- (IBAction)quitApp:(id)sender;
- (IBAction)closeAuthSheet:(id)sender;
@end
