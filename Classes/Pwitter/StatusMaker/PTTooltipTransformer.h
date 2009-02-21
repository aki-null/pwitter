//
//  PTTooltipTransformer.h
//  Pwitter
//
//  Created by Akihiro Noguchi on 21/02/09.
//  Copyright 2009 Aki. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PTTooltipTransformer : NSValueTransformer {
	
}
+ (Class)transformedValueClass;
+ (BOOL)allowsReverseTransformation;
- (id)transformedValue:(id)aValue;

@end
