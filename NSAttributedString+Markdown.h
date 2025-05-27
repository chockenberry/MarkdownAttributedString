//
//  NSAttributedString+Markdown.h
//  Tot
//
//  Created by Craig Hockenberry on 12/14/19.
//  Copyright © 2020 The Iconfactory. All rights reserved.
//
/*
	Copyright (c) 2020 The Iconfactory, Inc. <https://iconfactory.com>

	Permission is hereby granted, free of charge, to any person obtaining a copy
	of this software and associated documentation files (the "Software"), to deal
	in the Software without restriction, including without limitation the rights
	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	copies of the Software, and to permit persons to whom the Software is
	furnished to do so, subject to the following conditions:

	The above copyright notice and this permission notice shall be included in
	all copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
	THE SOFTWARE.
*/

#import <Foundation/Foundation.h>

#if TARGET_OS_OSX
#import <AppKit/AppKit.h>
#else
#import <UIKit/UIKit.h>
#endif

#if TARGET_OS_OSX

#define FONT_CLASS NSFont
#define FONT_DESCRIPTOR_CLASS NSFontDescriptor
#define FONT_DESCRIPTOR_SYMBOLIC_TRAITS NSFontDescriptorSymbolicTraits
#define FONT_DESCRIPTOR_TRAIT_BOLD NSFontDescriptorTraitBold
#define FONT_DESCRIPTOR_TRAIT_ITALIC NSFontDescriptorTraitItalic
#define FONT_DESCRIPTOR_CLASS_SYMBOLIC NSFontDescriptorClassSymbolic
#define FONT_DESCRIPTOR_FAMILY_ATTRIBUTE NSFontFamilyAttribute

#define COLOR_CLASS NSColor

#define IMAGE_CLASS NSImage

#else

#define FONT_CLASS UIFont
#define FONT_DESCRIPTOR_CLASS UIFontDescriptor
#define FONT_DESCRIPTOR_SYMBOLIC_TRAITS UIFontDescriptorSymbolicTraits
#define FONT_DESCRIPTOR_TRAIT_BOLD UIFontDescriptorTraitBold
#define FONT_DESCRIPTOR_TRAIT_ITALIC UIFontDescriptorTraitItalic
#define FONT_DESCRIPTOR_CLASS_SYMBOLIC UIFontDescriptorClassSymbolic
#define FONT_DESCRIPTOR_FAMILY_ATTRIBUTE UIFontDescriptorFamilyAttribute

#define COLOR_CLASS UIColor

#define IMAGE_CLASS UIImage

#endif

#define ALLOW_HORIZONTAL_RULES 1	// CONFIGURATION - When enabled, horizontal rules use text attachments in the rich text attributes

NS_ASSUME_NONNULL_BEGIN

#pragma mark - Markdown Character Set

@interface NSCharacterSet (Markdown)

@property (readonly, class, copy) NSCharacterSet *markdownLiteralCharacterSet;

@end

#pragma mark - Markdown UTType

extern NSString *const UTTypeMarkdown;
// NOTE: The definition above can be used to determine if text on the clipboard contains Markdown:
//
// if ([UIPasteboard.generalPasteboard containsPasteboardTypes:@[ UTTypeMarkdown, (NSString *)kUTTypeText ]]) { ... }

#pragma mark - Markdown Attribute Styles

typedef NSString * MarkdownStyleKey NS_EXTENSIBLE_STRING_ENUM;

extern MarkdownStyleKey MarkdownStyleEmphasisSingle;                // attribute dictionary for occurances of _ or * (emphasis, typically an italic font)
extern MarkdownStyleKey MarkdownStyleEmphasisDouble;                // attribute dictionary for occurances of __ or ** (strong, typically a bold font)
extern MarkdownStyleKey MarkdownStyleEmphasisBoth;					// attribute dictionary for occurances of _ or * within __ or ** (emphasis and strong, typically a bold italic font)

extern MarkdownStyleKey MarkdownStyleLink;							// optional attribute dictionary to use instead of NSLinkAttributeName, link will be styled with attributes instead of clickable

#pragma mark - Markdown Attributed String

@interface NSAttributedString (Markdown)

- (instancetype)initWithMarkdownRepresentation:(NSString *)markdownRepresentation attributes:(nonnull NSDictionary<NSAttributedStringKey, id> *)attributes;
- (instancetype)initWithMarkdownRepresentation:(NSString *)markdownString baseAttributes:(nonnull NSDictionary<NSAttributedStringKey, id> *)baseAttributes styleAttributes:(nullable NSDictionary<MarkdownStyleKey, NSDictionary<NSAttributedStringKey, id> *> *)styleAttributes;

- (instancetype)initWithMarkdownRepresentation:(NSString *)markdownRepresentation baseAttributes:(nonnull NSDictionary<NSAttributedStringKey, id> *)baseAttributes styleAttributes:(nullable NSDictionary<MarkdownStyleKey, NSDictionary<NSAttributedStringKey, id> *> *)styleAttributes processBlockElements:(BOOL)processBlockElements;

@property (nonatomic, readonly) NSString *markdownRepresentation;

#pragma mark -

// NOTE: This is mainly for the automated tests: it generates a representation that can be used to check the placement and state of attributes.
@property (nonatomic, readonly) NSString *markdownDebug;

@end


#pragma mark - Markdown Horizontal Rule

@interface MarkdownHorizontalRuleTextAttachment : NSTextAttachment <NSSecureCoding>

- (instancetype)initWithFont:(FONT_CLASS *)font color:(COLOR_CLASS *)color thickness:(CGFloat)thickness hasPadding:(BOOL)hasPadding hasSpaces:(BOOL)hasSpaces range:(NSRange)range;

@property (nonatomic, assign, readonly) NSRange range;		// NOTE: this value does not update as text is edited: consider it a temporary variable.

@property (nonatomic, strong, readonly) COLOR_CLASS *color;
@property (nonatomic, strong, readonly) FONT_CLASS *font;
@property (nonatomic, assign, readonly) CGFloat thickness;	// "***" = 2.0, "---" = 1.0
@property (nonatomic, assign, readonly) BOOL hasPadding;	// "  ***  " or "  ------  "
@property (nonatomic, assign, readonly) BOOL hasSpaces;		// "* * *" or "--- - ---"
@property (nonatomic, assign, readonly) NSInteger width;	// "***" = 3, "-----" = 5, "-- - --" = 7

@end

NS_ASSUME_NONNULL_END
