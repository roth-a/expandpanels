{==============================================================================
 Lizenshinweise:  Diese Komponente wurde geschrieben von Alexander Roth

    Dieses Programm ist freie Software. Sie können es unter den Bedingungen
    der GNU General Public License, wie von der Free Software Foundation
    veröffentlicht, weitergeben und/oder modifizieren, gemäß Version 2 der Lizenz.
==============================================================================}


{
Please send comments and ideas directly to:
        admin@alexanderroth.spacequadrat.de

You can access this unit over the subversion repository:
        http://forge.lazarusforum.de/projects/show/expandpanels
You can check out the repository (in linux) with the command:
        svn co http://svn.lazarusforum.de/svn/expandpanels expandpanels
}
//////////////////////////////
//  ExpandPanels   Version 1.994
//////////////////////////////

    {
Todo  List


- Every animation sould be equal and a standarised way to execute it
- A new animation should kill an old one (so at least the last animation is done correctly)
- simplyfy everything with verctor addition and scalar multiplication (orthogonal basis vectors... and so on)
      if horizonatal and vertical would be described by a unity vector, I could calculate if a certain operation should be performed
      and I could just multiply the basis vector  with an operation to get a delta movement (or none)
- the TExpandPanels lacks a arrange on bottom
     }

unit ExpandPanels;


{$mode objfpc}{$H+}

interface
uses
  controls,Classes, ExtCtrls, Graphics,math,ComCtrls,
  LResources, StdCtrls, dialogs, SysUtils;

type
  TExpandPanelsBehaviour=(EPHotMouse,EPMultipanel,EPSinglePanel);
//  TBoundEvent=procedure(sender:TObject; ALeft, ATop, AWidth, AHeight: integer) of object;
  TAnimationEvent=procedure(sender:TObject; deltaLeft, deltaTop, deltaWidth, deltaHeight: integer) of object;
  TNormalProcedure=procedure of object;


  { TBoundButton }

  TBoundButton = class(TButton)
  private
    procedure Click; override;
  public
    constructor Create(TheOwner: TComponent); override;
  end;




  { TMyRollOut }

  TMyRollOut = class(TPanel)
  private
    FButton:TBoundButton;
    FButtonSize: integer;
    FCollapseKind:TAnchorKind;
    FCollapsed:boolean;
    FAnimated:boolean;
    FOnExpand: TNotifyEvent;
    FOnPreExpand: TNotifyEvent;
    FOnAnimate: TAnimationEvent;
    FOnCollapse: TNotifyEvent;
    FOnPreCollapse: TNotifyEvent;
    FOnButtonClick: TNotifyEvent;
    FInternalOnAnimate: TAnimationEvent;
    FButtonPosition:TAnchorKind;
    FExpandedButtonColor:TColor;
    FCollapsedButtonColor:TColor;
    FExpandedSize:integer;
    FAnimationSpeed:real;
    StopCircleActions:boolean;
    StoredBevelOuter:TPanelBevel;
    FAnimating:boolean;
    FVisibleTotal:boolean;

    TargetAnimationSize:integer;
    EndProcedureOfAnimation:TNormalProcedure;

    Timer:TTimer;


    procedure WriteFExpandedSize(value:integer);

    procedure WriteFButtonSize(value:integer);

    procedure SetBounds(ALeft, ATop, AWidth, AHeight: integer); override;

    procedure WriteFCollapsedButtonColor(value:TColor);
    procedure WriteFExpandedButtonColor(value:TColor);
    procedure WriteFButtonPosition(value:TAnchorKind);
    procedure WriteFCollapseKind(value:TAnchorKind);
    procedure writeFAnimationSpeed(value:real);

    procedure PositionButton;

    procedure WriteFCollapsed(Collapsed:boolean);
    
    function RelevantSize(comp:TControl; akind:TAnchorKind):integer;
    function RelevantOrthogonalSize(comp:TControl; akind:TAnchorKind):integer;
    function DeltaCoordinates(deltaMove, deltaSize:integer):TRect;  // the outpot (left,top right, bottom) has all the information: left and top encode the movement. rigth and bottom the size changes

    procedure TimerAnimateSize(Sender: TObject);
    procedure EndTimerCollapse;
    procedure EndTimerExpand;
    procedure UpdateAll;

    procedure ButtonClick(Sender: TObject);
    procedure DoCollapse;
    procedure DoExpand;
    procedure AdjustClientRect(var ARect: TRect); override;
  
    property InternalOnAnimate: TAnimationEvent read FInternalOnAnimate write FInternalOnAnimate;
