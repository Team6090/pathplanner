# Pivot Grid Editor

![](pivotgrid.png)

The pivot grid editor is fairly rudimentary in its current state, but it allows editing of the grid that will be
used by PathPlannerLib pathfinding commands to avoid rotating the pivot in dangerous locations like under the stage. You likely shouldn't need to edit this more than once.

The grid can be edited by either clicking on individual grid nodes to toggle them between an obstacle or a non-obstacle,
or you can click and drag to "paint" multiple nodes. Nodes in red are considered an obstacle.

> **Note**
>
> A grid node should only be considered a non-obstacle if the robot won't hit an object while the **center** of the robot is in that location and the mechanism won't make contact while pivoting from **any orientation programmed**.
>
{style="note"}
