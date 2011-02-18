
@interface NSDictionary (NSNullSafe_Convenience)

- (id)objectForKey:(NSString *)aKey orDefault:(id)value;
- (id)objectForKeyOrNil:(NSString *)aKey;
- (NSURL *)urlForKey:(NSString *)key orDefault:(NSURL *)url;
- (NSDate *)dateForKey:(NSString *)key orDefault:(NSDate *)date;
- (BOOL)boolForKey:(NSString *)key orDefault:(BOOL)value;

@end
