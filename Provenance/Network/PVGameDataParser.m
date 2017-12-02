//
//  PVGameDataParser.m
//  Provenance
//
//  Created by Kamazuki on 2017/11/22.
//  Copyright © 2017年 James Addyman. All rights reserved.
//

#import "PVGameDataParser.h"
#import "NSObject+YYModel.h"

@interface PVGameDataParser ()

@property(nonatomic, strong) NSData* m_dataLeft;

@end

@implementation PVGameDataParser

-(void) parserData:(NSData *)data user:(PVModelUser*) tempUser
{
    //解决粘包的问题，将上次没有解析完的数据合并
    if (self.m_dataLeft != nil)
    {
        NSLog(@"using data left with length:%lu", self.m_dataLeft.length);
        NSMutableData* tempMData = [NSMutableData dataWithData:self.m_dataLeft];
        [tempMData appendData:data];
        self.m_dataLeft = nil;
        
        data = tempMData;
        
        NSLog(@"merge data length:%lu", data.length);
    }
    
    unsigned long tempLocation = 0;
    while (tempLocation < data.length)
    {
        //当前data有可能不够length的长度, 留到下次回调
        if (data.length < sizeof(unsigned long))
        {
            NSLog(@"data not enough for length byte. left with length:%lu", data.length - tempLocation);
            self.m_dataLeft = [data subdataWithRange:NSMakeRange(tempLocation, data.length - tempLocation)];
            break;
        }
        
        if (data.length - tempLocation < sizeof(unsigned long))
        {
            NSLog(@"data not enough for length byte. left with length:%lu", data.length - tempLocation);
            self.m_dataLeft = [data subdataWithRange:NSMakeRange(tempLocation, data.length - tempLocation)];
            break;
        }
        
        //读取消息体长度
        unsigned long tempLength = 0;
        [data getBytes:&tempLength range:NSMakeRange(tempLocation, sizeof(unsigned long))];
        
        //消息长度超过了当前buffer长度，留到下次回调
        if (tempLocation + sizeof(unsigned long) + tempLength > data.length)
        {
            NSLog(@"data left with length:%lu, target length:%lu", data.length - tempLocation, tempLength);
            self.m_dataLeft = [data subdataWithRange:NSMakeRange(tempLocation, data.length - tempLocation)];
            break;
        }
        
        //读取位置往后移动消息长度所占用的字节
        tempLocation += sizeof(unsigned long);
        
        //读取对应长度
        void* tempByte = malloc(tempLength);
        [data getBytes:tempByte range:NSMakeRange(tempLocation, tempLength)];
        
        NSData* tempModelData = [NSData dataWithBytes:tempByte length:tempLength];
        free(tempByte);
        
        if ([self.m_delegate respondsToSelector:@selector(didParserData:user:)])
        {
            [self.m_delegate didParserData:tempModelData user:tempUser];
        }
        
        //读取位置往后移动消息长度
        tempLocation = tempLocation + tempLength;
    }
}

+(NSData*) messageDataWithModel:(PVModelBase*) tempModel
{
    NSData* tempData = [tempModel yy_modelToJSONData];
    
    unsigned long tempLength = tempData.length;
    NSMutableData* tempResult = [NSMutableData dataWithBytes:&tempLength length:sizeof(tempLength)];
    [tempResult appendData:tempData];
    
    return tempResult;
}

@end
