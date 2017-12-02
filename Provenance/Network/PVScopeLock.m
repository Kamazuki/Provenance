//
//  PVScopeLock.m
//  Provenance
//
//  Created by Kamazuki on 2017/11/17.
//  Copyright © 2017年 James Addyman. All rights reserved.
//

#import "PVScopeLock.h"

@interface PVScopeLock ()

@property NSRecursiveLock* m_lock;

@end

@implementation PVScopeLock

-(id) initWithLock:(NSRecursiveLock*) tempLock
{
    self = [super init];
    if (self)
    {
        self.m_lock = tempLock;
    }
    return self;
}

-(void) scopeLock
{
     [self.m_lock lock];
}

-(void) dealloc
{
    [self.m_lock unlock];
}

@end
