//
//  HorizontalRuleTextAttachment.h
//  SampleApp
//
//  Created by Craig Hockenberry on 5/20/25.
//  Copyright © 2025 The Iconfactory. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface HorizontalRuleTextAttachment : NSTextAttachment

@property (nonatomic, assign) CGFloat thickness;
@property (nonatomic, assign) BOOL hasDot;

@end

NS_ASSUME_NONNULL_END
