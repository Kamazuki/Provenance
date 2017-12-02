//
//  PVGameCgi.m
//  Provenance
//
//  Created by Kamazuki on 2017/11/15.
//  Copyright © 2017年 James Addyman. All rights reserved.
//

#import "PVGameCgi.h"
#import "NSObject+YYModel.h"
#import "PVGameCgiDef.h"

@implementation PVGameCgi

-(void) cgiWithModel:(PVModelBase*) tempModel user:(PVModelUser*) tempUser
{
    if (tempModel.m_cgi == PVGameCgiDef_SendGameStatus)
    {
        PVModelGameStatus* temp = [PVModelGameStatus yy_modelWithJSON:tempModel.m_string];
        if (temp != nil)
        {
            [self.m_delegate onPVGameCgiSendGameStatus:temp user:tempUser];
        }
        return;
    }
    
    if (tempModel.m_cgi == PVGameCgiDef_SendGameRoomAction)
    {
        PVModelGameRoomAction* temp = [PVModelGameRoomAction yy_modelWithJSON:tempModel.m_string];
        if (temp != nil)
        {
            [self.m_delegate onPVGameCgiSendGameRoomAction:temp user:tempUser];
        }
        return;
    }
}

@end
