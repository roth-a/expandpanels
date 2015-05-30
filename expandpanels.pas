{==============================================================================
 Lizenshinweise:  Diese Komponente wurde geschrieben von Alexander Roth

    Dieses Programm ist freie Software. Sie können es unter den Bedingungen
    der GNU General Public License, wie von der Free Software Foundation
    veröffentlicht, weitergeben und/oder modifizieren, gemäß Version 2 der Lizenz.
==============================================================================}


{
For Instructions and Infos look up the Readme.txt
}


 //////////////////////////////
 //  ExpandPanels   Version 2.0.2
 //////////////////////////////




{
Todo  List

- simplyfy everything with verctor addition and scalar multiplication (orthogonal basis vectors... and so on)
      if horizonatal and vertical would be described by a unity vector, I could calculate if a certain operation should be performed
      and I could just multiply the basis vector  with an operation to get a delta movement (or none)
- the TExpandPanels lacks a arrange on bottom and right
     }

unit ExpandPanels;


{$mode objfpc}{$H+}

//{$DEFINE DebugInfo}// for debugging purposes


interface

uses
  Controls, Classes, ExtCtrls, Graphics, Math,
  LResources, StdCtrls, Dialogs, SysUtils;

type
  TExpandPanelsBehaviour = (EPHotMouse, EPMultipanel, EPSinglePanel);
  //  TBoundEvent=procedure(sender:TObject; ALeft, ATop, AWidth, AHeight: integer) of object;
  TAnimationEvent = procedure(Sender: TObject; deltaLeft, deltaTop, deltaWidth, deltaHeight: integer) of object;
  TNormalProcedure = procedure of object;


  { TBoundButton }

  TBoundButton = class(TButton)
  private
  public
    constructor Create(TheOwner: TComponent); override;
  end;




  { TMyRollOut }

  TMyRollOut = class(TPanel)
  private
    FEPManagesCollapsing: TNotifyEvent;
    FButton:      TBoundButton;
    FButtonSize:  integer;
    FCollapseKind: TAnchorKind;
    FCollapsed:   boolean;
    FAnimated:    boolean;
    FOnExpand:    TNotifyEvent;
    FOnPreExpand: TNotifyEvent;
    FOnAnimate:   TAnimationEvent;
    FOnCollapse:  TNotifyEvent;
    FOnPreCollapse: TNotifyEvent;
    FOnButtonClick: TNotifyEvent;
    FInternalOnAnimate: TAnimationEvent;
    FButtonPosition: TAnchorKind;
    FExpandedButtonColor: TColor;
    FCollapsedButtonColor: TColor;
    FExpandedSize: integer;
    FAnimationSpeed: real;
    StopCircleActions: boolean;
    StoredBevelOuter: TPanelBevel;
    FAnimating:   boolean;
    FVisibleTotal: boolean;

    TargetAnimationSize:     integer;
    EndProcedureOfAnimation: TNormalProcedure;

    Timer: TTimer;


    procedure setExpandedSize(Value: integer);
    procedure setButtonSize(Value: integer);

    procedure SetBounds(ALeft, ATop, AWidth, AHeight: integer); override;

    procedure setCollapsedButtonColor(Value: TColor);
    procedure setExpandedButtonColor(Value: TColor);
    procedure setButtonPosition(Value: TAnchorKind);
    procedure setCollapseKind(Value: TAnchorKind);
    procedure setAnimationSpeed(Value: real);
    procedure setCollapsed(Value: boolean);

    procedure PositionButton;


    function RelevantSize(comp: TControl; akind: TAnchorKind): integer;
    function RelevantOrthogonalSize(comp: TControl; akind: TAnchorKind): integer;
    function DeltaCoordinates(deltaMove, deltaSize: integer): TRect;  // the outpot (left,top right, bottom) has all the information: left and top encode the movement. rigth and bottom the size changes


    procedure Animate(aTargetSize: integer);

    procedure TimerAnimateSize(Sender: TObject);
    procedure EndTimerCollapse;
    procedure EndTimerExpand;
    procedure UpdateAll;

    procedure ButtonClick(Sender: TObject);
    procedure DoCollapse;
    procedure DoExpand;
    procedure AdjustClientRect(var ARect: TRect); override;

    property InternalOnAnimate: TAnimationEvent read FInternalOnAnimate write FInternalOnAnimate;
    property EPManagesCollapsing: TNotifyEvent read FEPManagesCollapsing write FEPManagesCollapsing;
  public
    property Animating: boolean read FAnimating;

    constructor Create(TheOwner: TComponent); override;
    destructor Destroy; override;
  published
    property ExpandedButtonColor: TColor read FExpandedButtonColor write setExpandedButtonColor;
    property CollapsedButtonColor: TColor read FCollapsedButtonColor write setCollapsedButtonColor;
    property CollapseKind: TAnchorKind read FCollapseKind write setCollapseKind;   //To where should it collapse?
    property ExpandedSize: integer read FExpandedSize write setExpandedSize;
    property ButtonPosition: TAnchorKind read FButtonPosition write setButtonPosition;
    property ButtonSize: integer read FButtonSize write setButtonSize;

    property Button: TBoundButton read FButton;

    property AnimationSpeed: real read FAnimationSpeed write setAnimationSpeed;
    property Animated: boolean read FAnimated write FAnimated default True;
    property Collapsed: boolean read FCollapsed write setCollapsed default False;
    property OnAnimate: TAnimationEvent read FOnAnimate write FOnAnimate;
    property OnButtonClick: TNotifyEvent read FOnButtonClick write FOnButtonClick;
    property OnPreExpand: TNotifyEvent read FOnPreExpand write FOnPreExpand;
    property OnExpand: TNotifyEvent read FOnExpand write FOnExpand;
    property OnCollapse: TNotifyEvent read FOnCollapse write FOnCollapse;
    property OnPreCollapse: TNotifyEvent read FOnPreCollapse write FOnPreCollapse;
  end;




  {==============================================================================
   Class:   TExpandPanels
   Description:
  ==============================================================================}

  { TExpandPanels }

  TExpandPanels = class(TComponent)
  private
    { Private-Deklarationen }
    PanelArray: TList;

    // Properties
    FArrangeKind: TAnchorKind;
    FButtonPosition, FCollapseKind: TAnchorKind;
    FOrthogonalAbove: integer;
    FAbove:     integer;
    FOrthogonalSize: integer;
    FBehaviour: TExpandPanelsBehaviour;
    FOnArrangePanels: TNotifyEvent;
    FFixedSize: integer;
    FUseFixedSize: boolean;
    FAutoCollapseIfTooHigh: boolean;

    FUseClientSize: boolean;

    function RelevantAbove(comp: TControl): integer;
    function RelevantOrthogonalAbove(comp: TControl): integer;
    function RelevantSize(comp: TControl): integer;
    function RelevantOrthogonalSize(comp: TControl): integer;
    procedure WriteRelevantAbove(comp: TMyRollOut; above: integer);
    procedure WriteRelevantSize(comp: TMyRollOut; size: integer);
    procedure WriteRelevantOrthogonalSize(comp: TMyRollOut; size: integer);
    procedure WriteRelevantOrthogonalAbove(comp: TMyRollOut; size: integer);

    procedure setArrangeKind(Value: TAnchorKind);
    procedure setButtonPosition(Value: TAnchorKind);
    procedure setCollapseKind(Value: TAnchorKind);
    procedure setUseClientSize(Value: boolean);
    procedure setUseFixedSize(Value: boolean);
    procedure setAutoCollapseIfTooHigh(Value: boolean);
    procedure setFixedSize(Value: integer);
    procedure setOrthogonalAbove(Value: integer);
    procedure setAbove(Value: integer);
    procedure setOrthogonalSize(Value: integer);
    procedure setBehaviour(Value: TExpandPanelsBehaviour);

    procedure MakeCorrectButtonClickPointers;

    procedure RollOutOnAnimate(Sender: TObject; deltaLeft, deltaTop, deltaWidth, deltaHeight: integer);

    procedure RollOutClick(Sender: TObject);
    procedure HotTrackSetActivePanel(Value: integer);
    procedure DelLastPanel;

    procedure RollOut1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: integer);
  protected
    { Protected-Deklarationen }
  public
    { Public-Deklarationen }

    property OrthogonalAbove: integer read FOrthogonalAbove write setOrthogonalAbove;
    property Above: integer read FAbove write setAbove;
    property OrthogonalSize: integer read FOrthogonalSize write setOrthogonalSize;

    function IdxOfPanel(aname: string): integer; overload;

    procedure CollapseIfTooHigh;
    //    procedure SetCorrectSize;
    procedure AddPanel(rollout: TMyRollOut);
    procedure InsertPanel(idx: integer; rollout: TMyRollOut);
    function DeltePanel(aname: string): boolean; overload;
    function DeltePanel(idx: integer): boolean; overload;
    procedure DelteLastPanel;
    procedure ArrangePanels;
    function Count: integer;
    function Panel(idx: integer): TMyRollOut;

    property CollapseKind: TAnchorKind read FCollapseKind write setCollapseKind;
    property ButtonPosition: TAnchorKind read FButtonPosition write setButtonPosition;

    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    { Published-Deklarationen }

    //    property FixedHeight:integer read FFixedHeight write setFixedSize;
    //    property UseFixedHeight:boolean read FUseFixedHeight write setUseFixedSize;
    //    property UseClientHeight:boolean read FUseClientHeight write setUseClientSize;
    //    property AutoCollapseIfTooHigh:boolean read FAutoCollapseIfTooHigh write setAutoCollapseIfTooHigh;
    property ArrangeKind: TAnchorKind read FArrangeKind write setArrangeKind;
    property OnArrangePanels: TNotifyEvent read FOnArrangePanels write FOnArrangePanels;
    property Behaviour: TExpandPanelsBehaviour read FBehaviour write setBehaviour;
  end;

