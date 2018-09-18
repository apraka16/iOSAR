# App that runs an AR session and uses plane detection to place 3D content using SceneKit.  

## REPO HAS BEEN MOVED PERMENENTLY AND IS NOT UPDATED ANYMORE. If one is interested for a conversation on this, they can get in touch at https://twitter.com/abhinavpraksh

## Basic 3D shapes to start off have been created using iOS SceneKit native codes. 

AR automatic plane detection in order to fix anchors in the scene. Depending on position of anchors, nodes are set in the scene so as to render AR experience. Target crosshairs (viz., focus square) to be used to let user know that AR is detecting planes and then crosshairs should visibly change in order to let the user know that plane has been detected and the scene is ready for the 3D object to be placed.

Proposed 3D modeling tool to be used to create advanced shapes is Blender. From Blender models can be imported in iOS using .dae extension. All models should be placed in .scnAssets folder.

## 3D objects which can be places in the View, using "add" button located bottom-center:

Shapes
------------
Cube
Sphere

## Basic user interaction have been enabled for 3D objects placed in :

Gesture | Action
------------ | -------------
Tap | Add selected 3D object (cube, sphere, etc.) in the center of detected plane 
Pinch | Scale object
Two-finger rotate | Rotate object
SwipeDown | Highlight Object for some seconds

## TODO:
* Lighting Condition: To use environment lighting conditions to light up the shapes
* Smooth Transition: To make transition of plane detection and consequent plane udpate smooth so as to have better UI
* Add multipleGesture recognition and create separate class/ sourceCode for multiple gesture driven animation/ user interaction. *Done*
* Create and add Blender models
* Facility of object placement w/o auto-addition of anchors.
* Facility to update crosshairs' (focusSquare) orientation depending on device orientation.

## Special Thanks
* Paul Hegarty (Stanford) lectures and Logging sourcecode.
* Apple team - ARKit starter sourcecode.
