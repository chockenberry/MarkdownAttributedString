//
//  StringData.h
//  SampleApp
//
//  Created by Craig Hockenberry on 1/24/20.
//  Copyright © 2020 The Iconfactory. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString *const StringDataDidChangeNotification;

@interface StringData : NSObject

@property (class, readonly) StringData *sharedStringData;

@property (nonatomic, strong) NSAttributedString *attributedString;

@end

NS_ASSUME_NONNULL_END
