// Copyright (c) 2022, Sports Visio, Inc
// https://sportsvisio.com
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImageExtension : NSObject
+ (nullable UIImage*)resize:(UIImage*)image toWidth:(int)width toHeight:(int)height;
+ (nullable float*)normalize:(UIImage*)image withMean:(NSArray<NSNumber*>*)mean withSTD:(NSArray<NSNumber*>*)std;
@end

NS_ASSUME_NONNULL_END
