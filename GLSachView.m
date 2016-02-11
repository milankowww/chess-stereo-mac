//
//  GLSachView.m
//  sach-pokus3-mac
//
//  Created by Milan Pikula on 23.5.2010.
//  Copyright 2010 IP Security Consulting. All rights reserved.
//

#import "GLSachView.h"
#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import <Cocoa/Cocoa.h>
#include <OpenGL/gl.h>
#import "GLTextura.h"

#define BGRGB 0.5f, 0.5f, 0.5f
#define USE_DEPTH_BUFFER 1

// class variable :)
static GLTextura * texturaBottom = NULL;
static GLTextura * texturaTravicka = NULL, * texturaOblacik = NULL;


//////////////////////////////////////////////////////
// support routines for camera transformation

static float vec3f_length(const float * a)
{
	assert(a);
	return sqrtf(a[0] * a[0] + a[1] * a[1] + a[2] * a[2]);
}

static void vec3f_subtract(float * result, const float * a, const float * b)
{
	assert(a && b && result);
	result[0] = a[0]-b[0];
	result[1] = a[1]-b[1];
	result[2] = a[2]-b[2];
}
static void vec3f_normalize(float * vect)
{
	assert(vect);
	float len = vec3f_length(vect);
	vect[0] /= len;
	vect[1] /= len;
	vect[2] /= len;
}
static void vec3f_cross_product(float * result, const float * a, const float * b)
{
	assert(a && b && result);
	result[0] = a[1]*b[2] - a[2]*b[1];
	result[1] = a[2]*b[0] - a[0]*b[2];
	result[2] = a[0]*b[1] - a[1]*b[0];
}
static float vec3f_dot_product(const float * a, const float * b)
{
	assert(a && b);
	return a[0] * b[0] + a[1] * b[1] + a[2] * b[2];
}
// from http://aoeu.snth.net/static/gen-perspective.pdf
static void projection(const float * pa, const float * pb, const float * pc, const float * pe, float n, float f)
{
	float va[3], vb[3], vc[3]; float vr[3], vu[3], vn[3];
	float l, r, b, t, d, M[16];
	
	// Compute an orthonormal basis for the screen.
	vec3f_subtract(vr, pb, pa);
	vec3f_subtract(vu, pc, pa);
	
	vec3f_normalize(vr);
	vec3f_normalize(vu);
	vec3f_cross_product(vn, vr, vu);
	vec3f_normalize(vn);

	// Compute the screen corner vectors.
	vec3f_subtract(va, pa, pe);
	vec3f_subtract(vb, pb, pe);
	vec3f_subtract(vc, pc, pe);
	
	// Find the distance from the eye to screen plane.
	d = -vec3f_dot_product(va, vn);
	
	// Find the extent of the perpendicular projection.
	l = vec3f_dot_product(vr, va) * n / d;
	r = vec3f_dot_product(vr, vb) * n / d;
	b = vec3f_dot_product(vu, va) * n / d;
	t = vec3f_dot_product(vu, vc) * n / d;
	
	// Load the perpendicular projection.
	glFrustum(l, r, b, t, n, f);
	
	// Rotate the projection to be non-perpendicular.
	memset(M, 0, sizeof(M));
	
	M[0] = vr[0]; M[1] = vu[0]; M[2] = vn[0];
	M[4] = vr[1]; M[8] = vr[2]; M[5] = vu[1];
	M[9] = vu[2]; M[6] = vn[1]; M[10] = vn[2];
	M[15] = 1.0f;
	
	glMultMatrixf(M);
	
	// Move the apex of the frustum to the origin.
	glTranslatef(-pe[0], -pe[1], -pe[2]);

}

//////////////////////////////////////////////////////

