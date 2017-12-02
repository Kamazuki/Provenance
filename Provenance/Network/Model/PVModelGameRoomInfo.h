//
//  PVModelGameRoomInfo.h
//  Provenance
//
//  Created by Kamazuki on 2017/11/24.
//  Copyright © 2017年 James Addyman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PVModelUser.h"

@interface PVModelGameRoomInfo : NSObject

@property(nonatomic, strong) NSMutableArray<PVModelUser*>* m_userArray;

@end
