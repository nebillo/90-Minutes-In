
@interface NSDate (ISODateFormatter)

+ (NSDate *)dateWithISOString:(NSString *)string;
- (NSString *)isoDescription;
- (NSString *)shortDescription;

@end