public
    property Animating:boolean read FAnimating;

    constructor Create(TheOwner: TComponent); override;
    destructor destroy; override;
  published
    property ExpandedButtonColor:TColor read FExpandedButtonColor write WriteFExpandedButtonColor;
    property CollapsedButtonColor:TColor read FCollapsedButtonColor write WriteFCollapsedButtonColor;
    property CollapseKind:TAnchorKind read FCollapseKind write WriteFCollapseKind;   //To where should it collapse?
    property ExpandedSize:integer read FExpandedSize write WriteFExpandedSize;
    property ButtonPosition:TAnchorKind read FButtonPosition write WriteFButtonPosition;
    property ButtonSize:integer read FButtonSize write WriteFButtonSize;

    property Button:TBoundButton read FButton;

    property AnimationSpeed:real read FAnimationSpeed write writeFAnimationSpeed;
    property Animated:boolean read FAnimated write FAnimated default true;
    property Collapsed:boolean read FCollapsed write WriteFCollapsed default false;
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
    PanelArray:TList;
    
    // Properties
    FArrangeKind: TAnchorKind;
    FButtonPosition,
    FCollapseKind:TAnchorKind;
    FOrthogonalAbove:integer;
    FAbove:integer;
    FOrthogonalSize:integer;
    FBehaviour:TExpandPanelsBehaviour;
    FOnArrangePanels: TNotifyEvent;
    FFixedSize:integer;
    FUseFixedSize:boolean;
    FAutoCollapseIfTooHigh:boolean;

    FUseClientSize:boolean;

    function RelevantAbove(comp:TControl):integer;
    function RelevantSize(comp:TControl):integer;
    function RelevantOrthogonalSize(comp:TControl):integer;
    procedure WriteRelevantAbove(comp:TMyRollOut; above:integer);
    procedure WriteRelevantSize(comp:TMyRollOut; size:integer);
    procedure WriteRelevantOrthogonalSize(comp:TMyRollOut; size:integer);
    procedure WriteRelevantOrthogonalAbove(comp:TMyRollOut; size:integer);

    procedure setArrangeKind(value: TAnchorKind);
    procedure setButtonPosition(value:TAnchorKind);
    procedure setCollapseKind(value:TAnchorKind);
    procedure setUseClientSize(value:boolean);
    procedure setUseFixedSize(value:boolean);
    procedure setAutoCollapseIfTooHigh(value:boolean);
    procedure setFixedSize(value:integer);
    procedure setOrthogonalAbove(value:Integer);
    procedure setAbove(value:Integer);
    procedure setOrthogonalSize(value:Integer);
    procedure setBehaviour(value:TExpandPanelsBehaviour);
    
    procedure RollOutOnAnimate(sender:TObject; deltaLeft, deltaTop, deltaWidth, deltaHeight: integer);

    procedure RollOutClick(Sender: TObject);
    procedure HotTrackSetActivePanel(value:integer);
    procedure DelLastPanel;

    procedure RollOut1MouseMove(Sender: TObject; Shift: TShiftState; X,  Y: Integer);
  protected
    { Protected-Deklarationen }
  public
    { Public-Deklarationen }

    property  OrthogonalAbove:integer read FOrthogonalAbove write setOrthogonalAbove;
    property  Above:integer read FAbove write setAbove;
    property  OrthogonalSize:integer read FOrthogonalSize write setOrthogonalSize;

    function IdxOfPanel(aname:string):integer; overload;

    procedure CollapseIfTooHigh;
//    procedure SetCorrectSize;
    procedure AddPanel(rollout:TMyRollOut);
    procedure InsertPanel(idx:integer; rollout:TMyRollOut);
    function DeltePanel(aname:string):boolean; overload;
    function DeltePanel(idx:integer):boolean;  overload;
    procedure DelteLastPanel;
    procedure ArrangePanels;
    function Count:integer;
    function Panel(idx:integer):TMyRollOut;

    constructor create(AOwner: TComponent); override;
    destructor destroy;  override;
  published
    { Published-Deklarationen }