procedure Register;

implementation




procedure korrigiere(var w: real; min, max: real);
var
  temp: real;
begin
  if max < min then
    begin
    temp := min;
    min  := max;
    max  := temp;
    end;

  if w < min then
    w := min;
  if w > max then
    w := max;
end;




{ TBoundButton }


constructor TBoundButton.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);

  SetSubComponent(True);
  //  ControlStyle := ControlStyle + [csNoFocus, csNoDesignSelectable];
end;




{/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
TExpandPanels  TExpandPanels  TExpandPanels  TExpandPanels  TExpandPanels  TExpandPanels  TExpandPanels  TExpandPanels  TExpandPanels  TExpandPanels  TExpandPanels
TExpandPanels  TExpandPanels  TExpandPanels  TExpandPanels  TExpandPanels  TExpandPanels  TExpandPanels  TExpandPanels  TExpandPanels  TExpandPanels  TExpandPanels
TExpandPanels  TExpandPanels  TExpandPanels  TExpandPanels  TExpandPanels  TExpandPanels  TExpandPanels  TExpandPanels  TExpandPanels  TExpandPanels  TExpandPanels
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////}




{==============================================================================
  Procedure:    create
  Belongs to:   TExpandPanels
  Result:       None
  Parameters:
                  AOwner : TComponent  =

  Description:
==============================================================================}
constructor TExpandPanels.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  PanelArray := TList.Create;

  FCollapseKind := akTop;
  FButtonPosition := akTop;
  FArrangeKind := akTop;
  FUseFixedSize := False;
  FUseClientSize := False;
  FFixedSize := 400;
  FAutoCollapseIfTooHigh := False;
  FAbove := 10;
  FOrthogonalAbove := 10;
  FOrthogonalSize := 200;
end;


{==============================================================================
  Procedure:    destroy
  Belongs to:   TExpandPanels
  Result:       None
  Parameters:

  Description:
==============================================================================}
destructor TExpandPanels.Destroy;
var
  i: integer;
begin
  for I := PanelArray.Count - 1 downto 0 do
    PanelArray.Delete(i);

  PanelArray.Free;
  PanelArray := nil;

  inherited Destroy;
end;




procedure TExpandPanels.AddPanel(rollout: TMyRollOut);
begin
  InsertPanel(PanelArray.Count, rollout);
end;



procedure TExpandPanels.InsertPanel(idx: integer; rollout: TMyRollOut);
begin
  if Count <= 0 then
    begin
    FAbove := RelevantAbove(rollout);
    FOrthogonalAbove := RelevantOrthogonalAbove(rollout);
    FOrthogonalSize := RelevantOrthogonalSize(rollout);
    end
  else
    begin
    WriteRelevantAbove(rollout, FAbove);
    WriteRelevantOrthogonalAbove(rollout, FOrthogonalAbove);
    WriteRelevantOrthogonalSize(rollout, FOrthogonalSize);
    end;

  with rollout do
    begin
    Tag := Idx;
    FButton.Tag := Idx;

    FButton.OnMouseMove := @RollOut1MouseMove;
    InternalOnAnimate   := @RollOutOnAnimate;
    end;


  PanelArray.Insert(idx, rollout);

  if FBehaviour <> EPMultipanel then
    HotTrackSetActivePanel(0);  //damit das erste ausgeklappt ist

  ArrangePanels;
  MakeCorrectButtonClickPointers;
end;




function TExpandPanels.DeltePanel(aname: string): boolean;
var
  i: integer;
begin
  Result := False;
  for i := 0 to PanelArray.Count - 1 do
    if TMyRollOut(PanelArray[i]).Name = aname then
      begin
      PanelArray.Delete(i);
      Result := True;
      break;
      end;
  ArrangePanels;
end;


function TExpandPanels.DeltePanel(idx: integer): boolean;
begin
  Result := False;
  if (idx >= 0) and (idx <= PanelArray.Count - 1) then
    begin
    PanelArray.Delete(idx);
    Result := True;
    end;
  ArrangePanels;
end;

procedure TExpandPanels.DelteLastPanel;
begin
  if (PanelArray.Count >= 1) then
    PanelArray.Delete(PanelArray.Count - 1);
  ArrangePanels;
end;




procedure TExpandPanels.DelLastPanel;
begin
  PanelArray.Delete(PanelArray.Count - 1);
end;


function TExpandPanels.RelevantAbove(comp: TControl): integer;
begin
  case FArrangeKind of
    akLeft: Result := comp.Left;
    akTop: Result  := comp.Top;
    end;
end;

function TExpandPanels.RelevantOrthogonalAbove(comp: TControl): integer;
begin
  case FArrangeKind of
    akTop: Result  := comp.Left;
    akLeft: Result := comp.Top;
    end;
end;

function TExpandPanels.RelevantSize(comp: TControl): integer;
begin
  case FArrangeKind of
    akLeft: Result := comp.Width;
    akTop: Result  := comp.Height;
    end;
end;

function TExpandPanels.RelevantOrthogonalSize(comp: TControl): integer;
begin
  case FArrangeKind of
    akLeft: Result := comp.Height;
    akTop: Result  := comp.Width;
    end;
end;

procedure TExpandPanels.WriteRelevantAbove(comp: TMyRollOut; above: integer);
begin
  case FArrangeKind of
    akLeft: comp.Left := above;
    akTop: comp.Top   := above;
    end;
end;

procedure TExpandPanels.WriteRelevantSize(comp: TMyRollOut; size: integer);
begin
  case FArrangeKind of
    akLeft: comp.Width := size;
    akTop: comp.Height := size;
    end;
end;

procedure TExpandPanels.WriteRelevantOrthogonalSize(comp: TMyRollOut; size: integer);
begin
  case FArrangeKind of
    akLeft: comp.Height := size;
    akTop: comp.Width   := size;
    end;
end;

procedure TExpandPanels.WriteRelevantOrthogonalAbove(comp: TMyRollOut; size: integer);
begin
  case FArrangeKind of
    akLeft: comp.Top := size;
    akTop: comp.Left := size;
    end;
end;


procedure TExpandPanels.setArrangeKind(Value: TAnchorKind);
begin
  case Value of  //that is mean, but I haven't implemented the bottom and right yet....
    akRight: Value  := akLeft;
    akBottom: Value := akTop;
    end;

  if FArrangeKind = Value then
    exit;
  FArrangeKind := Value;

  ArrangePanels;
end;

procedure TExpandPanels.setButtonPosition(Value: TAnchorKind);
var
  i: integer;
begin
  if FButtonPosition = Value then
    exit;
  FButtonPosition := Value;

  for i := 0 to PanelArray.Count - 1 do
    Panel(i).ButtonPosition := Value;
end;

procedure TExpandPanels.setCollapseKind(Value: TAnchorKind);
var
  i: integer;
begin
  if FCollapseKind = Value then
    exit;
  FCollapseKind := Value;

  for i := 0 to PanelArray.Count - 1 do
    Panel(i).CollapseKind := Value;
end;

procedure TExpandPanels.setUseClientSize(Value: boolean);
begin
  FUseClientSize := Value;

  ArrangePanels;
end;

procedure TExpandPanels.setUseFixedSize(Value: boolean);
begin
  if FUseFixedSize = Value then
    exit;
  FUseFixedSize := Value;

  ArrangePanels;
end;

procedure TExpandPanels.setAutoCollapseIfTooHigh(Value: boolean);
begin
  if FAutoCollapseIfTooHigh = Value then
    exit;
  FAutoCollapseIfTooHigh := Value;

  if FAutoCollapseIfTooHigh then
    CollapseIfTooHigh;
end;


procedure TExpandPanels.setFixedSize(Value: integer);
var
  r: real;
begin
  if FFixedSize = Value then
    exit;

  r := Value;
  korrigiere(r, 20, 10000);
  FFixedSize := round(r);

  ArrangePanels;
end;



procedure TExpandPanels.setOrthogonalAbove(Value: integer);
begin
  if FOrthogonalAbove = Value then
    exit;
  FOrthogonalAbove := Value;

  ArrangePanels;
end;


procedure TExpandPanels.setAbove(Value: integer);
begin
  if FAbove = Value then
    exit;
  FAbove := Value;

  ArrangePanels;
end;


procedure TExpandPanels.setOrthogonalSize(Value: integer);
var
  i: integer;
begin
  FOrthogonalSize := Value;

  for I := 0 to PanelArray.Count - 1 do
    WriteRelevantOrthogonalSize(TMyRollOut(PanelArray[i]), FOrthogonalSize);
end;




procedure TExpandPanels.setBehaviour(Value: TExpandPanelsBehaviour);
var
  i: integer;
  isAlreadyOneExpand: boolean;
begin
  isAlreadyOneExpand := False;
  FBehaviour := Value;

  MakeCorrectButtonClickPointers;

  // look if more then one is open
  for I := 0 to PanelArray.Count - 1 do
    with TMyRollOut(PanelArray[i]) do
      if (Behaviour <> EPMultipanel) and not Collapsed then   //leave only the first open, if it is not MultiPanel
        if not isAlreadyOneExpand then
          isAlreadyOneExpand := True
        else
          Collapsed := True;
end;

procedure TExpandPanels.MakeCorrectButtonClickPointers;
var
  i: integer;
begin
  // set correct pointers
  for I := 0 to PanelArray.Count - 1 do
    with TMyRollOut(PanelArray[i]) do
      if FBehaviour <> EPMultipanel then
        EPManagesCollapsing := @RollOutClick
      else
        EPManagesCollapsing := nil;
end;



procedure TExpandPanels.CollapseIfTooHigh;
var
  i, h, max:    integer;
  tempanimated: boolean;
begin
  if Count <= 1 then
    exit;


  h   := RelevantAbove(Panel(0));
  max := RelevantSize(Panel(0).Parent);

  for i := 0 to Count - 1 do
    if h + RelevantSize(Panel(i)) > max then
      with Panel(i) do
        begin
        tempanimated := Animated;
        Animated     := False;
        Collapsed    := True;
        Animated     := tempanimated;

        h := h + TMyRollOut(Panel(i)).ButtonSize;
        end
    else
      h := h + RelevantSize(Panel(i));
end;



procedure TExpandPanels.RollOutOnAnimate(Sender: TObject; deltaLeft, deltaTop, deltaWidth, deltaHeight: integer);
var
  idx, i, size: integer;
begin
  idx := PanelArray.IndexOf(Sender);

  for i := idx + 1 to PanelArray.Count - 1 do
    begin
    size := RelevantAbove(TMyRollOut(PanelArray[i]));
    case FArrangeKind of
      akTop: size  := size + deltaTop + deltaHeight;
      akLeft: size := size + deltaLeft + deltaWidth;
      end;

    WriteRelevantAbove(TMyRollOut(PanelArray[i]), size);

    end;
end;




 //procedure TExpandPanels.SetCorrectSize;
 //const plus=1;   //extra Anstand
 //var
 //    i, exSize,
 //    countexpanded,
 //    SumSize, closedSize:Integer;
 //begin
 //  if PanelArray.Count<=0 then
 //    exit;

 //  SumSize:=FFixedSize;
 //  if FUseClientSize then
 //    SumSize:=TMyRollOut(PanelArray[0]).Parent.Height;


 //  countexpanded:=0;
 //  closedSize:=0;
 //  for I := 0 to PanelArray.count-1 do
 //    with TMyRollOut(PanelArray[i]) do
 //      begin
//      if not Collapsed and not Animating         //error producer!!!   animating does not neccessairily mean that it is expanding
 //       or Collapsed and Animating then
 //        inc(countexpanded)
 //      else
 //        closedSize:=closedSize+Height;
 //      end;

//  exSize:=SumSize- FTop- closedSize;

 //  case Behaviour of
 //    EPMultipanel:
 //      if countexpanded>0 then
 //        exSize:=trunc(exSize/countexpanded)
 //      else
 //        exSize:=400;
 //  end;

 //  for I := 0 to PanelArray.count-1 do
 //    with TMyRollOut(PanelArray[i]) do
 //      begin
 //      if not FUseFixedSize and not FUseClientSize then
 //        ExpandedSize:=200
 //      else
 //        ExpandedSize:=exSize;
 //      end;
 //end;



{==============================================================================
  Procedure:    ArrangePanels
  Belongs to:   TExpandPanels
  Result:       None
  Parameters:

  Description:
==============================================================================}
procedure TExpandPanels.ArrangePanels;
const
  plus = 1;   //extra Anstand
var
  i, t: integer;
begin
  if Count <= 0 then
    exit;


  //left setzen!!!
  //  SetCorrectSize;

  t := FAbove + plus;

  for I := 0 to PanelArray.Count - 1 do
    begin
    if not TMyRollOut(PanelArray[i]).Visible then
      continue;

    WriteRelevantAbove(TMyRollOut(PanelArray[i]), t);
    WriteRelevantOrthogonalAbove(TMyRollOut(PanelArray[i]), OrthogonalAbove);
    t := t + plus + self.RelevantSize(TMyRollOut(PanelArray[i]));
    end;

  if FAutoCollapseIfTooHigh then
    CollapseIfTooHigh;

  if Assigned(FOnArrangePanels) then
    FOnArrangePanels(Self);
end;



function TExpandPanels.Count: integer;
begin
  Result := PanelArray.Count;
end;

function TExpandPanels.Panel(idx: integer): TMyRollOut;
begin
  if idx < Count then
    Result := TMyRollOut(PanelArray.Items[idx])
  else
    Result := nil;
end;




{==============================================================================
  Procedure:    RollOutClick
  Belongs to:   TExpandPanels
  Result:       None
  Parameters:
                  Sender : TObject  =

  Description:
==============================================================================}
procedure TExpandPanels.RollOutClick(Sender: TObject);
begin
  if (Behaviour <> EPMultipanel) then
    HotTrackSetActivePanel(TBoundButton(Sender).Tag);
end;




procedure TExpandPanels.HotTrackSetActivePanel(Value: integer);
var
  i: integer;
begin
  for I := PanelArray.Count - 1 downto 0 do
    TMyRollOut(PanelArray[i]).Collapsed := Value <> i;
end;




procedure TExpandPanels.RollOut1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: integer);
begin
  if (Behaviour = EPHotMouse) and (TMyRollOut(PanelArray[TBoundButton(Sender).Tag]).Collapsed) then
    HotTrackSetActivePanel(TBoundButton(Sender).Tag);
