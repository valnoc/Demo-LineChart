# Demo-LineChart

This is a demo project created to show a variant of line chart implementation.

#### Requirements:
- several datasets to show different situations
- "zooming" on a part of line chart via specialized control (x range control)
- lines and axes animation and adoption to y range when "x-zooming"
- ability to turn on/off lines
- info view with data values on chart click 

#### I used 
- CoreGraphics to maintain 2d calculation
- CALayers to combine several rendering layers
- CAShapeLayers for drawing layers with path
- CABasicAnimation for properties' animation

I've created a set of drawers for LineChartView. Each of them is responsible for drawing only one part of chart - y axis, lines, info view, etc. 
So, it's easy to add new "layers" of chart and to change one drawer to another. E.g., it's easy to change the way of drawing lines by injecting another drawer with the same protocol.
