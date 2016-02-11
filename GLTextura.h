//
//  GLTextura.h
//  sach-pokus3-mac
//
//  Created by Milan Pikula on 28.5.2010.
//  Copyright 2010 IP Security Consulting. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#include <OpenGL/gl.h>


@interface GLTextura : NSObject {
@public
	GLuint textureId;
	int width;
	int height;
}

// - (id)init;
- (id)initWithRaw:(NSString *)resource width:(int)w height:(int)h hasAlpha:(BOOL)al;
- (void)free;

@end
