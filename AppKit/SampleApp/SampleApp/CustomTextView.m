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

// https://christiantietze.de/posts/2021/02/disable-nstextattachment-sharing-service/
- (NSArray<NSSharingService *> *)sharingServicePicker:(NSSharingServicePicker *)sharingServicePicker sharingServicesForItems:(NSArray *)items proposedSharingServices:(NSArray<NSSharingService *> *)proposedServices
{
	return @[];
}

#if 1
- (NSArray<NSPasteboardType> *)writablePasteboardTypes
{
	NSMutableArray *result = [[super writablePasteboardTypes] mutableCopy];
	if (self.isRichText) {
		[result insertObject:UTTypeTot atIndex:0];
		[result insertObject:NSPasteboardTypeRTF atIndex:1];
#if 0 // include RTFD (with images for horizontal rules)
		[result insertObject:NSPasteboardTypeRTFD atIndex:2];
#endif
		[result addObject:NSPasteboardTypeString];
	}
	else {
		[result addObject:UTTypeMarkdown];
		[result addObject:NSPasteboardTypeString];
	}
	
#if 1 // use 0 to remove the workaround for Apple bullshit
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
	// NOTE: These pasteboard types overrides the NSPasteboardTypeRTFD and NSPasteboardTypeRTF specified above and add styling
	// to the pasteboard.
	[result removeObject:NSRTFDPboardType]; // NSRTFDPboardType = "NeXT RTFD pasteboard type"
	[result removeObject:NSRTFPboardType]; // NSRTFPboardType = "NeXT Rich Text Format v1.0 pasteboard type"

	// NOTE: This pasteboard types overrides the NSPasteboardTypeString specified above and wipes out the text we put on the
	// pasteboard. Also, the following is misleading:
	//
	// NSPasteboardType NSStringPboardType API_DEPRECATED_WITH_REPLACEMENT("NSPasteboardTypeString" ...)
	//
	// The original definition has the value "NSStringPboardType", the new one uses "public.utf8-plain-text".
	[result removeObject:NSStringPboardType]; // NSStringPboardType = "NSStringPboardType"
#pragma clang diagnostic pop
#endif
	
	NSLog(@"%s writablePasteboardTypes = %@", __PRETTY_FUNCTION__, result);

	return [result copy];
}
#endif