//    property FixedHeight:integer read FFixedHeight write WriteFFixedSize;
//    property UseFixedHeight:boolean read FUseFixedHeight write WriteFUseFixedSize;
//    property UseClientHeight:boolean read FUseClientHeight write WriteFUseClientSize;
//    property AutoCollapseIfTooHigh:boolean read FAutoCollapseIfTooHigh write WriteFAutoCollapseIfTooHigh;
    property ArrangeKind:TAnchorKind read FArrangeKind write setArrangeKind;
    property CollapseKind:TAnchorKind read FCollapseKind write setCollapseKind;
    property ButtonPosition:TAnchorKind read FButtonPosition write setButtonPosition;
    property OnArrangePanels: TNotifyEvent read FOnArrangePanels write FOnArrangePanels;
    property  Behaviour:TExpandPanelsBehaviour read FBehaviour write setBehaviour;
  end;

procedure Register;

implementation






procedure korrigiere(var w:real;  min,max:real);
var temp:real;
begin
  if max<min then
    begin
    temp:=min;
    min:=max;
    max:=temp;
    end;

  if w<min then w:=min;
  if w>max then w:=max;
end;






{ TBoundButton }


procedure TBoundButton.Click;
begin
  inherited Click;
  
  if Owner is TMyRollOut then
    TMyRollOut(Owner).ButtonClick(self);
end;

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
constructor TExpandPanels.create(AOwner: TComponent);
begin
  inherited create(AOwner);

  PanelArray:=TList.create;

  FArrangeKind:=akTop;
  FUseFixedSize:=false;
  FUseClientSize:=false;
  FFixedSize:=400;
  FAutoCollapseIfTooHigh:=false;
  FAbove:=10;
  FOrthogonalAbove:=10;
  FOrthogonalSize:=200;
end;


{==============================================================================
  Procedure:    destroy
  Belongs to:   TExpandPanels
  Result:       None
  Parameters:

  Description:
==============================================================================}
destructor TExpandPanels.destroy;
var i:Integer;
begin
  for I := PanelArray.Count - 1 downto 0 do
    PanelArray.delete(i);

  PanelArray.Free;
  PanelArray:=nil;

  inherited destroy;
end;




procedure TExpandPanels.AddPanel(rollout:TMyRollOut);
begin
  InsertPanel(PanelArray.Count, rollout);
end;



procedure TExpandPanels.InsertPanel(idx: integer; rollout: TMyRollOut);
begin
  WriteRelevantAbove(rollout, FAbove);
  WriteRelevantOrthogonalAbove(rollout, FOrthogonalAbove);
  WriteRelevantOrthogonalSize(rollout, FOrthogonalSize);
  with rollout do
    begin
    CollapseKind:=FCollapseKind;
    ButtonPosition:=akTop;
    Tag:=Idx;
    FButton.Tag:=Idx;


    FButton.OnClick:=@RollOutClick;
    FButton.OnMouseMove:=@RollOut1MouseMove;
    InternalOnAnimate:=@RollOutOnAnimate;
    end;


  PanelArray.Insert(idx, rollout);

  if  FBehaviour<>EPMultipanel then
    HotTrackSetActivePanel(0);  //damit das erste ausgeklappt ist

  ArrangePanels;
end;




function TExpandPanels.DeltePanel(aname: string): boolean;
var i:integer;
begin
  Result:=false;
  for i := 0 to PanelArray.Count-1 do
    if TMyRollOut(PanelArray[i]).Name=aname then
      begin
      PanelArray.Delete(i);
      Result:=true;
      break;
      end;
  ArrangePanels;
end;


function TExpandPanels.DeltePanel(idx: integer): boolean;
begin
  if (idx>=0)and(idx<=PanelArray.Count-1) then
    PanelArray.Delete(idx);
  ArrangePanels;
end;

procedure TExpandPanels.DelteLastPanel;
begin
  if (PanelArray.Count>=1) then
    PanelArray.Delete(PanelArray.Count-1);
  ArrangePanels;
end;





procedure TExpandPanels.DelLastPanel;
begin
  PanelArray.delete(PanelArray.count-1);
end;


function TExpandPanels.RelevantAbove(comp: TControl): integer;
begin
  case FArrangeKind of
    akLeft: Result:=comp.Left;
    akTop: Result:=comp.Top;
  end;
end;

function TExpandPanels.RelevantSize(comp: TControl): integer;
begin
  case FArrangeKind of
    akLeft: Result:=comp.Width;
    akTop: Result:=comp.Height;
  end;
end;

function TExpandPanels.RelevantOrthogonalSize(comp: TControl): integer;
begin
  case FArrangeKind of
    akLeft: Result:=comp.Height;
    akTop: Result:=comp.Width;
  end;
