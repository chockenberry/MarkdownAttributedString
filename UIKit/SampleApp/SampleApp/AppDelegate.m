//
//  AppDelegate.m
//  SampleApp
//
//  Created by Craig Hockenberry on 1/22/20.
//  Copyright © 2020 The Iconfactory. All rights reserved.
//

#import "AppDelegate.h"

#import "StringData.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	// Override point for customization after application launch.

	NSURL *exampleURL = [NSBundle.mainBundle URLForResource:@"Examples" withExtension:@"rtf"];
	NSData *exampleRTF = [NSData dataWithContentsOfURL:exampleURL];
	NSError *error = nil;
	NSMutableAttributedString *attributedString = [[[NSAttributedString alloc] initWithData:exampleRTF options:@{ } documentAttributes:nil error:&error] mutableCopy];
	[attributedString addAttribute:NSForegroundColorAttributeName value:UIColor.labelColor range:NSMakeRange(0, attributedString.length)];
	StringData.sharedStringData.attributedString = [attributedString copy];
	
	return YES;
}


#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
	// Called when a new scene session is being created.
	// Use this method to select a configuration to create the new scene with.
	return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
	// Called when the user discards a scene session.
	// If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
	// Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}


@end