- (BOOL)writeSelectionToPasteboard:(NSPasteboard *)pasteboard type:(NSPasteboardType)type
{
	NSLog(@"%s type = %@", __PRETTY_FUNCTION__, type);
	
	BOOL result = NO;
	
	NSRange range = self.selectedRange;
	//NSAttributedString *debugString = [self.attributedString attributedSubstringFromRange:range];
	//NSLog(@"%s range = %@, debugString = %@", __PRETTY_FUNCTION__, NSStringFromRange(range), debugString);

	if ([type isEqualToString:UTTypeTot]) {
		if (self.isRichText) {
			NSAttributedString *attributedString = [self.attributedString attributedSubstringFromRange:range];
			NSData *data = [NSKeyedArchiver archivedDataWithRootObject:attributedString requiringSecureCoding:NO error:nil];
			[pasteboard setData:data forType:UTTypeTot];
			result = YES;
		}
	}
	else if ([type isEqualToString:UTTypeMarkdown]) {
		if (!self.isRichText) {
			NSString *string = [self.string substringWithRange:range];
			[pasteboard setString:string forType:UTTypeMarkdown];
			result = YES;
		}
	}
	else if ([type isEqualToString:NSPasteboardTypeRTF]) {
		if (self.isRichText) {
			unichar character = NSAttachmentCharacter;
			NSString *attachmentString = [NSString stringWithCharacters:&character length:1];

			// remove color from the attributed string before putting it on the clipboard
			NSMutableAttributedString *editingAttributedString = [[self.attributedString attributedSubstringFromRange:range] mutableCopy];
			NSLog(@"%s RTF editingAttributedString = %@", __PRETTY_FUNCTION__, editingAttributedString);
			NSRange editingRange = NSMakeRange(0, editingAttributedString.length);
			[editingAttributedString removeAttribute:NSForegroundColorAttributeName range:editingRange];
			[editingAttributedString removeAttribute:NSAttachmentAttributeName range:editingRange];
			NSString *replacement = @"━━━━ • ━━━━";
			//NSString *replacement = @"──── · ────";
			[editingAttributedString.mutableString replaceOccurrencesOfString:attachmentString withString:replacement options:(0) range:NSMakeRange(0, editingAttributedString.length)];
			NSAttributedString *convertedAttributedString = [editingAttributedString copy];
			NSLog(@"%s RTF convertedAttributedString = %@", __PRETTY_FUNCTION__, convertedAttributedString);

			NSData *data = [convertedAttributedString RTFFromRange:NSMakeRange(0, convertedAttributedString.length) documentAttributes:@{}];
			//id data = [convertedAttributedString pasteboardPropertyListForType:NSPasteboardTypeRTFD];
			NSLog(@"%s RTF data.length = %ld", __PRETTY_FUNCTION__, data.length);
			[pasteboard setData:data forType:NSPasteboardTypeRTF];
			result = YES;
		}
	}
	else if ([type isEqualToString:NSPasteboardTypeRTFD]) {
		if (self.isRichText) {
			// remove color from the attributed string before putting it on the clipboard
			NSMutableAttributedString *editingAttributedString = [[self.attributedString attributedSubstringFromRange:range] mutableCopy];
			//NSLog(@"%s RTFD editingAttributedString = %@", __PRETTY_FUNCTION__, editingAttributedString);
			NSRange editingRange = NSMakeRange(0, editingAttributedString.length);
			[editingAttributedString removeAttribute:NSForegroundColorAttributeName range:editingRange];
			NSAttributedString *convertedAttributedString = [editingAttributedString copy];
			//NSLog(@"%s RTFD convertedAttributedString = %@", __PRETTY_FUNCTION__, convertedAttributedString);

			NSData *data = [convertedAttributedString RTFDFromRange:NSMakeRange(0, convertedAttributedString.length) documentAttributes:@{}];
			//id data = [convertedAttributedString pasteboardPropertyListForType:NSPasteboardTypeRTFD];
			//NSLog(@"%s RTFD data.length = %ld", __PRETTY_FUNCTION__, data.length);
			[pasteboard setData:data forType:NSPasteboardTypeRTFD];
			result = YES;
		}
	}
	else if ([type isEqualToString:NSPasteboardTypeString]) {
		if (self.isRichText) {
			unichar character = NSAttachmentCharacter;
			NSString *attachmentString = [NSString stringWithCharacters:&character length:1];

			NSMutableAttributedString *editingAttributedString = [[self.attributedString attributedSubstringFromRange:range] mutableCopy];
			NSLog(@"%s PLAIN editingAttributedString = %@", __PRETTY_FUNCTION__, editingAttributedString);
			NSString *replacement = @"━━━━ • ━━━━";
			//NSString *replacement = @"──── · ────";
			[editingAttributedString.mutableString replaceOccurrencesOfString:attachmentString withString:replacement options:(0) range:NSMakeRange(0, editingAttributedString.length)];
			NSString *convertedString = editingAttributedString.string;
			NSLog(@"%s PLAIN convertedString = %@", __PRETTY_FUNCTION__, convertedString);
			
			[pasteboard setString:convertedString forType:NSPasteboardTypeString];
			result = YES;
		}
		else {
			NSString *string = [self.string substringWithRange:range];
			NSLog(@"%s PLAIN string = %@", __PRETTY_FUNCTION__, string);
			[pasteboard setString:string forType:NSPasteboardTypeString];
			result = YES;
		}
	}
	else {
		result = [super writeSelectionToPasteboard:pasteboard type:type];
	}
	
	return result;
}

- (NSArray<NSPasteboardType> *)readablePasteboardTypes
{
	NSMutableArray *result = [[super readablePasteboardTypes] mutableCopy];
	[result insertObject:UTTypeTot atIndex:0];
	[result addObject:UTTypeMarkdown];
	return [result copy];
}

// Invoked automatically to read a specific type from the pasteboard.  The type will already have been by the preferredPasteboardTypeFromArray:restrictedToTypesFromArray: method so this should merely read the data using the appropriate accessor method on the pasteboard.
- (BOOL)readSelectionFromPasteboard:(NSPasteboard *)pasteboard type:(NSPasteboardType)type
{
	if ([self updateWithPasteboard:pasteboard inRange:self.selectedRange]) {
		return YES;
	}
	
	return [super readSelectionFromPasteboard:pasteboard type:type];
}

/*
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
 */

