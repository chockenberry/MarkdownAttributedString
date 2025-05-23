//
//  HorizontalRuleTextAttachment.h
//  SampleApp
//
//  Created by Craig Hockenberry on 5/20/25.
//  Copyright © 2025 The Iconfactory. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface HorizontalRuleTextAttachment : NSTextAttachment <NSSecureCoding>

- (instancetype)initWithFont:(NSFont *)font color:(NSColor *)color thickness:(CGFloat)thickness hasPadding:(BOOL)hasPadding hasSpaces:(BOOL)hasSpaces range:(NSRange)range;

@property (nonatomic, assign, readonly) NSRange range;		// NOTE: this value does not update as text is edited: consider it a temporary variable.

@property (nonatomic, strong, readonly) NSColor *color;
@property (nonatomic, strong, readonly) NSFont *font;
@property (nonatomic, assign, readonly) CGFloat thickness;	// "***" = 2.0, "---" = 1.0
@property (nonatomic, assign, readonly) BOOL hasPadding;	// "  ***  " or "  ------  "
@property (nonatomic, assign, readonly) BOOL hasSpaces;		// "* * *" or "--- - ---"
@property (nonatomic, assign, readonly) NSInteger width;	// "***" = 3, "-----" = 5, "-- - --" = 7

@end

NS_ASSUME_NONNULL_END
