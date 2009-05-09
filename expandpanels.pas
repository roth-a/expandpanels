{==============================================================================
 Lizenshinweise:  Diese Komponente wurde geschrieben von Alexander Roth

    Dieses Programm ist freie Software. Sie können es unter den Bedingungen
    der GNU General Public License, wie von der Free Software Foundation
    veröffentlicht, weitergeben und/oder modifizieren, gemäß Version 2 der Lizenz.
==============================================================================}

//////////////////////////////
//  ExpandPanels   Version 1.982
//////////////////////////////


unit ExpandPanels;


{$mode objfpc}{$H+}

interface
uses
  controls,Classes, ExtCtrls, Graphics,math,ComCtrls,
  LResources, StdCtrls, dialogs, SysUtils;

type
  TExpandPanelsBehaviour=(EPHotMouse,EPMultipanel,EPSinglePanel);
  TCollapseKind=(CKCollapseToButton, CKCollapseToOppositeOfButton);
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
    FCollapseKind:TCollapseKind;
    FCollapsed:boolean;
    FAnimated:boolean;
    FOnExpand: TNotifyEvent;
    FOnPreExpand: TNotifyEvent;
    FOnExpandAnimate: TAnimationEvent;
    FOnCollapse: TNotifyEvent;
    FOnPreCollapse: TNotifyEvent;
    FOnCollapseAnimate: TAnimationEvent;
    FOnButtonClick: TNotifyEvent;
    FButtonPosition:TAnchorKind;
    FExpandedButtonColor:TColor;
    FCollapsedButtonColor:TColor;
    FExpandedHeight:integer;
    FExpandedWidth:integer;
    FAnimationSpeed:real;
    FOriginalExpandedHeight:integer;
    FOriginalExpandedWidth:integer;
    StopCircleActions:boolean;
    StoredBound:TRect;
    StoredBevelOuter:TPanelBevel;
    FAnimating,
    FIsCollapsing,
    FIsExpanding:boolean;
    FVisibleTotal:boolean;

    TargetAnimationSize:integer;
    EndProcedureOfAnimation:TNormalProcedure;

    Timer:TTimer;
    
    procedure WriteFExpandedHeight(ExpandedHeight:integer);
    procedure WriteFExpandedWidth(ExpandedWidth:integer);

    procedure WriteFVisibleTotal(VisibleTotal:boolean);

    function ButtonPosition2ButtonAnchors(pos:TAnchorKind):TAnchors;

    procedure SetBounds(ALeft, ATop, AWidth, AHeight: integer); override;

    procedure WriteFCollapsedButtonColor(CollapsedButtonColor:TColor);
    procedure WriteFExpandedButtonColor(ExpandedButtonColor:TColor);
    procedure WriteFButtonPosition(ButtonPosition:TAnchorKind);
    procedure WriteFCollapseKind(CollapseKind:TCollapseKind);
    procedure writeFAnimationSpeed(AnimationSpeed:real);

    procedure PositionButton(ALeft, ATop, AWidth, AHeight: integer);

    procedure WriteFCollapsed(Collapsed:boolean);
    
    procedure TimerAnimateSize(Sender: TObject);
    procedure EndTimerCollapse;
    procedure EndTimerExpand;
    procedure EndTimerWriteFExpandedHeight;
    procedure EndTimerWriteFExpandedWidth;
    procedure UpdateAll;

    procedure ButtonClick(Sender: TObject);
    procedure DoCollapse;
    procedure DoExpand;
    procedure AdjustClientRect(var ARect: TRect); override;
  public
    property Animating:boolean read FAnimating;
    property IsCollapsing:boolean read FIsCollapsing;
    property IsExpanding:boolean read FIsExpanding;

    constructor Create(TheOwner: TComponent); override;
    destructor destroy; override;
  published
    property ExpandedButtonColor:TColor read FExpandedButtonColor write WriteFExpandedButtonColor;
    property CollapsedButtonColor:TColor read FCollapsedButtonColor write WriteFCollapsedButtonColor;
    property ButtonPosition:TAnchorKind read FButtonPosition write WriteFButtonPosition;
    property CollapseKind:TCollapseKind read FCollapseKind write WriteFCollapseKind;
    property VisibleTotal:boolean read FVisibleTotal write WriteFVisibleTotal;
    property ExpandedHeight:integer read FExpandedHeight write WriteFExpandedHeight;
    property ExpandedWidth:integer read FExpandedWidth write WriteFExpandedWidth;
    property OriginalExpandedHeight:integer read FOriginalExpandedHeight write FOriginalExpandedHeight;
    property OriginalExpandedWidth:integer read FOriginalExpandedWidth write FOriginalExpandedWidth;

    property Button:TBoundButton read FButton;

    property AnimationSpeed:real read FAnimationSpeed write writeFAnimationSpeed;
    property Animated:boolean read FAnimated write FAnimated default true;
    property Collapsed:boolean read FCollapsed write WriteFCollapsed default false;
    property OnButtonClick: TNotifyEvent read FOnButtonClick write FOnButtonClick;
    property OnPreExpand: TNotifyEvent read FOnPreExpand write FOnPreExpand;
    property OnExpand: TNotifyEvent read FOnExpand write FOnExpand;
    property OnExpandAnimate: TAnimationEvent read FOnExpandAnimate write FOnExpandAnimate;
    property OnCollapse: TNotifyEvent read FOnCollapse write FOnCollapse;
    property OnPreCollapse: TNotifyEvent read FOnPreCollapse write FOnPreCollapse;
    property OnCollapseAnimate: TAnimationEvent read FOnCollapseAnimate write FOnCollapseAnimate;
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
    FLeft:integer;
    FTop:integer;
    FWidth:integer;
    FBehaviour:TExpandPanelsBehaviour;
    FOnArrangePanels: TNotifyEvent;
    FFixedHeight:integer;
    FUseFixedHeight:boolean;
    FAutoCollapseIfTooHigh:boolean;

    FUseClientHeight:boolean;
    
    procedure WriteFUseClientHeight(value:boolean);
    procedure WriteFUseFixedHeight(value:boolean);
    procedure WriteFAutoCollapseIfTooHigh(value:boolean);
    procedure WriteFFixedHeight(value:integer);

    procedure setLeft(value:Integer);
    procedure setTop(value:Integer);
    procedure setWidth(value:Integer);
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

    property  Left:integer read FLeft write setLeft;
    property  Top:integer read FTop write setTop;
    property  Width:integer read FWidth write setWidth;

    function IdxOfPanel(aname:string):integer; overload;

    procedure CollapseIfTooHigh;
    procedure SetCorrectHeight;
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

