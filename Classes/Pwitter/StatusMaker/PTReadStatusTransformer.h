//
//  PTReadStatusTransformer.h
//  Pwitter
//
//  Created by Akihiro Noguchi on 6/02/09.
//  Copyright 2009 Aki. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PTReadStatusTransformer : NSValueTransformer {
	
}
+ (Class)transformedValueClass;
+ (BOOL)allowsReverseTransformation;
- (id)transformedValue:(id)aValue;

@end
