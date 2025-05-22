//
//  CustomTextView.h
//  SampleApp
//
//  Created by Craig Hockenberry on 5/21/25.
//  Copyright © 2025 The Iconfactory. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define TESTING 1 // to get -markdownDebug
#import "NSAttributedString+Markdown.h"

NS_ASSUME_NONNULL_BEGIN

@interface CustomTextView : NSTextView <NSSharingServicePickerDelegate>

@property (nonatomic, strong) NSDictionary<NSAttributedStringKey, id> *baseAttributes;
@property (nonatomic, strong, nullable) NSDictionary<MarkdownStyleKey, NSDictionary<NSAttributedStringKey, id> *> *styleAttributes;

@end

NS_ASSUME_NONNULL_END
