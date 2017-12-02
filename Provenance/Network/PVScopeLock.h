//
//  PVScopeLock.h
//  Provenance
//
//  Created by Kamazuki on 2017/11/17.
//  Copyright © 2017年 James Addyman. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PVScopeLock : NSObject

-(id) initWithLock:(NSRecursiveLock*) tempLock;
-(void) scopeLock;

@end
