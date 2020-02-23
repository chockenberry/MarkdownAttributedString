//
//  FirstViewController.m
//  SampleApp
//
//  Created by Craig Hockenberry on 1/22/20.
//  Copyright © 2020 The Iconfactory. All rights reserved.
//

#import "FirstViewController.h"

#import "NSAttributedString+Markdown.h"

#import "StringData.h"

@interface FirstViewController () <UITextViewDelegate>

@property (nonatomic, weak) IBOutlet UILabel *label;
@property (nonatomic, weak) IBOutlet UIButton *button;
@property (nonatomic, weak) IBOutlet UITextView *textView;
@property (nonatomic, weak) IBOutlet UILabel *helpLabel;

@end

@implementation FirstViewController

- (void)dealloc
{
	[NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)viewDidLoad
{
	[super viewDidLoad];

	self.textView.delegate = self;

	NSString *localizedLabel = NSLocalizedString(@"_UITextView_ with **Rich Text**", @"Rich Text Label");
	NSString *localizedButton = NSLocalizedString(@"Show **Rich Text** Example", @"Rich Text Button");
	NSString *localizedHelp = NSLocalizedString(@"Any changes made in _this view_ will be reflected in the **Markdown** view", @"Rich Text Help");

	NSDictionary<NSAttributedStringKey,id> *attributes = @{ NSFontAttributeName: [UIFont systemFontOfSize:20.0] };
	
	self.label.attributedText = [[NSAttributedString alloc] initWithMarkdownRepresentation:localizedLabel attributes:attributes];
	[self.button setAttributedTitle:[[NSAttributedString alloc] initWithMarkdownRepresentation:localizedButton attributes:attributes] forState:UIControlStateNormal];
	
	self.helpLabel.attributedText = [[NSAttributedString alloc] initWithMarkdownRepresentation:localizedHelp attributes:@{ NSFontAttributeName: [UIFont systemFontOfSize:16.0], NSForegroundColorAttributeName: UIColor.secondaryLabelColor }];

	self.textView.attributedText = StringData.sharedStringData.attributedString;
	
	[NSNotificationCenter.defaultCenter addObserver:self selector:@selector(stringDataDidChange:) name:StringDataDidChangeNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
	NSLog(@"%s animated = %d", __PRETTY_FUNCTION__, animated);
	[super viewWillDisappear:animated];

	StringData.sharedStringData.attributedString = self.textView.attributedText;
}

- (IBAction)setExamples:(id)sender
{
	NSLog(@"%s called", __PRETTY_FUNCTION__);
	
	NSURL *exampleURL = [NSBundle.mainBundle URLForResource:@"Examples" withExtension:@"rtf"];
	NSData *exampleRTF = [NSData dataWithContentsOfURL:exampleURL];
	NSError *error = nil;
	NSMutableAttributedString *attributedString = [[[NSAttributedString alloc] initWithData:exampleRTF options:@{ } documentAttributes:nil error:&error] mutableCopy];
	[attributedString addAttribute:NSForegroundColorAttributeName value:UIColor.labelColor range:NSMakeRange(0, attributedString.length)];
	StringData.sharedStringData.attributedString = [attributedString copy];
}

- (void)stringDataDidChange:(NSNotification *)notification
{
	NSLog(@"%s called", __PRETTY_FUNCTION__);
	self.textView.attributedText = StringData.sharedStringData.attributedString;
}

@end
