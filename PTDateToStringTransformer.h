//
//  PTDateToStringTransformer.h
//  Pwitter
//
//  Created by Akihiro Noguchi on 4/02/09.
//  Copyright 2009 Aki. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PTDateToStringTransformer : NSValueTransformer {

}
+ (Class)transformedValueClass;
+ (BOOL)allowsReverseTransformation;
- (id)transformedValue:(id)aValue;

@end
