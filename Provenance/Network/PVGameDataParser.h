//
//  PVGameDataParser.h
//  Provenance
//
//  Created by Kamazuki on 2017/11/22.
//  Copyright © 2017年 James Addyman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PVModelBase.h"
#import "PVModelUser.h"

@protocol PVGameDataParserDelegate <NSObject>

-(void) didParserData:(NSData*) data user:(PVModelUser*) tempUser;

@end

@interface PVGameDataParser : NSObject

@property(nonatomic, weak) id<PVGameDataParserDelegate> m_delegate;
-(void) parserData:(NSData *)data user:(PVModelUser*) tempUser;

//生成的data, 第一个字节是消息长度
+(NSData*) messageDataWithModel:(PVModelBase*) tempModel;

@end
