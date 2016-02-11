//
//  sach_pokus3_macAppDelegate.h
//  sach-pokus3-mac
//
//  Created by Milan Pikula on 23.5.2010.
//  Copyright 2010 IP Security Consulting. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "GLSachView.h"

@interface sach_pokus3_macAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
	NSWindow *sachMainWindow;
	NSView * sachMainView;
	GLSachView * sachLeftView, * sachRightView;
}

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSWindow *sachMainWindow;

@property (assign) IBOutlet NSView *sachMainView;

@property (assign) IBOutlet GLSachView *sachLeftView;
@property (assign) IBOutlet GLSachView *sachRightView;

@end
