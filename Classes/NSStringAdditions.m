
#import "NSStringAdditions.h"


@implementation NSString (URLEncoder)

- (NSString *)stringByEncodingForURL {
	NSString *str = (NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)self,
																		NULL, CFSTR("!*’();:@&=+$,/?%#[]"), kCFStringEncodingUTF8);
	return [str autorelease];
}

@end



@implementation NSString (Removing)

- (NSString *)stringByRemovingCharacterNotInString:(NSString *)exclude {
	NSMutableString *cleanString = [NSMutableString stringWithString:@""];
	for (NSUInteger i = 0; i < [self length]; i++) {
		NSString *letter = [NSString stringWithFormat:@"%C",[self characterAtIndex:i]];
		if (!NSEqualRanges([exclude rangeOfString:letter], NSMakeRange(NSNotFound, 0)))
			[cleanString appendString:letter];
	}
	return cleanString;
}

@end



@implementation NSString (TelephoneNumber)

- (NSString *)callableTelephoneNumber {
	static NSString * const telephoneCharacters = @"+0123456789";
	
	NSString *result = [self stringByRemovingCharacterNotInString:telephoneCharacters];
	return result;
}

@end



@implementation NSString (Email)

- (NSString *)stringByValidatingAsEmail {
	NSString *cleaned = [self stringByReplacingOccurrencesOfString:@" " withString:@""];
	
	NSArray *components = [cleaned componentsSeparatedByString:@"@"];
	if (components.count != 2) {
		return nil;
	}
	if (![[components objectAtIndex:0] length] || ![[components lastObject] length]) {
		return nil;
	}
	
	components = [[components lastObject] componentsSeparatedByString:@"."];
	if (components.count < 2) {
		return nil;
	}
	if (![[components objectAtIndex:0] length] || ![[components lastObject] length]) {
		return nil;
	}
	
	return cleaned;
}

@end

