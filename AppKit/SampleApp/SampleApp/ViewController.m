//
//  ViewController.m
//  MarkdownAttributedString
//
//  Created by Craig Hockenberry on 12/28/19.
//  Copyright © 2019 The Iconfactory. All rights reserved.
//

#import "ViewController.h"

static NSString *const savedStringKey = @"savedString";

#define TESTING 1 // to get -markdownDebug
#import "NSAttributedString+Markdown.h"

#define USE_STYLE_ATTRIBUTES 0		// Enable this to use extended style attributes for the Markdown to attributed string conversions

@interface ViewController () <NSTextViewDelegate>

@property (nonatomic, weak) IBOutlet NSTextField *richTextTextField;
@property (nonatomic, weak) IBOutlet NSButton *richTextButton;
@property (nonatomic, weak) IBOutlet NSTextView *richTextTextView;

@property (nonatomic, weak) IBOutlet NSTextField *markdownTextField;
@property (nonatomic, weak) IBOutlet NSButton *markdownButton;
@property (nonatomic, weak) IBOutlet NSTextView *markdownTextView;

@property (readonly) NSFont *richTextFont;
@property (readonly) NSFont *markdownFont;
@property (readonly) NSDictionary<NSAttributedStringKey, id> *baseAttributes;
@property (readonly) NSDictionary<MarkdownStyleKey, NSDictionary<NSAttributedStringKey, id> *> *styleAttributes;

@end

@implementation ViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	

	NSString *localizedRichTextLabel = NSLocalizedString(@"_NSTextView_ with **Rich Text**", @"Rich Text Label");
	NSString *localizedRichTextButton = NSLocalizedString(@"Show **Rich Text** Example", @"Rich Text Button");
	NSString *localizedMarkdownLabel = NSLocalizedString(@"_NSTextView_ with **Markdown**", @"Markdown Label");
	NSString *localizedMarkdownButton = NSLocalizedString(@"Show **Markdown** Examples", @"Markdown Button");
	
	NSDictionary<NSAttributedStringKey,id> *attributes = @{ NSFontAttributeName: [NSFont systemFontOfSize:13.0] };
	
	self.richTextTextField.attributedStringValue = [[NSAttributedString alloc] initWithMarkdownRepresentation:localizedRichTextLabel attributes:attributes];
	self.richTextButton.attributedTitle = [[NSAttributedString alloc] initWithMarkdownRepresentation:localizedRichTextButton attributes:attributes];
	self.markdownTextField.attributedStringValue = [[NSAttributedString alloc] initWithMarkdownRepresentation:localizedMarkdownLabel attributes:attributes];
	self.markdownButton.attributedTitle = [[NSAttributedString alloc] initWithMarkdownRepresentation:localizedMarkdownButton attributes:attributes];
}

- (void)viewWillAppear
{
	[super viewWillAppear];

	self.richTextTextView.font = self.richTextFont;
	self.richTextTextView.typingAttributes = self.baseAttributes;
	self.markdownTextView.font = self.markdownFont;
	self.markdownTextView.typingAttributes = @{ NSFontAttributeName: self.markdownFont };
}

- (void)viewDidAppear
{
	[super viewDidAppear];
	
	if ([NSUserDefaults.standardUserDefaults objectForKey:savedStringKey]) {
		[self performSelector:@selector(setMarkdownSavedString) withObject:nil afterDelay:0.0];
	}
	else {
		[self performSelector:@selector(setRichTextExamples:) withObject:nil afterDelay:0.0];
	}
}

#pragma mark - Accessors

- (NSFont *)richTextFont
{
	return [NSFont userFontOfSize:13.0];
}

- (NSFont *)markdownFont
{
	return [NSFont userFixedPitchFontOfSize:13.0];
}

- (NSDictionary<NSAttributedStringKey, id> *)baseAttributes
{
#if !USE_STYLE_ATTRIBUTES
	return @{ NSFontAttributeName: self.richTextFont };
#else
	return @{ NSFontAttributeName: [NSFont fontWithName:@"AvenirNext-Regular" size:14.0] };
#endif
}

- (NSDictionary<MarkdownStyleKey, NSDictionary<NSAttributedStringKey, id> *> *)styleAttributes
{
	return @{
		MarkdownStyleEmphasisSingle: @{
				NSFontAttributeName: [NSFont fontWithName:@"Verdana-Italic" size:14.0],
				NSForegroundColorAttributeName: NSColor.systemRedColor
		},
		MarkdownStyleEmphasisDouble: @{
				NSFontAttributeName: [NSFont fontWithName:@"LucidaGrande-Bold" size:14.0],
				NSForegroundColorAttributeName: NSColor.systemGreenColor
		},
		MarkdownStyleEmphasisBoth: @{
				NSFontAttributeName: [NSFont fontWithName:@"Palatino-BoldItalic" size:16.0],
				NSForegroundColorAttributeName: NSColor.systemBlueColor
		},
	};
}

#pragma mark - Actions

