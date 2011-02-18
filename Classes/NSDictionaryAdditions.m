
#import "NSDictionaryAdditions.h"

#import "NSDateAdditions.h"
#import <Three20Core/NSStringAdditions.h>


@implementation NSDictionary (NSNullSafe_Convenience)

- (id)objectForKey:(NSString *)aKey orDefault:(id)value {
	id obj = [self objectForKey:aKey];
	if (!obj || obj == [NSNull null]) {
		return value;
	} else {
		return obj;
	}
}


- (id)objectForKeyOrNil:(NSString *)aKey {
	return [self objectForKey:aKey orDefault:nil];
}


- (NSURL *)urlForKey:(NSString *)key orDefault:(NSURL *)url {
	NSString *str = [self objectForKeyOrNil:key];
	if (str && ![str isEmptyOrWhitespace]) {
		return [NSURL URLWithString:str];
	} else {
		return url;
	}
}


- (NSDate *)dateForKey:(NSString *)key orDefault:(NSDate *)date {
	NSString *str = [self objectForKeyOrNil:key];
	if (str && ![str isEmptyOrWhitespace]) {
		return [NSDate dateWithISOString:str];
	} else {
		return date;
	}
}


- (BOOL)boolForKey:(NSString *)key orDefault:(BOOL)value {
	id b = [self objectForKey:key];
	if (b && b != [NSNull null]) {
		return [b boolValue];
	} else {
		return value;
	}
}

@end