//    property FixedHeight:integer read FFixedHeight write WriteFFixedHeight;
//    property UseFixedHeight:boolean read FUseFixedHeight write WriteFUseFixedHeight;
//    property UseClientHeight:boolean read FUseClientHeight write WriteFUseClientHeight;
//    property AutoCollapseIfTooHigh:boolean read FAutoCollapseIfTooHigh write WriteFAutoCollapseIfTooHigh;
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

  FUseFixedHeight:=false;
  FUseClientHeight:=false;
  FFixedHeight:=400;
  FAutoCollapseIfTooHigh:=false;
  FTop:=10;
  FLeft:=10;
  FWidth:=200;
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



{==============================================================================
  Procedure:    AddPanel
  Belongs to:   TExpandPanels
  Result:       None
  Parameters:
                  rollout : TMyRollOut  =

  Description:
==============================================================================}
procedure TExpandPanels.AddPanel(rollout:TMyRollOut);
begin
  InsertPanel(PanelArray.Count, rollout);
end;



procedure TExpandPanels.InsertPanel(idx: integer; rollout: TMyRollOut);
begin
  if (Idx=0)and (PanelArray.Count=0) then
    begin
    FLeft:=rollout.Left;
    FWidth:=rollout.Width;
    FTop:=rollout.Top;
    end;


  with rollout do
    begin
    CollapseKind:=CKCollapseToButton;
    ButtonPosition:=akTop;
    Left:=self.Left;
    top:=self.Top;
    Width:=self.Width;
    Tag:=Idx;
    FButton.Tag:=Idx;

    OnButtonClick:=@RollOutClick;
    FButton.OnMouseMove:=@RollOut1MouseMove;
    OnCollapseAnimate:=@RollOutOnAnimate;
    OnExpandAnimate:=@RollOutOnAnimate;
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




