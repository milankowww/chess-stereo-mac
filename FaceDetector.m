//
//  FaceDetector.m
//  sach-pokus3-mac
//
//  Created by Milan Pikula on 26.5.2010.
//  Copyright 2010 IP Security Consulting. All rights reserved.
//

#import "FaceDetector.h"
#include <string.h>
#include <math.h>

#define DEBUG_WINDOW

#ifdef DEBUG_WINDOW
static CvFont font;
#endif

static int faceSizeCmp(const void * a, const void * b, void * unused)
{
	CvRect * r1 = (CvRect *) a;
	CvRect * r2 = (CvRect *) b;
	return (r1->width * r1->height) < (r2->width * r2->height);
}

static CvRect * doDetectFace(IplImage * img, CvHaarClassifierCascade * cascade, CvMemStorage * storage)
{	
    /* detect faces */
    CvSeq * faces = cvHaarDetectObjects(
										img,
										cascade,
										storage,
										1.1,
										2,
										CV_HAAR_DO_CANNY_PRUNING,
										cvSize(140, 140)
										);
	
	if (!faces->total)
		return NULL;
	cvSeqSort(faces, faceSizeCmp, NULL);	
	CvRect *r = ( CvRect* )cvGetSeqElem( faces, 0);
	
	return r;
}


@implementation FaceDetector
- (id)init
{
	NSString * nsFilename = [[NSBundle mainBundle] pathForResource:@"haarcascade_frontalface_alt" ofType:@"xml" inDirectory:@""];
	char      filename[4096];
	[nsFilename getCString:filename maxLength:(sizeof filename) encoding:NSUTF8StringEncoding];

    // load the classifier
    cascade = (CvHaarClassifierCascade *)cvLoad(filename, 0, 0, 0);
	if (!cascade)
		return nil;
	
    // setup memory buffer; needed by the face detector
    storage = cvCreateMemStorage(0);
	if (!storage) {		
		cvReleaseHaarClassifierCascade(&cascade);
		return nil;
	}
	
    // initialize camera
    capture = cvCaptureFromCAM(0);
	if (!capture) {
		cvReleaseHaarClassifierCascade(&cascade);
		cvReleaseMemStorage(&storage);
		return nil;
	}
	
	// initialize the constants
	faceHeightMm = 170.; // height of the HILIGHTED FRAME of face, as detected by openCV
	faceWidthMm = 170.; // width -//-
	cameraFovDeg = 60.;
	
#ifdef DEBUG_WINDOW
	cvNamedWindow("video", 1);
	cvInitFont(&font, CV_FONT_HERSHEY_PLAIN, 1.0f, 1.0f, 0., 1, 8);
#endif
	return self;
}

- (BOOL)detectFace
{
	IplImage  * frame;
	CvRect * face;
	
	@synchronized(self) {
		frame = cvQueryFrame(capture);
		if(!frame)
			return NO;

		cvFlip(frame, frame, 1);
		frame->origin = 0;

		face = doDetectFace(frame, cascade, storage);
		if (!face) {
			cvShowImage( "video", frame);
			// cvResizeWindow("video", 150, 150);
			return NO;
		}
		
		face2dX = face->x + face->width/2;
		face2dY = face->y + face->height/2;
		face2dW = face->width;
		face2dH = face->height;
		
		// CALCULATE FOR WIDTH:
		// how much of FOV is occupied
		double scanResolutionX = frame->width;

		double beta = cameraFovDeg * (face2dW / scanResolutionX); // FIXME: slightly incorrect

		// how big the distance is, given the known size of the object (face), and camera FOV
		faceDistanceMm = ( 1/tanf(beta/2 * M_PI/180) ) * face2dW * ((faceWidthMm/2) / face2dW);

		// where is the center of the image?
		double scanResolutionY = frame->height;
		double xCenterDistance = 2. * face2dX/scanResolutionX - 1.; // -1 .. +1
		double yCenterDistance = 2. * face2dY/scanResolutionY - 1.; // -1 .. +1

		faceXAngleDeg = cameraFovDeg/2. * xCenterDistance;
		faceYAngleDeg = cameraFovDeg/2. * yCenterDistance;
		
#ifdef DEBUG_WINDOW
		cvRectangle(frame,
					cvPoint(face->x, face->y),
					cvPoint(face->x + face->width, face->y + face->height),
					CV_RGB(255, 0, 0), 1, 8, 0);
		char buf[4096];
		snprintf(buf, sizeof(buf), "rect %dx%d@%d,%d", face->width,face->height, face->x, face->y);
		cvPutText(frame, buf, cvPoint(10, 15), &font, CV_RGB( 255, 255, 255));
		snprintf(buf, sizeof(buf), "dist %.1F mm (fov angle %.1F deg/%.1F deg)", faceDistanceMm, beta, cameraFovDeg);
		cvPutText(frame, buf, cvPoint(10, 30), &font, CV_RGB( 255, 255, 255));
		snprintf(buf, sizeof(buf), "face angle %.1F deg, %.1F deg", faceXAngleDeg, faceYAngleDeg);
		cvPutText(frame, buf, cvPoint(10, 45), &font, CV_RGB( 255, 255, 255));
		
		cvShowImage( "video", frame);
		// cvResizeWindow("video", 150, 150);
#endif	
		
		}
	return YES;
}

- (void)release
{

	cvReleaseCapture(&capture);
#ifdef DEBUG_WINDOW
	cvDestroyWindow("video");
#endif
	cvReleaseHaarClassifierCascade(&cascade);
	cvReleaseMemStorage(&storage);
}


@end