/*
- (BOOL)prepareForDragOperation:(id <NSDraggingInfo>)sender
{
	NSRange range = self.selectedRange;
	if (range.length == 0) {
		range.location = 0;
		range.length = self.attributedString.length;
	}

	NSLog(@"%s pasteboard = %@", __PRETTY_FUNCTION__, sender.draggingPasteboard.pasteboardItems.firstObject.types);
	if (self.isRichText) {
		// remove color from the attributed string before putting it on the clipboard
		NSMutableAttributedString *editingAttributedString = [[self.attributedString attributedSubstringFromRange:range] mutableCopy];

		NSData *data = [NSKeyedArchiver archivedDataWithRootObject:editingAttributedString requiringSecureCoding:NO error:nil];
		[sender.draggingPasteboard setData:data forType:UTTypeTot];
	}
	BOOL result = [super prepareForDragOperation:sender];

	NSLog(@"%s result = %d, pasteboard = %@", __PRETTY_FUNCTION__, result, sender.draggingPasteboard.pasteboardItems.firstObject.types);
	return result;
}
*/

/*
- (BOOL)performDragOperation:(id<NSDraggingInfo>)sender
{
	BOOL result = NO;

	NSPoint draggingLocation = sender.draggingLocation;
	NSUInteger index = [self characterIndexForInsertionAtPoint:[self convertPoint:draggingLocation fromView:nil]];
	NSRange dragRange = NSMakeRange(index, 0);

	if (sender.draggingSource == self) {
#if 1
		result = [super performDragOperation:sender];
#else
		NSPasteboardItem *pasteboardItem = sender.draggingPasteboard.pasteboardItems.firstObject;
		if ([pasteboardItem.types containsObject:UTTypeTot]) {
			NSData *data = [pasteboardItem dataForType:UTTypeTot];
			NSAttributedString *dragAttributedString = [NSKeyedUnarchiver unarchivedObjectOfClass:[NSAttributedString class] fromData:data error:nil];
			if (dragAttributedString != nil) {
				if ([self shouldChangeTextInRange:dragRange replacementString:dragAttributedString.string]) {
					[self.textStorage replaceCharactersInRange:dragRange withAttributedString:dragAttributedString];
					[self.textStorage replaceCharactersInRange:self.selectedRange withString:@""];
					[self didChangeText];

					self.selectedRange = dragRange;

					result = YES;
				}
			}
		}
		else {
			result = [super performDragOperation:sender];
		}
#endif
	}
	else {
		if ([self updateWithPasteboard:sender.draggingPasteboard inRange:dragRange selectRange:YES]) {
			result = YES;
		}
		else {
			result = [super performDragOperation:sender];
		}
	}
	
	return result;
}
*/

#pragma mark - Utility

- (NSAttributedString *)matchingAttributedString:(NSAttributedString *)attributedString processBlockElements:(BOOL)processBlockElements
{
	NSString *markdownString = [attributedString markdownRepresentation];
	NSAttributedString *result = [[NSAttributedString alloc] initWithMarkdownRepresentation:markdownString baseAttributes:self.baseAttributes styleAttributes:self.styleAttributes processBlockElements:processBlockElements];
	
	return result;
}

- (NSAttributedString *)matchingAttributedString:(NSAttributedString *)attributedString
{
	return [self matchingAttributedString:attributedString processBlockElements:YES];
}

- (NSAttributedString *)matchingString:(NSString *)string
{
	return [[NSAttributedString alloc] initWithString:string attributes:self.baseAttributes];
}

- (BOOL)updateWithString:(NSString *)string inRange:(NSRange)range richText:(BOOL)richText
{
	BOOL result = NO;
	
	NSAttributedString *matchingAttributedString = [self matchingString:string];
	if ([self shouldChangeTextInRange:range replacementString:matchingAttributedString.string]) {
		[self.textStorage replaceCharactersInRange:range withAttributedString:matchingAttributedString];
		[self didChangeText];
		
		result = YES;
	}
	
	return result;
}

- (BOOL)updateWithMarkdownAttributedString:(NSAttributedString *)attributedString inRange:(NSRange)range
{
	BOOL result = NO;

	NSString *string = [attributedString markdownRepresentation];
	NSAttributedString *matchingAttributedString = [self matchingString:string];
	if ([self shouldChangeTextInRange:range replacementString:matchingAttributedString.string]) {
		[self.textStorage replaceCharactersInRange:range withAttributedString:matchingAttributedString];
		[self didChangeText];

		result = YES;
	}

	return result;
}

