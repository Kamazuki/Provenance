//
//  PVControlRemoteViewController.h
//  Provenance
//
//  Created by Kamazuki on 2017/11/17.
//  Copyright © 2017年 James Addyman. All rights reserved.
//

#import "PVGenesisControllerViewController.h"
#import "PVGameServer.h"
#import "PVGame.h"

@interface PVControlRemoteViewController : PVGenesisControllerViewController

-(id) initWithServer:(PVGameServer*) tempServer game:(PVGame*) tempGame;

@end