end;


function TExpandPanels.IdxOfPanel(aname: string): integer;
var
  i: integer;
begin
  Result := -1;      // is not here
  for i := 0 to PanelArray.Count - 1 do
    if TMyRollOut(PanelArray[i]).Name = aname then
      begin
      Result := i;
      break;
      end;
end;




{ TMyRollOut }


procedure TMyRollOut.setCollapsed(Value: boolean);
begin
{$IFDEF DebugInfo}
  writeln('TMyRollOut.setCollapsed');
  writeln(BoolToStr(Collapsed, True));
{$ENDIF}

  if FCollapsed = Value then
    exit;
  FCollapsed := Value;


  if FCollapsed then
    DoCollapse
  else
    DoExpand;
end;

function TMyRollOut.RelevantSize(comp: TControl; akind: TAnchorKind): integer;
begin
  case akind of
    akTop, akBottom: Result := comp.Height;
    akLeft, akRight: Result := comp.Width;
    end;
end;

function TMyRollOut.RelevantOrthogonalSize(comp: TControl; akind: TAnchorKind): integer;
begin
  case akind of
    akTop, akBottom: Result := comp.Width;
    akLeft, akRight: Result := comp.Height;
    end;
end;

function TMyRollOut.DeltaCoordinates(deltaMove, deltaSize: integer): TRect;
begin
  Result := Rect(0, 0, 0, 0);

  case FCollapseKind of
    akTop: Result    := Rect(0, 0, 0, deltaSize);
    akLeft: Result   := Rect(0, 0, deltaSize, 0);
    akBottom: Result := Rect(0, deltaMove, 0, deltaSize);
    akRight: Result  := Rect(deltaMove, 0, deltaSize, 0);
    end;