- (IBAction)setRichTextExamples:(id)sender
{
	NSLog(@"%s called", __PRETTY_FUNCTION__);
	
	NSURL *exampleURL = [NSBundle.mainBundle URLForResource:@"Examples" withExtension:@"rtf"];
	NSData *exampleRTF = [NSData dataWithContentsOfURL:exampleURL];
	NSAttributedString *attributedString = [[NSAttributedString alloc] initWithRTF:exampleRTF documentAttributes:nil];
	
	[self.richTextTextView.textStorage setAttributedString:attributedString];
	self.markdownTextView.string = [attributedString markdownRepresentation];
	
	[self.view.window makeFirstResponder:self.richTextTextView];
	self.richTextTextView.selectedRange = NSMakeRange(0, self.richTextTextView.string.length);
}

- (IBAction)setMarkdownExamples:(id)sender
{
	NSLog(@"%s called", __PRETTY_FUNCTION__);
	
	NSURL *exampleURL = [NSBundle.mainBundle URLForResource:@"Examples" withExtension:@"md"];
	NSData *exampleMarkdown = [NSData dataWithContentsOfURL:exampleURL];
	NSString *markdownString = [[NSString alloc] initWithData:exampleMarkdown encoding:NSUTF8StringEncoding];
	
	self.markdownTextView.string = markdownString;
#if !USE_STYLE_ATTRIBUTES
	NSAttributedString *attributedString = [[NSAttributedString alloc] initWithMarkdownRepresentation:markdownString attributes:self.baseAttributes];
#else
	NSAttributedString *attributedString = [[NSAttributedString alloc] initWithMarkdownRepresentation:markdownString baseAttributes:self.baseAttributes styleAttributes:self.styleAttributes];
#endif
	[self.richTextTextView.textStorage setAttributedString:attributedString];
	
	[self.view.window makeFirstResponder:self.markdownTextView];
	self.markdownTextView.selectedRange = NSMakeRange(0, self.markdownTextView.string.length);
}

- (void)setMarkdownSavedString
{
	NSLog(@"%s called", __PRETTY_FUNCTION__);
	
	NSString *markdownString = [NSUserDefaults.standardUserDefaults stringForKey:savedStringKey];
	
	self.markdownTextView.string = markdownString;
#if !USE_STYLE_ATTRIBUTES
	NSAttributedString *attributedString = [[NSAttributedString alloc] initWithMarkdownRepresentation:markdownString attributes:self.baseAttributes];
#else
	NSAttributedString *attributedString = [[NSAttributedString alloc] initWithMarkdownRepresentation:markdownString baseAttributes:self.baseAttributes styleAttributes:self.styleAttributes];
#endif
	[self.richTextTextView.textStorage setAttributedString:attributedString];
	
	[self.view.window makeFirstResponder:self.markdownTextView];
	self.markdownTextView.selectedRange = NSMakeRange(0, self.markdownTextView.string.length);
}

#pragma mark - NSTextViewDelegate

- (void)textDidChange:(NSNotification *)notification
{
	//NSLog(@"%s notification = %@", __PRETTY_FUNCTION__, notification);
	
	if (notification.object == self.richTextTextView) {
		NSString *markdownString = [self.richTextTextView.attributedString markdownRepresentation];
		self.markdownTextView.string = markdownString;
	}
	else if (notification.object == self.markdownTextView) {
#if !USE_STYLE_ATTRIBUTES
		NSAttributedString *richTextString = [[NSAttributedString alloc] initWithMarkdownRepresentation:self.markdownTextView.string attributes:self.baseAttributes];
#else
		NSAttributedString *richTextString = [[NSAttributedString alloc] initWithMarkdownRepresentation:self.markdownTextView.string baseAttributes:self.baseAttributes styleAttributes:self.styleAttributes];
#endif
		
		// NOTE: The logging below is helpful for generating tests in teh NSAttributedString+MarkdownTest target. Use the SampleApp to reproduce a
		// bad conversion, then copy the testString and compareString to a new test.
		
		[self.richTextTextView.textStorage setAttributedString:richTextString];
		NSLog(@"%s Markdown string = %@", __PRETTY_FUNCTION__, self.markdownTextView.string);
		
		NSMutableString *sourceString = [self.markdownTextView.string mutableCopy];
		[sourceString replaceOccurrencesOfString:@"\\" withString:@"\\\\" options:(0) range:NSMakeRange(0, sourceString.length)];
		[sourceString replaceOccurrencesOfString:@"\n" withString:@"\\n" options:(0) range:NSMakeRange(0, sourceString.length)];
		[sourceString replaceOccurrencesOfString:@"\t" withString:@"\\t" options:(0) range:NSMakeRange(0, sourceString.length)];
		NSLog(@"NSString *testString = @\"%@\";", sourceString);
		
		NSMutableString *compareString = [[richTextString markdownDebug] mutableCopy];
		[compareString replaceOccurrencesOfString:@"\\" withString:@"\\\\" options:(0) range:NSMakeRange(0, compareString.length)];
		NSLog(@"NSString *compareString = @\"%@\";", compareString);
		
		[NSUserDefaults.standardUserDefaults setObject:self.markdownTextView.string forKey:savedStringKey];
		[NSUserDefaults.standardUserDefaults synchronize];
	}
}

@end