end;

procedure TExpandPanels.WriteRelevantAbove(comp: TMyRollOut; above: integer);
begin
  case FArrangeKind of
    akLeft: comp.Left:=above;
    akTop: comp.Top:=above;
  end;
end;

procedure TExpandPanels.WriteRelevantSize(comp: TMyRollOut; size: integer);
begin
  case FArrangeKind of
    akLeft: comp.Width:=size;
    akTop: comp.Height:=size;
  end;
end;

procedure TExpandPanels.WriteRelevantOrthogonalSize(comp: TMyRollOut;
  size: integer);
begin
  case FArrangeKind of
    akLeft: comp.Height:=size;
    akTop: comp.Width:=size;
  end;
end;

procedure TExpandPanels.WriteRelevantOrthogonalAbove(comp: TMyRollOut;
  size: integer);
begin
  case FArrangeKind of
    akLeft: comp.Top:=size;
    akTop: comp.Left:=size;
  end;
end;


procedure TExpandPanels.setArrangeKind(value: TAnchorKind);
begin
  case value of  //that is mean, but I haven't implemented the bottom and right yet....
    akRight: value:=akLeft;
    akBottom: value:=akTop;
  end;

  if FArrangeKind=value then  exit;
  FArrangeKind:=value;

  ArrangePanels;
end;

procedure TExpandPanels.setButtonPosition(value: TAnchorKind);
var i :integer;
begin
  if FButtonPosition=value then  exit;
  FButtonPosition:=value;

  for i := 0 to PanelArray.Count-1 do
    Panel(i).ButtonPosition:=value;
end;

procedure TExpandPanels.setCollapseKind(value: TAnchorKind);
var i :integer;
begin
  if FCollapseKind=value then  exit;
  FCollapseKind:=value;

  for i := 0 to PanelArray.Count-1 do
    Panel(i).CollapseKind:=value;
end;

procedure TExpandPanels.setUseClientSize(value: boolean);
begin
  FUseClientSize:=value;
  
  ArrangePanels;
end;

procedure TExpandPanels.setUseFixedSize(value: boolean);
begin
  if FUseFixedSize=value then    exit;
  FUseFixedSize:=value;
  
  ArrangePanels;
end;

procedure TExpandPanels.setAutoCollapseIfTooHigh(value: boolean);
begin
  if FAutoCollapseIfTooHigh=value then   exit;
  FAutoCollapseIfTooHigh:=value;
  
  if FAutoCollapseIfTooHigh then
    CollapseIfTooHigh;
end;


procedure TExpandPanels.setFixedSize(value: integer);
var r:real;
begin
  if FFixedSize=value then   exit;

  r:=value;
  korrigiere(r, 20, 10000);
  FFixedSize:=round(r);
  
  ArrangePanels;
end;



procedure TExpandPanels.setOrthogonalAbove(value:Integer);
var i:Integer;
begin
  if FOrthogonalAbove=value then exit;
  FOrthogonalAbove:=value;

  ArrangePanels;
end;


procedure TExpandPanels.setAbove(value:Integer);
begin
  if FAbove=value then exit;
  FAbove:=value;

  ArrangePanels;
end;


procedure TExpandPanels.setOrthogonalSize(value:Integer);
var i:Integer;
begin
  FOrthogonalSize:=value;

  for I := 0 to PanelArray.Count - 1 do
    WriteRelevantOrthogonalSize(TMyRollOut(PanelArray[i]), FOrthogonalSize);
end;





procedure TExpandPanels.setBehaviour(value:TExpandPanelsBehaviour);
var i:Integer;
    isAlreadyOneExpand:boolean;
begin
  isAlreadyOneExpand:=false;
  FBehaviour:=value;

  for I := 0 to PanelArray.Count - 1 do
    with TMyRollOut(PanelArray[i]) do
      if (Behaviour<>EPMultipanel)and  not Collapsed then   //leave only the first open, if it is not MultiPanel
        if not isAlreadyOneExpand then
          isAlreadyOneExpand:=true
        else
          Collapsed:=true;
end;



procedure TExpandPanels.CollapseIfTooHigh;
var i,h,max:integer;
    tempanimated:boolean;
