//
//  PVGameNotify.m
//  Provenance
//
//  Created by Kamazuki on 2017/11/15.
//  Copyright © 2017年 James Addyman. All rights reserved.
//

#import "PVGameNotify.h"
#import "NSObject+YYModel.h"
#import "PVGameNotifyDef.h"

@implementation PVGameNotify

-(void) notifyWithModel:(PVModelBase*) tempModel
{    
    if (tempModel.m_cgi == PVGameNotifyDef_GameRoomInfo)
    {
        PVModelGameRoomInfo* tempResult = [PVModelGameRoomInfo yy_modelWithJSON:tempModel.m_string];
        if (tempResult != nil)
        {
            [self.m_delegate onPVGameNotifyWithGameRoomInfo:tempResult];
        }
        return;
    }
    
    if (tempModel.m_cgi == PVGameNotifyDef_StartGame)
    {
        PVModelStartGame* tempResult = [PVModelStartGame yy_modelWithJSON:tempModel.m_string];
        if (tempResult != nil)
        {
            [self.m_delegate onPVGameNotifyWithStartGame:tempResult];
        }
        return;
    }
    
    if (tempModel.m_cgi == PVGameNotifyDef_GameStatus)
    {
        PVModelGameStatus* tempResult = [PVModelGameStatus yy_modelWithJSON:tempModel.m_string];
        if (tempResult != nil)
        {
            [self.m_delegate onPVGameNotifyWithGameStatus:tempResult];
        }
        return;
    }
}

@end
