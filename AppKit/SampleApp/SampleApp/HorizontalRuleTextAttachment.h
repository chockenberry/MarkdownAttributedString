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

- (instancetype)initWithColor:(NSColor *)color thickness:(CGFloat)thickness hasPadding:(BOOL)hasPadding hasSpaces:(BOOL)hasSpaces;

@property (class, nonatomic, readonly, strong) NSImage* placeholderImage;

@property (nonatomic, strong) NSColor *color;
@property (nonatomic, assign) CGFloat thickness;	// "---" or "___" = thin, "***" = thick
@property (nonatomic, assign) BOOL hasPadding;		// "  ***  " or "  ---  " or " ___  "
@property (nonatomic, assign) BOOL hasSpaces;		// "* * *" or "- - -" or "_ _ _"

@end

NS_ASSUME_NONNULL_END