end;



procedure TMyRollOut.TimerAnimateSize(Sender: TObject);
var
  step:  real;
  originalsize, size: integer;
  deltaMove, deltaSize: integer;
  delta: TRect;
  vorzeichen: integer;
begin
  deltaMove := 0;
  deltaSize := 0;
  StopCircleActions := False;
  FAnimating := True;
  step := FAnimationSpeed;


  Size := RelevantSize(Self, FCollapseKind);

  vorzeichen   := Sign(TargetAnimationSize - RelevantSize(self, FCollapseKind));  // muss ich delta addieren oder muss ich delta abziehen
  originalsize := ExpandedSize;


  //One huge step if not animated
  if not FAnimated or not (ComponentState * [csLoading, csDesigning] = []) then
    step := abs(Size - TargetAnimationSize);

  //small steps if animated
  if FAnimated and (ComponentState * [csLoading, csDesigning] = []) then
    begin
    step := step * originalsize / 200;
    if step < 3 then
      step := 3;
    end;


  //now actually do something

  if Abs(Size - TargetAnimationSize) > 0 then
    begin
    if Abs(Size - TargetAnimationSize) < abs(step) then  // if there is just a little bit left to go, set delta so it can go directly to the end size
      deltaSize := TargetAnimationSize - Size
    else
      deltaSize := vorzeichen * round(step);

    if (CollapseKind = akBottom) or (CollapseKind = akRight) then
      deltaMove := -deltaSize;


    delta := DeltaCoordinates(deltaMove, deltaSize);

    SetBounds(Left + delta.Left, Top + delta.Top, Width + delta.Right, Height + delta.Bottom);

    if assigned(FInternalOnAnimate) then
      FInternalOnAnimate(self, delta.Left, delta.Top, delta.Right, delta.Bottom);
    if assigned(FOnAnimate) then
      FOnAnimate(self, delta.Left, delta.Top, delta.Right, delta.Bottom);
    end;


  if Abs(Size - TargetAnimationSize) = 0 then        //it's finished  ( executes it NEXT time the timer activates!)
    begin
    Timer.Enabled := False;

    FAnimating := False;

    StopCircleActions := False;

    if assigned(EndProcedureOfAnimation) then
      EndProcedureOfAnimation;
    end;
