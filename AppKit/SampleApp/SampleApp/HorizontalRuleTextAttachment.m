//
//  HorizontalRuleTextAttachment.m
//  SampleApp
//
//  Created by Craig Hockenberry on 5/20/25.
//  Copyright © 2025 The Iconfactory. All rights reserved.
//

#import "HorizontalRuleTextAttachment.h"

@implementation HorizontalRuleTextAttachment

- (CGRect)attachmentBoundsForAttributes:(NSDictionary<NSAttributedStringKey,id> *)attributes location:(id<NSTextLocation>)location textContainer:(NSTextContainer *)textContainer proposedLineFragment:(CGRect)proposedLineFragment position:(CGPoint)position
{
	NSLog(@"%s proposedLineFragment = %@", __PRETTY_FUNCTION__, NSStringFromRect(proposedLineFragment));
	return proposedLineFragment;
}

- (NSImage *)imageForBounds:(CGRect)imageBounds textContainer:(NSTextContainer *)textContainer characterIndex:(NSUInteger)charIndex
{
	NSImage *image = [[NSImage alloc] initWithSize:NSMakeSize(imageBounds.size.width, imageBounds.size.height)];
	[image lockFocus];
	[NSColor.redColor set];
	NSRect fillRect = NSMakeRect(0, floor((imageBounds.size.height / 2) - (self.thickness / 2)), imageBounds.size.width, self.thickness);
	NSRectFill(fillRect);
	[image unlockFocus];
	
	return image;

}

@end
