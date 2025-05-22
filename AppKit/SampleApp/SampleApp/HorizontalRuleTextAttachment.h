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

- (instancetype)initWithFont:(NSFont *)font color:(NSColor *)color thickness:(CGFloat)thickness hasPadding:(BOOL)hasPadding hasSpaces:(BOOL)hasSpaces width:(NSInteger)width;

@property (class, nonatomic, readonly, strong) NSImage* placeholderImage;

@property (nonatomic, strong) NSColor *color;
@property (nonatomic, strong) NSFont *font;
@property (nonatomic, assign) CGFloat thickness;	// "---" = thin, "***" = thick
@property (nonatomic, assign) BOOL hasPadding;		// "  ***  " or "  ---  "
@property (nonatomic, assign) BOOL hasSpaces;		// "* * *" or "- - -"
@property (nonatomic, assign) NSInteger width;		// "***" = 3, "-----" = 5, "-- - --" = 7

@end

NS_ASSUME_NONNULL_END
