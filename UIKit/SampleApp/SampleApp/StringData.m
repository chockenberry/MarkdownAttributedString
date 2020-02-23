//
//  StringData.m
//  SampleApp
//
//  Created by Craig Hockenberry on 1/24/20.
//  Copyright © 2020 The Iconfactory. All rights reserved.
//

#import "StringData.h"

NSString *const StringDataDidChangeNotification = @"StringDataDidChangeNotification";

@interface StringData ()

@end

@implementation StringData

+ (StringData *)sharedStringData
{
	static StringData *sharedStringDataInstance = nil;
	static dispatch_once_t once;
	dispatch_once(&once, ^{
		sharedStringDataInstance = [[self alloc] init];
	});
	return sharedStringDataInstance;
}

- (void)setAttributedString:(NSAttributedString *)attributedString
{
	if (! [attributedString isEqual:_attributedString]) {
		_attributedString = attributedString;
		[NSNotificationCenter.defaultCenter postNotificationName:StringDataDidChangeNotification object:self];
	}
}
@end
