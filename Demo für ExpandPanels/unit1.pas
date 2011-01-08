unit Unit1; 

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs,
  ExpandPanels, FileCtrl, Calendar, Spin, EditBtn, StdCtrls, ExtCtrls;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button10: TButton;
    Button11: TButton;
    Button12: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;
    Button8: TButton;
    Button9: TButton;
    Calendar1: TCalendar;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    CheckBox6: TCheckBox;
    CheckBox7: TCheckBox;
    CheckBox8: TCheckBox;
    CheckBox9: TCheckBox;
    ColorButton1: TColorButton;
    ColorButton2: TColorButton;
    ColorButton3: TColorButton;
    ColorButton4: TColorButton;
    ColorButton5: TColorButton;
    ColorButton6: TColorButton;
    ColorButton7: TColorButton;
    ColorButton8: TColorButton;
    ColorButton9: TColorButton;
    ExpandPanels1: TExpandPanels;
    ExpandPanels2: TExpandPanels;
    ExpandPanels3: TExpandPanels;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    ListBox1: TListBox;
    ListBox2: TListBox;
    ListBox3: TListBox;
    Memo1: TMemo;
    Memo2: TMemo;
    Memo3: TMemo;
    MyRollOut1: TMyRollOut;
    MyRollOutEinzel: TMyRollOut;
    MyRollOut2: TMyRollOut;
    MyRollOut3: TMyRollOut;
    MyRollOut4: TMyRollOut;
    MyRollOut5: TMyRollOut;
    MyRollOut6: TMyRollOut;
    MyRollOut7: TMyRollOut;
    MyRollOut8: TMyRollOut;
    MyRollOut9: TMyRollOut;
    Panel1: TPanel;
    RadioGroup1: TRadioGroup;
    RadioGroup2: TRadioGroup;
    ScrollBar1: TScrollBar;
    ScrollBar2: TScrollBar;
    ScrollBar3: TScrollBar;
    procedure Button11Click(Sender: TObject);
    procedure Button12Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure CheckBox2Change(Sender: TObject);
    procedure CheckBox3Change(Sender: TObject);
    procedure CheckBox6Change(Sender: TObject);
    procedure CheckBox7Change(Sender: TObject);
    procedure CheckBox8Change(Sender: TObject);
    procedure CheckBox9Change(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure RadioGroup1Click(Sender: TObject);
    procedure RadioGroup2Click(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end; 

var
  Form1: TForm1; 
  my:TMyRollOut;

implementation

{ TForm1 }

procedure TForm1.RadioGroup1Click(Sender: TObject);
begin
  case RadioGroup1.ItemIndex of
    0: MyRollOutEinzel.ButtonPosition:=akTop;
    1: MyRollOutEinzel.ButtonPosition:=akBottom;
    2: MyRollOutEinzel.ButtonPosition:=akLeft;
    3: MyRollOutEinzel.ButtonPosition:=akRight;
  end;
end;

procedure TForm1.CheckBox2Change(Sender: TObject);
begin
//  ExpandPanels1.UseClientHeight:=CheckBox2.Checked;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  MyRollOutEinzel.ExpandedHeight:=Random(500);
end;

procedure TForm1.Button11Click(Sender: TObject);
begin
  my:=TMyRollOut.Create(self);
  my.Parent:=self;
  my.SetBounds(16,630, 200,100);
end;

procedure TForm1.Button12Click(Sender: TObject);
begin
  my.Free;
end;

procedure TForm1.CheckBox3Change(Sender: TObject);
begin
//  ExpandPanels2.UseClientHeight:=CheckBox3.Checked;
end;

procedure TForm1.CheckBox6Change(Sender: TObject);
begin
//  ExpandPanels3.UseClientHeight:=CheckBox6.Checked;
end;

procedure TForm1.CheckBox7Change(Sender: TObject);
begin
  MyRollOut1.Animated:=CheckBox7.Checked;
  MyRollOut2.Animated:=CheckBox7.Checked;
  MyRollOut3.Animated:=CheckBox7.Checked;
end;

procedure TForm1.CheckBox8Change(Sender: TObject);
begin
  MyRollOut4.Animated:=CheckBox8.Checked;
  MyRollOut5.Animated:=CheckBox8.Checked;
  MyRollOut6.Animated:=CheckBox8.Checked;
end;

procedure TForm1.CheckBox9Change(Sender: TObject);
begin
  MyRollOut7.Animated:=CheckBox9.Checked;
  MyRollOut8.Animated:=CheckBox9.Checked;
  MyRollOut9.Animated:=CheckBox9.Checked;
end;



procedure TForm1.FormShow(Sender: TObject);
begin
  Randomize;
  ExpandPanels1.AddPanel(MyRollOut1);
  ExpandPanels1.AddPanel(MyRollOut2);
  ExpandPanels1.AddPanel(MyRollOut3);
  
  ExpandPanels2.AddPanel(MyRollOut4);
  ExpandPanels2.AddPanel(MyRollOut5);
  ExpandPanels2.AddPanel(MyRollOut6);

  ExpandPanels3.AddPanel(MyRollOut7);
  ExpandPanels3.AddPanel(MyRollOut8);
  ExpandPanels3.AddPanel(MyRollOut9);
end;



procedure TForm1.RadioGroup2Click(Sender: TObject);
begin
  case RadioGroup2.ItemIndex of
    0: MyRollOutEinzel.CollapseKind:=CKCollapseToButton;
    1: MyRollOutEinzel.CollapseKind:=CKCollapseToOppositeOfButton;
  end;
end;

initialization
  {$I unit1.lrs}

end.