static void renderFigure(float baseX, float baseY, float baseZ, float size)
{
	glPushMatrix();
	glTranslatef(baseX, baseY, baseZ);
	glScalef(0.1f * size, 0.1f * size, 0.3f * size);
	glRotatef(rand() * 360.0f / RAND_MAX, 0.0f, 0.0f, 1.0f);
	glBegin(GL_TRIANGLES);

	glVertex3f(-.5f, -.433f, 0.0f); glVertex3f(.5f, -.433f, 0.0f); glVertex3f(0.0f, 0.0f, 1.0f);
	glVertex3f(.5f, -.433f, 0.0f); glVertex3f(0.0f, .433f, 0.0f); glVertex3f(0.0f, 0.0f, 1.0f);
	glVertex3f(0.0f, .433f, 0.0f); glVertex3f(-.5f, -.433f, 0.0f); glVertex3f(0.0f, 0.0f, 1.0f);
	
	glVertex3f(-.5f, -.433f, 0.0f); glVertex3f(0.0f, .433f, 0.0f); glVertex3f(.5f, -.433f, 0.0f);
	glEnd();
	glPopMatrix();
}

static void renderBoardAndFigures(float boardScale, float boardRotationZ)
{
	glPushMatrix();
	// zoom
	glScalef(boardScale, boardScale, boardScale);
	// natocenie obrazku okolo jeho osi
    glRotatef(boardRotationZ, 0.0f, 0.0f, 1.0f);
	// prvy fix suradnicovej sustavy (dajme si 0:0 do stredu sachovnice)
	glTranslatef(-0.5f, -0.5f, 0.0f);
		
	int r, c;
	glBegin(GL_TRIANGLES);

	// chessboard borders
	glColor3f(0.9f, 0.9f, 0.9f);
	//glColor3f(0.6f, 0.6f, 0.6f);
	glVertex3f(0.1f, 0.1f, 0.0f); glVertex3f(0.0f, 0.0f, -0.1f); glVertex3f(1.0f, 0.0f, -0.1f);
	glVertex3f(0.1f, 0.1f, 0.0f); glVertex3f(1.0f, 0.0f, -0.1f); glVertex3f(0.9f, 0.1f, 0.0f);
	
	glColor3f(0.6f, 0.6f, 0.6f);
	glVertex3f(0.9f, 0.1f, 0.0f); glVertex3f(1.0f, 0.0f, -0.1f); glVertex3f(1.0f, 1.0f, -0.1f);
	glVertex3f(0.9f, 0.1f, 0.0f); glVertex3f(1.0f, 1.0f, -0.1f); glVertex3f(0.9f, 0.9f, 0.0f);
	
	glColor3f(0.9f, 0.9f, 0.9f);
	//glColor3f(0.6f, 0.6f, 0.6f);
	glVertex3f(0.9f, 0.9f, 0.0f); glVertex3f(1.0f, 1.0f, -0.1f); glVertex3f(0.0f, 1.0f, -0.1f);
	glVertex3f(0.9f, 0.9f, 0.0f); glVertex3f(0.0f, 1.0f, -0.1f); glVertex3f(0.1f, 0.9f, 0.0f); 
	
	glColor3f(0.6f, 0.6f, 0.6f);
	glVertex3f(0.1f, 0.9f, 0.0f); glVertex3f(0.0f, 1.0f, -0.1f); glVertex3f(0.0f, 0.0f, -0.1f);
	glVertex3f(0.1f, 0.9f, 0.0f); glVertex3f(0.0f, 0.0f, -0.1f); glVertex3f(0.1f, 0.1f, 0.0f);
	
	// draw the chessboard	
	for (r=0; r<8; r++)
		for (c=0; c<8; c++) {			
			glColor4f((r^c)&1 ? 1.0f : 0.0f, 0.f, 0.35f, 1.0f);
			
			if (!r && !c)
				glColor4f(0.0f, 0.f, 1.0f, 1.0f);
			glVertex3f(0.1f + r*0.1f, 0.1f + c*0.1f, 0.0f);
			glVertex3f(0.2f + r*0.1f, 0.1f + c*0.1f, 0.0f);
			glVertex3f(0.2f + r*0.1f, 0.2f + c*0.1f, 0.0f);
			
			glVertex3f(0.1f + r*0.1f, 0.1f + c*0.1f, 0.0f);
			glVertex3f(0.2f + r*0.1f, 0.2f + c*0.1f, 0.0f);
			glVertex3f(0.1f + r*0.1f, 0.2f + c*0.1f, 0.0f);
			
		}
	
	glEnd();
	
	srand(11);
	// draw some figures
	for (r=7; r>=0; r--)
		for (c=7; c>=0; c--)
			if ((r^c)&1) {
				glColor4f(r/8., c/8., (r-c+8)/16., 0.8f);
				renderFigure(0.15f + r*0.1f, 0.15f + c*0.1f, 0.02f, 0.6f);
			}	
	
	glPopMatrix();
}

