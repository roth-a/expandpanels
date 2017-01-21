# TMyRollOut and ExpandPanel

These are [Lazarus](http://www.lazarus-ide.org/) components. More infos please check the [TMyRollOut and ExpandPanel wiki](http://wiki.lazarus.freepascal.org/TMyRollOut_and_ExpandPanel).

* TMyRollOut is a visual component. It is a Panel that collapses when clicked on the button.
 			  ![](TMyRollOut.png)
* ![](TExpandPanels.png) TExpandPanels a non visual component. It arranges multiple TMyRollOut instances beneath/side-by-side to each other to save space.


## Features
 * saves space
 * everything is animated (you can turn it off if you want)
 * you can place the button of the panel on the top, bottom, left or right (in this cases the caption is printed vertically)
 * you can collapse the panel to any direction you want
 * you can align the caption to the left, right, center and the glyph to left, right or hide both
 * ExpandPanels arranges all the panel nicely under (or besides) each other, so it takes as little space as possible
 * ExpandPanels has different "behaviors": It can open as many panels as you click, or just the one you last clicked


## Usage

### Components installed in Lazarus
After installing both components into Lazarus, you can add multiple TMyRollOut instances (myrollout1, myrollout2, etc.) to the form. To arrange them beneath each other you have to add the TMyRollOut instances to a expandpanel (in OnCreate) with the command:
```
expandpanel1.AddPanel(myrollout1);
expandpanel1.AddPanel(myrollout2);
```

### Components *not* installed in Lazarus
If you want to create all the components during runtime (like in the development example), you have to execute:
```
expandpanel1:=TExpandPanels.create(self);
myrollout1:=TMyRollOut.Create(self);
myrollout1.Parent:=self;
expandpanel1.AddPanel(myrollout1);
```
and then  add them to the expandpanel1
```
expandpanel1.AddPanel(myrollout1);
expandpanel1.AddPanel(myrollout2);
```

## Demo Project

![](Expandpanels.png)