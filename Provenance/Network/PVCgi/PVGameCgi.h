//
//  PVGameCgi.h
//  Provenance
//
//  Created by Kamazuki on 2017/11/15.
//  Copyright © 2017年 James Addyman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PVModelBase.h"
#import "PVModelUser.h"
#import "PVModelGameStatus.h"
#import "PVModelGameRoomAction.h"

@protocol PVGameCgiDelegate <NSObject>

-(void) onPVGameCgiSendGameRoomAction:(PVModelGameRoomAction*) tempAction  user:(PVModelUser*) tempUser;
-(void) onPVGameCgiSendGameStatus:(PVModelGameStatus*) tempInstruction  user:(PVModelUser*) tempUser;

@end

@interface PVGameCgi : NSObject

@property(nonatomic, weak) id<PVGameCgiDelegate> m_delegate;

-(void) cgiWithModel:(PVModelBase*) tempModel user:(PVModelUser*) tempUser;

@end