end;



procedure TMyRollOut.EndTimerCollapse;
begin
  StoredBevelOuter := BevelOuter;
  BevelOuter := bvNone;

  if assigned(OnCollapse) then
    OnCollapse(self);


  UpdateAll;
end;

procedure TMyRollOut.EndTimerExpand;
begin
  BevelOuter := StoredBevelOuter;

  if assigned(OnExpand) then
    OnExpand(self);

  UpdateAll;
end;



procedure TMyRollOut.UpdateAll;
begin
  Update;
  //  FButton.Update;
end;




procedure TMyRollOut.setExpandedSize(Value: integer);
begin
  {$IFDEF DebugInfo}
  writeln('TMyRollOut.setExpandedSize');
  writeln(IntToStr(Value));
  {$ENDIF}

  if (FExpandedSize = Value) then
    exit;

  FExpandedSize := Value;

  if not Collapsed then
    Animate(FExpandedSize);
end;


procedure TMyRollOut.setButtonSize(Value: integer);
begin
  if FButtonSize = Value then
    exit;

  FButtonSize := Value;

  PositionButton;
end;




procedure TMyRollOut.SetBounds(ALeft, ATop, AWidth, AHeight: integer);
begin
  inherited SetBounds(ALeft, ATop, AWidth, AHeight);

  if not Collapsed and not Animating and (ComponentState * [csLoading] = []) then
    FExpandedSize := RelevantSize(self, FCollapseKind);
