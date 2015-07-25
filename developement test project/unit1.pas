unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  ExtCtrls, Calendar, StdCtrls, Buttons, ExpandPanels, StrUtils;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1:    TButton;
    Calendar1:  TCalendar;
    Edit1: TEdit;
    GroupBox1: TGroupBox;
    ListBox1:   TListBox;
    RBehaviour: TRadioGroup;
    RButt1: TRadioGroup;
    RButt2: TRadioGroup;
    RDirection: TRadioGroup;
    RColl:      TRadioGroup;
    RButt:      TRadioGroup;
    SpeedButton1: TSpeedButton;
    procedure Edit1Change(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure RBehaviourClick(Sender: TObject);
    procedure RButt1Click(Sender: TObject);
    procedure RButt2Click(Sender: TObject);
    procedure RButtClick(Sender: TObject);
    procedure RCollClick(Sender: TObject);
    procedure RDirectionClick(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  Form1: TForm1;
  ex1:   TExpandPanels;
  p1, p2, p3: TMyRollOut;

implementation

{ TForm1 }


procedure TForm1.FormCreate(Sender: TObject);
begin
  ex1 := TExpandPanels.Create(self);

  p1 := TMyRollOut.Create(self);
  p2 := TMyRollOut.Create(self);
  p3 := TMyRollOut.Create(self);

  p1.Parent      := self;
  Calendar1.Parent := p1;
  Calendar1.Align := alClient;
  p2.Parent      := self;
  ListBox1.Parent := p2;
  ListBox1.Align := alClient;
  p3.Parent      := self;
  Button1.Parent := p3;

  ex1.AddPanel(p1);
  ex1.AddPanel(p2);
  ex1.AddPanel(p3);



  ex1.ButtonPosition := TAnchorKind(RButt.ItemIndex);
  ex1.CollapseKind   := TAnchorKind(RColl.ItemIndex);
  ex1.Behaviour      := TExpandPanelsBehaviour(RBehaviour.ItemIndex);

  RButt1Click(nil);
end;

procedure TForm1.Edit1Change(Sender: TObject);
begin
   p1.Button.Caption := Edit1.Text;
   p2.Button.Caption := Edit1.Text;
   p3.Button.Caption := Edit1.Text;
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
  ex1.Behaviour := TExpandPanelsBehaviour(RBehaviour.ItemIndex);
end;

procedure TForm1.RButt1Click(Sender: TObject);
begin
  p1.Button.GlyphLayout:=TGlyphLayout(RButt1.ItemIndex);
  p2.Button.GlyphLayout:=TGlyphLayout(RButt1.ItemIndex);
  p3.Button.GlyphLayout:=TGlyphLayout(RButt1.ItemIndex);
end;

procedure TForm1.RButt2Click(Sender: TObject);
begin
     p1.Button.TextLayout:=TTextLayout(RButt2.ItemIndex);
     p2.Button.TextLayout:=TTextLayout(RButt2.ItemIndex);
     p3.Button.TextLayout:=TTextLayout(RButt2.ItemIndex);
end;


procedure TForm1.RButtClick(Sender: TObject);
begin
  ex1.ButtonPosition := TAnchorKind(RButt.ItemIndex);
end;

procedure TForm1.RCollClick(Sender: TObject);
begin
  ex1.CollapseKind := TAnchorKind(RColl.ItemIndex);
end;

procedure TForm1.RDirectionClick(Sender: TObject);
begin
  ex1.ArrangeKind := TAnchorKind(RDirection.ItemIndex);
end;

procedure TForm1.SpeedButton1Click(Sender: TObject);
begin
     p1.Button.Caption := DupeString(Edit1.Caption, 10);
     p2.Button.Caption := DupeString(Edit1.Caption, 10);
     p3.Button.Caption := DupeString(Edit1.Caption, 10);
end;

initialization
  {$I unit1.lrs}

end.
