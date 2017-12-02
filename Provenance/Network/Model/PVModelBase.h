//
//  PVModelBase.h
//  Provenance
//
//  Created by Kamazuki on 2017/11/15.
//  Copyright © 2017年 James Addyman. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PVModelBase : NSObject

@property(nonatomic, assign) unsigned long long m_sequence;
@property(nonatomic, assign) unsigned long long m_cgi;
@property(nonatomic, strong) NSString* m_string;

@end
