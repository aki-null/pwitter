//
//  PTStatusEntityView.h
//  Pwitter
//
//  Created by Akihiro Noguchi on 26/12/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PTStatusEntityView : NSBox {
	BOOL _isSelected;
	id _theDelegate;
}

- (id)delegate;
- (void)setDelegate:(id)theDelegate;
- (void)setSelected:(BOOL)flag;
- (BOOL)selected;

@end

@interface NSObject (ViewDelegate)
- (void)doubleClick:(id)sender;
@end
