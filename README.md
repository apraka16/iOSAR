# App that runs an AR session and uses plane detection to place 3D content using SceneKit.  

## Basic 3D shapes to start off have been created using iOS SceneKit native codes. 

Proposed 3D modeling tool to be used to create advanced shapes is Blender. From Blender models can be imported in iOS using .dae extension. All models should be placed in .scnAssets folder.

## 3D objects which can be places in the View, using buttons on the top right:

Shapes | Button
------------ | -------------
Cube | C
Sphere | S

## Basic user interaction have been enabled for 3D objects placed in :

Gesture | Action
------------ | -------------
Tap | Add selected 3D object (cube, sphere, etc.) in the center of detected plane 
Swipe | Remove swiped 3D object from the current location

## TODO:
* Lighting Condition: To use environment lighting conditions to light up the shapes
* Smooth Transition: To make transition of plane detection and consequent plane udpate smooth so as to have better UI
* Add multipleGesture recognition and create separate class/ sourceCode for multiple gesture driven animation/ user interaction.
* Create and add Blender models

## Special Thanks
* Paul Hegarty (Stanford) lectures and Logging sourcecode.
* Apple team - ARKit starter sourcecode.