@implementation GLSachView

@synthesize animationInterval;

- (void)drawAnObject
{
	if (!faceDetector)
		return;
	
	glPushMatrix();

	// pokus o antialiasing - nechodi na ifone
	glEnable(GL_POLYGON_SMOOTH); glHint (GL_POLYGON_SMOOTH_HINT, GL_NICEST);
	glEnable(GL_LINE_SMOOTH); glHint (GL_LINE_SMOOTH_HINT, GL_DONT_CARE);
	glEnable(GL_POINT_SMOOTH); glHint (GL_POINT_SMOOTH_HINT, GL_DONT_CARE);
	//glShadeModel(GL_SMOOTH);

	// textury
	glEnable(GL_TEXTURE_2D);

	// alpha kanal
	glEnable(GL_BLEND);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

	// orezavanie veci ked sa pretinaju
	glEnable(GL_DEPTH_TEST);
	glDepthMask(GL_TRUE);
	glDepthFunc(GL_LESS);
	
	// nastavenie kamery a zobrazenia
	glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
//	glTranslatef(eyePosition, 0.0f, 0.0f);
//	glRotatef(eyeAngle, 0,1,0);
	float scr1[] = {-1.6f, 0.0f, -1.0f};
	float scr2[] = {1.6f,  0.0f, -1.0f};
	float scr3[] = {-1.6f, 0.0f, 1.0f};
	float viewer[] = {0.0f, -3.0f, 0.2f};
	if (faceDetector) {
		float dist = faceDetector->faceDistanceMm/80.0f;
		float faceXAngleDeg = faceDetector->faceXAngleDeg / 2.0;
		float faceYAngleDeg = faceDetector->faceYAngleDeg / 2.0;

		viewer[0] = dist * sin(faceXAngleDeg * M_PI / 180.0f) + eyePosition;
		viewer[1] = -dist * cos(faceXAngleDeg * M_PI / 180.0f) * cos(faceYAngleDeg * M_PI / 180.0f);
		viewer[2] = 0.55f -dist * sin(faceYAngleDeg * M_PI / 180.0f);
	}
	projection(scr1, scr2, scr3, viewer, 1.0f, 25.0f);

	
	// shading
	//glEnable(GL_SHADE_MODEL);
	//glShadeModel(GL_SMOOTH);
	// svetlo
	// farba vertexu je: mat_emision + mat_amb * model_fullscene_amb + prispevky light sourcov
	// light source prispevok = vzdialenost_mat_od_svetla KRAT {
	//			mat_amb * lig_amb +
	//			mat_dif * lig_dif * DOT_PROD(normala vertexu, normala vertex->svetlo) +
	//			mat_spec * lig_spec * DOT_PROD(norm vertex->oko, vertex->svetlo)^(shinines)
	// }
	GLfloat l_position[4] = {2.0,-1.0,4.0,1.0};
    GLfloat l_ambient[4]  = {0.2,0.2,0.2,1.0};
    GLfloat l_diffuse[4]  = {0.9,5.9,0.9,1.0};
    GLfloat l_specular[4] = {1.0,1.0,1.0,1.0};
	
	GLfloat mat_ambient[] = {0.3, 0.9, 0.3, 1.0};
    GLfloat mat_diffuse[] = {0.0, 0.0, 0.9, 1.0};
    GLfloat mat_specular[] = {1.1, 0.0, 0.0, 1.0};
    GLfloat mat_shininess[] = {10.0};	
	
	glMaterialfv (GL_FRONT, GL_AMBIENT, mat_ambient);
    glMaterialfv (GL_FRONT, GL_DIFFUSE, mat_diffuse);
    glMaterialfv (GL_FRONT, GL_SPECULAR, mat_specular);
    glMaterialfv (GL_FRONT, GL_SHININESS, mat_shininess);	
	
	//glColorMaterial(GL_FRONT_AND_BACK, GL_AMBIENT_AND_DIFFUSE);	
	//glEnable(GL_COLOR_MATERIAL);
    //glEnable(GL_NORMALIZE);
	
	glLightfv(GL_LIGHT0, GL_POSITION, l_position);
	glLightfv(GL_LIGHT0, GL_AMBIENT, l_ambient);
	glLightfv(GL_LIGHT0, GL_DIFFUSE, l_diffuse);
	glLightfv(GL_LIGHT0, GL_SPECULAR, l_specular);
	
	//glEnable(GL_LIGHTING);
	//glEnable(GL_LIGHT0);

	// orezavanie veci ktore nevidno
	//glEnable(GL_CULL_FACE);
	
	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();
	glClearColor(0, 0, 0, 1);
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	
	
	// zadna sachovnica
	glTranslatef(0.0f, 4.0f, -0.4f);
	renderBoardAndFigures(boardScale, boardRotationZ);
	glTranslatef(0.0f, -4.0f, 0.4f);

	
	// OKRAJE OKOLO CELEHO IHRISKA
	
	if (texturaBottom)
		glBindTexture(GL_TEXTURE_2D, texturaBottom->textureId);
	
	// podlaha	
	glColor3f(1.0f, 1.0f, 1.0f);
	glBegin(GL_TRIANGLES);
	glTexCoord2d(0.0f, 0.0f); glVertex3f(-1.6f, 0.0f, -1.0f);
	glTexCoord2d(2.0f, 0.0f); glVertex3f(1.6f, 0.0f, -1.0f);
	glTexCoord2d(2.0f, 4.0f); glVertex3f(1.6f, 4.0f, -1.0f);
	glTexCoord2d(0.0f, 0.0f); glVertex3f(-1.6f, 0.0f, -1.0f);
	glTexCoord2d(2.0f, 4.0f); glVertex3f(1.6f, 4.0f, -1.0f);
	glTexCoord2d(0.0f, 4.0f); glVertex3f(-1.6f, 4.0f, -1.0f);
	glEnd();
	
	// lavy bok
	glBegin(GL_TRIANGLES);
#define TX(corner,rot) (sqrt(2.)*sin(M_PI/2. * (corner + 0.5) + (rot * M_PI / 180.)))
#define TY(corner,rot) (sqrt(2.)*cos(M_PI/2. * (corner + 0.5) + (rot * M_PI / 180.)))
	// glColor3f(0.5f, 0.5f, 0.5f);
	glColor3f(1.0f, 1.0f, 1.0f);
	glTexCoord2d(TX(2, 15), TY(2, 15)); glVertex3f(-1.6f, 0.0f, -1.0f);
	glTexCoord2d(TX(1, 15), TY(1, 15)); glVertex3f(-1.6f, 2.0f, -1.0f);
	glTexCoord2d(TX(0, 15), TY(0, 15)); glVertex3f(-1.6f, 2.0f, 1.0f);
	glTexCoord2d(TX(2, 15), TY(2, 15)); glVertex3f(-1.6f, 0.0f, -1.0f);
	glTexCoord2d(TX(0, 15), TY(0, 15)); glVertex3f(-1.6f, 2.0f, 1.0f);
	glTexCoord2d(TX(3, 15), TY(3, 15)); glVertex3f(-1.6f, 0.0f, 1.0f);
	
	// glColor3f(0.5f, 0.5f, 0.5f); // pravy bok
	glColor3f(1.0f, 1.0f, 1.0f);
	glTexCoord2d(TX(2, 30), TY(2, 30)); glVertex3f(1.6f, 0.0f, -1.0f);
	glTexCoord2d(TX(0, 30), TY(0, 30)); glVertex3f(1.6f, 2.0f, 1.0f);
	glTexCoord2d(TX(1, 30), TY(1, 30)); glVertex3f(1.6f, 2.0f, -1.0f); 
	glTexCoord2d(TX(2, 30), TY(2, 30)); glVertex3f(1.6f, 0.0f, -1.0f);
	glTexCoord2d(TX(3, 30), TY(3, 30)); glVertex3f(1.6f, 0.0f, 1.0f);
	glTexCoord2d(TX(0, 30), TY(0, 30)); glVertex3f(1.6f, 2.0f, 1.0f);
	
	glEnd();
	
	glBindTexture(GL_TEXTURE_2D, 0);
	glBegin(GL_TRIANGLES);
	glColor3f(0.15f, 0.27f, 0.45f); // strecha
	glVertex3f(-5.0f, 0.0f, 1.0f); glVertex3f(5.0f, 5.0f, 1.0f); glVertex3f(5.0f, 0.0f, 1.0f); 
	glVertex3f(-5.0f, 0.0f, 1.0f); glVertex3f(-5.0f, 5.0f, 1.0f); glVertex3f(5.0f, 5.0f, 1.0f);
	glEnd();
	
	
	// zadok
	glBindTexture(GL_TEXTURE_2D, texturaBottom->textureId);
	glBegin(GL_TRIANGLES);
	glColor4f(0.57f, 0.17f, 0.17f, 0.9f);
	glColor3f(0.57f, 0.17f, 0.17f);
	glTexCoord2d(0.0f, 0.0f); glVertex3f(-1.6f, 2.0f, -1.0f);
	glTexCoord2d(2.0f, 0.0f); glVertex3f(1.6f, 2.0f, -1.0f);
	glTexCoord2d(2.0f, 2.0f); glVertex3f(1.6f, 2.0f, 1.0f); 
	glTexCoord2d(0.0f, 0.0f); glVertex3f(-1.6f, 2.0f, -1.0f);
	glTexCoord2d(2.0f, 2.0f); glVertex3f(1.6f, 2.0f, 1.0f);
	glTexCoord2d(0.0f, 2.0f); glVertex3f(-1.6f, 2.0f, 1.0f);
	glEnd();	
	
	
	
	// travicka
	if (texturaTravicka) {
		glBindTexture(GL_TEXTURE_2D, texturaTravicka->textureId);
		glColor3f(0.0, 1.0, 0.0);
		glBegin(GL_TRIANGLES);
		
		float i, j; 
		for (j=4; j > -4; j-=1.2)
			for (i = 4; i >= -0.5; i-=0.8) {
				glTexCoord2d(0.0f, 0.98f); glVertex3f(-0.8f+j, 0.3f+i, -1.0f);
				glTexCoord2d(1.0f, 0.98f); glVertex3f(0.2f+j, 0.3f+i, -1.0f);
				glTexCoord2d(1.0f, 0.02f); glVertex3f(0.2f+j, 0.3f+i, -0.8f); 
				glTexCoord2d(0.0f, 0.98f); glVertex3f(-0.8f+j, 0.3f+i, -1.0f);
				glTexCoord2d(1.0f, 0.02f); glVertex3f(0.2f+j, 0.3f+i, -0.8f);
				glTexCoord2d(0.0f, 0.02f); glVertex3f(-0.8f+j, 0.3f+i, -0.8f);
		}
		glEnd();
	}

	if (texturaOblacik) {
		glBindTexture(GL_TEXTURE_2D, texturaOblacik->textureId);
		glColor3f(1.0, 1.0, 1.0);
		glBegin(GL_TRIANGLES);
		
		float i, j; 
		int odraz;
		
		for (odraz = 0; odraz >= 0; odraz--)
		for (j=2; j > -2; j-= 1.5)
			for (i = 3.5; i >= -0.5; i-=1.0) {
				float depth = 0.3f + i;
				if (odraz)
					depth = 4.0f + depth;
				glTexCoord2d(0.0f, 0.98f); glVertex3f(-0.8f+j, depth, 0.8f);
				glTexCoord2d(1.0f, 0.98f); glVertex3f(0.2f+j, depth, 0.8f);
				glTexCoord2d(1.0f, 0.02f); glVertex3f(0.2f+j, depth, 1.0f); 
				glTexCoord2d(0.0f, 0.98f); glVertex3f(-0.8f+j, depth, 0.8f);
				glTexCoord2d(1.0f, 0.02f); glVertex3f(0.2f+j, depth, 1.0f);
				glTexCoord2d(0.0f, 0.02f); glVertex3f(-0.8f+j, depth, 1.0f);
			}
		glEnd();
	}
	
	
	
	
	
	glBindTexture(GL_TEXTURE_2D, 0);

	
	
	// sachovnicu trosku nadol, prosim
	glTranslatef(0.0f, 0.0f, -0.4f);
	renderBoardAndFigures(boardScale, boardRotationZ);
	
	
	glPopMatrix();
}

