
#import "NSDateAdditions.h"

#import "ISO8601DateFormatter.h"


ISO8601DateFormatter *_isoDateFormatter;

ISO8601DateFormatter *NMIsoDateFormatter() {
	@synchronized(_isoDateFormatter) {
		if (_isoDateFormatter == nil) {
			_isoDateFormatter = [[ISO8601DateFormatter alloc] init];
		}
	}
	return _isoDateFormatter;
}


@implementation NSDate (ISOFormatter)

+ (NSDate *)dateWithISOString:(NSString *)string {
	return [NMIsoDateFormatter() dateFromString:string];
}


- (NSString *)isoDescription {
	return [NMIsoDateFormatter() stringFromDate:self];
}

@end