begin
  if Count<=1 then
    exit;


  h:=RelevantAbove(Panel(0));
  max:=RelevantSize(Panel(0).Parent);

  for i := 0 to Count-1 do
    if h+ RelevantSize(Panel(i))> max then
      with Panel(i) do
        begin
        tempanimated:=Animated;
        Animated:=false;
        Collapsed:=true;
        Animated:=tempanimated;

        h:=h+ TMyRollOut(Panel(i)).ButtonSize;
        end
    else
      h:=h+ RelevantSize(Panel(i));
end;



procedure TExpandPanels.RollOutOnAnimate(sender: TObject; deltaLeft, deltaTop, deltaWidth, deltaHeight: integer);
var idx,
    i,size:integer;
begin
  idx:=PanelArray.IndexOf(sender);

  for i:= idx+1 to PanelArray.Count-1 do
    begin
    size:=RelevantAbove(TMyRollOut(PanelArray[i]));
    case FArrangeKind of
      akTop:     size := size+ deltaTop + deltaHeight;
      akLeft:   size := size+ deltaLeft + deltaWidth;
    end;

    WriteRelevantAbove(TMyRollOut(PanelArray[i]),size );

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
//
//  SumSize:=FFixedSize;
//  if FUseClientSize then
//    SumSize:=TMyRollOut(PanelArray[0]).Parent.Height;
//
//
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
//
//  exSize:=SumSize- FTop- closedSize;
//
//  case Behaviour of
//    EPMultipanel:
//      if countexpanded>0 then
//        exSize:=trunc(exSize/countexpanded)
//      else
//        exSize:=400;
//  end;
//
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
const plus=1;   //extra Anstand
var i,
    t:Integer;
begin
  if Count<=0 then
    exit;


  //left setzen!!!
//  SetCorrectSize;

  t:=FAbove+ plus;

  for I := 0 to PanelArray.count-1 do
    begin
    if not TMyRollOut(PanelArray[i]).Visible then
      continue;

    WriteRelevantAbove( TMyRollOut(PanelArray[i]), t );
    WriteRelevantOrthogonalAbove(TMyRollOut(PanelArray[i]), OrthogonalAbove);
    t:=t + plus + self.RelevantSize(TMyRollOut(PanelArray[i]));
    end;

  if FAutoCollapseIfTooHigh then
    CollapseIfTooHigh;
      
  if Assigned(FOnArrangePanels) then
    FOnArrangePanels(Self);
end;



function TExpandPanels.Count: integer;
begin
  Result:=PanelArray.Count;
end;

function TExpandPanels.Panel(idx: integer): TMyRollOut;
begin
  if idx<Count then
    Result:=TMyRollOut(PanelArray.Items[idx])
  else
    Result:=nil;
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
  if  (Behaviour<>EPMultipanel) then
    HotTrackSetActivePanel(TBoundButton(Sender).Tag);

end;





{==============================================================================
  Procedure:    HotTrackSetActivePanel
  Belongs to:   TExpandPanels
  Result:       None
  Parameters:
                  value : integer  =

  Description:
==============================================================================}
procedure TExpandPanels.HotTrackSetActivePanel(value:integer);
var i:Integer;
begin
  for I := PanelArray.count-1 downto 0 do
    TMyRollOut(PanelArray[i]).Collapsed:=not (value=i);
end;







{==============================================================================
  Procedure:    RollOut1MouseMove
  Belongs to:   TExpandPanels
  Result:       None
  Parameters:
                  Sender : TObject  =
                  Shift : TShiftState  =
                  X : Integer  =
                  Y : Integer  =

  Description:
==============================================================================}
procedure TExpandPanels.RollOut1MouseMove(Sender: TObject; Shift: TShiftState; X,  Y: Integer);
begin
  if  (Behaviour= EPHotMouse)and( TMyRollOut(PanelArray[TBoundButton(Sender).Tag]).Collapsed) then
    HotTrackSetActivePanel(TBoundButton(Sender).Tag  );
end;


function TExpandPanels.IdxOfPanel(aname: string): integer;
var i:integer;
begin
  Result:=-1;      // is not here
  for i := 0 to PanelArray.Count-1 do
    if TMyRollOut(PanelArray[i]).Name=aname then
      begin
      Result:=i;
      break;
      end;
end;





{ TMyRollOut }


procedure TMyRollOut.WriteFCollapsed(Collapsed: boolean);
begin
  if FCollapsed=Collapsed   and  not Animating then
    exit;

  if not Collapsed then    // Collapsed erst der Zustand ist der gesetzt werden soll, nicht die gelesene Property
    DoExpand
  else
    DoCollapse;
