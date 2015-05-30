unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, ExpandPanels,  FileUtil, Forms, Controls,
  Graphics, Dialogs, Calendar, ExtCtrls, Buttons, StdCtrls;

type

  { TForm1 }

  TForm1 = class(TForm)
    Calendar1:  TCalendar;
    Calendar10: TCalendar;
    Calendar11: TCalendar;
    Calendar14: TCalendar;
    Calendar15: TCalendar;
    Calendar2:  TCalendar;
    Calendar3:  TCalendar;
    Calendar9:  TCalendar;
    CheckBox2:  TCheckBox;
    ExpandPanels2: TExpandPanels;
    ExpandPanels3: TExpandPanels;
    Label1:     TLabel;
    MyRollOut1: TMyRollOut;
    MyRollOut10: TMyRollOut;
    MyRollOut11: TMyRollOut;
    MyRollOut14: TMyRollOut;
    MyRollOut15: TMyRollOut;
    MyRollOut2: TMyRollOut;
    MyRollOut3: TMyRollOut;
    myrolloutsingle: TMyRollOut;
    MyRollOut9: TMyRollOut;
    RadioButton1: TRadioButton;
    RadioGroup1: TRadioGroup;
    RBehaviour: TRadioGroup;
    RButt:      TRadioGroup;
    RColl:      TRadioGroup;
    RDirection: TRadioGroup;
    Shape2:     TShape;
    procedure CheckBox2Change(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure RadioGroup1Click(Sender: TObject);
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

implementation

{$R *.lfm}

{ TForm1 }



{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
begin
  ExpandPanels3.AddPanel(MyRollOut1);
  ExpandPanels3.AddPanel(MyRollOut2);
  ExpandPanels3.AddPanel(MyRollOut3);


  ExpandPanels2.AddPanel(MyRollOut11);
  ExpandPanels2.AddPanel(MyRollOut9);
  ExpandPanels2.AddPanel(MyRollOut10);
end;

procedure TForm1.RadioGroup1Click(Sender: TObject);
begin

end;

procedure TForm1.CheckBox2Change(Sender: TObject);
begin
  MyRollOut11.Visible := CheckBox2.Checked;
  MyRollOut9.Visible  := CheckBox2.Checked;
  MyRollOut10.Visible := CheckBox2.Checked;
  MyRollOut14.Visible := CheckBox2.Checked;
  MyRollOut15.Visible := CheckBox2.Checked;
end;

procedure TForm1.RBehaviourClick(Sender: TObject);
begin
  ExpandPanels3.Behaviour := TExpandPanelsBehaviour(RBehaviour.ItemIndex);
end;

procedure TForm1.RButtClick(Sender: TObject);
begin
  myrolloutsingle.ButtonPosition := TAnchorKind(RButt.ItemIndex);
end;

procedure TForm1.RCollClick(Sender: TObject);
begin
  myrolloutsingle.CollapseKind := TAnchorKind(RColl.ItemIndex);
end;

procedure TForm1.RDirectionClick(Sender: TObject);
begin
  ExpandPanels3.ArrangeKind    := TAnchorKind(RDirection.ItemIndex);
  ExpandPanels3.CollapseKind   := ExpandPanels3.ArrangeKind;
  ExpandPanels3.ButtonPosition := ExpandPanels3.ArrangeKind;

  if RDirection.ItemIndex = 0 then
    begin
    ExpandPanels3.Above := 100;
    ExpandPanels3.OrthogonalAbove := 208;
    end
  else
    begin
    ExpandPanels3.OrthogonalAbove := Height - ExpandPanels3.Panel(0).Height;
    ExpandPanels3.Above := 208;
    end;
end;

end.
