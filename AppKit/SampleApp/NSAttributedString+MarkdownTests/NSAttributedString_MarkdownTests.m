//
//  NSAttributedString_MarkdownTests.m
//  NSAttributedString+MarkdownTests
//
//  Created by Craig Hockenberry on 2/21/20.
//  Copyright © 2020 The Iconfactory. All rights reserved.
//

#import <XCTest/XCTest.h>


#define TESTING 1 // to get -markdownDebug
#import "NSAttributedString+Markdown.h"

@interface NSAttributedString_MarkdownTests : XCTestCase

@property (class, nonatomic, readonly, strong) NSString *longMarkdownString;

@end

@implementation NSAttributedString_MarkdownTests

- (void)setUp
{
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

+ (NSString *)longMarkdownString
{
	static NSString *result = nil;
	if (! result) {
		NSURL *longMarkdownURL = [NSBundle.mainBundle URLForResource:@"Long" withExtension:@"md"];
		NSData *longMarkdownData = [NSData dataWithContentsOfURL:longMarkdownURL];
		result = [[NSString alloc] initWithData:longMarkdownData encoding:NSUTF8StringEncoding];
	}
	return result;
}

static BOOL checkMarkdownToRichText(NSString *testString, NSString *compareString)
{
	NSAttributedString *attributedTestString = [[NSAttributedString alloc] initWithMarkdownRepresentation:testString attributes:@{ NSFontAttributeName: [NSFont systemFontOfSize:12.0] }];
	NSString *checkString = [attributedTestString markdownDebug];
	NSLog(@"%s checkString = %@", __PRETTY_FUNCTION__, checkString);
	return [checkString isEqual:compareString];
}

static BOOL checkRichTextToMarkdown(NSAttributedString *testString, NSString *compareString)
{
	NSString *checkString = [testString markdownRepresentation];
	NSLog(@"%s checkString = %@", __PRETTY_FUNCTION__, checkString);
	return [checkString isEqual:compareString];
}

static BOOL checkMarkdownRoundTrip(NSString *testString)
{
	NSAttributedString *attributedTestString = [[NSAttributedString alloc] initWithMarkdownRepresentation:testString attributes:@{ NSFontAttributeName: [NSFont systemFontOfSize:12.0] }];
	NSString *checkString = [attributedTestString markdownRepresentation];
	return [checkString isEqual:testString];
}

- (void)testPlainText
{
	NSString *testString = @"Test plain text";
	NSString *compareString = @"[Test plain text](  )";
	XCTAssert(checkMarkdownToRichText(testString, compareString), @"Markdown to rich text test failed");
	XCTAssert(checkMarkdownRoundTrip(testString), @"Round-trip test failed");
}

- (void)testLiterals
{
	NSString *testString = @"Test \\*\\* \\_\\_ and \\* \\_ in string";
	NSString *compareString = @"[Test ** __ and * _ in string](  )";
	XCTAssert(checkMarkdownToRichText(testString, compareString), @"Markdown to rich text test failed");
	// no round-trip test because conversion is lossy (literals aren't strictly needed)
}

- (void)testBareLiterals
{
	NSString *testString = @"Test * and _ in string";
	NSString *compareString = @"[Test * and _ in string](  )";
	XCTAssert(checkMarkdownToRichText(testString, compareString), @"Markdown to rich text test failed");
	XCTAssert(checkMarkdownRoundTrip(testString), @"Round-trip test failed");
}

- (void)testSpanWithBareLiterals
{
	NSString *testString = @"Test for _span that contains _ and * literals_";
	NSString *compareString = @"[Test for ](  )[span that contains _ and * literals]( I)";
	XCTAssert(checkMarkdownToRichText(testString, compareString), @"Markdown to rich text test failed");
	XCTAssert(checkMarkdownRoundTrip(testString), @"Round-trip test failed");
}

- (void)testTabsWithBareLiterals
{
	NSString *testString = @"\t*\t*\t*\n\t_\t_\t_";
	NSString *compareString = @"[\\t*\\t*\\t*\\n\\t_\\t_\\t_](  )";
	XCTAssert(checkMarkdownToRichText(testString, compareString), @"Markdown to rich text test failed");
	XCTAssert(checkMarkdownRoundTrip(testString), @"Round-trip test failed");
}

- (void)testUnterminatedMarkers
{
	NSString *testString = @"Test * unterminated _ markers and \\*\\* _ escapes";
	NSString *compareString = @"[Test * unterminated _ markers and ** _ escapes](  )";
	XCTAssert(checkMarkdownToRichText(testString, compareString), @"Markdown to rich text test failed");
	XCTAssert(checkMarkdownRoundTrip(testString), @"Round-trip test failed");
}

- (void)testMiddleMarkers
{
	NSString *testString = @"Test un_frigging_believable";
	NSString *compareString = @"[Test un](  )[frigging]( I)[believable](  )";
	XCTAssert(checkMarkdownToRichText(testString, compareString), @"Markdown to rich text test failed");
	XCTAssert(checkMarkdownRoundTrip(testString), @"Round-trip test failed");
}

- (void)testLiteralsInSpan
{
	NSString *testString = @"Test _literals\\_in\\_text span_";
	NSString *compareString = @"[Test ](  )[literals_in_text span]( I)";
	XCTAssert(checkMarkdownToRichText(testString, compareString), @"Markdown to rich text test failed");
	XCTAssert(checkMarkdownRoundTrip(testString), @"Round-trip test failed");
}

- (void)testSymbolsInSpan
{
	NSString *testString = @"Test **span with ⌘ and ⚠️ symbols**";
	NSString *compareString = @"[Test ](  )[span with ⌘ and ⚠️ symbols](B )";
	XCTAssert(checkMarkdownToRichText(testString, compareString), @"Markdown to rich text test failed");
	XCTAssert(checkMarkdownRoundTrip(testString), @"Round-trip test failed");
}

- (void)testSymbolsAndLiterals
{
	NSString *testString = @"Test ¯\\\\\\_(ツ)\\_/¯";
	NSString *compareString = @"[Test ¯\\_(ツ)_/¯](  )";
	XCTAssert(checkMarkdownToRichText(testString, compareString), @"Markdown to rich text test failed");
	XCTAssert(checkMarkdownRoundTrip(testString), @"Round-trip test failed");
}

- (void)testStylesEmbedded
{
	NSString *testString = @"**Test _emphasis_ embedded** and _Test **strong** embedded_";
	NSString *compareString = @"[Test ](B )[emphasis](BI)[ embedded](B )[ and ](  )[Test ]( I)[strong](BI)[ embedded]( I)";
	XCTAssert(checkMarkdownToRichText(testString, compareString), @"Markdown to rich text test failed");
	XCTAssert(checkMarkdownRoundTrip(testString), @"Round-trip test failed");
}

- (void)testStylesEmbeddedWeirdly
{
	NSString *testString = @"Test **strong _and** emphasis_ embedded";
	NSString *compareString = @"[Test ](  )[strong ](B )[and](BI)[ emphasis]( I)[ embedded](  )";
	XCTAssert(checkMarkdownToRichText(testString, compareString), @"Markdown to rich text test failed");
	XCTAssert(checkMarkdownRoundTrip(testString), @"Round-trip test failed");
}

- (void)testStylesAcrossLines
{
	NSString *testString = @"Test the _beginning of a **span\nthat** continues on next line._ Because\n**Markdown** is a visual specfication.";
	NSString *compareString = @"[Test the ](  )[beginning of a ]( I)[span\\nthat](BI)[ continues on next line.]( I)[ Because\\n](  )[Markdown](B )[ is a visual specfication.](  )";
	XCTAssert(checkMarkdownToRichText(testString, compareString), @"Markdown to rich text test failed");
	XCTAssert(checkMarkdownRoundTrip(testString), @"Round-trip test failed");
}

- (void)testStylesAcrossLineBreaks
{
	NSString *testString = @"Test _emphasis\n\nthat will not span_ lines.";
	NSString *compareString = @"[Test _emphasis\\n\\nthat will not span_ lines.](  )";
	XCTAssert(checkMarkdownToRichText(testString, compareString), @"Markdown to rich text test failed");
	//XCTAssert(checkMarkdownRoundTrip(testString), @"Round-trip test failed");
}

- (void)testBlankSpans
{
	NSString *testString = @"Test **this.****\n\n**";
	NSString *compareString = @"[Test ](  )[this.](B )[**\\n\\n**](  )";
	XCTAssert(checkMarkdownToRichText(testString, compareString), @"Markdown to rich text test failed");
	//XCTAssert(checkMarkdownRoundTrip(testString), @"Round-trip test failed");
}

- (void)testStylesWithLiterals
{
	NSString *testString = @"Test **\\*\\*strong with literals\\*\\*** and _\\_emphasis too\\__";
	NSString *compareString = @"[Test ](  )[**strong with literals**](B )[ and ](  )[_emphasis too_]( I)";
	XCTAssert(checkMarkdownToRichText(testString, compareString), @"Markdown to rich text test failed");
	XCTAssert(checkMarkdownRoundTrip(testString), @"Round-trip test failed");
}

- (void)testBasicLinks
{
	NSString *testString = @"Test [inline links](https://iconfactory.com) and automatic links like <https://daringfireball.net/projects/markdown/syntax>";
	NSString *compareString = @"[Test ](  )[inline links](  )<https://iconfactory.com>[ and automatic links like ](  )[https://daringfireball.net/projects/markdown/syntax](  )<https://daringfireball.net/projects/markdown/syntax>";
	XCTAssert(checkMarkdownToRichText(testString, compareString), @"Markdown to rich text test failed");
	XCTAssert(checkMarkdownRoundTrip(testString), @"Round-trip test failed");
}

- (void)testOtherLinks
{
	NSString *testString = @"Test <zippy@pinhead.com> <tel:867-5309> <ssh:l33t@daringfireball.net> <dict://tot>";
	NSString *compareString = @"[Test ](  )[zippy@pinhead.com](  )<mailto:zippy@pinhead.com>[ ](  )[tel:867-5309](  )<tel:867-5309>[ ](  )[ssh:l33t@daringfireball.net](  )<ssh:l33t@daringfireball.net>[ ](  )[dict://tot](  )<dict://tot>";
	XCTAssert(checkMarkdownToRichText(testString, compareString), @"Markdown to rich text test failed");
	XCTAssert(checkMarkdownRoundTrip(testString), @"Round-trip test failed");
}

- (void)testAutomaticLinksWithUnterminatedMarkers
{
	NSString *testString = @"Test <https://music.apple.com/us/album/egg-man/721276795?i=721277066&uo=4&app=itunes&at=10l4G7&ct=STREAMER_MAC>";
	NSString *compareString = @"[Test ](  )[https://music.apple.com/us/album/egg-man/721276795?i=721277066&uo=4&app=itunes&at=10l4G7&ct=STREAMER_MAC](  )<https://music.apple.com/us/album/egg-man/721276795?i=721277066&uo=4&app=itunes&at=10l4G7&ct=STREAMER_MAC>";
	XCTAssert(checkMarkdownToRichText(testString, compareString), @"Markdown to rich text test failed");
	XCTAssert(checkMarkdownRoundTrip(testString), @"Round-trip test failed");
}

- (void)testAttributeLinksWithoutEscaping
{
	NSURL *URL = [NSURL URLWithString:@"https://music.apple.com/us/album/*/721276795?i=721277066&uo=4&app=itunes&at=10l4G7&ct=STREAMER_MAC"];
	
	NSMutableAttributedString *attributedTestString = [[NSMutableAttributedString alloc] initWithString:@""];
	NSAttributedString *bareLinkString = [[NSAttributedString alloc] initWithString:URL.absoluteString attributes:@{NSLinkAttributeName: URL}];
	[attributedTestString appendAttributedString:bareLinkString];
	NSAttributedString *spacerString = [[NSAttributedString alloc] initWithString:@" " attributes:nil];
	[attributedTestString appendAttributedString:spacerString];
	NSAttributedString *namedLinkString = [[NSAttributedString alloc] initWithString:@"inline" attributes:@{NSLinkAttributeName: URL}];
	[attributedTestString appendAttributedString:namedLinkString];

	NSString *compareString = @"<https://music.apple.com/us/album/*/721276795?i=721277066&uo=4&app=itunes&at=10l4G7&ct=STREAMER_MAC> [inline](https://music.apple.com/us/album/*/721276795?i=721277066&uo=4&app=itunes&at=10l4G7&ct=STREAMER_MAC)";

	XCTAssert(checkRichTextToMarkdown(attributedTestString, compareString), @"Rich text to Markdown test failed");
}

- (void)testAutomaticLinksWithMarkers
{
	NSString *testString = @"Test <https://daringfireball.net/2020/02/my_2019_apple_report_card>";
	NSString *compareString = @"[Test ](  )[https://daringfireball.net/2020/02/my_2019_apple_report_card](  )<https://daringfireball.net/2020/02/my_2019_apple_report_card>";
	XCTAssert(checkMarkdownToRichText(testString, compareString), @"Markdown to rich text test failed");
	XCTAssert(checkMarkdownRoundTrip(testString), @"Round-trip test failed");
}

- (void)testInlineLinksWithMarkers
{
	NSString *testString = @"Test **[w\\_oo\\_t](https://daringfireball.net/2020/02/my_2019_apple_report_card)**";
	NSString *compareString = @"[Test ](  )[w_oo_t](B )<https://daringfireball.net/2020/02/my_2019_apple_report_card>";	XCTAssert(checkMarkdownToRichText(testString, compareString), @"Markdown to rich text test failed");
	XCTAssert(checkMarkdownRoundTrip(testString), @"Round-trip test failed");
}

- (void)testIgnoreListMarker
{
	// https://daringfireball.net/projects/markdown/syntax#list
	// "List markers typically start at the left margin, but may be indented by up to three spaces. List markers must be followed by one or more spaces or a tab.

	NSString *testString = @"* One **item**\n * Two\n  * _Three_\n   * Four\n*\tFive\n *     Six\n\t*\tSeven";
	NSString *compareString = @"[* One ](  )[item](B )[\\n * Two\\n  * ](  )[Three]( I)[\\n   * Four\\n*\\tFive\\n *     Six\\n\\t*\\tSeven](  )";
	XCTAssert(checkMarkdownToRichText(testString, compareString), @"Markdown to rich text test failed");
	XCTAssert(checkMarkdownRoundTrip(testString), @"Round-trip test failed");
}

- (void)testIgnoreHorizontalRules
{
	// https://daringfireball.net/projects/markdown/syntax#hr
	// "You can produce a horizontal rule tag by placing three or more hyphens, asterisks, or underscores on a line by themselves. If you wish, you may use spaces between the hyphens or asterisks."
	
	NSString *testString = @"* * *\n***\n*****\n  *  *  *  \n*** ***\n_ _ _\n___\n_____\n  _ _ _ \n___ ___\n---\n";
	NSString *compareString = @"[* * *\\n***\\n*****\\n  *  *  *  \\n*** ***\\n_ _ _\\n___\\n_____\\n  _ _ _ \\n___ ___\\n---\\n](  )";
	XCTAssert(checkMarkdownToRichText(testString, compareString), @"Markdown to rich text test failed");
	XCTAssert(checkMarkdownRoundTrip(testString), @"Round-trip test failed");
}

- (void)testForPeopleWhoDoMarkdownWrong
{
	NSString *testString = @"Test *single asterisk* and __double underscore__";
	NSString *compareString = @"[Test ](  )[single asterisk]( I)[ and ](  )[double underscore](B )";
	XCTAssert(checkMarkdownToRichText(testString, compareString), @"People who do Markdown wrong test failed");
	// no round-trip test because the wrongs will be righted
}

- (void)testForPlainTextFromHell
{
	// Hell: https://support.code42.com/Administrator/6/Planning_and_installing/Manage_app_installations_in_your_Code42_environment/Deployment_script_and_command_reference

	NSString *testString = @" msiexec /i Code42CrashPlan_n.n.n_Win64.msi\n  CP_ARGS=“DEPLOYMENT_URL=https://.host:port\n  &DEPLOYMENT_POLICY_TOKEN=0fb12341-246b-448d-b07f-c6573ad5ad02\n  &SSL_WHITELIST=7746278a457e64737094c44eeb2bbc32357ece44\n  &PROXY_URL=http://.host:port/fname.pac”\n  CP_SILENT=true DEVICE_CLOAKED=false /norestart /qn \n\n";
	NSString *compareString = @"[ msiexec /i Code42CrashPlan](  )[n.n.n]( I)[Win64.msi\\n  CP](  )[ARGS=“DEPLOYMENT]( I)[URL=https://.host:port\\n  &DEPLOYMENT](  )[POLICY]( I)[TOKEN=0fb12341-246b-448d-b07f-c6573ad5ad02\\n  &SSL](  )[WHITELIST=7746278a457e64737094c44eeb2bbc32357ece44\\n  &PROXY]( I)[URL=http://.host:port/fname.pac”\\n  CP](  )[SILENT=true DEVICE]( I)[CLOAKED=false /norestart /qn \\n\\n](  )";
	XCTAssert(checkMarkdownToRichText(testString, compareString), @"Markdown to rich text test failed");
	XCTAssert(checkMarkdownRoundTrip(testString), @"Round-trip test failed");
}

- (void)testConversionToRichTextPerformance
{
	NSString *longMarkdownString = NSAttributedString_MarkdownTests.longMarkdownString;

    [self measureBlock:^{
		NSAttributedString *convertedMarkdownAttributedString = [[NSAttributedString alloc] initWithMarkdownRepresentation:longMarkdownString attributes:@{ NSFontAttributeName: [NSFont systemFontOfSize:12.0] }];
		NSLog(@"original length = %ld, converted length = %ld", longMarkdownString.length, convertedMarkdownAttributedString.length);
    }];
}

- (void)testConversionToMarkdownPerformance
{
	NSString *longMarkdownString = NSAttributedString_MarkdownTests.longMarkdownString;
	NSAttributedString *longAttributedMarkdownString = [[NSAttributedString alloc] initWithMarkdownRepresentation:longMarkdownString attributes:@{ NSFontAttributeName: [NSFont systemFontOfSize:12.0] }];

    [self measureBlock:^{
		NSString *convertedMarkdownString = [longAttributedMarkdownString markdownRepresentation];
		NSLog(@"original length = %ld, converted length = %ld", longAttributedMarkdownString.length, convertedMarkdownString.length);
    }];
}

- (void)testInlineLinksWithEscapes
{
	NSString *testString = @"[\\(opt\\-shift\\-k\\)](https://apple.com)\n";
	NSString *compareString = @"[(opt-shift-k)](  )<https://apple.com>[\\n](  )";
	XCTAssert(checkMarkdownToRichText(testString, compareString), @"Markdown to rich text test failed");
}

- (void)testInlineLinksWithWithoutEscapes
{
	NSString *testString = @"[This (should not break) parsing](https://apple.com)\n";
	NSString *compareString = @"[This (should not break) parsing](  )<https://apple.com>[\\n](  )";
	XCTAssert(checkMarkdownToRichText(testString, compareString), @"Markdown to rich text test failed");
}

- (void)testMarkdownEscapes
{
	NSMutableAttributedString *attributedTestString = [[NSMutableAttributedString alloc] initWithString:@"my_variable_name = 1;"];
	NSString *compareString = @"my\\_variable\\_name = 1;";
	XCTAssert(checkRichTextToMarkdown(attributedTestString, compareString), @"Rich text to Markdown test failed");
}

- (void)testBackslashEscapes
{
	NSString *testString = @"This is two \\\\\\\\ escapes and this is \\\\\\\\\\\\ three and don't break here \\";
	NSString *compareString = @"[This is two \\\\ escapes and this is \\\\\\ three and don't break here \\](  )";
	XCTAssert(checkMarkdownToRichText(testString, compareString), @"Markdown to rich text test failed");
	XCTAssert(checkMarkdownRoundTrip(testString), @"Round-trip test failed");
}

// NOTE: The following tests were submitted by Simon Ward in https://github.com/chockenberry/MarkdownAttributedString/issues/4

- (NSAttributedString *)attributedString:(NSString *)text withTraits:(NSFontDescriptorSymbolicTraits)traits
{
    NSFont *font = [NSFont systemFontOfSize: 17.0];
    NSFontDescriptor *fontDescriptor = font.fontDescriptor;
    NSFontDescriptorSymbolicTraits symbolicTraits = fontDescriptor.symbolicTraits;
    
    NSFontDescriptorSymbolicTraits newSymbolicTraits = symbolicTraits | traits;
    NSFontDescriptor *newFontDescriptor = [fontDescriptor fontDescriptorWithSymbolicTraits:newSymbolicTraits];
	NSFont *newFont = [NSFont fontWithDescriptor:newFontDescriptor size:font.pointSize];
    
    return [[NSAttributedString alloc] initWithString:text attributes:@{NSFontAttributeName: newFont}];
}

- (void)applySymbolicTraits:(NSFontDescriptorSymbolicTraits)traits toAttributedString:(NSMutableAttributedString *)attributedString range:(NSRange)range
{
    NSFont *font = [NSFont systemFontOfSize: 17.0];
    NSFontDescriptor *fontDescriptor = font.fontDescriptor;
    NSFontDescriptorSymbolicTraits symbolicTraits = fontDescriptor.symbolicTraits;
    
    NSFontDescriptorSymbolicTraits newSymbolicTraits = symbolicTraits | traits;
    NSFontDescriptor *newFontDescriptor = [fontDescriptor fontDescriptorWithSymbolicTraits:newSymbolicTraits];
    NSFont *newFont = [NSFont fontWithDescriptor:newFontDescriptor size:font.pointSize];
    
    [attributedString setAttributes:@{NSFontAttributeName: newFont} range:range];
}

- (void)testItalic
{
    NSAttributedString *attrString = [self attributedString:@"Italic" withTraits:NSFontDescriptorTraitItalic];
    XCTAssertEqualObjects(attrString.markdownRepresentation, @"_Italic_");
}

- (void)testBold
{
    NSAttributedString *attrString = [self attributedString:@"Bold" withTraits:NSFontDescriptorTraitBold];
    XCTAssertEqualObjects(attrString.markdownRepresentation, @"**Bold**");
}

- (void)testBoldItalic
{
    NSAttributedString *attrString = [self attributedString:@"Italic Bold" withTraits:NSFontDescriptorTraitItalic | NSFontDescriptorTraitBold];
    XCTAssertEqualObjects(attrString.markdownRepresentation, @"**_Italic Bold_**");
}

- (void)testSeparate
{
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:@"This is italic and this is bold."];
    [self applySymbolicTraits:NSFontDescriptorTraitItalic toAttributedString:attrString range:NSMakeRange(8, 6)];
    [self applySymbolicTraits:NSFontDescriptorTraitBold toAttributedString:attrString range:NSMakeRange(27, 4)];
    
    XCTAssertEqualObjects(attrString.markdownRepresentation, @"This is _italic_ and this is **bold**.");
}

