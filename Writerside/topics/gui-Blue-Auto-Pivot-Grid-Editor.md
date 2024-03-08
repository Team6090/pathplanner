# Blue Auto Pivot Grid Editor

![](blueautopivotgrid.png)

The blue auto pivot grid editor is fairly rudimentary in its current state, but it allows editing of the grid that will be
used as a parameter within the user's code to avoid rotating the pivot in dangerous locations like under the stage or the opposing alliance's wing. You likely shouldn't need to edit this more than once.

The grid can be edited by either clicking on individual grid nodes to toggle them between a permitted zone or a restricted zone,
or you can click and drag to "paint" multiple nodes. Nodes in red are considered a restricted zone.

> **Note**
>
> A grid node should only be considered a permitted zone if the robot is acceptable to pivot while the **center** of the robot is in that location and in **any orientation programmed**.
>
{style="note"}