end;

function TMyRollOut.RelevantSize(comp: TControl; akind: TAnchorKind): integer;
begin
  case akind of
    akTop, akBottom: Result:=comp.Height;
    akLeft, akRight: Result:=comp.Width;
  end;
end;

function TMyRollOut.RelevantOrthogonalSize(comp: TControl; akind: TAnchorKind
  ): integer;
begin
  case akind of
    akTop, akBottom: Result:=comp.Width;
    akLeft, akRight: Result:=comp.Height;
  end;
end;

function TMyRollOut.DeltaCoordinates(deltaMove, deltaSize: integer): TRect;
begin
  Result:=Rect(0,0,0,0);

  case FCollapseKind of
    akTop: Result:=Rect(0,0,0,deltaSize);
    akLeft: Result:=Rect(0,0,deltaSize,0);
    akBottom: Result:=Rect(0,deltaMove,0,deltaSize);
    akRight: Result:=Rect(deltaMove,0,deltaSize,0);
  end;
end;




procedure TMyRollOut.TimerAnimateSize(Sender: TObject);
var step:real;
    originalsize, size:integer;
    deltaMove, deltaSize: integer;
    delta:TRect;
    vorzeichen:integer;
begin
  deltaMove:=0;
  deltaSize:=0;
  StopCircleActions:=false;
  FAnimating:=true;
  step:=FAnimationSpeed;


  Size:=RelevantSize(Self,FCollapseKind);

  vorzeichen:=Sign(TargetAnimationSize-RelevantSize(self, FCollapseKind));  // muss ich delta addieren oder muss ich delta abziehen
  originalsize:=ExpandedSize;


  //One huge step if not animated
  if not FAnimated or  not (ComponentState * [csLoading, csDesigning] = []) then
    step:=abs( Size-TargetAnimationSize);

  //small steps if animated
  if FAnimated and (ComponentState * [csLoading, csDesigning] = []) then
    begin
    step:=step* originalsize/200;
    if step<3 then
      step:=3;
    end;


  if Abs(Size-TargetAnimationSize)>0 then
    begin
    if Abs(Size-TargetAnimationSize)<abs(step) then  // if there is just a little bit left to go, set delta so it can go directly to the end size
      deltaSize:=TargetAnimationSize-Size
    else
      deltaSize:=vorzeichen*round(step);

    if  (CollapseKind=akBottom) or (CollapseKind=akRight) then
      deltaMove:=-deltaSize;


    delta:=DeltaCoordinates(deltaMove, deltaSize);

    SetBounds(Left+delta.Left, Top+delta.Top, Width+delta.Right, Height+delta.Bottom);

    if assigned(FInternalOnAnimate) then
      FInternalOnAnimate(self, delta.Left, delta.Top, delta.Right, delta.Bottom);
    if assigned(FOnAnimate) then
      FOnAnimate(self, delta.Left, delta.Top, delta.Right, delta.Bottom);
    end;


  if Abs(Size-TargetAnimationSize)=0 then        //it's finished  ( executes it NEXT time the timer activates!)
    begin
    Timer.Enabled:=false;

    FAnimating:=false;

    StopCircleActions:=false;

    if assigned(EndProcedureOfAnimation) then
      EndProcedureOfAnimation;
    end;
end;



procedure TMyRollOut.EndTimerCollapse;
var i:integer;
begin
  FCollapsed:=true;

  StoredBevelOuter:=BevelOuter;
  BevelOuter:=bvNone;

  if assigned(OnCollapse) then
    OnCollapse(self);

  //for i:=0 to ControlCount-1 do
    //if Controls[i] <> FButton then
      //Controls[i].Visible:=false;

  UpdateAll;
end;

procedure TMyRollOut.EndTimerExpand;
begin
  FCollapsed:=false;

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





procedure TMyRollOut.WriteFExpandedSize(value: integer);
begin
  if FExpandedSize=ExpandedSize then exit;

  FExpandedSize:=value;
end;


procedure TMyRollOut.WriteFButtonSize(value: integer);
begin
  if FButtonSize=value then exit;

  FButtonSize:=value;

  PositionButton;
end;




