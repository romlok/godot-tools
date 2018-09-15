# Some Godot stuff

This is a selection of reusable chunks from some of my projects.

## Addons/Plugins

Each plugin tries to focus on doing just one thing, so allowing the developer
to combine them into something greater.

### followother

Two custom nodes: FollowOther and LookAtOther, which track another node in
the tree and manipulate their own parent's Transform so that it follows the
position and/or rotation of the target, or just stares intently at it.

Optional interpolation included at no extra charge.

### cameracontrols

FPSController and RTSController can be added as a child of a node, and will
respond to mouse/action input events to change the parent node's transform.

Designed to manipulate a Camera, or the parent node of an offset Camera.

## Gfx

### Boxguy

It's a boxy kinda guy. Rigged and animated, kinda.