- (BOOL)updateWithAttributedString:(NSAttributedString *)attributedString inRange:(NSRange)range
{
	BOOL result = NO;

	NSAttributedString *matchingAttributedString = [self matchingAttributedString:attributedString];

	// NOTE: The range is checked to ensure that text attachments are surrounded by newlines
	if (matchingAttributedString.length > 0) {
		unichar character = NSAttachmentCharacter;
		NSString *attachmentString = [NSString stringWithCharacters:&character length:1];
		NSString *beginningString = [matchingAttributedString.string substringToIndex:1];
		NSString *endingString = [matchingAttributedString.string substringFromIndex:matchingAttributedString.length - 1];
		BOOL needsPrefix = [beginningString isEqualToString:attachmentString];
		BOOL needsSuffix = [endingString isEqualToString:attachmentString];
		if (needsPrefix || needsSuffix) {
			NSString *destinationString = self.textStorage.string;
			if (range.location > 0) {
				NSRange leadingRange = NSMakeRange(range.location - 1, 1);
				if ([[destinationString substringWithRange:leadingRange] isEqual:@"\n"]) {
					needsPrefix = NO;
				}
			}
			if (range.location + range.length < destinationString.length - 1) {
				NSRange trailingRange = NSMakeRange(range.location + range.length, 1);
				if ([[destinationString substringWithRange:trailingRange] isEqual:@"\n"]) {
					needsSuffix = NO;
				}
			}
			NSAttributedString *newline = [[NSAttributedString alloc] initWithString:@"\n"];

			NSMutableAttributedString *updatedMatchingAttributedString = [matchingAttributedString mutableCopy];
			if (needsPrefix) {
				[updatedMatchingAttributedString insertAttributedString:newline atIndex:0];
			}
			if (needsSuffix) {
				[updatedMatchingAttributedString appendAttributedString:newline];
			}
			matchingAttributedString = [updatedMatchingAttributedString copy];
		}
	}
	
	if ([self shouldChangeTextInRange:range replacementString:matchingAttributedString.string]) {
		[self.textStorage replaceCharactersInRange:range withAttributedString:matchingAttributedString];
		[self didChangeText];

		result = YES;
	}

	return result;
}

- (BOOL)updateWithMarkdownString:(NSString *)string inRange:(NSRange)range
{
	BOOL result = NO;

	NSAttributedString *attributedString = [[NSAttributedString alloc] initWithMarkdownRepresentation:string baseAttributes:self.baseAttributes styleAttributes:self.styleAttributes];
	if ([self shouldChangeTextInRange:range replacementString:attributedString.string]) {
		[self.textStorage replaceCharactersInRange:range withAttributedString:attributedString];
		[self didChangeText];

		result = YES;
	}

	return result;
}

- (BOOL)updateWithPasteboard:(NSPasteboard *)pasteboard inRange:(NSRange)range
{
	BOOL result = NO;
	
	NSPasteboardItem *pasteboardItem = pasteboard.pasteboardItems.firstObject;

	if ([pasteboardItem.types containsObject:UTTypeTot]) {
		NSData *data = [pasteboardItem dataForType:UTTypeTot];
		NSAttributedString *attributedString = [NSKeyedUnarchiver unarchivedObjectOfClass:[NSAttributedString class] fromData:data error:nil];
		if (attributedString != nil) {
			result = [self updateWithAttributedString:attributedString inRange:range];
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
				result = [self updateWithAttributedString:linkString inRange:range];
			}
			else if (URL) {
				NSAttributedString *linkString = [[NSAttributedString alloc] initWithString:URLString attributes:URLAttributes];
				result = [self updateWithAttributedString:linkString inRange:range];
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
				
				result = [self updateWithString:string inRange:range richText:NO];
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
						result = [self updateWithAttributedString:attributedString inRange:range];
					}
					else {
						result = [self updateWithMarkdownAttributedString:attributedString inRange:range];
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
						result = [self updateWithMarkdownString:string inRange:range];
					}
					else {
						result = [self updateWithString:string inRange:range richText:self.isRichText];
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
					result = [self updateWithAttributedString:attributedString inRange:range];
				}
				else {
					result = [self updateWithMarkdownAttributedString:attributedString inRange:range];
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
					result = [self updateWithAttributedString:attributedString inRange:range];
				}
				else {
					result = [self updateWithMarkdownAttributedString:attributedString inRange:range];
				}
			}
		}
	} // end NSPasteboardTypeHTML
	else if ([pasteboardItem.types containsObject:UTTypeMarkdown]) {
		NSString *string = [pasteboardItem stringForType:UTTypeMarkdown];
		if (string) {
			if (self.isRichText) {
				result = [self updateWithMarkdownString:string inRange:range];
			}
			else {
				result = [self updateWithString:string inRange:range richText:self.isRichText];
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
					result = [self updateWithAttributedString:linkString inRange:range];
				}
				else {
					result = [self updateWithString:string inRange:range richText:NO];
				}
			}
			else {
				result = [self updateWithString:string inRange:range richText:self.isRichText];
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
