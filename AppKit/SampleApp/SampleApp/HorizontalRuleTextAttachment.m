//
//  HorizontalRuleTextAttachment.m
//  SampleApp
//
//  Created by Craig Hockenberry on 5/20/25.
//  Copyright © 2025 The Iconfactory. All rights reserved.
//

#import "HorizontalRuleTextAttachment.h"

@interface HorizontalRuleTextAttachment ()

@end

@implementation HorizontalRuleTextAttachment

- (instancetype)initWithFont:(NSFont *)font color:(NSColor *)color thickness:(CGFloat)thickness hasPadding:(BOOL)hasPadding hasSpaces:(BOOL)hasSpaces range:(NSRange)range
{
	self = [super init];
	if (self != nil) {
		_font = font;
		_color = color;
		_thickness = thickness;
		_hasPadding = hasPadding;
		_hasSpaces = hasSpaces;
		_range = range;
		
		// NOTE: Placeholder image has size in points and will be included in RTFD package as a TIFF file.
		NSRect placeholderBounds = NSMakeRect(0, 0, 300, thickness + 2);
		self.image = [self imageForBounds:placeholderBounds];
	}
	return self;
}

- (NSInteger)width
{
	return self.range.length;
}

- (CGRect)attachmentBoundsForAttributes:(NSDictionary<NSAttributedStringKey,id> *)attributes location:(id<NSTextLocation>)location textContainer:(NSTextContainer *)textContainer proposedLineFragment:(CGRect)proposedLineFragment position:(CGPoint)position
{
	NSLog(@"%s proposedLineFragment = %@", __PRETTY_FUNCTION__, NSStringFromRect(proposedLineFragment));
	if (self.font != nil && textContainer.textView.window != nil) {
		proposedLineFragment.size.height = floor((self.font.ascender + self.font.descender + self.font.leading) * textContainer.textView.window.backingScaleFactor);
	}
	NSLog(@"%s return = %@", __PRETTY_FUNCTION__, NSStringFromRect(proposedLineFragment));
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

static NSString *const horizontalRuleFontCodingKey = @"font";
static NSString *const horizontalRuleColorCodingKey = @"color";
static NSString *const horizontalRuleThicknessCodingKey = @"thickness";
static NSString *const horizontalRulePaddingCodingKey = @"padding";
static NSString *const horizontalRuleSpacesCodingKey = @"spaces";

+ (BOOL)supportsSecureCoding
{
	return YES;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
	if (self.font != nil) {
		[self.font encodeWithCoder:coder];
	}
	if (self.color != nil) {
		[self.color encodeWithCoder:coder];
	}
	
	[coder encodeDouble:self.thickness forKey:horizontalRuleThicknessCodingKey];
	[coder encodeBool:self.hasPadding forKey:horizontalRulePaddingCodingKey];
	[coder encodeBool:self.hasSpaces forKey:horizontalRuleSpacesCodingKey];
	
	NSValue *rangeValue = [NSValue valueWithRange:self.range];
	if (rangeValue != nil) {
		[rangeValue encodeWithCoder:coder];
	}
}

- (nullable instancetype)initWithCoder:(NSCoder *)decoder
{
	NSFont *font = [[NSFont alloc] initWithCoder:decoder];
	NSColor *color = [[NSColor alloc] initWithCoder:decoder];

	CGFloat thickness = [decoder decodeDoubleForKey:horizontalRuleThicknessCodingKey];
	BOOL hasPadding = [decoder decodeBoolForKey:horizontalRulePaddingCodingKey];
	BOOL hasSpaces = [decoder decodeBoolForKey:horizontalRuleSpacesCodingKey];

	NSValue *value = [[NSValue alloc] initWithCoder:decoder];
	NSRange range = value.rangeValue;
	return [self initWithFont:font color:color thickness:thickness hasPadding:hasPadding hasSpaces:hasSpaces range:range];
}

@end
