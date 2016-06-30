unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  ExtCtrls, Calendar, StdCtrls, Buttons, Spin, ExpandPanels, StrUtils;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1:    TButton;
    Calendar1:  TCalendar;
    cbBorders: TComboBox;
    cbFlat: TCheckBox;
    cbRounded: TCheckBox;
    edButtonSize: TSpinEdit;
    Edit1: TEdit;
    edTabWidth: TSpinEdit;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    ListBox1:   TListBox;
    RBehaviour: TRadioGroup;
    RGlyph: TRadioGroup;
    RCapt: TRadioGroup;
    RDirection: TRadioGroup;
    RColl:      TRadioGroup;
    RButt:      TRadioGroup;
    RGlyphKind: TRadioGroup;
    RStyle: TComboBox;
    SpeedButton1: TSpeedButton;
    procedure cbBordersChange(Sender: TObject);
    procedure cbFlatClick(Sender: TObject);
    procedure cbNoBordersClick(Sender: TObject);
    procedure cbRoundedClick(Sender: TObject);
    procedure edButtonSizeChange(Sender: TObject);
    procedure Edit1Change(Sender: TObject);
    procedure edTabWidthChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure RBehaviourClick(Sender: TObject);
    procedure RGlyphClick(Sender: TObject);
    procedure RCaptClick(Sender: TObject);
    procedure RButtClick(Sender: TObject);
    procedure RCollClick(Sender: TObject);
    procedure RGlyphKindClick(Sender: TObject);
    procedure RStyleChange(Sender: TObject);
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

  p1.Button.Caption:='Caption 1';
  p2.Button.Caption:='Caption 2';
  p3.Button.Caption:='Caption 3';

  ex1.AddPanel(p1);
  ex1.AddPanel(p2);
  ex1.AddPanel(p3);

  ex1.ButtonPosition := TAnchorKind(RButt.ItemIndex);
  ex1.ButtonGlyphLayout :=glRight;
  ex1.CollapseKind   := TAnchorKind(RColl.ItemIndex);
  ex1.Behaviour      := TExpandPanelsBehaviour(RBehaviour.ItemIndex);
end;

procedure TForm1.Edit1Change(Sender: TObject);
begin
   p1.Button.Caption := Edit1.Text+' 1';
   p2.Button.Caption := Edit1.Text+' 2';
   p3.Button.Caption := Edit1.Text+' 3';
end;

procedure TForm1.cbRoundedClick(Sender: TObject);
begin
  p1.BevelRounded:=cbRounded.Checked;
  p2.BevelRounded:=cbRounded.Checked;
  p3.BevelRounded:=cbRounded.Checked;
end;

procedure TForm1.edButtonSizeChange(Sender: TObject);
begin
  p1.ButtonSize:=edButtonSize.Value;
  p2.ButtonSize:=edButtonSize.Value;
  p3.ButtonSize:=edButtonSize.Value;
end;

procedure TForm1.cbFlatClick(Sender: TObject);
begin
  p1.Button.Flat:=cbFlat.Checked;
  p2.Button.Flat:=cbFlat.Checked;
  p3.Button.Flat:=cbFlat.Checked;
end;

procedure TForm1.cbBordersChange(Sender: TObject);
begin
    p1.BevelOuter:=TBevelcut(cbBorders.ItemIndex);
    p2.BevelOuter:=TBevelcut(cbBorders.ItemIndex);
    p3.BevelOuter:=TBevelcut(cbBorders.ItemIndex);
end;

procedure TForm1.cbNoBordersClick(Sender: TObject);
begin
  p1.BevelOuter:=bvNone;
  p2.BevelOuter:=bvNone;
  p3.BevelOuter:=bvNone;
end;

procedure TForm1.edTabWidthChange(Sender: TObject);
begin
  ex1.ButtonTabWidth:=edTabWidth.Value;
end;


procedure TForm1.FormDestroy(Sender: TObject);
begin
  ex1.Free;
  p1.Free;
  p2.Free;
  p3.Free;
end;

procedure TForm1.FormShow(Sender: TObject);
begin
  edButtonSize.Value:=p1.ButtonSize;
  edTabWidth.Value:=p1.Button.TabWidth;
end;

procedure TForm1.RBehaviourClick(Sender: TObject);
begin
  ex1.Behaviour := TExpandPanelsBehaviour(RBehaviour.ItemIndex);
end;

procedure TForm1.RGlyphClick(Sender: TObject);
begin
  ex1.ButtonGlyphLayout:=TGlyphLayout(RGlyph.ItemIndex);
end;

procedure TForm1.RCaptClick(Sender: TObject);
begin
  ex1.ButtonTextLayout:=TTextLayout(RCapt.ItemIndex);
end;

procedure TForm1.RButtClick(Sender: TObject);
begin
  ex1.ButtonPosition := TAnchorKind(RButt.ItemIndex);
end;

procedure TForm1.RCollClick(Sender: TObject);
begin
  ex1.CollapseKind := TAnchorKind(RColl.ItemIndex);
end;

procedure TForm1.RGlyphKindClick(Sender: TObject);
begin
  ex1.ButtonGlyphKind:=TGlyphKind(RGlyphKind.ItemIndex);
end;

procedure TForm1.RStyleChange(Sender: TObject);
begin
  ex1.ButtonStyle:=TBoundButtonStyle(RStyle.ItemIndex);
end;

procedure TForm1.RDirectionClick(Sender: TObject);
begin
  ex1.ArrangeKind := TAnchorKind(RDirection.ItemIndex);
end;

procedure TForm1.SpeedButton1Click(Sender: TObject);
begin
     p1.Button.Caption := DupeString(Edit1.Caption, 10)+' 1';
     p2.Button.Caption := DupeString(Edit1.Caption, 10)+' 2';
     p3.Button.Caption := DupeString(Edit1.Caption, 10)+' 3';
end;

initialization
  {$I unit1.lrs}

end.