{==============================================================================
  Procedure:    DelLastPanel
  Belongs to:   TExpandPanels
  Result:       None
  Parameters:

  Description:
==============================================================================}
procedure TExpandPanels.DelLastPanel;
begin
  PanelArray.delete(PanelArray.count-1);
end;



procedure TExpandPanels.WriteFUseClientHeight(value: boolean);
begin
  FUseClientHeight:=value;
  
  ArrangePanels;
end;

procedure TExpandPanels.WriteFUseFixedHeight(value: boolean);
begin
  if FUseFixedHeight=value then
    exit;
    
  FUseFixedHeight:=value;
  
  ArrangePanels;
end;

procedure TExpandPanels.WriteFAutoCollapseIfTooHigh(value: boolean);
begin
  if FAutoCollapseIfTooHigh=value then
    exit;

  FAutoCollapseIfTooHigh:=value;
  
  if FAutoCollapseIfTooHigh then
    CollapseIfTooHigh;
end;


procedure TExpandPanels.WriteFFixedHeight(value: integer);
var r:real;
begin
  if FFixedHeight=value then
    exit;

  r:=value;
  korrigiere(r, 20, 10000);
  FFixedHeight:=round(r);
  
  ArrangePanels;
end;


{==============================================================================
  Procedure:    setLeft
  Belongs to:   TExpandPanels
  Result:       None
  Parameters:
                  value : Integer  =

  Description:
==============================================================================}
procedure TExpandPanels.setLeft(value:Integer);
var i:Integer;
begin
  FLeft:=value;

  for I := 0 to PanelArray.Count - 1 do
    with TMyRollOut(PanelArray[i]) do
      if not Collapsed then
        Left:= FLeft;


  ArrangePanels;
end;


{==============================================================================
  Procedure:    setTop
  Belongs to:   TExpandPanels
  Result:       None                         Width
  Parameters:
                  value : Integer  =

  Description:
==============================================================================}
procedure TExpandPanels.setTop(value:Integer);
begin
  FTop:=value;

  //for I := 0 to PanelArray.Count - 1 do
    //TMyRollOut(PanelArray[i]).Top:= FTop;

  ArrangePanels;
end;


{==============================================================================
  Procedure:    setWidth
  Belongs to:   TExpandPanels
  Result:       None
  Parameters:
                  value : Integer  =

  Description:
==============================================================================}
procedure TExpandPanels.setWidth(value:Integer);
var i:Integer;
begin
  FWidth:=value;

  for I := 0 to PanelArray.Count - 1 do
    with TMyRollOut(PanelArray[i]) do
//      if not Collapsed then
        Width:= FWidth;

  ArrangePanels;
end;




{==============================================================================
  Procedure:    setBehaviour
  Belongs to:   TExpandPanels
  Result:       None
  Parameters:
                  value : TExpandPanelsBehaviour  =

  Description:
==============================================================================}
procedure TExpandPanels.setBehaviour(value:TExpandPanelsBehaviour);
var i:Integer;
    isAlreadyOneExpand:boolean;
begin
  isAlreadyOneExpand:=false;
  FBehaviour:=value;

  for I := 0 to PanelArray.Count - 1 do
    with TMyRollOut(PanelArray[i]) do
      if (Behaviour<>EPMultipanel)and  not Collapsed then
        if not isAlreadyOneExpand then
          isAlreadyOneExpand:=true
        else
          Collapsed:=true;

  ArrangePanels;
end;

procedure TExpandPanels.CollapseIfTooHigh;
var i,h:integer;
    tempanimated:boolean;
