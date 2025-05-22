//
//  CustomTextView.m
//  SampleApp
//
//  Created by Craig Hockenberry on 5/21/25.
//  Copyright © 2025 The Iconfactory. All rights reserved.
//

#import "CustomTextView.h"

NSString *const UTTypeTot = @"com.iconfactory.tot";

@implementation CustomTextView

- (NSArray<NSSharingService *> *)sharingServicePicker:(NSSharingServicePicker *)sharingServicePicker sharingServicesForItems:(NSArray *)items proposedSharingServices:(NSArray<NSSharingService *> *)proposedServices
{
	return @[];
}

- (void)copy:(id)sender
{
	NSLog(@"%s sender = %@", __PRETTY_FUNCTION__, sender);

	NSRange range = self.selectedRange;
	if (range.length == 0) {
		range.location = 0;
		range.length = self.attributedString.length;
	}

	NSPasteboard *pasteboard = NSPasteboard.generalPasteboard;
	[pasteboard clearContents];
	if (self.isRichText) {
		// remove color from the attributed string before putting it on the clipboard
		NSMutableAttributedString *editingAttributedString = [[self.attributedString attributedSubstringFromRange:range] mutableCopy];
		[editingAttributedString removeAttribute:NSForegroundColorAttributeName range:NSMakeRange(0, editingAttributedString.length)];
		NSAttributedString *convertedAttributedString = [editingAttributedString copy];
		
		[pasteboard writeObjects:@[ convertedAttributedString ]];

		NSData *data = [NSKeyedArchiver archivedDataWithRootObject:editingAttributedString requiringSecureCoding:NO error:nil];
		[pasteboard setData:data forType:UTTypeTot];
	}
	else {
		NSString *string = [self.string substringWithRange:range];

		[pasteboard addTypes:@[ UTTypeMarkdown ] owner:nil];
		[pasteboard setString:string forType:NSPasteboardTypeString];
		[pasteboard setString:string forType:UTTypeMarkdown];
	}
}

- (void)paste:(id)sender
{
	NSLog(@"%s sender = %@", __PRETTY_FUNCTION__, sender);
	if (! [self updateWithPasteboard:NSPasteboard.generalPasteboard inRange:self.selectedRange selectRange:NO]) {
		[super paste:sender];
	}
}

#pragma mark - Utility

- (NSAttributedString *)matchingAttributedString:(NSAttributedString *)attributedString
{
	NSString *markdownString = [attributedString markdownRepresentation];
	NSAttributedString *result = [[NSAttributedString alloc] initWithMarkdownRepresentation:markdownString baseAttributes:self.baseAttributes styleAttributes:self.styleAttributes];
	
	return result;
}

- (NSAttributedString *)matchingString:(NSString *)string
{
	return [[NSAttributedString alloc] initWithString:string attributes:self.baseAttributes];
}

- (BOOL)updateWithString:(NSString *)string inRange:(NSRange)range richText:(BOOL)richText selectRange:(BOOL)selectRange
{
	BOOL result = NO;
	
	NSAttributedString *matchingAttributedString = [self matchingString:string];
	if ([self shouldChangeTextInRange:range replacementString:matchingAttributedString.string]) {
		[self.textStorage replaceCharactersInRange:range withAttributedString:matchingAttributedString];
		[self didChangeText];
		if (selectRange) {
			self.selectedRange = NSMakeRange(range.location, string.length);
		}
		else {
			self.selectedRange = NSMakeRange(range.location + string.length, 0);
		}
		result = YES;
	}
	
	return result;
}

- (BOOL)updateWithMarkdownAttributedString:(NSAttributedString *)attributedString inRange:(NSRange)range selectRange:(BOOL)selectRange
{
	BOOL result = NO;

	NSString *string = [attributedString markdownRepresentation];
	NSAttributedString *matchingAttributedString = [self matchingString:string];
	if ([self shouldChangeTextInRange:range replacementString:matchingAttributedString.string]) {
		[self.textStorage replaceCharactersInRange:range withAttributedString:matchingAttributedString];
		[self didChangeText];
		if (selectRange) {
			self.selectedRange = NSMakeRange(range.location, string.length);
		}
		else {
			self.selectedRange = NSMakeRange(range.location + string.length, 0);
		}

		result = YES;
	}

	return result;
}

