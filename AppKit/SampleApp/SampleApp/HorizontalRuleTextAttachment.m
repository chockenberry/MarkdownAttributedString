//
//  HorizontalRuleTextAttachment.m
//  SampleApp
//
//  Created by Craig Hockenberry on 5/20/25.
//  Copyright © 2025 The Iconfactory. All rights reserved.
//

#import "HorizontalRuleTextAttachment.h"

@implementation HorizontalRuleTextAttachment

+ (NSImage *)placeholderImage
{
	// size is in points and will be included in RTFD package as a TIFF file
	NSImage *image = [[NSImage alloc] initWithSize:NSMakeSize(300, 1)];
	[image lockFocus];
	[NSColor.blackColor set];
	NSRect fillRect = NSMakeRect(0, 0, 300, 1);
	NSRectFill(fillRect);
	[image unlockFocus];
	
	return image;
}

- (instancetype)initWithColor:(NSColor *)color thickness:(CGFloat)thickness hasPadding:(BOOL)hasPadding hasSpaces:(BOOL)hasSpaces
{
	self = [super init];
	if (self != nil) {
		_color = color;
		_thickness = thickness;
		_hasPadding = hasPadding;
		_hasSpaces = hasSpaces;
	}
	return self;
}

- (CGRect)attachmentBoundsForAttributes:(NSDictionary<NSAttributedStringKey,id> *)attributes location:(id<NSTextLocation>)location textContainer:(NSTextContainer *)textContainer proposedLineFragment:(CGRect)proposedLineFragment position:(CGPoint)position
{
	NSLog(@"%s proposedLineFragment = %@", __PRETTY_FUNCTION__, NSStringFromRect(proposedLineFragment));
	return proposedLineFragment;
}

- (NSImage *)imageForBounds:(CGRect)imageBounds textContainer:(NSTextContainer *)textContainer characterIndex:(NSUInteger)charIndex
{
	return [self imageForBounds:imageBounds];
}

- (NSImage *)imageForBounds:(CGRect)imageBounds
{
	NSImage *image = [[NSImage alloc] initWithSize:NSMakeSize(imageBounds.size.width, imageBounds.size.height)];
	[image lockFocus];
	[self.color set];
	
	CGFloat padding = 0.0;
	if (self.hasPadding) {
		padding = 20.0;
	}
	
	CGFloat verticalCenter = floor((imageBounds.size.height / 2) - (self.thickness / 2));
	
	if (self.hasSpaces) {
		CGFloat midPoint = (imageBounds.size.width / 2.0);
		CGFloat spacing = 10.0;
		
		NSRect leftFillRect = NSMakeRect(0 + padding, verticalCenter, midPoint - padding - spacing, self.thickness);
		NSRectFill(leftFillRect);
#if 0 // square dot
		NSRect centerFillRect = NSMakeRect(midPoint - (self.thickness / 2.0), verticalCenter, self.thickness, self.thickness);
		NSRectFill(centerFillRect);
#else // circular dot
		NSRect centerFillRect = NSMakeRect(midPoint - self.thickness, verticalCenter - self.thickness / 2.0, self.thickness * 2, self.thickness * 2);
		NSBezierPath *path = [NSBezierPath bezierPathWithOvalInRect:centerFillRect];
		[path fill];
#endif
		NSRect rightFillRect = NSMakeRect(midPoint + spacing, verticalCenter, midPoint - padding - spacing, self.thickness);
		NSRectFill(rightFillRect);
	}
	else {
		NSRect fillRect = NSMakeRect(0 + padding, verticalCenter, imageBounds.size.width - (padding * 2), self.thickness);
		NSRectFill(fillRect);
	}
	[image unlockFocus];
	
	return image;

}

#pragma mark - NSSecureCoding

NSString *const horizontalRuleColorCodingKey = @"color";
NSString *const horizontalRuleThicknessCodingKey = @"thickness";
NSString *const horizontalRulePaddingCodingKey = @"padding";
NSString *const horizontalRuleSpacesCodingKey = @"spaces";

+ (BOOL)supportsSecureCoding
{
	return YES;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
	[self.color encodeWithCoder:coder];

	[coder encodeDouble:self.thickness forKey:horizontalRuleThicknessCodingKey];
	[coder encodeBool:self.hasPadding forKey:horizontalRulePaddingCodingKey];
	[coder encodeBool:self.hasSpaces forKey:horizontalRuleSpacesCodingKey];
}

- (nullable instancetype)initWithCoder:(NSCoder *)decoder
{
	NSColor *color = [[NSColor alloc] initWithCoder:decoder];
	if (color == nil) {
		return nil;
	}

	CGFloat thickness = [decoder decodeDoubleForKey:horizontalRuleThicknessCodingKey];
	BOOL hasPadding = [decoder decodeBoolForKey:horizontalRulePaddingCodingKey];
	BOOL hasSpaces = [decoder decodeBoolForKey:horizontalRuleSpacesCodingKey];

	return [self initWithColor:color thickness:thickness hasPadding:hasPadding hasSpaces:hasSpaces];
}

@end