begin
  if Count<=1 then
    exit;

  h:=Panel(0).Top;
  for i := 0 to Count-1 do
    h:=h+ Panel(i).Height;

  if h>Panel(i).Parent.Height then
    for i := 0 to Count-1 do
      with Panel(i) do
        begin
        tempanimated:=Animated;
        Animated:=false;
        Collapsed:=true;
        Animated:=tempanimated;
        end;
end;



procedure TExpandPanels.RollOutOnAnimate(sender: TObject; deltaLeft, deltaTop, deltaWidth, deltaHeight: integer);
var idx,
    i:integer;
begin
  idx:=PanelArray.IndexOf(sender);
  
  for i:= idx+1 to PanelArray.Count-1 do
    with TMyRollOut(PanelArray[i]) do
      begin
      //if (deltaLeft<>0) or (deltaWidth<>0) then
        //Left:=Left+deltaLeft+deltaWidth;
      if (deltaTop<>0) or (deltaHeight<>0) then
        Top:=Top+deltaTop+deltaHeight;
      end;
end;




procedure TExpandPanels.SetCorrectHeight;
const plus=1;   //extra Anstand
var
    i, exheight,
    countexpanded,
    SumHeight, closedHeight:Integer;
begin
  if PanelArray.Count<=0 then
    exit;
    
  SumHeight:=FFixedHeight;
  if FUseClientHeight then
    SumHeight:=TMyRollOut(PanelArray[0]).Parent.Height;
    

  countexpanded:=0;
  closedHeight:=0;
  for I := 0 to PanelArray.count-1 do
    with TMyRollOut(PanelArray[i]) do
      begin
      if not Collapsed and not IsCollapsing
       or Collapsed and IsExpanding then
        inc(countexpanded)
      else
        closedHeight:=closedHeight+Height;
      end;
        
  exHeight:=SumHeight- FTop- closedHeight;

  case Behaviour of
    EPMultipanel:
      if countexpanded>0 then
        exHeight:=trunc(exHeight/countexpanded)
      else
        exheight:=400;
  end;

  for I := 0 to PanelArray.count-1 do
    with TMyRollOut(PanelArray[i]) do
      begin
      if not FUseFixedHeight and not FUseClientHeight then
        ExpandedHeight:=OriginalExpandedHeight
      else
        ExpandedHeight:=exHeight;
      end;
end;



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
    oben:Integer;
begin
  if Count<=0 then
    exit;

  SetCorrectHeight;

  oben:=Top+ plus;

  for I := 0 to PanelArray.count-1 do
    with TMyRollOut(PanelArray[i]) do
      begin
      if not VisibleTotal then
        continue;
        
      Top:=oben;
      oben:=oben+Height+plus;
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
    
  SetCorrectHeight;
  
//  ArrangePanels;
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

//  ArrangePanels;
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




procedure TMyRollOut.TimerAnimateSize(Sender: TObject);
var step:real;
    originalsize:integer;
    deltaLeft, deltaTop, deltaWidth, deltaHeight: integer;
    vorzeichen:integer;