end;



procedure TMyRollOut.setCollapsedButtonColor(Value: TColor);
begin
  FCollapsedButtonColor := Value;

  if Collapsed then
    FButton.Color := FCollapsedButtonColor;
end;

procedure TMyRollOut.setExpandedButtonColor(Value: TColor);
begin
  FExpandedButtonColor := Value;

  if not Collapsed then
    FButton.Color := FExpandedButtonColor;
end;

procedure TMyRollOut.setButtonPosition(Value: TAnchorKind);
var
  wasanimated, wascollpased: boolean;
begin
  if FButtonPosition = Value then
    exit;

  wasanimated  := Animated;
  wascollpased := Collapsed;
  Animated     := False;
  if Collapsed then
    Collapsed := False;

  FButtonPosition := Value;
  PositionButton;

  Collapsed := wascollpased;
  Animated  := wasanimated;
end;


procedure TMyRollOut.setCollapseKind(Value: TAnchorKind);
var
  wasanimated, wascollpased: boolean;
begin
  if FCollapseKind = Value then
    exit;

  wasanimated  := Animated;
  wascollpased := Collapsed;
  Animated     := False;

  if Collapsed then
    Collapsed := False;

  FCollapseKind := Value;


  //switsch sizes

  case FCollapseKind of
    akLeft, akRight: FExpandedSize := Width;
    akTop, akBottom: FExpandedSize := Height;
    end;


  Collapsed := wascollpased;


  Animated := wasanimated;
