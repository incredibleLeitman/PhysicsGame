# PhysicsGame
Simple game prototype to show some physic game engine basics for @FHTechnikumWien


## topics TBD

**Standard group:**
- Normalisation and magnitude
- Movement by forces vs velocity
- Drag function (not unity default)
- Gravity function (not unity default)
- Collision Normals
- Angular velocity
- Momentum
- Impulse
- Orbit
- Friction + Mass
- Coefficient of restitution
- Reflection
- Potential/kinetic energy

**Toughie group:**
- Hooke's law/Damping: This can be a spring, an elevator, water, a rope
- Galilean relativity
- Centrifugal/Coriolis correction
- Cross products in physics (3D)
- Projectile Motion
- Pendulums
- Advanced slope physics

**Euler group:**
- Demonstrate understanding of euler integration


## overview and description

My project is a time travelling 2d platformer called Rad Boar Rewind. These are my topics:

**- Normalisation and magnitude (Standard)**

InputManager.cs reads your input, adds a deadzone then scales the normalized value from 0.1 to 1

**- Movement by forces vs velocity (Standard)**

RadBoar.cs has a function called Move(), if you hold L2 it will move you by velocity, otherwise it
moves you by force.

**- Drag function (Standard)**

RadBoar.cs contains a function called Drag(). The drag changes depending on the fluid you’re
traversing.

**- Gravity function (Standard)**

RadBoar.cs contains a function called Grav(). The gravity changes in different rooms.

**- Collision Normals (Standard)**

RadBoar.cs OnCollisionEnter2D reads the y normal of the collision and uses that to check whether
you’re grounded

**- Momentum (Standard)**

Explosion.cs makes a bigger explosion with more particles depending on the mass and
relativeVelocity of the two colliding objects

**- Orbit (Standard)**

Orb.cs follows you according to GMm/r^2

**- Galilean Relativity (Toughie)**

I tried to implement a moving frame of reference in FloatingArena.cs. Floating arena moves at a
constant velocity, I wanted to show that Rad Boar would have his normal expected velocity + the
velocity of the Floating Arena to demonstrate relativity. Unfortunately when I tried adding on the
velocity every frame or parenting him to the object, this did not solve the problem, and he
accelerates instead of appearing to move normally in his local frame.

**- Hooke’s Law AND Pendulum (Toughies)**

I added a rope that you can swing on in Pendulum.cs. Not only does it swing with a period based on
the length, but the rope itself is stretchy and oscillates when you jump on it, eventually reaching 0
due to damping!

**- Euler integration (Euler)**

Companion.cs lerps your little companion towards you using its velocity

## controls

| key        | action |
| :------------- | :----- |
| k      | toggle InputHandler visibility |

Player can also be moved with a controller

## used assets

- [starting assets from GDQuest](https://github.com/GDQuest/godot-beginner-2d-platformer/releases/tag/1.1.0)

## references

- [official Godot Demo projects](https://godotengine.github.io/godot-demo-projects)

- [moving platforms with animation player](https://kidscancode.org/godot_recipes/2d/moving_platforms/)

- https://godotengine.org/article/handling-axis-godot

- https://www.reddit.com/r/godot/comments/bkbttb/how_to_access_the_deadzone_value_set_in_the_input/

- https://godotengine.org/qa/10532/godot-joystick-axis-never-rests-at-0

- https://docs.godotengine.org/de/stable/tutorials/3d/fps_tutorial/part_four.html