begin
  deltaLeft:=0;
  deltaTop:=0;
  deltaWidth:=0;
  deltaHeight:=0;
  StopCircleActions:=false;
  FAnimating:=true;
  step:=FAnimationSpeed;

  case ButtonPosition of
    akTop,akBottom:
      begin
      vorzeichen:=Sign(TargetAnimationSize-Height);  // muss ich delta addieren oder muss ich delta abziehen
      originalsize:=ExpandedHeight;
      if not FAnimated or  not (ComponentState * [csLoading, csDesigning] = []) then
        step:=abs(Height-TargetAnimationSize);
      end;
    akLeft,akRight:
      begin
      vorzeichen:=Sign(TargetAnimationSize-Width);  // muss ich delta addieren oder muss ich delta abziehen
      originalsize:=ExpandedWidth;
      if not FAnimated or  not (ComponentState * [csLoading, csDesigning] = []) then
        step:=abs(Width-TargetAnimationSize);
      end;
  end;
  if FAnimated and (ComponentState * [csLoading, csDesigning] = []) then
    begin
    step:=step* originalsize/200;
    if step<3 then
      step:=3;
    end;


  case ButtonPosition of
    akTop, akBottom:
      if abs(height-TargetAnimationSize)>0 then
        begin                                                                      //  min---x---max    // a = delta
        if vorzeichen*height+round(step) <= vorzeichen* TargetAnimationSize then   //v*x+a<v*a
          deltaHeight:=vorzeichen*round(step)
        else
          deltaHeight:=TargetAnimationSize-Height;

        if (ButtonPosition=akTop) and (CollapseKind=CKCollapseToOppositeOfButton)
        or (ButtonPosition=akBottom) and (CollapseKind=CKCollapseToButton) then
          deltaTop:=-deltaHeight;

        SetBounds(Left+deltaLeft, Top+deltaTop, Width+deltaWidth, Height+deltaHeight);
        if assigned(FOnExpandAnimate) then
          FOnExpandAnimate(self, deltaLeft, deltaTop, deltaWidth, deltaHeight);
        end
      else  // wird erst beim nächsten Timer ausgeführt ist aber nicht schlimm
        if assigned(EndProcedureOfAnimation) then
          EndProcedureOfAnimation;
    akLeft, akRight:
      if abs(Width-TargetAnimationSize)>0 then
        begin
        if vorzeichen*Width+round(step) <= vorzeichen* TargetAnimationSize then   //v*x+a<v*a
          deltaWidth:=vorzeichen*round(step)
        else
          deltaWidth:=TargetAnimationSize-Width;

        if (ButtonPosition=akLeft) and (CollapseKind=CKCollapseToOppositeOfButton)
        or (ButtonPosition=akRight) and (CollapseKind=CKCollapseToButton) then
          deltaLeft:=-deltaWidth;

        SetBounds(Left+deltaLeft, Top+deltaTop, Width+deltaWidth, Height+deltaHeight);
        if assigned(FOnExpandAnimate) then
          FOnExpandAnimate(self, deltaLeft, deltaTop, deltaWidth, deltaHeight);
        end
      else  // wird erst beim nächsten Timer ausgeführt ist aber nicht schlimm
        if assigned(EndProcedureOfAnimation) then
          EndProcedureOfAnimation;
  end;
end;



procedure TMyRollOut.EndTimerCollapse;
var i:integer;
begin
  Timer.Enabled:=false;
  FAnimating:=false;
  StopCircleActions:=false;

//  Visible:=false;

  FIsCollapsing:=false;
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
  Timer.Enabled:=false;
  FAnimating:=false;
  StopCircleActions:=false;

  FIsExpanding:=false;
  FCollapsed:=false;

  BevelOuter := StoredBevelOuter;

  if assigned(OnExpand) then
    OnExpand(self);
    
  UpdateAll;
end;


procedure TMyRollOut.EndTimerWriteFExpandedHeight;
begin
  Timer.Enabled:=false;
  FAnimating:=false;
  StopCircleActions:=false;

  //if not Collapsed and (FButtonPosition in [akTop, akBottom])   then
    //Height:=FExpandedHeight;

  UpdateAll;
end;

procedure TMyRollOut.EndTimerWriteFExpandedWidth;
begin
  Timer.Enabled:=false;
  FAnimating:=false;
  StopCircleActions:=false;

  //if not Collapsed and (FButtonPosition in [akLeft, akRight]) then
    //Width:=FExpandedWidth;

  UpdateAll;
end;

procedure TMyRollOut.UpdateAll;
begin
  Update;
//  FButton.Update;
end;






