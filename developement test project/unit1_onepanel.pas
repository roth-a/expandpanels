unit unit1_onepanel;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  ExtCtrls, StdCtrls, Buttons, Spin, ExpandPanels, StrUtils;

type

  { TForm1 }

  TForm1 = class(TForm)
    cbNoBorders: TCheckBox;
    cbRounded: TCheckBox;
    cbFlat: TCheckBox;
    Edit1: TEdit;
    Edit2: TEdit;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    p1: TMyRollOut;
    RGlyph: TRadioGroup;
    RCapt: TRadioGroup;
    RColl:      TRadioGroup;
    RButt:      TRadioGroup;
    RStyle: TRadioGroup;
    SpeedButton1: TSpeedButton;
    edTabWidth: TSpinEdit;
    procedure cbFlatClick(Sender: TObject);
    procedure cbNoBordersClick(Sender: TObject);
    procedure cbRoundedClick(Sender: TObject);
    procedure Edit1Change(Sender: TObject);
    procedure edTabWidthChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure RBehaviourClick(Sender: TObject);
    procedure RGlyphClick(Sender: TObject);
    procedure RCaptClick(Sender: TObject);
    procedure RButtClick(Sender: TObject);
    procedure RCollClick(Sender: TObject);
    procedure RStyleClick(Sender: TObject);
    procedure RDirectionClick(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  Form1: TForm1;

implementation

{ TForm1 }


procedure TForm1.FormCreate(Sender: TObject);
begin
end;

procedure TForm1.Edit1Change(Sender: TObject);
begin
   p1.Button.Caption := Edit1.Text;
end;

procedure TForm1.cbRoundedClick(Sender: TObject);
begin
  p1.BevelRounded:=cbRounded.Checked;
end;

procedure TForm1.cbFlatClick(Sender: TObject);
begin
  p1.Button.Flat:=cbFlat.Checked;
end;

procedure TForm1.cbNoBordersClick(Sender: TObject);
begin
  p1.BevelOuter:=bvNone;
end;

procedure TForm1.edTabWidthChange(Sender: TObject);
begin
  p1.Button.TabWidth:=edTabWidth.Value;
end;


procedure TForm1.FormDestroy(Sender: TObject);
begin
  p1.Free;
end;

procedure TForm1.RBehaviourClick(Sender: TObject);
begin
end;

procedure TForm1.RGlyphClick(Sender: TObject);
begin
  p1.Button.GlyphLayout:=TGlyphLayout(RGlyph.ItemIndex);
end;

procedure TForm1.RCaptClick(Sender: TObject);
begin
     p1.Button.TextLayout:=TTextLayout(RCapt.ItemIndex);
end;


procedure TForm1.RButtClick(Sender: TObject);
begin
  p1.ButtonPosition := TAnchorKind(RButt.ItemIndex);
end;

procedure TForm1.RCollClick(Sender: TObject);
begin
  p1.CollapseKind := TAnchorKind(RColl.ItemIndex);
end;

procedure TForm1.RStyleClick(Sender: TObject);
begin
     p1.Button.Style:=TBoundButtonStyle(RStyle.ItemIndex);
end;

procedure TForm1.RDirectionClick(Sender: TObject);
begin
end;

procedure TForm1.SpeedButton1Click(Sender: TObject);
begin
     p1.Button.Caption := DupeString(Edit1.Caption, 10);
end;

initialization
  {$I unit1_onepanel.lrs}

end.