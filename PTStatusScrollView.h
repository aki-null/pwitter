//
//  PTStatusScrollView.h
//  Pwitter
//
//  Created by Akihiro Noguchi on 10/01/09.
//  Copyright 2009 Aki. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <BGHUDAppKit/BGHUDScrollView.h>


@interface PTStatusScrollView : BGHUDScrollView {
	float fOldPosition;
	float fLastPosition;
	BOOL fViewChanged;
	float fLastWidth;
	float fLastHeight;
	BOOL fShouldReset;
}
@end
