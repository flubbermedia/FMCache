//
//  FMCache.h
//
//  Created by Maurizio Cremaschi and Andrea Ottolina on 8/2/12.
//  Copyright 2012 Flubber Media Ltd.
//
//  Distributed under the permissive zlib License
//  Get the latest version from https://github.com/flubbermedia/FMCache
//
//  This software is provided 'as-is', without any express or implied
//  warranty.  In no event will the authors be held liable for any damages
//  arising from the use of this software.
//
//  Permission is granted to anyone to use this software for any purpose,
//  including commercial applications, and to alter it and redistribute it
//  freely, subject to the following restrictions:
//
//  1. The origin of this software must not be misrepresented; you must not
//  claim that you wrote the original software. If you use this software
//  in a product, an acknowledgment in the product documentation would be
//  appreciated but is not required.
//
//  2. Altered source versions must be plainly marked as such, and must not be
//  misrepresented as being the original software.
//
//  3. This notice may not be removed or altered from any source distribution.
//

#import <Foundation/Foundation.h>

@interface FMCache : NSObject

+ (id)objectForKey:(NSString *)key;

+ (void)setObject:(id <NSCoding>)object forKey:(NSString *)key;
+ (void)setObject:(id <NSCoding>)object forKey:(NSString *)key expirationDate:(NSDate *)date;

+ (void)setObject:(id <NSCoding>)object forKey:(NSString *)key useMemory:(BOOL)useMemory;
+ (void)setObject:(id <NSCoding>)object forKey:(NSString *)key expirationDate:(NSDate *)date useMemory:(BOOL)useMemory;

+ (void)removeObjectForKey:(NSString*)key;
+ (void)removeAllObject;

+ (BOOL)hasObjectForKey:(NSString*)key;
+ (BOOL)hasObjectOnDiskForKey:(NSString*)key;
+ (BOOL)hasObjectInMemoryForKey:(NSString*)key;

@end
