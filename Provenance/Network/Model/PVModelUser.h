//
//  PVModelUser.h
//  Provenance
//
//  Created by Kamazuki on 2017/11/15.
//  Copyright © 2017年 James Addyman. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PVModelUser : NSObject

@property(nonatomic, strong) NSString* m_name;
@property(nonatomic, assign) unsigned int m_id;
@property(nonatomic, assign) unsigned int m_ready;

@end
