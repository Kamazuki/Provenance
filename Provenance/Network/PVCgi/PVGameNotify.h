//
//  PVGameNotify.h
//  Provenance
//
//  Created by Kamazuki on 2017/11/15.
//  Copyright © 2017年 James Addyman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PVModelBase.h"
#import "PVModelUser.h"
#import "PVModelGameStatus.h"
#import "PVModelGameRoomInfo.h"
#import "PVModelStartGame.h"

@protocol PVGameNotifyDelegate <NSObject>

-(void) onPVGameNotifyWithGameStatus:(PVModelGameStatus*) tempStatus;
-(void) onPVGameNotifyWithGameRoomInfo:(PVModelGameRoomInfo *) tempInfo;
-(void) onPVGameNotifyWithStartGame:(PVModelStartGame*) tempStartGame;

@end

@interface PVGameNotify : NSObject

@property(nonatomic, weak) id<PVGameNotifyDelegate> m_delegate;

-(void) notifyWithModel:(PVModelBase*) tempModel;

@end
