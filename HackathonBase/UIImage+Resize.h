//
//  UIImage+Resize.h
//  HackathonBase
//
//  Created by Sihao Lu, Vincent Yan on 9/13/15.
//  Copyright © 2015 Sihao Lu, Vincent Yan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage(ResizeCategory)
-(UIImage*)resizedImageToSize:(CGSize)dstSize;
-(UIImage*)resizedImageToFitInSize:(CGSize)boundingSize scaleIfSmaller:(BOOL)scale;
@end