end;

procedure TMyRollOut.setAnimationSpeed(Value: real);
begin
  korrigiere(Value, 3, 1000);
  FAnimationSpeed := Value;
end;




procedure TMyRollOut.PositionButton;

  function ButtonRect: TRect;
  begin
    case FButtonPosition of
      akBottom, akTop: Result := Rect(0, 0, RelevantOrthogonalSize(self, FButtonPosition), FButtonSize);
      akLeft, akRight: Result := Rect(0, 0, FButtonSize, RelevantOrthogonalSize(self, FButtonPosition));
      end;

    //this must come after the thing above!!!
    // this moves the button to the bottom, or the right
    case FButtonPosition of
      akBottom: Result.Top := Result.Top + RelevantSize(self, FButtonPosition) - FButtonSize;
      akRight: Result.Left := Result.Left + RelevantSize(self, FButtonPosition) - FButtonSize;
      end;
  end;

var
  new: TRect;
begin
  if StopCircleActions or not Assigned(FButton) then
    exit;
  StopCircleActions := True;


  new := ButtonRect;
  FButton.SetBounds(new.Left, new.Top, new.Right, new.Bottom);


  //set anchors
  case FButtonPosition of
    akBottom: FButton.Anchors := [akTop, akLeft, akBottom, akRight] - [akTop];
    akLeft: FButton.Anchors   := [akTop, akLeft, akBottom, akRight] - [akRight];
    akTop: FButton.Anchors    := [akTop, akLeft, akBottom, akRight] - [akBottom];
    akRight: FButton.Anchors  := [akTop, akLeft, akBottom, akRight] - [akLeft];
    end;


  StopCircleActions := False;
