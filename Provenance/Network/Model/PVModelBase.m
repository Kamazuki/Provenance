//
//  PVModelBase.m
//  Provenance
//
//  Created by Kamazuki on 2017/11/15.
//  Copyright © 2017年 James Addyman. All rights reserved.
//

#import "PVModelBase.h"

@implementation PVModelBase

-(NSString*) debugDescription
{
    return [NSString stringWithFormat:@"m_sequence:%llu", self.m_sequence];
}

@end
