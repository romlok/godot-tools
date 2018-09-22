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

### inputcontrols

MouselookController and PanController can be added as children of a Spatial
node, and will alter the parent node's transform in response to mouse/input
events.

Note that, in line with camera orientation, "forward" for such controlled
nodes is considered to be the *negative* Z axis.


## Gfx

### Boxguy

It's a boxy kinda guy. Rigged and animated, kinda.

