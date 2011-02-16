//
//  NMUser.h
//  NinetyMinutes
//
//  Created by Nebil on 12/02/11.
//  Copyright 2011 Nebil Kriedi. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NMUser : NSObject <NSCoding>
{
}

@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, copy) NSString *facebookId;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *firstName;
@property (nonatomic, copy) NSString *lastName;
@property (nonatomic, copy) NSString *picture;

- (id)initWithDictionary:(NSDictionary *)dictionary;

@end
