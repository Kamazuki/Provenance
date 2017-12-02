//
//  PVGameNetworkService.h
//  Provenance
//
//  Created by Kamazuki on 2017/11/15.
//  Copyright © 2017年 James Addyman. All rights reserved.
//

#ifndef PVGameNetworkService_h
#define PVGameNetworkService_h

#import <Foundation/Foundation.h>
#import "PVModelUser.h"

@protocol PVGameNetworkService;
@protocol PVGameNetworkServiceDelegate <NSObject>

@optional
-(void) onPVGameNetworkService:(id<PVGameNetworkService>) service serviceUpdateWithArray:(NSArray*) tempArray;

@end

@protocol PVGameNetworkService <NSObject>

-(void) setDelegate:(id<PVGameNetworkServiceDelegate>) tempDelegate;
-(void) start;

@end

#endif /* PVGameNetworkService_h */
