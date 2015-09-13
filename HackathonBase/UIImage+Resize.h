//
//  UIImage+Resize.h
//  HackathonBase
//
//  Created by Sihao Lu on 9/13/15.
//  Copyright © 2015 Sihao Lu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage(ResizeCategory)
-(UIImage*)resizedImageToSize:(CGSize)dstSize;
-(UIImage*)resizedImageToFitInSize:(CGSize)boundingSize scaleIfSmaller:(BOOL)scale;
@end