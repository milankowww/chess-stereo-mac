Chess-Stereo-Mac

In 2010 I got inspired by the emerging 3d technologies that react to user.
I thought I'd try to create a 3d chess which will use the camera of my Mac to
track position and distance of my head and by displaying the scene from
appropriate angle, create an illusion of true 3-dimensional landscape.

This proof of concept for Mac OS X displays a 3d scene in left-right
stereoscopic view (suitable for most 3d TVs) and rotates the scene according to
the position of user, which is obtained from the camera using the OpenCV
library. From the position and dimension of the detected face it calculates the
3d coordinates of viewer, and responds by rotating the scene appropriately.

The 3d part works well. It turned out to be to slow and I lost interest, so the
chess functionality was never implemented. Improvements welcome.

I wanted to publish the complete XCode project, but it turns out the project
does not compile in a new XCode environment and I don't have the energy to
fix it, so I only publish the sources.

How to compile:
- create the XCode project
- add files
- add OpenCV
- add haarcascade_frontalface_alt.xml

How to use:

- connect the Mac to your 3D TV
- start the app
- switch to full screen
- start the 3d mode on your TV and use 3d glasses
- stay within the view of your camera. Move the head to explore the scene from different angles.

Screenshots are in the Screenshots/ subdirectory.

Patches and comments are very welcome.

(c) Milan Pikula 2010
