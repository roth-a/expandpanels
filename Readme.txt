Contact me here: admin@alexanderroth.spacequadrat.de



Infos for this package you can find here:
  http://forge.lazarusforum.de/projects/show/expandpanels

The svn Repository is Available here:
  http://forge.lazarusforum.de/repositories/show/expandpanels

You can check it out with:
  svn co http://svn.lazarusforum.de/svn/expandpanels expandpanels





Implementation:

A Step by Step Guide is available here:
  https://student.physik.uni-mainz.de/~rothalex/?q=de/node/98



Note:

You have to add a myrollout to a expandpanels (during creation) with the command:
  expandpanel1.AddPanel(myrollout1);



If you want to create all the components during runtime (like in the developement example), you have to execute:
  ex1:=TExpandPanels.create(self);

  p1:=TMyRollOut.Create(self);
  p1.Parent:=self;
  ex1.AddPanel(p1);