//procedure TMyRollOut.ButtonOnSetBounds(sender: TObject; ALeft, ATop, AWidth,AHeight: integer);
//var    newLeft, newTop, newWidth, newHeight: integer;
//begin
////  if StopCircleActions then
    //exit;

  //StopCircleActions:=true;
  //newLeft:=Left;
  //newTop:=Top;
  //newWidth:=Width;
  //newHeight:=Height;


  //case ButtonPosition of
    //akTop, akBottom:
      //begin
      //newLeft  := ALeft;
      //newWidth := AWidth;
      //end;
    //akLeft, akRight:
      //begin
      //newTop    := ATop;
      //newHeight := AHeight;
      //end;
  //end;


  //case ButtonPosition of
    //akTop:
      //if Collapsed and (CollapseKind=CKCollapseToOppositeOfButton) then
        //newTop:=ATop+AHeight-ExpandedHeight
      //else
        //newTop:=ATop+AHeight;
    //akBottom:
      //if Collapsed and (CollapseKind=CKCollapseToOppositeOfButton) then
        //newTop:=ATop
      //else
        //newTop:=ATop-ExpandedHeight;
    //akLeft:
      //if Collapsed and (CollapseKind=CKCollapseToOppositeOfButton) then
        //newLeft:=ALeft+AWidth-ExpandedWidth
      //else
        //newLeft:=ALeft+AWidth;
    //akRight:
      //if Collapsed and (CollapseKind=CKCollapseToOppositeOfButton) then
        //newLeft:=ALeft
      //else
        //newLeft:=ALeft-ExpandedWidth;
  //end;

  //SetBounds(newLeft, newTop, newWidth, newHeight);

  //StopCircleActions:=false;
//end;



procedure TMyRollOut.SetBounds(ALeft, ATop, AWidth, AHeight: integer);
begin
  inherited SetBounds(ALeft, ATop, AWidth, AHeight);
  
  if not Collapsed and not Animating then
    FExpandedSize:=RelevantSize(self,FCollapseKind);
end;



procedure TMyRollOut.WriteFCollapsedButtonColor(value: TColor);
begin
  FCollapsedButtonColor:=value;
  
  if Collapsed then
    FButton.Color:=FCollapsedButtonColor;
end;

procedure TMyRollOut.WriteFExpandedButtonColor(value: TColor);
begin
  FExpandedButtonColor:=value;

  if not Collapsed then
    FButton.Color:=FExpandedButtonColor;
end;

procedure TMyRollOut.WriteFButtonPosition(value: TAnchorKind);
var wasanimated, wascollpased:boolean;
begin
  if FButtonPosition=value then    exit;

  wasanimated:=Animated;
  wascollpased:=Collapsed;
  Animated:=false;
  if Collapsed then
    Collapsed:=false;

  FButtonPosition:=value;
  PositionButton;

  Collapsed := wascollpased;
  Animated := wasanimated;
end;


procedure TMyRollOut.WriteFCollapseKind(value: TAnchorKind);
var wasanimated, wascollpased:boolean;
begin
  if FCollapseKind=value then
    exit;

  wasanimated:=Animated;
  wascollpased:=Collapsed;
  Animated:=false;

  if Collapsed then
    Collapsed:=false;

  FCollapseKind:=value;

  Collapsed := wascollpased;


  Animated := wasanimated;
end;

procedure TMyRollOut.writeFAnimationSpeed(value: real);
begin
  korrigiere(value, 3, 1000);
  FAnimationSpeed:=value;
end;




procedure TMyRollOut.PositionButton;

  function ButtonRect:TRect;
  begin
    case FButtonPosition of
      akBottom,akTop: Result:= Rect(0,0,RelevantOrthogonalSize(self,FButtonPosition), FButtonSize);
      akLeft,akRight: Result:= Rect(0,0,FButtonSize, RelevantOrthogonalSize(self,FButtonPosition));
    end;

    //this must come after the thing above!!!
    // this moves the button to the bottom, or the right
    case FButtonPosition of
      akBottom: Result.Top:=Result.Top + RelevantSize(self, FButtonPosition)-FButtonSize;
      akRight: Result.Left:=Result.Left+ RelevantSize(self, FButtonPosition)-FButtonSize;
    end;
  end;

var    new: TRect;
begin
  if StopCircleActions or not Assigned(FButton) then
    exit;
  StopCircleActions:=true;


  new:=ButtonRect;
  FButton.SetBounds(new.Left, new.Top, new.Right, new.Bottom);


  //set anchors
  case FButtonPosition of
    akBottom:   FButton.Anchors:=[akTop, akLeft, akBottom, akRight]-[akTop];
    akLeft:     FButton.Anchors:=[akTop, akLeft, akBottom, akRight]-[akRight];
    akTop:      FButton.Anchors:=[akTop, akLeft, akBottom, akRight]-[akBottom];
    akRight:    FButton.Anchors:=[akTop, akLeft, akBottom, akRight]-[akLeft];
  end;


  StopCircleActions:=false;