procedure TMyRollOut.WriteFExpandedHeight(ExpandedHeight: integer);
begin
  if FExpandedHeight=ExpandedHeight then
    exit;

  FExpandedHeight:=ExpandedHeight;

  if not (ComponentState * [csLoading, csDesigning] = []) then
    begin
    if csDesigning in ComponentState then
      FOriginalExpandedHeight:=ExpandedHeight;

    TargetAnimationSize:=ExpandedHeight;
    EndProcedureOfAnimation:=@EndTimerWriteFExpandedHeight;
    TimerAnimateSize(self);
    TimerAnimateSize(self);
    end
  else if not Collapsed and not IsCollapsing then
    begin
    FAnimating:=true;
    StopCircleActions:=true;

    TargetAnimationSize:=ExpandedHeight;
    EndProcedureOfAnimation:=@EndTimerWriteFExpandedHeight;
    Timer.Enabled:=true;
    Timer.OnTimer:=@TimerAnimateSize;
    end
  else if IsExpanding then
    TargetAnimationSize:=ExpandedHeight;
end;


procedure TMyRollOut.WriteFExpandedWidth(ExpandedWidth: integer);
begin
  if FExpandedWidth=ExpandedWidth then
    exit;

  FExpandedWidth:=ExpandedWidth;

  if not (ComponentState * [csLoading, csDesigning] = []) then
    begin
    if csDesigning in ComponentState then
      FOriginalExpandedWidth:=ExpandedWidth;

    TargetAnimationSize:=ExpandedWidth;
    EndProcedureOfAnimation:=@EndTimerWriteFExpandedWidth;
    TimerAnimateSize(self);
    TimerAnimateSize(self);
    end
  else if not Collapsed and not IsCollapsing then
    begin
    FAnimating:=true;
    StopCircleActions:=true;

    TargetAnimationSize:=ExpandedWidth;
    EndProcedureOfAnimation:=@EndTimerWriteFExpandedWidth;
    Timer.Enabled:=true;
    Timer.OnTimer:=@TimerAnimateSize;
    end
  else if IsExpanding then
    TargetAnimationSize:=ExpandedWidth;
end;


procedure TMyRollOut.WriteFVisibleTotal(VisibleTotal: boolean);
begin
  FVisibleTotal:=VisibleTotal;
  
  Self.Visible:=FVisibleTotal;
  FButton.Visible:=FVisibleTotal;
end;


function TMyRollOut.ButtonPosition2ButtonAnchors(pos: TAnchorKind): TAnchors;
begin
  result:=[akTop, akLeft, akBottom, akRight];

  case pos of
    akBottom: Result:=Result-[akTop];
    akLeft: Result:=Result-[akRight];
    akTop:  Result:=Result-[akBottom];
    akRight:Result:=Result-[akLeft];
  end;
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
  
  if not Collapsed and not FAnimating then
    begin
    FExpandedHeight:=AHeight;
    FExpandedWidth:=AWidth;
    FOriginalExpandedHeight:=AHeight;
    FOriginalExpandedWidth:=AWidth;
    end;


  //if not StopCircleActions then
    //PositionButton(ALeft, ATop, AWidth, AHeight);

//  Update;
end;



procedure TMyRollOut.WriteFCollapsedButtonColor(CollapsedButtonColor: TColor);
begin
  FCollapsedButtonColor:=CollapsedButtonColor;
  
  if Collapsed then
    FButton.Color:=FCollapsedButtonColor;
end;

procedure TMyRollOut.WriteFExpandedButtonColor(ExpandedButtonColor: TColor);
begin
  FExpandedButtonColor:=ExpandedButtonColor;

  if not Collapsed then
    FButton.Color:=FExpandedButtonColor;
end;

procedure TMyRollOut.WriteFButtonPosition(ButtonPosition: TAnchorKind);
var wasanimated, wascollpased:boolean;
begin
  if FButtonPosition=ButtonPosition then
    exit;

  wasanimated:=Animated;
  wascollpased:=Collapsed;
  Animated:=false;
  if Collapsed then
    Collapsed:=false;

  FButtonPosition:=ButtonPosition;
  
  Collapsed := wascollpased;
  Animated := wasanimated;

  PositionButton(Left, Top, Width, Height);
end;


procedure TMyRollOut.WriteFCollapseKind(CollapseKind: TCollapseKind);
var wasanimated, wascollpased:boolean;
begin
  if FCollapseKind=CollapseKind then
    exit;

  wasanimated:=Animated;
  wascollpased:=Collapsed;
  Animated:=false;
  if Collapsed then
    Collapsed:=false;

  FCollapseKind:=CollapseKind;

  Collapsed := wascollpased;
  Animated := wasanimated;
