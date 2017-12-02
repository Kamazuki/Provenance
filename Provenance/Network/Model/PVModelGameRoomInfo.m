//
//  PVModelGameRoomInfo.m
//  Provenance
//
//  Created by Kamazuki on 2017/11/24.
//  Copyright © 2017年 James Addyman. All rights reserved.
//

#import "PVModelGameRoomInfo.h"

@implementation PVModelGameRoomInfo

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"m_userArray" : [PVModelUser class]};
}

@end
