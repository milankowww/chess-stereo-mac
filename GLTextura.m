//
//  GLTextura.m
//  sach-pokus3-mac
//
//  Created by Milan Pikula on 28.5.2010.
//  Copyright 2010 IP Security Consulting. All rights reserved.
//

#import "GLTextura.h"


@implementation GLTextura
- (id)initWithRaw:(NSString *)resource width:(int)w height:(int)h hasAlpha:(BOOL)al
{
		
	NSString * nsFilename = [[NSBundle mainBundle] pathForResource:resource ofType:@"raw" inDirectory:@""];
	NSData * contents = [NSData dataWithContentsOfFile:nsFilename];
	
	width = w;
	height = h;
	
	if ([contents length] != width * height * (3 + (al ? 1 : 0)))
		return nil;
	
	char * texture = malloc([contents length]);
	if (!texture)
		return nil;
	
	[contents getBytes:texture];
	
	glGenTextures(1, &textureId);
	glBindTexture(GL_TEXTURE_2D, textureId); // select as current texture
	glTexEnvf( GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE );
	// when texture area is small, bilinear filter the closest mipmap
	glTexParameterf( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER,
					GL_LINEAR_MIPMAP_NEAREST );
	// when texture area is large, bilinear filter the original
	glTexParameterf( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );	
	// the texture wraps over at the edges (repeat)
	glTexParameterf( GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT );
	glTexParameterf( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT );

	
	if (al)
		gluBuild2DMipmaps( GL_TEXTURE_2D, GL_RGBA, width, height,
						  GL_RGBA, GL_UNSIGNED_BYTE, texture );
	else
		gluBuild2DMipmaps( GL_TEXTURE_2D, 3, width, height,
						  GL_RGB, GL_UNSIGNED_BYTE, texture );
	
	free(texture);
	
	return self;
}

- (void)free
{
	glDeleteTextures(1, &textureId);
}

@end
