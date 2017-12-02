//
//  PVModelGameStatus.m
//  Provenance
//
//  Created by Kamazuki on 2017/11/16.
//  Copyright © 2017年 James Addyman. All rights reserved.
//

#import "PVModelGameStatus.h"

@implementation PVModelGameStatus

-(NSString*) debugDescription
{
    return [NSString stringWithFormat:@"m_controllerStatus = %llu", self.m_controllerStatus];
}

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"m_controllerStatus" : @"s"};
}

@end
