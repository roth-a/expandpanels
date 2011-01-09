unit Unit1; 

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  ExtCtrls, Calendar, StdCtrls, ExpandPanels;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Calendar1: TCalendar;
    ListBox1: TListBox;
    RBehaviour: TRadioGroup;
    RDirection: TRadioGroup;
    RColl: TRadioGroup;
    RButt: TRadioGroup;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure RBehaviourClick(Sender: TObject);
    procedure RButtClick(Sender: TObject);
    procedure RCollClick(Sender: TObject);
    procedure RDirectionClick(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end; 

var
  Form1: TForm1;
  ex1:TExpandPanels;
  p1,p2,p3:TMyRollOut;

implementation

{ TForm1 }


procedure TForm1.FormCreate(Sender: TObject);
begin
  ex1:=TExpandPanels.create(self);

  p1:=TMyRollOut.Create(self);
  p2:=TMyRollOut.Create(self);
  p3:=TMyRollOut.Create(self);

  p1.Parent:=self;
  Calendar1.Parent:=p1;
  Calendar1.Align:=alClient;
  p2.Parent:=self;
  ListBox1.Parent:=p2;
  ListBox1.Align:=alClient;
  p3.Parent:=self;
  Button1.Parent:=p3;

  ex1.AddPanel(p1);
  ex1.AddPanel(p2);
  ex1.AddPanel(p3);



  ex1.ButtonPosition:=TAnchorKind(RButt.ItemIndex);
  ex1.CollapseKind:=TAnchorKind(RColl.ItemIndex);
  ex1.Behaviour:=TExpandPanelsBehaviour(RBehaviour.ItemIndex);
end;


procedure TForm1.FormDestroy(Sender: TObject);
begin
  ex1.Free;
  p1.Free;
  p2.Free;
  p3.Free;
end;

procedure TForm1.RBehaviourClick(Sender: TObject);
begin
  ex1.Behaviour:=TExpandPanelsBehaviour(RBehaviour.ItemIndex);
end;


procedure TForm1.RButtClick(Sender: TObject);
begin
  ex1.ButtonPosition:=TAnchorKind(RButt.ItemIndex);
end;

procedure TForm1.RCollClick(Sender: TObject);
begin
  ex1.CollapseKind:=TAnchorKind(RColl.ItemIndex);
end;

procedure TForm1.RDirectionClick(Sender: TObject);
begin
  ex1.ArrangeKind:=TAnchorKind(RDirection.ItemIndex);
end;

initialization
  {$I unit1.lrs}

end.