#if NO
// NOTE: This test is disabled for now: https://github.com/chockenberry/MarkdownAttributedString/issues/4
// I'm not sure this is a valid test, Markdown (like HTML) has no requirement for the order of styling or its scope.
- (void)testOverlap
{
    NSMutableAttributedString *attrString1 = [[NSMutableAttributedString alloc] initWithString:@"Italic Bold"];
    [self applySymbolicTraits:NSFontDescriptorTraitItalic toAttributedString:attrString1 range:NSMakeRange(0, 11)];
    [self applySymbolicTraits:NSFontDescriptorTraitItalic | NSFontDescriptorTraitBold toAttributedString:attrString1 range:NSMakeRange(7, 4)];
    
    XCTAssertEqualObjects(attrString1.markdownRepresentation, @"_Italic **Bold**_");
    
    NSMutableAttributedString *attrString2 = [[NSMutableAttributedString alloc] initWithString:@"Bold Italic"];
    [self applySymbolicTraits:NSFontDescriptorTraitBold toAttributedString:attrString2 range:NSMakeRange(0, 11)];
    [self applySymbolicTraits:NSFontDescriptorTraitBold | NSFontDescriptorTraitItalic toAttributedString:attrString2 range:NSMakeRange(5, 6)];
    
    XCTAssertEqualObjects(attrString2.markdownRepresentation, @"**Bold _Italic_**");
}
#endif

#if NO
// NOTE: This test is disabled for now: https://github.com/chockenberry/MarkdownAttributedString/issues/5
// The test will pass if ESCAPE_ALL_LITERALS is turned on, but that has a nasty side effect where the punctuation in regular text gets escaped and becomes hard to read.
- (void)testEscaping
{
    for (NSString *character in @[@"\\", @"`", @"*", @"_", @"{", @"}", @"[", @"]", @"(", @")", @"#", @"+", @"-", @".", @"!"]) {
        NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:character];
        NSString *expected = [@"\\" stringByAppendingString:character];
        XCTAssertEqualObjects(attrString.markdownRepresentation, expected);
    }
}
#endif

@end
