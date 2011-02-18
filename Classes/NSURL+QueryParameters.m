
#import "NSURL+QueryParameters.h"

#import <Three20Core/NSStringAdditions.h>
#import "NSStringAdditions.h"


@implementation NSURL (QueryParameters)

- (NSDictionary *)queryStringParameters {
    return [[self query] queryContentsUsingEncoding:NSUTF8StringEncoding];
}


- (NSURL *)urlByAddingQueryStringParameters:(NSDictionary *)parameters {
	NSMutableDictionary *params = [NSMutableDictionary dictionary];
	for (NSString *key in parameters) {
		[params setObject:[[parameters objectForKey:key] stringByEncodingForURL] forKey:key];
	}
	NSString *newUrl = [[self absoluteString] stringByAddingQueryDictionary:params];
	return [NSURL URLWithString:newUrl];
}

@end
