//
//  PVModelGameRoomAction.h
//  Provenance
//
//  Created by Kamazuki on 2017/11/24.
//  Copyright © 2017年 James Addyman. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : unsigned int
{
    PVModelGameRoomActionGetRoomInfo = 1,
    PVModelGameRoomActionGetReady = 2,
    PVModelGameRoomActionGetNoReady = 3,
    PVModelGameRoomActionGetStart = 4,
} PVModelGameRoomActionType;

@interface PVModelGameRoomAction : NSObject

@property(nonatomic, assign) PVModelGameRoomActionType m_action;

@end
