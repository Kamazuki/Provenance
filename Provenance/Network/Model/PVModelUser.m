//
//  PVModelUser.m
//  Provenance
//
//  Created by Kamazuki on 2017/11/15.
//  Copyright © 2017年 James Addyman. All rights reserved.
//

#import "PVModelUser.h"

@implementation PVModelUser

-(NSString*) debugDescription
{
    return [NSString stringWithFormat:@"m_name = %@, m_id = %u", self.m_name, self.m_id];
}

@end
