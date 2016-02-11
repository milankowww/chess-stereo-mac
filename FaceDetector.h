//
//  FaceDetector.h
//  sach-pokus3-mac
//
//  Created by Milan Pikula on 26.5.2010.
//  Copyright 2010 IP Security Consulting. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#include <opencv/cv.h>
#include <opencv/highgui.h>

@interface FaceDetector : NSObject {
@private
	CvHaarClassifierCascade *cascade;
	CvMemStorage            *storage;	
	CvCapture *capture;	
@public
	// results of CV face detection (public? protected?)
	int face2dX, face2dY;
	int face2dW, face2dH;
	// int frame2dW, frame2dH;
	
	// real world constants used for calculations
	double faceHeightMm;
	double faceWidthMm;
	double cameraFovDeg;
	// double cameraElevationMm;
	// double viewWidhtMm;
	// double viewHeightMm;
	
	// calculated real world position (final)
	double faceDistanceMm;
	double faceXAngleDeg;
	double faceYAngleDeg;
}

- (id)init;
- (BOOL)detectFace;

@end
