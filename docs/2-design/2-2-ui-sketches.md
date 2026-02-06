## 2.2 UI sketches

![Sketch of the main menu](./assets/ui-main.png)

Pictured is the main interface of the program, the graph display. The UI of the
graph display includes an axis-aligned bounding box (AABB) to represent the domain
of the graph, the graph itself and the HUD bar (detailed below).

Keeping in line with my consideration of simplicity in the high level overview, menuing
is kept to a minumum and everything can be accessed within one or two button presses from
the graph display.

![Sketch of the different modes](./assets/ui-modes.png)

Taking inspiration from current solutions, in order to keep input as intuitive as
possible with the limited controls of the calculator keyboard, I've split different
interactions across several input modes. Each mode has its own keybinds and help
menu<!--TODO: help menu--> and displays relevant information to the interactino.

I've considered how to divide various input tasks in a way that doesn't overwhelm
the user, and I want to make sure it's as easy as possible to switch between modes.
This will likely be via a special super key that won't be used anywhere else.

The HUD is colour coded per mode, and lists relevant information only to streamline
the presentation of data to the user.

![Sketch of a theoretical way to display the domain](./assets/ui-domain.png)

![Sketch of how the rotational angles could work](./assets/ui-rotate.png)

The axis-aligned bounding box will be used to orient the graph from the perspective
of the user; for graph exploration purposes, it's important that the orientation,
size, proprtions and scale of the graph is communicated effectively. I found that
making the three axis visible on the graph display with colour coding not only
made it clearer how the graph was rotated/scaled, but also made it more obvious
which axis was which.

