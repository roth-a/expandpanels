unit Unit1; 

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, ExpandPanels, UColoredBox, FileUtil, Forms, Controls,
  Graphics, Dialogs, Calendar, Spin, ExtCtrls, Buttons, StdCtrls;

type

  { TForm1 }

  TForm1 = class(TForm)
    BitBtn1: TBitBtn;
    Calendar10: TCalendar;
    Calendar11: TCalendar;
    Calendar12: TCalendar;
    Calendar13: TCalendar;
    Calendar14: TCalendar;
    Calendar15: TCalendar;
    Calendar2: TCalendar;
    Calendar3: TCalendar;
    Calendar6: TCalendar;
    Calendar7: TCalendar;
    Calendar8: TCalendar;
    Calendar9: TCalendar;
    CheckBox1: TCheckBox;
    ExpandPanels1: TExpandPanels;
    ExpandPanels2: TExpandPanels;
    ExpandPanels3: TExpandPanels;
    MyRollOut1: TMyRollOut;
    MyRollOut10: TMyRollOut;
    MyRollOut11: TMyRollOut;
    MyRollOut12: TMyRollOut;
    MyRollOut13: TMyRollOut;
    MyRollOut14: TMyRollOut;
    MyRollOut15: TMyRollOut;
    MyRollOut2: TMyRollOut;
    MyRollOut3: TMyRollOut;
    MyRollOut6: TMyRollOut;
    MyRollOut7: TMyRollOut;
    MyRollOut8: TMyRollOut;
    MyRollOut9: TMyRollOut;
    RadioButton1: TRadioButton;
    Shape1: TShape;
    SpinEdit1: TSpinEdit;
    procedure FormCreate(Sender: TObject);
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

  ExpandPanels1.AddPanel(MyRollOut6);
  ExpandPanels1.AddPanel(MyRollOut7);
  ExpandPanels1.AddPanel(MyRollOut8);


  ExpandPanels2.AddPanel(MyRollOut9);
  ExpandPanels2.AddPanel(MyRollOut10);
  ExpandPanels2.AddPanel(MyRollOut11);
end;

end.