- (BOOL)updateWithAttributedString:(NSAttributedString *)attributedString inRange:(NSRange)range selectRange:(BOOL)selectRange
{
	BOOL result = NO;

	NSAttributedString *matchingAttributedString = [self matchingAttributedString:attributedString];
	
	NSDictionary<NSAttributedStringKey, id> *linkTextAttributes = self.linkTextAttributes;

	if ([self shouldChangeTextInRange:range replacementString:matchingAttributedString.string]) {
		[self.textStorage replaceCharactersInRange:range withAttributedString:matchingAttributedString];
		[self didChangeText];
		if (selectRange) {
			self.selectedRange = NSMakeRange(range.location, matchingAttributedString.length);
		}
		else {
			self.selectedRange = NSMakeRange(range.location + matchingAttributedString.length, 0);
		}

		result = YES;
	}

	return result;
}

- (BOOL)updateWithMarkdownString:(NSString *)string inRange:(NSRange)range selectRange:(BOOL)selectRange
{
	BOOL result = NO;

	NSAttributedString *attributedString = [[NSAttributedString alloc] initWithMarkdownRepresentation:string baseAttributes:self.baseAttributes styleAttributes:self.styleAttributes];
	if ([self shouldChangeTextInRange:range replacementString:attributedString.string]) {
		[self.textStorage replaceCharactersInRange:range withAttributedString:attributedString];
		[self didChangeText];
		if (selectRange) {
			self.selectedRange = NSMakeRange(range.location, attributedString.length);
		}
		else {
			self.selectedRange = NSMakeRange(range.location + attributedString.length, 0);
		}

		result = YES;
	}

	return result;
}

