# PhysicsGame
Simple game prototype to show some physic game engine basics for @FHTechnikumWien

## Table of Contents

- [Topics](#topics)
- [Trivia](#trivia)
- [Overview and description](#overview)
	* [Standard Group](#standard-grp)
	* [Toughie Group](#toughie-grp)
	* [Euler Group](#euler-grp)
- [Controls](#control-anchor)
- [Assets](#assets)
- [References and resources](#references)

<a name="trivia" />

## Trivia

### Terminology

- Acceleration a is the change of velocity over time
- Speed s is change of position over time, acceleration * delta
- Velocity v is dir * speed
- Force F push or pull on an object thtat cause a mass to accelerate (gravity, magnetism, ...)

 ``F = m*a = dp/dt``

- Momentum p

``p = m*v``

### Newtons laws

I. An object at rest will stay at rest, and an object in motion will stay in motion unless acted on by a net external force
II. The rate of change of momentum of a body over time is directly proportional to the force applied, and occurs in the same direction as the applied force.
III. All forces between two objects exist in equal magnitude and opposite direction.


<a name="topics" />

## Topics (TBD)

Your grade will be based on a Unity project you make. This can be a game, or a simulation that
implements and demonstrates your understanding of these topics:

Your mark will be based on

A. Your 7 additional highest marks from the standard or toughie groups excluding those in
point B (70 points)
B. Your 2 highest marks from the toughie group (20 points)
C. Your mark from the Euler group (10 points)

**Standard group:**
- [x] Normalisation and magnitude
- [x] Movement by forces vs velocity
- [x] Drag function (not unity default)
- [x] Gravity function (not unity default)
- [x] Collision Normals
- [ ] Angular velocity
- [x] Momentum
- [x] Impulse
- [ ] Orbit
- [ ] Friction + Mass
- [x] Coefficient of restitution
- [x] Reflection
- [ ] Potential/kinetic energy

**Toughie group:**
- [ ] Hooke's law/Damping: This can be a spring, an elevator, water, a rope
- [x] Galilean relativity
- [ ] Centrifugal/Coriolis correction
- [ ] Cross products in physics (3D)
- [x] Projectile Motion
- [ ] Pendulums
- [ ] Advanced slope physics

**Euler group:**
- [x] Demonstrate understanding of euler integration


<a name="overview" />

## Overview and description (TBD)

My project is a time travelling 2d platformer called Rad Boar Rewind. These are my topics:

<a name="standard-grp" />

### Standard

**- Normalisation and magnitude**

*Read the controller input vector.
For a 3D game, add a deadzone and change the magnitude so it uses the squared value of the
reading instead of the raw value
For a 2D platformer modify the value so that any x value from 0.9-1 will produce a value of 1 and
e*very other reading from the deadzone (say 0.1) to the max zone (0.9) is scaled correctly

![InputHandler](Images/InputHandler.png?raw=true "InputHandler")

InputManager.gd reads input, adds inner and outer deadzones (defined as JOYPAD_DEADZONE with a value of 0.2) and then scales to normalized value. Show the received and mapped input values using 'k'.

**- Movement by forces vs velocity TBD**

*When the L button is being held, make your character controller modify the velocity directly as a  velocity and not an acceleration. When L is not being held, make your character controller move with  a force, either with a velocity delta or by AddForce*

RadBoar.cs has a function called Move(), if you hold L2 it will move you by velocity, otherwise it moves you by force.

Implemented different movements for pawns: simple Enemy.gd just moves by setting the velocity in the opposite direction after colliding with an obstacle. Bomb.gd applies gravity and bounces off of walls and other obstacles and Player.gd hast different implemented methods for moving:
0... TBD

**- Drag function**

*Write your own drag function which will take a factor that can e.g. change depending on the fluid the
character is in. You can also write a more advanced function that will support your Galilean Relativity*

Pawn.gd contains a ``apply_drag()`` function to lerp with the configured drag factor. Thus can be set using ``set_drag`` on Pawn and derived classes and is used if entering/exiting Water.

**- Gravity function**

*Write a gravity function with a uniform gravitational acceleration regardless of inertial mass. You could also change the gravitational field strength based on where the character is ontriggerenter to have a kind of moonwalk area.*

Pawn.gd contains a ``apply_gravity()`` function. Value can be changed using the ``set_gravity`` function on Pawn and derived classes.

**- Collision Normals**

*When the character hits the floor, they should become grounded so they can jump again. Depending on the angle of what they hit, they should not become grounded. You can demonstrate this with walls or even sloped surfaces.*

Player has a downward raycast attached to it which reads the normal of it in Player.gd. This value is used to determine, if the player is grounded and sets the rotation of the sprite to align the model with the surface. The effect can be seen in the level: for the higher slopes the player is not able to jump, because the angle does not count as grounded.

**- Angular Velocity**

*A missile that comes towards you and rotates by angular velocity rather than by quaternion towards its forward. Easier in 2d!*

**- Momentum**

*When two objects collide they should*

Explosion.cs makes a bigger explosion with more particles depending on the mass and
relativeVelocity of the two colliding objects

If a Bomb collides with another Bomb or Player, the momentum of both changes. Although both using a default mass of 1, their velocity is usually different.
When a Bomb explodes it applies a force depending on it's mass and the distance to an object (the more the nearer). In case the affected Object is also a Bomb, another explosion is triggered, summing the resulting forces. This means, if a Player stands beside multiple bombs when they explode, the combined force of all explosions it added.

**- Impulse**

*Show your understanding of impulse with a force that happens over a short period of time rather than instant. E.g. an advanced jump cycle in which the character has a variable jump height depending on how long they press A, rather than a simple “add y velocity”.*

Player.gd has three different methods for jumping, that can be selected with key 'j' on keyboard:
0... linear
1... logarithmic
2... cosine
This allows higher jumping depending on how long the jump button is pressed.

**- Orbit**

*A sentry bot that orbits you following Newton’s Law of Gravitation would satisfy this in any kind of 2d game, or you could straight up do planets in space if you want to make a space game. It could even just be a set-piece you stumble upon.*

Orb.cs follows you according to GMm/r^2

**- Friction + Mass**

*Add some different slopes with different coefficients of friction (using your own function rather than Physics Materials). You could go the extra mile and do dynamic vs static friction or resolving slopes correctly*

**- Coefficient of Restitution**

*Instead of using the built in “bounciness” you can make your own coefficient of restitution, where two objects collide and pass on velocity correctly. You can make bouncy balls and bowling balls e.g.*

Bomb.gd applies the ``collide`` function, defined in Pawn.gd, if they collide with another moving Pawn such as Player or other Bombs for itself and the collided object. If they collide with non-movable objects like walls, the instead use a ``bounce`` function to adjust their given velocity.

**- Reflection**

*A mirror puzzle which raycasts outwards from a laser, and if it hits anything on a mirror mask, will reflect. At this point it would take the angle of incidence, raycast towards the angle of reflection and once it hits a non reflective surface represent all the reflections with a LineRenderer*

Not sure if this counts as reflection, but Bomb.gd use a ``bounce`` function when colliding with walls to adjust their given velocity, which would result in the reflected angle if there would be no drag or gravity applied.

**- Potential/kinetic energy**

*A simple harmonic oscillator that converts potential energy into kinetic energy and vice versa and displays their values. You could do a mass on a pulley e.g.
I would personally not choose this topic because this is an analytical way of doing physics and not generally a simulation based one, and therefore it is rarely used in games. But since it’s on the syllabus, I will mark it if you try it.*

<a name="toughie-grp" />

### Toughie

**- Hooke’s Lap/Damping**

*A damped pair of scales. When you push one down, the other goes up, they wobble and then damp. A body of water represented by a line renderer, the surface splashes when you jump on it*

**- Galilean Relativity**

*Working moving platforms in which your normal physics, gravity, drag apply from your typical frame of reference into your new frame and you correctly inherit the velocity of your parent with physics (not through trying to use parenting or moving by transform)*

``Plattform.gs`` moves (defined by it’s mode) at a constant velocity. If Player.gd touches the top surface (one way collision) the current platform velocity is set as ground_velocity which is used as target for the drag lerp. The ground which the player stands on is constantly monitored to determine velocity changes of the plattform as well as falling/jumping off.

**- Centrifugal/Coriolis correction**

*When you’re standing on a rotating moving platform, your frame of reference is rotating. You canmake your character stay on a rotating platform correctly by simulating the Centrifugal force.Likewise if you simulate the Coriolis force they can walk along the middle without veering to one side. No need to do both, one is fine if this topic is selected.*

**- Cross products in Physics (3D)**

*Throw an object and have it spin towards the right direction depending on the view angle and where you project it*

**- Projectile Motion**

*A projectile launcher with a fixed velocity that can calculate the correct angle at which to project something in order to hit a target (or the character) Or e.g. a Deterministic parabolic arc simulator that will show where an object flies before it is fired*

Cannon.gd tracks the position of the Player if in reachable range and outside a defined close range to calculate the angle and velocity of fired bombs to hit. The resulting velocity is drawn per line, simulating the Bomb movement.

Somehow this is a little offset: if the angle to hit the Player is < 45 ° the arc is to small, at exactly 45 ° it fits, > 45 ° it's larger than thge correct distance.
I have spend several hours trying to pin down the problem but was not able to fix it :/
I manually derived the quadratic equation for theta on paper but ended up using the shown code from RudeBear because this gives the most accurate results.

I believe this could be either a problem with scaling, although I double-checked all the objects and positions in the level and could'nt find something that doesn't look correct.
Or maybe I just messed up applying the correct quadrant for the shooting direction.


For this task I also added a "SUVAT.gd" node to provide an api for all the equations, but I ended up not using them in code.


**- Pendulums**

*Pendulums that correctly oscillate with angular velocity showing a correct period depending on the length. Bonus if you go full gyro*

**- Advanced slope physics**

*Slope physics where, upon running up slopes of different heights, you will either manage to walk up (albeit slower) or you will slide down depending on the angle. Standing still on slopes and railings when no input is detected instead of sliding down.*

**- Hooke’s Law AND Pendulum**

I added a rope that you can swing on in Pendulum.cs. Not only does it swing with a period based on the length, but the rope itself is stretchy and oscillates when you jump on it, eventually reaching 0 due to damping!

<a name="euler-grp" />

### Euler

**- Euler integration**

*Moving something to a desired position via its VELOCITY without a rigidbody.position/move function. Any function that shows you really understand how Time.fixedDeltaTime works in the engine and how it ties into calculus.*

Companion.cs lerps your little companion towards you using its velocity

<a name="control-anchor" />

## Controls

| key        | action |
| :------------- | :----- |
| k      | toggle InputHandler visibility |
| m      | change move mode |
| j      | change jump modes: linear, exp, cos |

Player can also be moved with a controller

<a name="assets" />

## Used assets

- [starting assets from GDQuest](https://github.com/GDQuest/godot-beginner-2d-platformer/releases/tag/1.1.0)

- "Boom" from one of my previous projects "Phaethon 3200"

- diverse Super Mario assets found from the internet

- Alex Rose head from his [Twitter Account](https://twitter.com/alexrosegames?lang=de)

- Boom Sound from [freesound.org](https://freesound.org/people/XHALE303/sounds/535592/)

<a name="references" />

## Additional references and resources

- [Hyperphysics](http://hyperphysics.phy-astr.gsu.edu/hbase/hframe.html)

- [official Godot Demo projects](https://godotengine.github.io/godot-demo-projects)

- [moving platforms with animation player](https://kidscancode.org/godot_recipes/2d/moving_platforms/)

- https://godotengine.org/article/handling-axis-godot

- https://www.reddit.com/r/godot/comments/bkbttb/how_to_access_the_deadzone_value_set_in_the_input/

- https://godotengine.org/qa/10532/godot-joystick-axis-never-rests-at-0

- https://docs.godotengine.org/de/stable/tutorials/3d/fps_tutorial/part_four.html
