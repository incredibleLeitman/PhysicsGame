# PhysicsGame

Simple game prototype built in Godot to show some physic game engine basics for @FHTechnikumWien.


## Table of Contents

- [Trivia](#trivia)
- [Overview and description](#overview)
- [Topics](#topics)
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
- Force F push or pull on an object that cause a mass to accelerate (gravity, magnetism, ...)

 ``F = m*a = dp/dt``

- Momentum p

``p = m*v``

### Euler

- Euler

    ``s += v * dt``

    ``v += a * dt``

- Improved Euler (Heun)

    ``s += dt * v * dt² * a/2``

    ``v += a * dt``

- Euler-Cromer

    ``v += a * dt``

    ``s += v * dt``

### Newtons laws

I. An object at rest will stay at rest, and an object in motion will stay in motion unless acted on by a net external force

II. The rate of change of momentum of a body over time is directly proportional to the force applied, and occurs in the same direction as the applied force.

III. All forces between two objects exist in equal magnitude and opposite direction.

### SUVAT

|  |  |
| :-: | :- |
| **S** | displacement |
| **U** | initial velocity (v - a * t) |
| **V** | final velocity |
| **A** | acceleration |
| **T** | time |

[1] ``v = u + a * t``

[2] ``s = u * t + 0.5 * a * t²``

[3] ``s = 0.5 * (u + v) * t	``

[4] ``v² = u² + 2 * a * s``

[5] ``s = v * t - 0.5 * a * t²``


``a = (v - u)/t``


<a name="overview" />

## Overview and description

In my project I just have thrown together demonstrations of the given concepts. I marked all the implemented topics from the three groups with a checkmark [x], 
topics marked with **TBD** are currently not implemented and may appear in future versions.

Because I haven't touched Unity in years, I used [Godot](https://godotengine.org/) for my project, but most implementation concepts work very similar. (``_process`` and ``_physics_process`` instead of ``Update`` and ``FixedUpdate``, positive y direction is down instead of up, etc...)

The demo level contains a "normal" Enemy on the left side, a few cannons that can shoot bombs at the player if in range and a larger bomb with more impact on the right side.
In between there are two platforms to demonstrate ground velocity integration and a "water" tunnel where gravity and drag values change if entered.
It also provides different angled slopes to show that the player character is grounded depending on the normal to the floor.

Player Pawn can be controlled by A, D and Cursor keys to move, W and Cursor UP to jump and with connected controllers: left control stick to move, A (XBox) or X (PS) to jump.
Controller inputs are mapped with respect to deadzones and can be shown using 'k' on keyboard.

![PhysicsGame](Images/PhysicsGame.png?raw=true "Physics Game")

I am really sorry that it looks so bad but I just have no feeling and hand for how to make things look more appealing ``¯\_(ツ)_/¯``


<a name="control-anchor" />

## Controls

| key        | action |
| :------------- | :----- |
| k      | toggle InputHandler visibility |
| m      | change move mode |
| j      | change jump modes: linear, exp, cos |
| WASD   | move character and jump|
| Cursor | move character and jump|

Player can also be moved with a controller


<a name="topics" />

## Topics

Your grade will be based on a Unity project you make. This can be a game, or a simulation that implements and demonstrates your understanding of these topics:

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
- [ ] Angular velocity TBD
- [x] Momentum
- [x] Impulse
- [ ] Orbit TBD
- [ ] Friction + Mass TBD
- [x] Coefficient of restitution
- [x] Reflection
- [ ] Potential/kinetic energy TBD

**Toughie group:**
- [ ] Hooke's law/Damping TBD
- [x] Galilean relativity
- [ ] Centrifugal/Coriolis correction TBD
- [ ] Cross products in physics (3D) TBD
- [x] Projectile Motion
- [ ] Pendulums TBD
- [ ] Advanced slope physics TBD

**Euler group:**
- [x] Demonstrate understanding of euler integration


<a name="standard-grp" />

### Standard

**- Normalisation and magnitude**

![InputHandler](Images/InputHandler.png?raw=true "InputHandler")

InputManager.gd reads input, adds inner and outer deadzones (defined as JOYPAD_DEADZONE with a value of 0.2) and then scales to normalized value. Show the received and mapped input values using 'k'.

**- Movement by forces vs velocity**

I Implemented different movements for pawns: simple Enemy.gd just moves by setting the velocity in the opposite direction after colliding with an obstacle. Platform.gd moves depending on it's mode either horizontally or vertically by velocity. Bomb.gd applies gravity and bounces off of walls and other obstacles and Player.gd has different implemented methods for moving (see [Euler Group](#euler-grp)).
In ``_calculate_move`` the movement speed is calculated depending on input strength and direction and added as force if current player velocity is below max speed.

**- Drag function**

Pawn.gd contains a ``apply_drag()`` function to lerp with the configured drag factor. Thus can be set using ``set_drag`` on Pawn and derived classes and is used if entering/exiting Water.

**- Gravity function**

Pawn.gd contains a ``apply_gravity()`` function. Value can be changed using the ``set_gravity`` function on Pawn and derived classes.

**- Collision Normals**

Player has a downward raycast attached to it which reads the normal of it in Player.gd ``_check_on_ground``. This value is used to determine, if the player is grounded and sets the rotation of the sprite to align the model with the surface. The effect can be seen in the level: for the higher slopes the player is not able to jump, because the angle does not count as grounded.

**- Angular Velocity TBD**

*A missile that comes towards you and rotates by angular velocity rather than by quaternion towards its forward. Easier in 2d!*

**- Momentum**

If a Bomb collides with another Bomb or Player, the momentum of both changes. Although both using a default mass of 1, their velocity is usually different.
When a Bomb explodes it applies a force depending on it's mass and the distance to an object (the closer the more). In case the affected Object is also a Bomb, another explosion is triggered, summing the resulting forces. This means, if a Player stands beside multiple bombs when they explode, the combined force of all explosions it added.

**- Impulse**

Player.gd has three different methods for an advanced jump cycle implemented in ``_jump``, that can be selected with key 'j' on keyboard:
0... linear
1... logarithmic
2... cosine
This allows higher jumping depending on how long the jump button is pressed.

**- Orbit TBD**

*A sentry bot that orbits you following Newton’s Law of Gravitation would satisfy this in any kind of 2d game, or you could straight up do planets in space if you want to make a space game. It could even just be a set-piece you stumble upon.*

Orb.cs follows you according to GMm/r^2

**- Friction + Mass TBD**

*Add some different slopes with different coefficients of friction (using your own function rather than Physics Materials). You could go the extra mile and do dynamic vs static friction or resolving slopes correctly*

**- Coefficient of Restitution**

Bomb.gd applies the ``collide`` function, defined in Pawn.gd, if they collide with another moving Pawn such as Player or other Bombs for itself and the collided object. If they collide with non-movable objects like walls, they instead use a ``bounce`` function to adjust their given velocity.

**- Reflection**

Not sure if this counts as reflection, but Bomb.gd use a ``bounce`` function when colliding with walls to adjust their given velocity, which would result in the reflected angle if there would be no drag or gravity applied.

**- Potential/kinetic energy TBD**

*A simple harmonic oscillator that converts potential energy into kinetic energy and vice versa and displays their values. You could do a mass on a pulley e.g. I would personally not choose this topic because this is an analytical way of doing physics and not generally a simulation based one, and therefore it is rarely used in games. But since it’s on the syllabus, I will mark it if you try it.*

<a name="toughie-grp" />

### Toughie

**- Hooke’s Law/Damping TBD**

*A damped pair of scales. When you push one down, the other goes up, they wobble and then damp. A body of water represented by a line renderer, the surface splashes when you jump on it*

**- Galilean Relativity**

``Plattform.gs`` moves (defined by it’s mode) at a constant velocity. If Player.gd touches the top surface (one way collision) the current platform velocity is set as ground_velocity with ``_set_floor_velocity`` which is used as target for the drag lerp. The ground which the player stands on is constantly monitored to determine velocity changes of the plattform as well as falling/jumping off.

**- Centrifugal/Coriolis correction TBD**

*When you’re standing on a rotating moving platform, your frame of reference is rotating. You canmake your character stay on a rotating platform correctly by simulating the Centrifugal force.Likewise if you simulate the Coriolis force they can walk along the middle without veering to one side. No need to do both, one is fine if this topic is selected.*

**- Cross products in Physics (3D) TBD**

*Throw an object and have it spin towards the right direction depending on the view angle and where you project it*

**- Projectile Motion**

Cannon.gd tracks the position of the Player if in reachable range and outside a defined close range to calculate the angle and velocity of fired bombs to hit. The resulting velocity is drawn per line, simulating the bombs movement.

Although the simulation and actual bomb movement are congruent, somehow there is a little offset for the tracking: if the angle to hit the Player is < 45 ° the arc is to small, at exactly 45 ° it fits and > 45 ° it's larger than the correct distance.
I have spent several hours trying to pin down the problem but was not able to fix it :/
I manually derived the quadratic equation for theta on paper but ended up using the shown code from RudeBear because this gives the most accurate results.

I believe this could be either a problem with scaling, although I double-checked all the objects and positions in the level and couldn't find something that doesn't look correct.
Or maybe I just messed up applying the correct quadrant for the shooting direction.

For this task I also added a SUVAT.gd node to provide an api for all the equations, but I ended up not using them in code.

**- Pendulums TBD**

*Pendulums that correctly oscillate with angular velocity showing a correct period depending on the length. Bonus if you go full gyro*

**- Advanced slope physics TBD**

*Slope physics where, upon running up slopes of different heights, you will either manage to walk up (albeit slower) or you will slide down depending on the angle. Standing still on slopes and railings when no input is detected instead of sliding down.*

**- Hooke’s Law AND Pendulum* TBD*

I added a rope that you can swing on in Pendulum.cs. Not only does it swing with a period based on the length, but the rope itself is stretchy and oscillates when you jump on it, eventually reaching 0 due to damping!

<a name="euler-grp" />

### Euler

**- Euler integration**

Player.gd uses three different move semantics in ``_physics_process``: Euler, improved Euler and Euler-Cromer which can be changed using 'm' on the keyboard.
The ``move_and_...`` functions are only moving the Node by the given velocity (and internally using fixed delta time) but additionally calculating collisions
and handling further movement if colliding such as slide or snap.

<a name="assets" />

## Used assets

- [starting assets from GDQuest](https://github.com/GDQuest/godot-beginner-2d-platformer/releases/tag/1.1.0)

- "Boom" from one of my previous projects "Phaethon 3200"

- diverse Super Mario assets found on the internet

- Alex Rose head from his [Twitter Account](https://twitter.com/alexrosegames?lang=de)

- Boom Sound from [freesound.org](https://freesound.org/people/XHALE303/sounds/535592/)

<a name="references" />

## Additional references and resources

- [Hyperphysics](http://hyperphysics.phy-astr.gsu.edu/hbase/hframe.html)

- [official Godot Demo projects](https://godotengine.github.io/godot-demo-projects)

- [Dynamic 2D Water in Unity](https://gamedevelopment.tutsplus.com/tutorials/creating-dynamic-2d-water-effects-in-unity--gamedev-14143)

- [Buoyancy and water in Godot](https://notapixelstudio.wordpress.com/2018/03/11/adding-water-and-buoyancy-to-a-platform-game-with-godot-and-tiled/)

- [a guide to 2D platformers](http://higherorderfun.com/blog/2012/05/20/the-guide-to-implementing-2d-platformers/)

- [Math for Game Programmers](http://higherorderfun.com/blog/2012/06/03/math-for-game-programmers-05-vector-cheat-sheet/)