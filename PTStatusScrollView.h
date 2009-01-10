//
//  PTStatusScrollView.h
//  Pwitter
//
//  Created by Akihiro Noguchi on 10/01/09.
//  Copyright 2009 Aki. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PTStatusScrollView : NSScrollView {
	float fOldPosition;
	float fLastPosition;
	BOOL fViewChanged;
	float fLastWidth;
	float fLastHeight;
}

@end
