//
//  GLSachView.h
//  sach-pokus3-mac
//
//  Created by Milan Pikula on 23.5.2010.
//  Copyright 2010 IP Security Consulting. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

#import "FaceDetector.h"

@interface GLSachView : NSOpenGLView {
@private
	NSTimer * animationTimer;
    NSTimeInterval animationInterval;
	FaceDetector * faceDetector;
	
	float eyePosition, eyeAngle;
	
@public
	float boardRotationZ; // rotation against the Z axis
	float boardScale; // zoom, default value 4.
}
@property NSTimeInterval animationInterval;

// openGL methods
- (void) drawRect:(NSRect)bounds;
- (void) reshape; // handle window resizing

// methods for our owner
- (void)startAnimation;
- (void)stopAnimation;
- (void) timerTick;
- (void)performClose:(id)sender;
- (void)setFaceDetector:(FaceDetector *)faceDetector;
- (void)eyePosition:(float)setEyePosition eyeAngle:(float)eyeAngle;

// keyboard and mouse controls
- (BOOL)acceptsFirstResponder;
- (void)rotateWithEvent:(NSEvent *)event;
- (void)magnifyWithEvent:(NSEvent *)event;

@end
