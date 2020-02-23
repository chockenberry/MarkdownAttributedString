//
//  SecondViewController.m
//  SampleApp
//
//  Created by Craig Hockenberry on 1/22/20.
//  Copyright © 2020 The Iconfactory. All rights reserved.
//

#import "SecondViewController.h"

#import "NSAttributedString+Markdown.h"

#import "StringData.h"

#define USE_STYLE_ATTRIBUTES 0		// Enable this to use extended style attributes for the Markdown to attributed string conversions

@interface SecondViewController () <UITextViewDelegate>

@property (nonatomic, weak) IBOutlet UILabel *label;
@property (nonatomic, weak) IBOutlet UIButton *button;
@property (nonatomic, weak) IBOutlet UITextView *textView;
@property (nonatomic, weak) IBOutlet UILabel *helpLabel;

@property (readonly) NSDictionary<NSAttributedStringKey, id> *baseAttributes;
@property (readonly) NSDictionary<MarkdownStyleKey, NSDictionary<NSAttributedStringKey, id> *> *styleAttributes;

@end

@implementation SecondViewController

- (void)dealloc
{
	[NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	self.textView.delegate = self;

	NSString *localizedLabel = NSLocalizedString(@"_UITextView_ with **Markdown**", @"Markdown Label");
	NSString *localizedButton = NSLocalizedString(@"Show **Markdown** Examples", @"Markdown Button");
	NSString *localizedHelp = NSLocalizedString(@"Any changes made in _this view_ will be reflected in the **Rich Text** view", @"Markdown Help");

	NSDictionary<NSAttributedStringKey,id> *attributes = @{ NSFontAttributeName: [UIFont systemFontOfSize:20.0] };
	
	self.label.attributedText = [[NSAttributedString alloc] initWithMarkdownRepresentation:localizedLabel attributes:attributes];
	[self.button setAttributedTitle:[[NSAttributedString alloc] initWithMarkdownRepresentation:localizedButton attributes:attributes] forState:UIControlStateNormal];

	self.helpLabel.attributedText = [[NSAttributedString alloc] initWithMarkdownRepresentation:localizedHelp attributes:@{ NSFontAttributeName: [UIFont systemFontOfSize:16.0], NSForegroundColorAttributeName: UIColor.secondaryLabelColor }];

	NSAttributedString *attributedString = StringData.sharedStringData.attributedString;
	self.textView.attributedText = [self attributedStringConvertedToMarkdown:attributedString];

	[NSNotificationCenter.defaultCenter addObserver:self selector:@selector(stringDataDidChange:) name:StringDataDidChangeNotification object:nil];
	[NSNotificationCenter.defaultCenter addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
	[NSNotificationCenter.defaultCenter addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
	NSLog(@"%s animated = %d", __PRETTY_FUNCTION__, animated);
	[super viewWillDisappear:animated];
	
	NSString *string = self.textView.text;
#if !USE_STYLE_ATTRIBUTES
	NSAttributedString *attributedString = [[NSAttributedString alloc] initWithMarkdownRepresentation:string attributes:self.baseAttributes];
#else
	NSAttributedString *attributedString = [[NSAttributedString alloc] initWithMarkdownRepresentation:string baseAttributes:self.baseAttributes styleAttributes:self.styleAttributes];
#endif
	StringData.sharedStringData.attributedString = attributedString;
}

#pragma mark - Accessors

- (NSDictionary<NSAttributedStringKey, id> *)baseAttributes
{
#if !USE_STYLE_ATTRIBUTES
	return @{ NSFontAttributeName:[UIFont systemFontOfSize:20.0], NSForegroundColorAttributeName: UIColor.labelColor };
#else
	return @{ NSFontAttributeName: [UIFont fontWithName:@"AvenirNext-UltraLight" size:20.0], NSForegroundColorAttributeName: UIColor.labelColor };
#endif
}

- (NSDictionary<MarkdownStyleKey, NSDictionary<NSAttributedStringKey, id> *> *)styleAttributes
{
	return @{
		MarkdownStyleEmphasisSingle: @{
				NSFontAttributeName: [UIFont fontWithName:@"AvenirNext-UltraLightItalic" size:20.0],
				NSForegroundColorAttributeName: UIColor.systemRedColor
		},
		MarkdownStyleEmphasisDouble: @{
				NSFontAttributeName: [UIFont fontWithName:@"AvenirNext-DemiBold" size:20.0],
				NSForegroundColorAttributeName: UIColor.systemGreenColor
		},
		MarkdownStyleEmphasisBoth: @{
				NSFontAttributeName: [UIFont fontWithName:@"AvenirNext-HeavyItalic" size:20.0],
				NSForegroundColorAttributeName: UIColor.systemBlueColor
		},
	};
}

#pragma mark - Actions

- (IBAction)setExamples:(id)sender
{
	NSLog(@"%s called", __PRETTY_FUNCTION__);
	
	NSURL *exampleURL = [NSBundle.mainBundle URLForResource:@"Examples" withExtension:@"md"];
	NSData *exampleMarkdown = [NSData dataWithContentsOfURL:exampleURL];
	NSString *string = [[NSString alloc] initWithData:exampleMarkdown encoding:NSUTF8StringEncoding];

#if !USE_STYLE_ATTRIBUTES
	NSAttributedString *attributedString = [[NSAttributedString alloc] initWithMarkdownRepresentation:string attributes:self.baseAttributes];
#else
	NSAttributedString *attributedString = [[NSAttributedString alloc] initWithMarkdownRepresentation:string baseAttributes:self.baseAttributes styleAttributes:self.styleAttributes];
#endif
	StringData.sharedStringData.attributedString = attributedString;
}

- (IBAction)dismissKeyboard:(id)sender
{
	[self.textView resignFirstResponder];
}

#pragma mark - Utility

- (NSAttributedString *)attributedStringConvertedToMarkdown:(NSAttributedString *)attributedString
{
	UIFont *systemFont = [UIFont systemFontOfSize:18.0];
	UIFontDescriptor *fontDescriptor = [systemFont.fontDescriptor fontDescriptorWithDesign:UIFontDescriptorSystemDesignMonospaced];
	UIFont *systemMonospacedFont = [UIFont fontWithDescriptor:fontDescriptor size:systemFont.pointSize];

	NSString *string = [attributedString markdownRepresentation];
	NSDictionary<NSAttributedStringKey,id> *attributes = @{ NSFontAttributeName: systemMonospacedFont, NSForegroundColorAttributeName: UIColor.labelColor };
	return [[NSAttributedString alloc] initWithString:string attributes:attributes];
}

#pragma mark - Notifications

- (void)stringDataDidChange:(NSNotification *)notification
{
	NSLog(@"%s called", __PRETTY_FUNCTION__);
	
	NSAttributedString *attributedString = StringData.sharedStringData.attributedString;
	self.textView.attributedText = [self attributedStringConvertedToMarkdown:attributedString];
}

- (void)keyboardDidShow:(NSNotification *)notification
{
	CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
	CGFloat bottomInset = keyboardSize.height - self.view.safeAreaInsets.bottom;
	self.additionalSafeAreaInsets = UIEdgeInsetsMake(0, 0, bottomInset, 0);
}

- (void)keyboardWillHide:(NSNotification *)notification
{
	self.additionalSafeAreaInsets = UIEdgeInsetsMake(0, 0, 0, 0);
}

@end
