// Copyright (c) 2022, Sports Visio, Inc
// https://sportsvisio.com
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TorchModule : NSObject

- (nullable instancetype)initWithFileAtPath:(NSString*)filePath;
- (nullable NSArray<NSNumber*>*)predictImage:(void*)imageBuffer withWidth:(int)width andHeight:(int)height;
- (nullable NSArray<NSNumber*>*)predict:(void*)data withShape:(NSArray<NSNumber*>*)shape andDtype:(NSString*)dtype;

@end

NS_ASSUME_NONNULL_END
