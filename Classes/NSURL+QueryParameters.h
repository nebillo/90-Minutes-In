
@interface NSURL (QueryParameters)

- (NSDictionary *)queryStringParameters;
- (NSURL *)urlByAddingQueryStringParameters:(NSDictionary *)newParameters;

@end
