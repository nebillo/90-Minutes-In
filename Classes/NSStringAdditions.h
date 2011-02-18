
@interface NSString (URLEncoder)

- (NSString *)stringByEncodingForURL;

@end


@interface NSString (Removing)

- (NSString *)stringByRemovingCharacterNotInString:(NSString *)exclude;

@end


@interface NSString (TelephoneNumber)

- (NSString *)callableTelephoneNumber;

@end


@interface NSString (Email)

- (NSString *)stringByValidatingAsEmail;

@end
