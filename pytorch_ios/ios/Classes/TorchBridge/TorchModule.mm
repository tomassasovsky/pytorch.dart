// Copyright (c) 2022, Sports Visio, Inc
// https://sportsvisio.com
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

#import "TorchModule.h"
#import <LibTorch/LibTorch.h>

@class Convert;

@implementation TorchModule {
@protected
    torch::jit::script::Module _module;
}

- (nullable instancetype)initWithFileAtPath:(NSString*)filePath {
    self = [super init];
    if (self) {
      try {
          _module = torch::jit::load(filePath.UTF8String);
          _module.eval();
      } catch (const std::exception& e) {
          NSLog(@"%s", e.what());
          return nil;	
      }
    }
    return self;
}

- (NSArray<NSNumber*>*)predictImage:(void*)imageBuffer withWidth:(int)width andHeight:(int)height {
    try {
        at::Tensor tensor = torch::from_blob(imageBuffer, {1, 3, height, width}, at::kFloat);
        torch::autograd::AutoGradMode guard(false);
        at::AutoNonVariableTypeMode non_var_type_mode(true);
        
        at::Tensor outputTensor = _module.forward({tensor}).toTensor();
        
        float *floatBuffer = outputTensor.data_ptr<float>();
        if(!floatBuffer){
            return nil;
        }
        
        int prod = 1;
        for(int i = 0; i < outputTensor.sizes().size(); i++) {
            prod *= outputTensor.sizes().data()[i];  
        }
        
        NSMutableArray<NSNumber*>* results = [[NSMutableArray<NSNumber*> alloc] init];
        for (int i = 0; i < prod; i++) {
            [results addObject: @(floatBuffer[i])];   
        }
        
        return [results copy];
    } catch (const std::exception& e) {
        NSLog(@"%s", e.what());
    }
    return nil;
}

- (NSArray<NSNumber*>*)predict:(void*)data withShape:(NSArray<NSNumber*>*)shape andDtype:(NSString*)dtype {
    std::vector<int64_t> shapeVec;    
    for(int i = 0; i < [shape count]; i++){
        shapeVec.push_back([[shape objectAtIndex:i] intValue]);
    }
    at::ScalarType type = [self _convert: dtype];
    
    at::Tensor tensor = torch::from_blob(data, shapeVec, type);
    torch::autograd::AutoGradMode guard(false);
	at::AutoNonVariableTypeMode non_var_type_mode(true);    
	
    at::Tensor outputTensor =  _module.forward({tensor}).toTensor();
    
    float* floatBuffer = outputTensor.data_ptr<float>();
	if(!floatBuffer){
		return nil;
	}
    
    int prod = 1;
    for(int i = 0; i < outputTensor.sizes().size(); i++) {
        prod *= outputTensor.sizes().data()[i];  
    }
	
    NSMutableArray *results = [[NSMutableArray alloc] init];
	for(int i = 0; i < prod; i++){
		[results addObject:@(floatBuffer[i])];
	}
    
    return [results copy];
}

- (at::ScalarType)_convert:(NSString*)dtype {
    NSArray *dtypes = @[@"float32", @"float64", @"int32", @"int64", @"int8", @"uint8"];
    int type = (int)[dtypes indexOfObject:dtype];    
    switch(type){
    case 0:
        return torch::kFloat32;
    case 1:
        return torch::kFloat64;
    case 2:
        return torch::kInt32;
    case 3:
        return torch::kInt64;
    case 4:
        return torch::kInt8;
    case 5:
        return torch::kUInt8;
    }
    return at::ScalarType::Undefined;
}

@end
