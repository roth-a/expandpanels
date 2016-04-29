unit effects_panel_main;

{$mode objfpc}{$H+}

//{$DEFINE DEBUG_PAINT_SIM_ANIM}  //Activate to Test the Animation Step by Step manually using _AnimateXXX

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, Buttons,
  ExtCtrls, StdCtrls, Spin, Calendar, ExpandPanels;

type

  { TForm1 }
  TanimationSpeedType = (astTotalTime, astSpeed);

  TForm1 = class(TForm)
    Calendar1: TCalendar;
    CheckBox1: TCheckBox;
    cbAnimated: TCheckBox;
    Edit1: TEdit;
    edMinDelta: TSpinEdit;
    edMinInterval: TSpinEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Memo1: TMemo;
    RAnimationKind: TRadioGroup;
    roll1: TMyRollOut;
    Panel1: TPanel;
    RButt: TRadioGroup;
    RColl: TRadioGroup;
    edTotalTime: TSpinEdit;
    SpeedButton1: TSpeedButton;
    edHeight: TSpinEdit;
    SpeedButton2: TSpeedButton;
    SpeedButton3: TSpeedButton;
    SpeedButton4: TSpeedButton;
    SpeedButton5: TSpeedButton;
    SpeedButton6: TSpeedButton;
    procedure cbAnimatedClick(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure RAnimationKindClick(Sender: TObject);
    procedure RButtClick(Sender: TObject);
    procedure RCollClick(Sender: TObject);
    procedure roll1CollapseExpand(Sender: TObject);
    procedure roll1PreCollapseExpand(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure SpeedButton3Click(Sender: TObject);
    procedure SpeedButton4Click(Sender: TObject);
    procedure SpeedButton5Click(Sender: TObject);
    procedure SpeedButton6Click(Sender: TObject);
  private
    { private declarations }
    tStart, tEnd :QWord;

  public
    { public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.CheckBox1Click(Sender: TObject);
begin
     roll1.panel.BevelRounded:=CheckBox1.Checked;
end;

procedure TForm1.cbAnimatedClick(Sender: TObject);
begin
     roll1.Animated:=cbAnimated.Checked;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
     Panel1.BevelInner:=roll1.BevelInner;
     Panel1.BevelOuter:=roll1.BevelOuter;
     Panel1.BevelWidth:=roll1.BevelWidth;
     edMinDelta.Value :=AnimationMinDelta;
     edMinInterval.Value:=AnimationMinInterval;
end;

procedure TForm1.RAnimationKindClick(Sender: TObject);
begin
  roll1.AnimationEffectKind:=TmrEffectKind(RAnimationKind.ItemIndex);
end;

procedure TForm1.RButtClick(Sender: TObject);
begin
     roll1.ButtonPosition := TAnchorKind(RButt.ItemIndex);
end;

procedure TForm1.RCollClick(Sender: TObject);
begin
     roll1.CollapseKind:=TAnchorKind(RColl.ItemIndex);
end;

procedure TForm1.roll1CollapseExpand(Sender: TObject);
begin
     tEnd :=GetTickCount64;
     Memo1.Lines.Add('Animation Steps: '+IntToStr(roll1.Animation_Step));
     Memo1.Lines.Add('Start: '+IntToStr(tStart)+' End: '+IntToStr(tEnd)+' = '+IntToStr(tEnd-tStart));
end;

procedure TForm1.roll1PreCollapseExpand(Sender: TObject);
begin
     AnimationMinInterval:=edMinInterval.Value;
     AnimationMinDelta:=edMinDelta.Value;
     roll1.AnimationTotalTime:=edTotalTime.Value;
     tStart :=GetTickCount64;
end;

procedure TForm1.SpeedButton1Click(Sender: TObject);
begin
     roll1.ExpandedSize :=edHeight.Value;
end;

procedure TForm1.SpeedButton4Click(Sender: TObject);
var
   _newPExpand : Integer;

begin
     _newPExpand :=(edHeight.Value-roll1.ButtonSize);
     _newPExpand :=((_newPExpand div edMinDelta.Value)-1) * edMinDelta.Value;
     roll1.ExpandedSize :=_newPExpand+roll1.ButtonSize;
     Label5.Caption:=IntToStr(roll1.ExpandedSize);
end;

procedure TForm1.SpeedButton5Click(Sender: TObject);
var
   _newPExpand : Integer;

begin
     _newPExpand :=(edHeight.Value-roll1.ButtonSize);
     _newPExpand :=((_newPExpand div edMinDelta.Value)+1) * edMinDelta.Value;
     roll1.ExpandedSize :=_newPExpand+roll1.ButtonSize;
     Label5.Caption:=IntToStr(roll1.ExpandedSize);
end;

procedure TForm1.SpeedButton6Click(Sender: TObject);
var
   rtButton :TButton;

begin
   rtButton :=TButton.Create(Self);
   rtButton.Caption:='New RunTime Button';
   rtButton.SetBounds(160, 40, 80, 32);
   rtButton.Parent:=roll1;
end;

procedure TForm1.SpeedButton2Click(Sender: TObject);
begin
     {$ifdef DEBUG_PAINT_SIM_ANIM}
     roll1.AnimateCollapse(roll1);
     {$endif}
end;


procedure TForm1.SpeedButton3Click(Sender: TObject);
begin
     {$ifdef DEBUG_PAINT_SIM_ANIM}
     roll1.AnimateExpand(roll1);
     {$endif}
end;


end.