- (BOOL)updateWithPasteboard:(NSPasteboard *)pasteboard inRange:(NSRange)range selectRange:(BOOL)selectRange
{
	BOOL result = NO;
	
	NSPasteboardItem *pasteboardItem = pasteboard.pasteboardItems.firstObject;

	if ([pasteboardItem.types containsObject:UTTypeTot]) {
		NSData *data = [pasteboardItem dataForType:UTTypeTot];
		NSAttributedString *attributedString = [NSKeyedUnarchiver unarchivedObjectOfClass:[NSAttributedString class] fromData:data error:nil];
		if (attributedString != nil) {
			result = [self updateWithAttributedString:attributedString inRange:range selectRange:selectRange];
		}
	}
	else if ([pasteboardItem.types containsObject:NSPasteboardTypeURL]) {
		if (self.isRichText) {
			NSString *URLString = [pasteboardItem stringForType:NSPasteboardTypeURL];
			NSURL *URL = [NSURL URLWithString:URLString];
			NSString *nameString = [pasteboardItem stringForType:@"public.url-name"];
			
			NSMutableDictionary<NSAttributedStringKey, id> *URLAttributes = [self.baseAttributes mutableCopy];
			[URLAttributes setObject:URL forKey:NSLinkAttributeName];
			
			if (URL && nameString) {
				NSAttributedString *linkString = [[NSAttributedString alloc] initWithString:nameString attributes:URLAttributes];
				result = [self updateWithAttributedString:linkString inRange:range selectRange:selectRange];
			}
			else if (URL) {
				NSAttributedString *linkString = [[NSAttributedString alloc] initWithString:URLString attributes:URLAttributes];
				result = [self updateWithAttributedString:linkString inRange:range selectRange:selectRange];
			}
			else {
				// return NO and let superclass handle linking string up
			}
		}
		else {
			NSString *linkString = [pasteboardItem stringForType:NSPasteboardTypeURL];
			if (linkString) {
				NSString *string = nil;
				if ((NSEvent.modifierFlags & NSEventModifierFlagShift) != 0) {
					// some folks, namely John Gruber, want bare links when they drag into Tot.
					string = linkString;
				}
				else {
					string = [NSString stringWithFormat:@"<%@>", linkString];
				}
				
				result = [self updateWithString:string inRange:range richText:NO selectRange:selectRange];
			}
		}
	}
	else if ([pasteboardItem.types containsObject:NSPasteboardTypeFileURL]) {
		NSURL *URL = [NSURL URLFromPasteboard:pasteboard];
		if (URL) {
			NSLog(@"%s NSPasteboardTypeFileURL URL = %@", __PRETTY_FUNCTION__, URL);
			
			CFStringRef fileExtension = (__bridge CFStringRef)[URL pathExtension];
			CFStringRef fileUTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileExtension, NULL);
			
			if (UTTypeConformsTo(fileUTI, kUTTypeRTF)) {
				NSData *RTFData = [NSData dataWithContentsOfURL:URL];
				NSAttributedString *attributedString = [[NSAttributedString alloc] initWithRTF:RTFData documentAttributes:nil];
				if (attributedString) {
					//NSLog(@"%s NSPasteboardTypeFileURL attributedString = %@", __PRETTY_FUNCTION__, attributedString);
					
					if (self.isRichText) {
						result = [self updateWithAttributedString:attributedString inRange:range selectRange:selectRange];
					}
					else {
						result = [self updateWithMarkdownAttributedString:attributedString inRange:range selectRange:selectRange];
					}
				}
			}
			else if (UTTypeConformsTo(fileUTI, kUTTypeText)) {
				NSString *string = [NSString stringWithContentsOfURL:URL encoding:NSUTF8StringEncoding error:nil];
				if (string) {
					//NSLog(@"%s NSPasteboardTypeFileURL string = %@", __PRETTY_FUNCTION__, string);
		
					// NOTE: If the file UTI is for Markdown, we'll use it to generate an attributed string for the rich text view. Otherwise, it just
					// gets added as plain text.
					BOOL parseMarkdown = [(__bridge NSString *)fileUTI isEqual:UTTypeMarkdown];

					if (self.isRichText && parseMarkdown) {
						result = [self updateWithMarkdownString:string inRange:range selectRange:selectRange];
					}
					else {
						result = [self updateWithString:string inRange:range richText:self.isRichText selectRange:selectRange];
					}
				}
			}

			CFRelease(fileUTI);
		}
	} // end NSPasteboardTypeFileURL
	else if ([pasteboardItem.types containsObject:NSPasteboardTypeRTF]) {
		NSData *RTFData = [pasteboardItem dataForType:NSPasteboardTypeRTF];
		if (RTFData) {
			NSLog(@"%s NSPasteboardTypeRTF RTFData.length = %ld", __PRETTY_FUNCTION__, RTFData.length);
			NSAttributedString *attributedString = [[NSAttributedString alloc] initWithRTF:RTFData documentAttributes:nil];
			if (attributedString) {
				//NSLog(@"%s NSPasteboardTypeRTF attributedString = %@", __PRETTY_FUNCTION__, attributedString);
				
				if (self.isRichText) {
					result = [self updateWithAttributedString:attributedString inRange:range selectRange:selectRange];
				}
				else {
					result = [self updateWithMarkdownAttributedString:attributedString inRange:range selectRange:selectRange];
				}
			}
		}
	} // end NSPasteboardTypeRTF
	else if ([pasteboardItem.types containsObject:NSPasteboardTypeHTML]) {
		NSData *HTMLData = [pasteboardItem dataForType:NSPasteboardTypeHTML];
		if (HTMLData) {
			NSLog(@"%s NSPasteboardTypeHTML HTMLData.length = %ld", __PRETTY_FUNCTION__, HTMLData.length);
			NSAttributedString *attributedString = [[NSAttributedString alloc] initWithHTML:HTMLData documentAttributes:nil];
			if (attributedString) {
				//NSLog(@"%s NSPasteboardTypeHTML attributedString = %@", __PRETTY_FUNCTION__, attributedString);
				
				if (self.isRichText) {
					result = [self updateWithAttributedString:attributedString inRange:range selectRange:selectRange];
				}
				else {
					result = [self updateWithMarkdownAttributedString:attributedString inRange:range selectRange:selectRange];
				}
			}
		}
	} // end NSPasteboardTypeHTML
	else if ([pasteboardItem.types containsObject:UTTypeMarkdown]) {
		NSString *string = [pasteboardItem stringForType:UTTypeMarkdown];
		if (string) {
			if (self.isRichText) {
				result = [self updateWithMarkdownString:string inRange:range selectRange:selectRange];
			}
			else {
				result = [self updateWithString:string inRange:range richText:self.isRichText selectRange:selectRange];
			}
		}
	} // end UTTypeMarkdown
	else if ([pasteboardItem.types containsObject:NSPasteboardTypeString]) {
		NSString *string = [pasteboardItem stringForType:NSPasteboardTypeString];
		if (string) {
			NSURL *URL = [NSURL URLWithString:string];
			if (URL && URL.host) { // relative URLs are treated as plain text
				if (self.isRichText) {
					NSMutableDictionary<NSAttributedStringKey, id> *URLAttributes = [self.baseAttributes mutableCopy];
					[URLAttributes setObject:URL forKey:NSLinkAttributeName];

					NSAttributedString *linkString = [[NSAttributedString alloc] initWithString:string attributes:URLAttributes];
					result = [self updateWithAttributedString:linkString inRange:range selectRange:selectRange];
				}
				else {
					result = [self updateWithString:string inRange:range richText:NO selectRange:selectRange];
				}
			}
			else {
				result = [self updateWithString:string inRange:range richText:self.isRichText selectRange:selectRange];
			}
		}
	} // end NSPasteboardTypeString
	else {
		NSLog(@"%s no string data", __PRETTY_FUNCTION__);
		// return NO and let superclass handle pasteboard
	}
	
	return result;
}

@end
