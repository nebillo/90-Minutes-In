//
//  NMUser.h
//  NinetyMinutes
//
//  Created by Nebil on 12/02/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NMUser : NSObject <NSCoding>
{
}

@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *fullname;

@end