end;

procedure TMyRollOut.writeFAnimationSpeed(AnimationSpeed: real);
begin
  korrigiere(AnimationSpeed, 3, 1000);
  FAnimationSpeed:=AnimationSpeed;
end;




procedure TMyRollOut.PositionButton(ALeft, ATop, AWidth, AHeight: integer);

  procedure korr(var int:integer);
  begin
    if int<1 then
      int:=1;
  end;


var    newLeft, newTop, newWidth, newHeight: integer;
begin
  if StopCircleActions or not Assigned(FButton) then
    exit;
  StopCircleActions:=true;


  FButton.Visible:=VisibleTotal;

  case ButtonPosition of
    akTop, akBottom:
      begin
      newLeft:=0;
      newWidth:=AWidth-2;
      newHeight:=27;
      end;
    akLeft, akRight:
      begin
      newTop:=0;
      newHeight:=AHeight-2;
      newWidth:=27;
      end;
  end;

    //end;
  case ButtonPosition of
    akTop:
      newTop:=0;
    akBottom:
      newTop:=AHeight-newHeight-1;
    akLeft:
      newLeft:=1;
    akRight:
      newLeft:=AWidth-newWidth-1;
  end;

  //set anchors
  FButton.Anchors:=ButtonPosition2ButtonAnchors(FButtonPosition);

  korr(newHeight);
  korr(newLeft);
  korr(newWidth);
  korr(newTop);

  FButton.SetBounds(newLeft, newTop, newWidth, newHeight);

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
  case ButtonPosition of
    akLeft, akRight: collapsesize:=FButton.Width;
    akTop, akBottom: collapsesize:=FButton.Height;
  end;

  if FCollapsed then
    begin
    if Animating then
      TargetAnimationSize:=collapsesize;
    exit;
    end;

  FIsCollapsing:=true;

  if assigned(OnPreCollapse) then
    OnPreCollapse(self);

  FButton.Color:=FCollapsedButtonColor;
  FButton.Brush.Color:=FCollapsedButtonColor;


  TargetAnimationSize:=collapsesize;
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
var i:integer;
begin
  case ButtonPosition of
    akTop,akBottom: TargetAnimationSize:=ExpandedHeight;
    akLeft,akRight: TargetAnimationSize:=ExpandedWidth;
  end;

  if not FCollapsed then
    begin
    if Animating then
      TargetAnimationSize:=TargetAnimationSize;
    exit;
    end;

  //for i:=0 to ControlCount-1 do
    //if Controls[i] <> FButton then
      //Controls[i].Visible:=true;

  FIsExpanding:=true;

  if assigned(OnPreExpand) then
    OnPreExpand(self);

//  FButton.ControlStyle := FButton.ControlStyle + [csNoFocus, csNoDesignSelectable];
//  FButton.Parent:=self;

  FButton.Color:=FExpandedButtonColor;
  FButton.Brush.Color:=FExpandedButtonColor;

  Visible:=VisibleTotal;

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

  FAnimated:=true;
  FCollapseKind:=CKCollapseToButton;
  FVisibleTotal:=true;
  FCollapsed:=false;
//  BorderStyle:=bsSingle;
//  BevelOuter:=bvNone;
  FButtonPosition:=akTop;
  FCollapsedButtonColor:=clSkyBlue;
  FExpandedButtonColor:=RGBToColor(23, 136,248);
  FExpandedHeight:=200;
  FOriginalExpandedHeight:=FExpandedHeight;
  FExpandedWidth:=200;
  FOriginalExpandedWidth:=FExpandedWidth;
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
    Name:='MainButton';
    Caption:='Caption';
    Color:=ExpandedButtonColor;
    ControlStyle := ControlStyle + [csNoFocus, csNoDesignSelectable];
    end;

  StopCircleActions:=false;
  PositionButton(Self.Left, self.Top, self.Width, Height);
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