- (void) drawRect: (NSRect) bounds
{	
	[[self openGLContext] makeCurrentContext];
	
	if (faceDetector) {
		[faceDetector detectFace];
		[self drawAnObject];		
	} else {
		glClearColor((float)(Random()%10) / 10., (float)(Random()%10) / 10., 0, 1);
		glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	}
	glFlush();
}

- (void) reshape
{
	NSRect frame = [self frame];
	
	if(NSIsEmptyRect([self visibleRect])) {
        glViewport(0, 0, 1, 1);
    } else {
        glViewport(0, 0,  frame.size.width ,frame.size.height);
    }
}

- (void) timerTick
{
	/*
	static int i = 0;
	
	if (i++ == 5*60)
		[self enterFullScreenMode:[NSScreen mainScreen] withOptions:[NSDictionary dictionaryWithObjectsAndKeys: @"1", @"NSFullScreenModeApplicationPresentationOptions", nil]
		 ];
	else if (i == 10*60)
		[self exitFullScreenModeWithOptions:nil];
	 */
	[self drawRect:[self bounds]];
}


- (void)startAnimation {

	[[self openGLContext] makeCurrentContext];

	texturaBottom = [[GLTextura alloc] initWithRaw:@"pasik" width:512 height:512 hasAlpha:FALSE];
	texturaTravicka = [[GLTextura alloc] initWithRaw:@"travicka" width:256 height:64 hasAlpha:TRUE];
	texturaOblacik = [[GLTextura alloc] initWithRaw:@"oblacik" width:256 height:64 hasAlpha:TRUE];
	
	boardRotationZ = 12.0f;
	boardScale = 1.0;
    self->animationTimer = [NSTimer scheduledTimerWithTimeInterval:animationInterval target:self selector:@selector(timerTick) userInfo:nil repeats:YES];
}


