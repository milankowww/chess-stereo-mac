//
//  sach_pokus3_macAppDelegate.m
//  sach-pokus3-mac
//
//  Created by Milan Pikula on 23.5.2010.
//  Copyright 2010 IP Security Consulting. All rights reserved.
//

#import "sach_pokus3_macAppDelegate.h"
#import "GLSachView.h"

#import "FaceDetector.h"

#include <stdio.h>

#include <opencv/cv.h>
#include <opencv/highgui.h>



@implementation sach_pokus3_macAppDelegate

@synthesize window;
@synthesize sachMainWindow;
@synthesize sachMainView;
@synthesize sachLeftView;
@synthesize sachRightView;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Insert code here to initialize your application 

	int fullScreen = 0;

	if (fullScreen) {
		// [sachMainView enterFullScreenMode:[NSScreen mainScreen] withOptions:nil];

		NSRect mainDisplayRect = [[NSScreen mainScreen] frame];
		NSRect mainDisplayRectLeft = NSMakeRect(mainDisplayRect.origin.x, mainDisplayRect.origin.y, mainDisplayRect.size.width/2.0, mainDisplayRect.size.height);
		NSRect mainDisplayRectRight = NSMakeRect(mainDisplayRect.origin.x + mainDisplayRect.size.width/2.0, mainDisplayRect.origin.y, mainDisplayRect.size.width/2.0, mainDisplayRect.size.height);
		
		[sachMainWindow initWithContentRect: mainDisplayRect styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:NO];

		// nad menubar
		[sachMainWindow setLevel:NSMainMenuWindowLevel+1];
		[sachMainWindow setOpaque:YES];
		[sachMainWindow setHidesOnDeactivate:YES];
				
		[sachLeftView setFrame:mainDisplayRectLeft];
		[sachRightView setFrame:mainDisplayRectRight];
		// [sachMainWindow setFrame:mainDisplayRect display:YES animate:YES];
	
		[sachMainWindow setContentView:sachLeftView];
		
		[sachMainWindow makeKeyAndOrderFront:self];
	}

	FaceDetector * faceDetector = [[FaceDetector alloc] init];
	
	float multiplier = -1;
	
	[sachLeftView setFaceDetector:faceDetector];
	[sachLeftView eyePosition:0.2*multiplier eyeAngle:-15.0*multiplier];
	[sachLeftView setAnimationInterval:(1.0 / 30.0)];
	[sachLeftView startAnimation];

	[sachRightView setFaceDetector:faceDetector];
	[sachRightView eyePosition:-0.2*multiplier eyeAngle:15.0*multiplier];
	[sachRightView setAnimationInterval:(1.0 / 30.0)];
	[sachRightView startAnimation];
}

@end
