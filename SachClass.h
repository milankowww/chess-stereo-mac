//
//  SachClass.h
//  sach-pokus3-mac
//
//  Created by Milan Pikula on 23.5.2010.
//  Copyright 2010 IP Security Consulting. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SachClass : NSObject {
	NSOpenGLView * glOutlet;
}

@property (nonatomic,retain) IBOutlet NSOpenGLView * glOutlet;

@end