- (void)stopAnimation {
    self->animationTimer = nil;
}

- (void)setAnimationInterval:(NSTimeInterval)interval {
    
    animationInterval = interval;
    if (self->animationTimer) {
        [self stopAnimation];
        [self startAnimation];
    }
}

- (void)setFaceDetector:(id)faceDetector {
	self->faceDetector = faceDetector;
}

- (void)eyePosition:(float)setEyePosition eyeAngle:(float)eyeAngle {
	self->eyePosition = setEyePosition;
	self->eyeAngle = eyeAngle;
}


//The GL view is stored in the nib file. When it's unarchived it's sent -initWithCoder:
- (id)initWithCoder:(NSCoder*)coder {
	self = [super initWithCoder:coder];
	if (self) {
		animationInterval = 1.0 / 60.0;
	}
	return self;
}

- (void)performClose:(id)sender
{
	[self dealloc];
}
- (void)dealloc {
    
    [self stopAnimation];
    /*
    if ([EAGLContext currentContext] == context) {
        [EAGLContext setCurrentContext:nil];
    }
    
    [context release];  
	 */
	[super dealloc];
}

- (BOOL)acceptsFirstResponder
{
	return YES;
}
- (void)rotateWithEvent:(NSEvent *)event
{
	boardRotationZ += [event rotation];
	if (boardRotationZ > 360.0)
		boardRotationZ -= 360.0;
	if (boardRotationZ < 0.0)
		boardRotationZ += 360.0;
}
- (void)magnifyWithEvent:(NSEvent *)event
{
	boardScale += 5.*[event magnification];
	if (boardScale > 10.0f)
		boardScale = 10.0f;
	if (boardScale < 0.5f)
		boardScale = 0.5f;
}

@end
