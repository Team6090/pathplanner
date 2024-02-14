# Limelight Grid Editor

![](limelightgrid.png)

The limelight grid editor is fairly rudimentary in its current state, but it allows editing of the grid that will be
used by PathPlannerLib pathfinding commands to avoid pose correction in certain areas. You likely shouldn't need to edit this much.

The grid can be edited by either clicking on individual grid nodes to toggle them between an obstacle or a non-obstacle,
or you can click and drag to "paint" multiple nodes. Nodes in red are considered an obstacle.

> **Note**
>
> A grid node should only be considered a non-obstacle if you do not want to correct in that area while the **center** of the robot is there.
>
{style="note"}