end;











procedure TMyRollOut.ButtonClick(Sender: TObject);
begin
  if Collapsed then
    DoExpand
  else
    DoCollapse;

  if OnButtonClick<>nil then
    OnButtonClick(self);
end;





procedure TMyRollOut.DoCollapse;
var collapsesize:integer;
begin
  collapsesize:=FButtonSize;  // RelevantSize(FButton, FCollapseKind)
  TargetAnimationSize:=collapsesize;


  if assigned(OnPreCollapse) then
    OnPreCollapse(self);

  FButton.Color:=FCollapsedButtonColor;
  FButton.Brush.Color:=FCollapsedButtonColor;


  EndProcedureOfAnimation:=@EndTimerCollapse;
  if (ComponentState * [csLoading, csDesigning] = []) and Animated then
    begin
    Timer.OnTimer:=@TimerAnimateSize;
    Timer.Enabled:=true;
    end
  else
    begin
    TimerAnimateSize(self);
    TimerAnimateSize(self);
    end;
end;



procedure TMyRollOut.DoExpand;
begin
  TargetAnimationSize:=FExpandedSize;

  if assigned(OnPreExpand) then
    OnPreExpand(self);

//  FButton.ControlStyle := FButton.ControlStyle + [csNoFocus, csNoDesignSelectable];
//  FButton.Parent:=self;

  FButton.Color:=FExpandedButtonColor;
  FButton.Brush.Color:=FExpandedButtonColor;


  EndProcedureOfAnimation:=@EndTimerExpand;

  if (ComponentState * [csLoading, csDesigning] = []) and Animated then
    begin
    Timer.OnTimer:=@TimerAnimateSize;
    Timer.Enabled:=true;
    end
  else
    begin
    TimerAnimateSize(self);
    TimerAnimateSize(self);
    end;
end;


procedure TMyRollOut.AdjustClientRect(var ARect: TRect);
begin
  inherited AdjustClientRect(ARect);

  if Assigned(FButton) then
    case ButtonPosition of
      akTop:
        ARect.Top:=ARect.Top+fButton.Height;
      akBottom:
        ARect.Bottom:=ARect.Bottom-fButton.Height;
      akLeft:
        ARect.Left:=ARect.Left+fButton.Width;
      akRight:
        ARect.Right:=ARect.Right-fButton.Width;
    end;
end;



constructor TMyRollOut.Create(TheOwner: TComponent);
begin
  StopCircleActions:=true;

  inherited;

  FButtonSize:=27;
  FAnimated:=true;
  FCollapseKind:=akTop;
  FVisibleTotal:=true;
  FCollapsed:=false;
//  BorderStyle:=bsSingle;
//  BevelOuter:=bvNone;
  FButtonPosition:=akTop;
  FCollapsedButtonColor:=clSkyBlue;
  FExpandedButtonColor:=RGBToColor(23, 136,248);
  FExpandedSize:=200;
  Height:=ExpandedSize;
  Width:=200;
  FAnimationSpeed:=20;
//  AutoScroll:=false;


  Timer:=TTimer.Create(self);
  Timer.Enabled:=false;
  Timer.Name:='Animationtimer';
  Timer.Interval:=20;

  FButton:=TBoundButton.Create(self);
  with FButton do
    begin
    Parent:=self;
    Name:='Button';
    Caption:='Caption';
    Color:=ExpandedButtonColor;
    ControlStyle := ControlStyle + [csNoFocus, csNoDesignSelectable];
    end;

  StopCircleActions:=false;
  PositionButton;
end;



destructor TMyRollOut.destroy;
begin
  timer.Enabled:=false;

  Timer.Free;

  if (ComponentState * [csLoading, csDesigning] = []) then
    FButton.Free;  // bringt einen Fehler in der Designtime wenn ich das hier mache

//  FButton.Free;  // bringt einen Fehler in der Designtime wenn ich das hier mache

  inherited destroy;
end;



procedure Register;
begin
  RegisterComponents('Misc',[TMyRollOut]);
  RegisterComponents('Misc',[TExpandPanels]);
end;

end.

