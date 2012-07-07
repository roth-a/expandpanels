This is the Readme for the component package (TMyRollOut+ExpandPanels) for Lazarus (www.lazarus.freepascal.org).

The package contains two components. The visual TMyRollOut and the non-visual ExpandPanels. TMyRollOut is a collapsable panel. Two or more TMyRollOut's can be automatically put beneath each other with ExpandPanels.


Contact me here: roth-a :a:t:  gmx.de



Download the latest version from:
  https://github.com/roth-a/expandpanels/zipball/master

Clone the repository with:
  git clone git://github.com/roth-a/expandpanels.git

Screenshots and a video tutorial for installation in Lazarus and demonstration of the functionality:
  http://student.physik.uni-mainz.de/~rothalex/?q=content/expandpanels





Usage notes for grouping myrollout in an expandpanel:
  You have to add a myrollout to a expandpanel (in OnCreate) with the command:
    expandpanel1.AddPanel(myrollout1);



  If you want to create all the components during runtime (like in the developement example), you have to execute:
    ex1:=TExpandPanels.create(self);

    p1:=TMyRollOut.Create(self);
    p1.Parent:=self;
    ex1.AddPanel(p1);







PS: For everyone who wants to learn git: http://githowto.com