end;




procedure TMyRollOut.ButtonClick(Sender: TObject);
begin
  if Assigned(FEPManagesCollapsing) then
    FEPManagesCollapsing(self)
  else
    Collapsed := not Collapsed;

  if Assigned(OnButtonClick) then
    OnButtonClick(self);
end;




procedure TMyRollOut.Animate(aTargetSize: integer);
var
  storAnimated: boolean;
begin
  //  FinishLastAnimationFast
  storAnimated := Animated;
  Animated     := False;
  TimerAnimateSize(self);
  Animated := storAnimated;


  // Now do animation
  TargetAnimationSize := aTargetSize;



  if (ComponentState * [csLoading, csDesigning] = []) and Animated then
    begin
    Timer.Enabled := True;
    Timer.OnTimer := @TimerAnimateSize;
    EndProcedureOfAnimation := nil;
    end
  else
    begin
    TimerAnimateSize(self);
    TimerAnimateSize(self);
    end;
end;




procedure TMyRollOut.DoCollapse;
begin
  if assigned(OnPreCollapse) then
    OnPreCollapse(self);

  FButton.Color := FCollapsedButtonColor;
  FButton.Brush.Color := FCollapsedButtonColor;

  EndProcedureOfAnimation := @EndTimerCollapse;


  Animate(FButtonSize);

{$IFDEF DebugInfo}
  writeln('TMyRollOut.DoCollapse');
  writeln('FButtonSize ' + IntToStr(FButtonSize));
{$ENDIF}

end;



procedure TMyRollOut.DoExpand;
begin
  if assigned(OnPreExpand) then
    OnPreExpand(self);

  //  FButton.ControlStyle := FButton.ControlStyle + [csNoFocus, csNoDesignSelectable];
  //  FButton.Parent:=self;

  FButton.Color := FExpandedButtonColor;
  FButton.Brush.Color := FExpandedButtonColor;


  EndProcedureOfAnimation := @EndTimerExpand;

  Animate(FExpandedSize);

{$IFDEF DebugInfo}
  writeln('TMyRollOut.DoExpand');
  writeln('FExpandedSize ' + IntToStr(FExpandedSize));
{$ENDIF}

end;


procedure TMyRollOut.AdjustClientRect(var ARect: TRect);
begin
  inherited AdjustClientRect(ARect);

  if Assigned(FButton) then
    case ButtonPosition of
      akTop:
        ARect.Top    := ARect.Top + fButton.Height;
      akBottom:
        ARect.Bottom := ARect.Bottom - fButton.Height;
      akLeft:
        ARect.Left   := ARect.Left + fButton.Width;
      akRight:
        ARect.Right  := ARect.Right - fButton.Width;
      end;
end;



constructor TMyRollOut.Create(TheOwner: TComponent);
begin
  StopCircleActions := True;

  inherited;

  FButtonSize := 27;
  FAnimated := True;
  FCollapseKind := akTop;
  FVisibleTotal := True;
  FCollapsed := False;
  FButtonPosition := akTop;
  FCollapsedButtonColor := clSkyBlue;
  FExpandedButtonColor := RGBToColor(23, 136, 248);
  FExpandedSize := 200;
  Height  := FExpandedSize;
  Width   := 200;
  FAnimationSpeed := 20;
  Caption := '';


  Timer      := TTimer.Create(self);
  Timer.Enabled := False;
  Timer.Name := 'Animationtimer';
  Timer.Interval := 20;

  FButton := TBoundButton.Create(self);
  with FButton do
    begin
    Parent  := self;
    Name    := 'Button';
    Caption := 'Caption';
    Color   := ExpandedButtonColor;
    ControlStyle := ControlStyle + [csNoFocus, csNoDesignSelectable];
    FButton.OnClick := @self.ButtonClick;
    end;

  StopCircleActions := False;
  PositionButton;
end;



destructor TMyRollOut.Destroy;
begin
  timer.Enabled := False;

  Timer.Free;

  if (ComponentState * [csLoading, csDesigning] = []) then
    FButton.Free;  // bringt einen Fehler in der Designtime wenn ich das hier mache

  //  FButton.Free;  // bringt einen Fehler in der Designtime wenn ich das hier mache

  inherited Destroy;
end;



procedure Register;
begin
  RegisterComponents('Misc', [TMyRollOut]);
  RegisterComponents('Misc', [TExpandPanels]);
end;

initialization
              {$I pexpandpanels.lrs}
end.
