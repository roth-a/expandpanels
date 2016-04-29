{
********************************************************************************
*                         ExpandPanels   Version 2.2                           *
*                                                                              *
*                                                                              *
*   (c)  Alexander Roth, Massimo Magnano                                       *
*                                                                              *
*   (o)                                                                        *
*    This component is free software: you can redistribute it and/or modify    *
*    it under the terms of the GNU General Public License as published by      *
*    the Free Software Foundation, version 2 of the License.                   *
*    It is distributed in the hope that it will be useful,                     *
*    but WITHOUT ANY WARRANTY;                                                 *
*    The GNU General Public License is available at                            *
*    <http://www.gnu.org/licenses/>.                                           *
*                                                                              *
********************************************************************************

Instructions and Infos: Readme.txt
Change Log: Changelog.txt
To-do and bugs List: to-do.txt
}

unit ExpandPanels;


{$mode objfpc}{$H+}

// for debugging purposes
//{$DEFINE DebugInfo}
//{$DEFINE DEBUG_PAINT}
//{$DEFINE DEBUG_PAINT_SIM_ANIM}  //Activate to Test the Animation Step by Step manually using _AnimateXXX

interface

uses
  Controls, Classes, ExtCtrls, Graphics, Math,
  LResources,  Dialogs, SysUtils, Buttons, Themes, Types, Menus, Forms;

type
  TExpandPanelsBehaviour = (EPHotMouse, EPMultipanel, EPSinglePanel);
  //  TBoundEvent=procedure(sender:TObject; ALeft, ATop, AWidth, AHeight: integer) of object;
  TAnimationEvent = procedure(Sender: TObject; deltaLeft, deltaTop, deltaWidth, deltaHeight: integer) of object;
  TNormalProcedure = procedure of object;


  { TBoundButton }

  TGlyphLayout =
  (
    glLeft,
    glRight,
    glNone
  );

  TTextLayout =
  (
    tlLeft,
    tlRight,
    tlCenter,
    tlNone
  );

  TBoundButton = class(TCustomSpeedButton)
  private
    rColorExpanded: TColor;
    rColorHighlight: TColor;
    rColorShadow: TColor;
    rGlyphLayout: TGlyphLayout;
    rLineShow: Boolean;
    rTextLayout: TTextLayout;

    procedure setColorExpanded(AValue: TColor);
    procedure SetColorHighlight(AValue: TColor);
    procedure SetColorShadow(AValue: TColor);
    procedure SetGlyphLayout(AValue: TGlyphLayout);
    procedure SetLineShow(AValue: Boolean);
    procedure SetTextLayout(AValue: TTextLayout);

  protected
    rGlyph :TButtonGlyph;
    rUserGlyphExpanded,
    rUserGlyphCollapsed,
    rGlyphExpanded,
    rGlyphCollapsed :TBitmap;

    procedure SetGlyphCollapsed(AValue: TBitmap);
    procedure SetGlyphExpanded(AValue: TBitmap);
    procedure LoadGlyph(GlyphDST :TBitmap; ResName :String);
    procedure BuildGlyphs;
    procedure Paint; override;
    procedure Loaded; override;

  (*  property AllowAllUp;
    property Down;
    property Flat;
    property Glyph;
    property GroupIndex;
    property Height;            //Don't Decrease visibility :-O
    property HelpContext;
    property HelpKeyword;
    property HelpType;
    property Layout;
    property Left;
    property Margin;
    property Name;
    property NumGlyphs;
    property Spacing;
    property ShowCaption;
    property Tag;
    property Top;
    property Width;
    property Transparent;
    *)
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

  published
    property Caption;
    property Color nodefault;
    property ColorExpanded: TColor read rColorExpanded write setColorExpanded;
    property ColorHighlight: TColor read rColorHighlight write SetColorHighlight default clDefault;
    property ColorShadow: TColor read rColorShadow write SetColorShadow default clDefault;
    property Font;
    property GlyphExpanded: TBitmap read rUserGlyphExpanded write SetGlyphExpanded;
    property GlyphCollapsed: TBitmap read rUserGlyphCollapsed write SetGlyphCollapsed;

    //Creating at RUNTIME Set in the Last Line of your Code else Glyphs is not Loaded correctly
    property GlyphLayout: TGlyphLayout read rGlyphLayout write SetGlyphLayout default glNone;

    //property LineShow: Boolean read rLineShow write SetLineShow default False; In The Next Future
    property ShowAccelChar;
    property TextLayout: TTextLayout read rTextLayout write SetTextLayout default tlLeft;
  end;

  { TMyRollOutSubPanel}
  TMyRollOut = class;

  TMyRollOutSubPanel = class (TCustomPanel)
  private
    rBevelRounded: Boolean;
  protected
    rollOwner: TMyRollOut;
    rColorHighlight: TColor;
    rColorShadow: TColor;

    procedure SetBevelRounded(AValue: Boolean);
    procedure SetColorHighlight(AValue: TColor);
    procedure SetColorShadow(AValue: TColor);

    procedure Paint; override;

    property Caption stored False;
  public
    constructor Create(TheOwner: TMyRollOut);

  published
    property ColorHighlight: TColor read rColorHighlight write SetColorHighlight default clBtnHighlight;
    property ColorShadow: TColor read rColorShadow write SetColorShadow default clBtnShadow;
    property BevelRounded: Boolean read rBevelRounded write SetBevelRounded default True;

  end;

  { TMyRollOut }
                             //Gradient from .. to .. (S=Shadow, H=Highlight)
                             //           CollapseKind
  TmrEffectKind = (          // (akTop, akLeft) (akBottom, akRight)
  ekFoldingDouble,           //            HS-HS-SH
  ekFoldingDown,             //            HS-SH-HS
  ekCurtain,                 //            HS-HS-HS
  ekCurtainPersian,          //            SH-SH-SH
  ekWaveDoubleExternal,      //  |-> SH-SH-HS         SH-HS-HS <-|
  ekWaveDoubleInternal,      //  |-> SH-HS-HS         SH-SH-HS <-|
  //ekWaveInternal,          //  |-> SH-HS-SH     Don't work here|
  ekWave,                    //             SH-HS
  ekWave2,                   //             HS-SH
  ekNone
  );

  TMyRollOut = class(TPanel)
  protected
    FAnimationTotalTime: Cardinal;
    FEPManagesCollapsing: TNotifyEvent;
    FButton: TBoundButton;
    rPanel: TMyRollOutSubPanel;
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
    FAnimating,
    FAnimating_Collapsing,        //if = False is Expanding
    FAnimating_Partial: boolean;  //so we don't hide the SubPanel the first time
    anim_delta, anim_step: Word;
    anim_CollapsedSize: Integer;
    rAnimationEffectKind: TmrEffectKind;
    FVisibleTotal: boolean;

    //TargetAnimationSize:     integer;
    //EndProcedureOfAnimation: TNormalProcedure;

    Timer: TTimer;

    function GetBevelInner: TPanelBevel;
    function GetBevelOuter: TPanelBevel;
    function GetBevelWidth: TBevelWidth;
    function GetEnabled: Boolean;
    procedure setAnimationTotalTime(AValue: Cardinal);
    procedure SetBevelInner(AValue: TPanelBevel);
    procedure SetBevelOuter(AValue: TPanelBevel);
    procedure SetBevelWidth(AValue: TBevelWidth);
    procedure SetEnabled(AValue: Boolean);
    procedure setExpandedSize(Value: integer);
    procedure setButtonSize(Value: integer);

    procedure setButtonPosition(Value: TAnchorKind);
    procedure setCollapseKind(Value: TAnchorKind);
    procedure setAnimationSpeed(Value: real);
    procedure setCollapsed(Value: boolean);

    procedure PositionButtonAndPanel;

    function RelevantSize(comp: TControl; akind: TAnchorKind): integer;
    function RelevantOrthogonalSize(comp: TControl; akind: TAnchorKind): integer;
    function DeltaCoordinates(deltaMove, deltaSize: integer): TRect;  // the outpot (left,top right, bottom) has all the information: left and top encode the movement. rigth and bottom the size changes

    procedure SetRelevantSize(comp: TControl; AKind: TAnchorKind; ASize: Integer);

    procedure EndTimerCollapse(Sender: TObject);
    procedure EndTimerExpand(Sender: TObject);

    procedure CalculateAnimValues;

    {$ifdef DEBUG_PAINT_SIM_ANIM}
      public
    {$EndIf}
    procedure AnimateCollapse(Sender: TObject);
    procedure AnimateExpand(Sender: TObject);

    {$ifdef DEBUG_PAINT_SIM_ANIM}
      protected
    {$EndIf}

    procedure UpdateAll;

    procedure ButtonClick(Sender: TObject);
    procedure DoCollapse(isPartial: Boolean=False);
    procedure DoExpand(isPartial: Boolean=False);
    procedure AdjustClientRect(var ARect: TRect); override;

    property InternalOnAnimate: TAnimationEvent read FInternalOnAnimate write FInternalOnAnimate;
    property EPManagesCollapsing: TNotifyEvent read FEPManagesCollapsing write FEPManagesCollapsing;

    (*function DSGN_AddClicked(ADesigner: TIDesigner;
                                MouseDownComponent: TComponent; Button: TMouseButton;
                                Shift: TShiftState; X, Y: Integer;
                                var AComponentClass: TComponentClass;
                                var NewParent: TComponent): boolean;*)
    procedure MoveControlsToSubPanel;
    procedure Loaded; override;
    procedure CreateWnd; override;
    procedure Paint; override;
    procedure Paint_Effect(ACanvas: TCanvas; ARect: TRect; gfDirection: TGradientDirection); virtual;
    procedure Resize; override;
    procedure AlignControls(AControl: TControl;
                            var RemainingClientRect: TRect); override;

  public
    constructor Create(TheOwner: TComponent); override;
    destructor Destroy; override;

    procedure SetBounds(ALeft, ATop, AWidth, AHeight: integer); override;
    procedure InsertControl(AControl: TControl; Index: integer); override;

    property Animating: boolean read FAnimating;
    property Animation_Step: Word read anim_step;

  published
    property BevelInner: TPanelBevel read GetBevelInner write SetBevelInner default bvNone;
    property BevelOuter: TPanelBevel read GetBevelOuter write SetBevelOuter default bvRaised;
    property BevelWidth: TBevelWidth read GetBevelWidth write SetBevelWidth default 1;
    property Enabled: Boolean read GetEnabled write SetEnabled;

    property Collapsed: boolean read FCollapsed write setCollapsed default False;
    property CollapseKind: TAnchorKind read FCollapseKind write setCollapseKind;   //To where should it collapse?
    property ExpandedSize: integer read FExpandedSize write setExpandedSize;

    property ButtonPosition: TAnchorKind read FButtonPosition write setButtonPosition;
    property ButtonSize: integer read FButtonSize write setButtonSize;
    property Button: TBoundButton read FButton;

    property Panel: TMyRollOutSubPanel read rPanel;

    property Animated: boolean read FAnimated write FAnimated default True;
    property AnimationSpeed: real read FAnimationSpeed write setAnimationSpeed;
    property AnimationTotalTime: Cardinal read FAnimationTotalTime write setAnimationTotalTime default 300;
    property AnimationEffectKind: TmrEffectKind read rAnimationEffectKind write rAnimationEffectKind default ekFoldingDouble;

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

var
   AnimationMinInterval: Word = 30;   //Calculated by Processor Speed (No Idea ????)
   AnimationMinDelta: Word = 21;      //Minimum Pixels to Add/Remove  (Multiple of 3)
   anim_t_start, anim_t_end: QWord;   //Declared here so i can see it on Debugging

procedure Register;

implementation

uses GraphType, LCLProc;

const
  //GrayScale a Color : Taken from BGRABitmap package
  redWeightShl10   = 306; // = 0.299
  greenWeightShl10 = 601; // = 0.587
  blueWeightShl10  = 117; // = 0.114


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


//Function copied from BGRABitmap package may work ;-)
function Grayscale(AColor :TColor):TColor;
Var
  rColor, gray :Integer;

begin
  rColor :=ColorToRGB(AColor);
  gray  := (Red(rColor) * redWeightShl10 + Green(rColor) * greenWeightShl10 + Blue(rColor) * blueWeightShl10 + 512) shr 10;
  Result :=RGBToColor(gray, gray, gray);
end;

function GetHighlightColor(BaseColor: TColor; Value:Integer): TColor;
Var
  rColor :Integer;

begin
  rColor :=ColorToRGB(BaseColor);
  Result := RGBToColor(
       Min(Red(rColor) + Value, $FF),
       Min(Green(rColor) + Value, $FF),
       Min(Blue(rColor) + Value, $FF));
end;

function GetShadowColor(BaseColor: TColor; Value:Integer): TColor;
Var
  rColor :Integer;

begin
  rColor :=ColorToRGB(BaseColor);
  Result := RGBToColor(
       Max(Red(rColor) - Value, $22),
       Max(Green(rColor) - Value, $22),
       Max(Blue(rColor) - Value, $22));
end;

//Canvas Draw Functions
procedure Frame3d_Rounded(Canvas: TCanvas;
                          var ARect: TRect; const FrameWidth : integer; RX, RY:Integer;
                          const Style : TGraphicsBevelCut;
                          ShadowColor, HighlightColor, InternalColor: TColor);
var
   DRect: TRect;

   procedure drawUP;
   begin
     inc(DRect.Left,1); inc(DRect.Top,1);

     //is outside the Rect but in this way we don't have a hole of 1 px
     inc(DRect.Right,1); inc(DRect.Bottom,1);

     Canvas.Brush.Color :=ShadowColor;
     Canvas.Brush.Style :=bsSolid;
     Canvas.Pen.Color := clNone;
     Canvas.Pen.Width := 1;         //The Shadow is always 1 Pixel
     Canvas.Pen.Style := psClear;
     Canvas.RoundRect(DRect, RX,RY);

     dec(DRect.Left,1); dec(DRect.Top,1);
     dec(DRect.Right,2); dec(DRect.Bottom,2);
     Canvas.Brush.Color :=InternalColor;

     if (InternalColor = clNone)
     then Canvas.Brush.Style :=bsClear
     else Canvas.Brush.Style :=bsSolid;

     Canvas.Pen.Color :=HighlightColor;
     Canvas.Pen.Width := FrameWidth;
     Canvas.Pen.Style := psSolid;
     Canvas.RoundRect(DRect, RX,RY);

     Inc(ARect.Top, FrameWidth);
     Inc(ARect.Left, FrameWidth);
     Dec(ARect.Right, FrameWidth+1); //+The Shadow (1 Pixel) +1?
     Dec(ARect.Bottom, FrameWidth+1);
   end;

   procedure drawFLAT;
   begin
     Canvas.Brush.Color := InternalColor;

     if (InternalColor = clNone)
     then Canvas.Brush.Style :=bsClear
     else Canvas.Brush.Style :=bsSolid;

     Canvas.Pen.Color := clNone;
     Canvas.Pen.Width := FrameWidth;
     Canvas.Pen.Style := psClear;
     Canvas.RoundRect(DRect, RX,RY);

     InflateRect(ARect, -FrameWidth, -FrameWidth); //No Shadow
   end;

   procedure drawDOWN;
   begin
     Canvas.Brush.Color :=ShadowColor;
     Canvas.Brush.Style :=bsSolid;
     Canvas.Pen.Color := clNone;
     Canvas.Pen.Width := 1;
     Canvas.Pen.Style := psClear;
     Canvas.RoundRect(DRect, RX,RY);

     inc(DRect.Left,1); inc(DRect.Top,1);
     Canvas.Brush.Color :=InternalColor;

     if (InternalColor = clNone)
     then Canvas.Brush.Style :=bsClear
     else Canvas.Brush.Style :=bsSolid;

     Canvas.Pen.Color :=HighlightColor;
     Canvas.Pen.Width := FrameWidth;
     Canvas.Pen.Style := psSolid;
     Canvas.RoundRect(DRect, RX,RY);

     Inc(ARect.Top, FrameWidth+1); //+The Shadow (1 Pixel)
     Inc(ARect.Left, FrameWidth+1);
     Dec(ARect.Right, FrameWidth);
     Dec(ARect.Bottom, FrameWidth);
   end;

begin
     DRect :=ARect;
     Case Style of
     bvNone, bvSpace: drawFLAT;
     bvRaised: drawUP;
     bvLowered: drawDOWN;
     end;
end;

{ TMyRollOutSubPanel }

procedure TMyRollOutSubPanel.SetBevelRounded(AValue: Boolean);
begin
  if (rBevelRounded <> AValue) then
  begin
    rBevelRounded := AValue;

    if not(csLoading in ComponentState)
    then Invalidate;
   end;
end;

procedure TMyRollOutSubPanel.SetColorHighlight(AValue: TColor);
begin
  if (rColorHighlight <> AValue) then
  begin
    rColorHighlight := AValue;

    if not(csLoading in ComponentState)
    then Invalidate;
  end;
end;

procedure TMyRollOutSubPanel.SetColorShadow(AValue: TColor);
begin
  if (rColorShadow <> AValue) then
  begin
    rColorShadow := AValue;

    if not(csLoading in ComponentState)
    then Invalidate;
  end;
end;

procedure TMyRollOutSubPanel.Paint;
var
  ARect: TRect;
  TS : TTextStyle;

begin
  ARect := GetClientRect;

  {$ifdef DEBUG_PAINT}
    Canvas.Brush.Color:=clRed;
    Canvas.Brush.Style:=bsSolid;
    Canvas.FillRect(ARect);
  {$endif}

  // if BevelOuter is set then draw a frame with BevelWidth
  if (BevelOuter <> bvNone)
  then if rBevelRounded
       then Frame3d_Rounded(Canvas, ARect, BevelWidth, 5, 5, BevelOuter, rColorShadow, rColorHighlight, Color)
       else Canvas.Frame3d(ARect, BevelWidth, BevelOuter);

  InflateRect(ARect, -BorderWidth, -BorderWidth);

  // if BevelInner is set then skip the BorderWidth and draw a frame with BevelWidth
  if (BevelInner <> bvNone)
  then if rBevelRounded
       then Frame3d_Rounded(Canvas, ARect, BevelWidth, 5, 5, BevelInner, rColorShadow, rColorHighlight, Color)
       else Canvas.Frame3d(ARect, BevelWidth, BevelInner);

  if (rollOwner.Caption <> '') then
  begin
    TS := Canvas.TextStyle;
    TS.Alignment := BidiFlipAlignment(Self.Alignment, UseRightToLeftAlignment);
    if (BiDiMode <> bdLeftToRight)
    then TS.RightToLeft:= True;
    TS.Layout:= Graphics.tlCenter;
    TS.Opaque:= false;
    TS.Clipping:= false;
    TS.SystemFont:=Canvas.Font.IsDefault;
    if not Enabled then
    begin
      Canvas.Font.Color := clBtnHighlight;
      OffsetRect(ARect, 1, 1);
      Canvas.TextRect(ARect, ARect.Left, ARect.Top, rollOwner.Caption, TS);
      Canvas.Font.Color := clBtnShadow;
      OffsetRect(ARect, -1, -1);
     end
    else
     Canvas.Font.Color := Font.Color;

    Canvas.TextRect(ARect,ARect.Left,ARect.Top, rollOwner.Caption, TS);
  end;
end;

constructor TMyRollOutSubPanel.Create(TheOwner: TMyRollOut);
begin
  inherited Create(TheOwner);

  rollOwner :=TheOwner;
  rColorHighlight:=clBtnHighlight;
  rColorShadow:=clBtnShadow;
  rBevelRounded:=True;
  SetSubComponent(True);
end;

{ TBoundButton }

procedure TBoundButton.SetColorHighlight(AValue: TColor);
begin
  if (rColorHighlight <> AValue) then
  begin
       rColorHighlight := AValue;

       if not(csLoading in ComponentState)
       then Invalidate;
  end;
end;

procedure TBoundButton.setColorExpanded(AValue: TColor);
begin
  if (rColorExpanded <> AValue) then
  begin
       rColorExpanded := AValue;

       if not(csLoading in ComponentState)
       then Invalidate;
  end;
end;

procedure TBoundButton.SetColorShadow(AValue: TColor);
begin
  if (rColorShadow <> AValue) then
  begin
       rColorShadow := AValue;

       if not(csLoading in ComponentState)
       then Invalidate;
  end;
end;

procedure TBoundButton.SetGlyphLayout(AValue: TGlyphLayout);
begin
  if (rGlyphLayout <> AValue) then
  begin
       rGlyphLayout := AValue;

       if not(csLoading in ComponentState) then
       begin
            BuildGlyphs;
            Invalidate;
        end;
  end;
end;

procedure TBoundButton.SetLineShow(AValue: Boolean);
begin
  if (rLineShow <> AValue) then
  begin
       rLineShow := AValue;
       if not(csLoading in ComponentState)
       then Invalidate;
  end;
end;

procedure TBoundButton.SetTextLayout(AValue: TTextLayout);
begin
  if (rTextLayout <> AValue) then
  begin
       rTextLayout := AValue;
       if not(csLoading in ComponentState)
       then Invalidate;
  end;
end;

procedure TBoundButton.SetGlyphCollapsed(AValue: TBitmap);
begin
     rUserGlyphCollapsed.Assign(AValue);
     if not(csLoading in ComponentState) then
     begin
          BuildGlyphs;
          Invalidate;
      end;
end;

procedure TBoundButton.SetGlyphExpanded(AValue: TBitmap);
begin
     rUserGlyphExpanded.Assign(AValue);
     if not(csLoading in ComponentState) then
     begin
          BuildGlyphs;
          Invalidate;
      end;
end;

procedure TBoundButton.LoadGlyph(GlyphDST: TBitmap; ResName: String);
Var
   rGlyphO: TPortableNetworkGraphic;

begin
  rGlyphO :=TPortableNetworkGraphic.Create;
  rGlyphO.LoadFromLazarusResource(ResName);
  GlyphDST.Assign(rGlyphO);
  FreeAndNil(rGlyphO);
end;

procedure TBoundButton.BuildGlyphs;
begin
  if (rGlyphLayout <> glNone) then
  begin
       if (rUserGlyphCollapsed.Empty)
       then begin
                 case TMyRollOut(Owner).CollapseKind of
                 akTop: LoadGlyph(rGlyphCollapsed, 'EXP_PANEL_BOTTOM');
                 akLeft: LoadGlyph(rGlyphCollapsed, 'EXP_PANEL_RIGHT');
                 akRight: LoadGlyph(rGlyphCollapsed, 'EXP_PANEL_LEFT');
                 akBottom: LoadGlyph(rGlyphCollapsed, 'EXP_PANEL_TOP');
                 end;
            end
       else rGlyphCollapsed.Assign(rUserGlyphCollapsed);

       if (rUserGlyphExpanded.Empty)
       then begin
                 case TMyRollOut(Owner).CollapseKind of
                 akTop: LoadGlyph(rGlyphExpanded, 'EXP_PANEL_TOP');
                 akLeft: LoadGlyph(rGlyphExpanded, 'EXP_PANEL_LEFT');
                 akRight: LoadGlyph(rGlyphExpanded, 'EXP_PANEL_RIGHT');
                 akBottom: LoadGlyph(rGlyphExpanded, 'EXP_PANEL_BOTTOM');
                 end;
             end
       else rGlyphExpanded.Assign(rUserGlyphExpanded);
  end;
end;

procedure TBoundButton.Paint;
var
  paintRect :TRect;
  xColor,
  xHColor,
  xSColor  :TColor;
  middleX,
  middleY,
  glyphLeft,
  glyphTop :Integer;
  xCaption :String;


  procedure drawButton(Collapsed :Boolean; var ATop, ALeft :Integer);
  begin
    if Collapsed
    then rGlyph.Glyph.Assign(rGlyphCollapsed)
    else rGlyph.Glyph.Assign(rGlyphExpanded);

    //We must Calculate the Real Position of the Glyph
    Case TMyRollOut(Owner).FButtonPosition of
    akTop,
    akBottom : begin
                    if (rGlyphLayout = glLeft)
                    then begin
                              ALeft :=2;
                              ATop :=middleY-(rGlyph.Glyph.Height div 2);
                          end
                    else begin
                              ALeft :=paintRect.Right-2-rGlyph.Glyph.Width;
                              ATop :=middleY-(rGlyph.Glyph.Height div 2);
                          end;
                end;
    akLeft :begin
                 if (rGlyphLayout = glLeft)
                 then begin  //Really on Bottom of paintRect
                           ALeft :=middleX-(rGlyph.Glyph.Width div 2);
                           ATop :=paintRect.Bottom-2-rGlyph.Glyph.Height;
                       end
                 else begin  //Really on Top of paintRect
                           ALeft :=middleX-(rGlyph.Glyph.Width div 2);
                           ATop :=2;
                       end;
             end;
    akRight :begin
                 if (rGlyphLayout = glLeft)
                 then begin  //Really on Top of paintRect
                           ALeft :=middleX-(rGlyph.Glyph.Width div 2);
                           ATop :=2;
                       end
                 else begin  //Really on Bottom of paintRect
                           ALeft :=middleX-(rGlyph.Glyph.Width div 2);
                           ATop :=paintRect.Bottom-2-rGlyph.Glyph.Height;
                       end;
             end;
    end;

    rGlyph.Draw(Canvas, paintRect, point(ALeft, ATop), FState, true, 0);
  end;

  procedure drawUP;
  begin
       inc(paintRect.Left,1); inc(paintRect.Top,1);

       //is outside the Rect but in this way we don't have a hole of 1 px
       inc(paintRect.Right,1); inc(paintRect.Bottom,1);

       Canvas.Brush.Color :=xSColor; //clbtnShadow;
       Canvas.Brush.Style :=bsSolid;
       Canvas.Pen.Color := clNone;
       Canvas.Pen.Width := 1;
       Canvas.Pen.Style := psClear;
       Canvas.RoundRect(paintRect, 5,5);

       dec(paintRect.Left,1); dec(paintRect.Top,1);
       dec(paintRect.Right,2); dec(paintRect.Bottom,2);
       Canvas.Brush.Color :=xColor;
       Canvas.Brush.Style :=bsSolid;
       Canvas.Pen.Color :=xHColor; //clbtnHighlight;
       Canvas.Pen.Width := 1;
       Canvas.Pen.Style := psSolid;
       Canvas.RoundRect(paintRect, 5,5);
  end;

  procedure drawFLAT;
  begin
       Canvas.Brush.Color := xColor;
       Canvas.Brush.Style :=bsSolid;
       Canvas.Pen.Color := clNone;
       Canvas.Pen.Width := 1;
       Canvas.Pen.Style := psClear;
       Canvas.RoundRect(paintRect, 5,5);
  end;

  procedure drawDOWN;
  begin
       Canvas.Brush.Color :=xSColor; //clbtnShadow;
       Canvas.Brush.Style :=bsSolid;
       Canvas.Pen.Color := clNone;
       Canvas.Pen.Width := 1;
       Canvas.Pen.Style := psClear;
       Canvas.RoundRect(paintRect, 5,5);

       inc(paintRect.Left,1); inc(paintRect.Top,1);
       Canvas.Brush.Color :=xColor;
       Canvas.Brush.Style :=bsSolid;
       Canvas.Pen.Color :=xHColor; //clbtnHighlight;
       Canvas.Pen.Width := 1;
       Canvas.Pen.Style := psSolid;
       Canvas.RoundRect(paintRect, 5,5);
  end;

  procedure CalcCuttedCaption(var ACaption :String; var txtW :Integer; MaxWidth :Integer);
  Var
     txtMaxChars  :Integer;

  begin
       txtW :=0;
       if (MaxWidth < Canvas.TextWidth('...'))
       then ACaption :=''
       else begin
                 txtMaxChars :=Canvas.TextFitInfo(ACaption, MaxWidth);
                 txtW :=Canvas.TextWidth(ACaption);
                 while (txtW > MaxWidth) do
                 begin
                      dec(txtMaxChars, 3);    //-1 Chars fit better, -3 Chars for more speed
                      ACaption :=Copy(ACaption, 0, txtMaxChars)+'...';
                      txtW :=Canvas.TextWidth(ACaption);
                 end;
             end;
  end;

  procedure drawText;
  Var
     ATop, ALeft,
     DTop, DLeft,
     AWidth, AHeight,
     txtW, txtH   :Integer;

  begin
    txtH :=Canvas.TextHeight(xCaption);
    AWidth :=paintRect.Right-2;
    AHeight :=paintRect.Bottom-2;

    Case TMyRollOut(Owner).FButtonPosition of
    akTop,
    akBottom : begin
                    Canvas.Font.Orientation := 0;

                    ATop :=middleY-(txtH div 2);

                    if (rGlyphLayout <> glNone) then
                    begin
                        if (rTextLayout = tlCenter)
                        then dec(AWidth, rGlyph.Glyph.Width*2+4)
                        else dec(AWidth, rGlyph.Glyph.Width+2)
                     end;

                    CalcCuttedCaption(xCaption, txtW, AWidth);
                    (* Original Code, Test Speed
                    if (txtW > AWidth)
                    then begin
                              txtMaxChars :=Canvas.TextFitInfo(xCaption, AWidth);
                              xCaption :=Copy(xCaption, 0, txtMaxChars-3)+'...';
                              txtW :=Canvas.TextWidth(xCaption);
                              if (txtW > AWidth)
                              then xCaption :='';
                          end;
                    *)
                    Case rTextLayout of
                    tlLeft :begin
                                  ALeft :=4;
                                  if (rGlyphLayout = glLeft)
                                  then inc(ALeft, rGlyph.Glyph.Width+2);
                             end;
                    tlRight:begin
                                 ALeft :=AWidth-txtW;
                                 if (rGlyphLayout = glLeft)
                                 then inc(ALeft, rGlyph.Glyph.Width+2);
                             end;
                    tlCenter:begin
                                  ALeft :=middleX-(txtW div 2);
                              end;
                    end;

                    //Disabled Position
                    DTop :=ATop+1;
                    DLeft :=ALeft+1;
                end;
    akLeft : begin
                  //Vertically from Bottom to Top
                  Canvas.Font.Orientation := 900;

                  ALeft:=middleX-(txtH div 2);

                  if (rGlyphLayout <> glNone) then
                  begin
                     if (rTextLayout = tlCenter)
                     then dec(AHeight, rGlyph.Glyph.Height*2+4)
                     else dec(AHeight, rGlyph.Glyph.Height+2)
                  end;

                  //Vertically the Max Width is Height
                  CalcCuttedCaption(xCaption, txtW, AHeight);

                  Case rTextLayout of
                  tlLeft :begin   //To Bottom of the ClientRect
                               ATop :=AHeight;

                               if (rGlyphLayout = glRight)
                               then inc(ATop, rGlyph.Glyph.Height+2);
                           end;
                  tlRight:begin  //To Top of the ClientRect
                               ATop :=txtW+4;
                               if (rGlyphLayout = glRight)
                               then inc(ATop, rGlyph.Glyph.Height+2);
                           end;
                  tlCenter:begin
                                ATop :=middleY+(txtW div 2);
                            end;
                  end;

                  //Disabled Position
                  DTop :=ATop-1;
                  DLeft :=ALeft+1;
              end;
    akRight : begin
                  //Vertically from Top to Bottom
                  Canvas.Font.Orientation := -900;

                  ALeft:=middleX+(txtH div 2);

                  if (rGlyphLayout <> glNone) then
                  begin
                     if (rTextLayout = tlCenter)
                     then dec(AHeight, rGlyph.Glyph.Height*2+4)
                     else dec(AHeight, rGlyph.Glyph.Height+2)
                  end;

                  CalcCuttedCaption(xCaption, txtW, AHeight);

                  Case rTextLayout of
                  tlLeft :begin  //To Top of the ClientRect
                               ATop :=4;

                               if (rGlyphLayout = glLeft)
                               then inc(ATop, rGlyph.Glyph.Height+2);
                           end;
                  tlRight:begin  //To Bottom of the ClientRect
                               ATop :=AHeight-txtW;
                               if (rGlyphLayout = glLeft)
                               then inc(ATop, rGlyph.Glyph.Height+2);
                           end;
                  tlCenter:begin
                                ATop :=middleY-(txtW div 2);
                            end;
                  end;

                  //Disabled Position
                  DTop :=ATop+1;
                  DLeft :=ALeft-1;
              end;
    end;

    if (xCaption <> '') then
    begin
         if (FState = bsDisabled)
         then begin
                   Canvas.Font.Color := clBtnHighlight;
                   Canvas.TextOut(DLeft, DTop, xCaption);
                   Canvas.Font.Color := clBtnShadow;
               end
         else Canvas.Font.Color := Font.Color;

         Canvas.TextOut(ALeft, ATop, xCaption);
    end;
  end;

begin
  paintRect :=GetClientRect;

  {$ifdef DEBUG_PAINT}
    Canvas.Brush.Color:=clYellow;
    Canvas.Brush.Style:=bsSolid;
    Canvas.FillRect(paintRect);
  {$endif}

  middleY :=paintRect.Top+((paintRect.Bottom-paintRect.Top) div 2);
  middleX :=paintRect.Left+((paintRect.Right-paintRect.Left) div 2);

  if TMyRollOut(Owner).FCollapsed
  then xColor :=Self.Color
  else xColor :=rColorExpanded;

  xCaption :=Caption;

  Case FState of
  Buttons.bsHot:begin
                     if (rColorHighlight = clDefault)
                     then xHColor :=GetHighlightColor(xColor, 120)
                     else xHColor :=rColorHighlight;

                     if (rColorShadow = clDefault)
                     then xSColor :=GetShadowColor(xColor, 40)
                     else xSColor :=rColorShadow;

                     xColor :=GetHighlightColor(xColor, 20);
                     drawUP;
                end;
  Buttons.bsDown:begin
                      if (rColorHighlight = clDefault)
                      then xHColor :=GetHighlightColor(xColor, 60)
                      else xHColor :=rColorHighlight;

                      if (rColorShadow = clDefault)
                      then xSColor :=GetShadowColor(xColor, 60)
                      else xSColor :=rColorShadow;

                      xColor :=GetHighlightColor(xColor, 20);
                      drawDOWN;

                  end;
  else begin
            if (FState = bsDisabled)
            then xColor :=GrayScale(xColor);

            if (rColorHighlight = clDefault)
            then xHColor :=GetHighlightColor(xColor, 60)
            else xHColor :=rColorHighlight;

            if (rColorShadow = clDefault)
            then xSColor :=GetShadowColor(xColor, 60)
            else xSColor :=rColorShadow;

            if Flat
            then drawFLAT
            else drawUP;
        end;
  end;

  if (rGlyphLayout <> glNone)
  then drawButton(TMyRollOut(Owner).Collapsed, glyphTop, glyphLeft)
  else begin
            glyphTop :=0;
            glyphLeft:=0;
        end;

  if (rTextLayout <> tlNone) and (xCaption <> '')
  then drawText;
end;

procedure TBoundButton.Loaded;
begin
  inherited Loaded;

  if not(csDesigning in ComponentState) then
  begin
       //IF Used Outside TMyRollout
       if not(Owner is TMyRollout)
       then BuildGlyphs;
  end;
end;

constructor TBoundButton.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  Color :=clSkyBlue;
  rColorExpanded := RGBToColor(23, 136, 248);
  rColorHighlight :=clDefault;
  rColorShadow :=clDefault;
  rGlyphLayout :=glNone;
  rTextLayout :=tlLeft;
  rLineShow :=False;
  Flat :=False;

  //Why FGlyph is Private in ancestor?????
  rGlyph := TButtonGlyph.Create;
  rGlyph.IsDesigning := csDesigning in ComponentState;
  rGlyph.ShowMode := gsmAlways;

  rGlyphExpanded :=TBitmap.Create;
  rGlyphExpanded.Transparent := True;
  rGlyphCollapsed :=TBitmap.Create;
  rGlyphCollapsed.Transparent := True;
  rUserGlyphExpanded :=TBitmap.Create;
  rUserGlyphExpanded.Transparent := True;
  rUserGlyphCollapsed :=TBitmap.Create;
  rUserGlyphCollapsed.Transparent := True;

  SetSubComponent((Owner is TMyRollout));
//  ControlStyle := ControlStyle + [csNoFocus, csNoDesignSelectable];
end;

destructor TBoundButton.Destroy;
begin
  FreeAndNil(rGlyphExpanded);
  FreeAndNil(rGlyphCollapsed);
  FreeAndNil(rUserGlyphExpanded);
  FreeAndNil(rUserGlyphCollapsed);
  FreeAndNil(rGlyph);
  inherited Destroy;
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

  //Using Self.Panel(index) avoid the compiler misundersted between the Method and TMyRollOutSubPanel
  h   := RelevantAbove(Self.Panel(0));
  max := RelevantSize(Self.Panel(0).Parent);

  for i := 0 to Count - 1 do
    if h + RelevantSize(Self.Panel(i)) > max then
      with Self.Panel(i) do
        begin
        tempanimated := Animated;
        Animated     := False;
        Collapsed    := True;
        Animated     := tempanimated;

        h := h + TMyRollOut(Self.Panel(i)).ButtonSize;
        end
    else
      h := h + RelevantSize(Self.Panel(i));
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
  debugln('TMyRollOut.setCollapsed '+BoolToStr(Collapsed, True));
{$ENDIF}

  if FCollapsed = Value then
    exit;

  FCollapsed := Value;

  if not(csLoading in ComponentState)
  then if Value
       then DoCollapse
       else DoExpand;
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

procedure TMyRollOut.SetRelevantSize(comp: TControl; AKind: TAnchorKind; ASize: Integer);
begin
  case AKind of
    akTop, akBottom: comp.Height :=ASize;
    akLeft, akRight: comp.Width :=ASize;
  end;
end;

procedure TMyRollOut.CalculateAnimValues;
var
   tInterval: Cardinal;
   aSteps, aSize: Word;

begin
  //Calculate The Number of Steps to do given AnimationMinDelta pixels
  aSize :=FExpandedSize-FButtonSize;
  anim_delta :=AnimationMinDelta;
  aSteps :=aSize div AnimationMinDelta;
  if ((aSize mod AnimationMinDelta) > 0)
  then inc(aSteps);

  tInterval :=FAnimationTotalTime div aSteps;
  if (tInterval < AnimationMinInterval) then
  begin
    //If the Interval is too fast for this CPU Increment the Delta
    tInterval :=AnimationMinInterval;
    aSteps :=FAnimationTotalTime div AnimationMinInterval;
    anim_delta :=aSize div aSteps; //if there is a rest the Animation will last more
  end;

  Timer.Interval:=tInterval;
end;

procedure TMyRollOut.AnimateCollapse(Sender: TObject);
var
   Stop, p_Stop: Boolean;
   b_rect, old_b_rect, p_rect: TRect;

begin
  inc(anim_step);

  b_rect :=BoundsRect;
  p_rect :=rPanel.BoundsRect;
  //Bottom is really the Height and Right is really the Width
  p_rect.Bottom :=p_rect.Bottom-p_rect.Top;
  b_rect.Bottom :=b_rect.Bottom-b_rect.Top;
  p_rect.Right :=p_rect.Right-p_rect.Left;
  b_rect.Right :=b_rect.Right-b_rect.Left;
  old_b_rect :=b_rect; //Used to generate OnAnimate events with deltas

  Case FCollapseKind of
  akTop: begin
           Stop :=((b_rect.Bottom-anim_delta) <= anim_CollapsedSize);
           if Stop
           then b_rect.Bottom :=anim_CollapsedSize
           else begin
                  //The First Time Decrease only the SubPanel Height so we have space for Animation
                  if (Sender <> nil)
                  then dec(b_rect.Bottom, anim_delta);

                  dec(p_rect.Bottom, anim_delta);
                  p_Stop :=(p_rect.Bottom < 2);
                end;
         end;
  akBottom: begin
              Stop :=((b_rect.Bottom-anim_delta) <= anim_CollapsedSize);
              if Stop
              then begin           //Return to real Bottom
                     b_rect.Top :=(b_rect.Bottom+b_rect.Top)-anim_CollapsedSize;
                     b_rect.Bottom :=anim_CollapsedSize;
                    end
              else begin
                     //The First Time Increase only the Top of SubPanel so we have space for Animation
                     if (Sender <> nil)
                     then begin
                            inc(b_rect.Top, anim_delta);
                            dec(b_rect.Bottom, anim_delta);
                           end
                     else inc(p_rect.Top, anim_delta);

                     dec(p_rect.Bottom, anim_delta);
                     p_Stop :=(p_rect.Bottom < 2);
                   end;
            end;
  akLeft: begin
            Stop :=((b_rect.Right-anim_delta) <= anim_CollapsedSize);
            if Stop
            then b_rect.Right :=anim_CollapsedSize
            else begin
                   //The First Time Decrease only the SubPanel Right so we have space for Animation
                   if (Sender <> nil)
                   then dec(b_rect.Right, anim_delta);

                   dec(p_rect.Right, anim_delta);
                   p_Stop :=(p_rect.Right < 2);
                 end;
          end;
  akRight: begin
             Stop :=((b_rect.Right-anim_delta) <= anim_CollapsedSize);
             if Stop
             then begin           //Return to real Right
                    b_rect.Left :=(b_rect.Right+b_rect.Left)-anim_CollapsedSize;
                    b_rect.Right :=anim_CollapsedSize;
                   end
             else begin
                    //The First Time Increase only the Left of SubPanel so we have space for Animation
                    if (Sender <> nil)
                    then begin
                           inc(b_rect.Left, anim_delta);
                           dec(b_rect.Right, anim_delta);
                          end
                    else inc(p_rect.Left, anim_delta);

                    dec(p_rect.Right, anim_delta);
                    p_Stop :=(p_rect.Right < 2);
                  end;
           end;
  end;

  //MaxM: Do not optimize this MUST be in this order
  if Stop
  then begin
         FAnimating :=False;
         //rPanel.Visible :=False;

         //Now PositionButtonAndPanel is Called and the Panel is in the right position
         SetBounds(b_rect.Left, b_rect.Top, b_rect.Right, b_rect.Bottom);
         {$ifdef DEBUG_PAINT_SIM_ANIM}
          if Assigned(Timer.OnStopTimer) then Timer.OnStopTimer(nil);
         {$endif}
        end
  else begin
         FAnimating :=True;

         //if the Sub-Panel have a small size (tipically) is over the Button, make invisible to avoid Paint
         if p_Stop
         then rPanel.Visible :=False
         else rPanel.SetBounds(p_rect.Left, p_rect.Top, p_rect.Right, p_rect.Bottom);

         SetBounds(b_rect.Left, b_rect.Top, b_rect.Right, b_rect.Bottom);
        end;

//if (Sender <> nil) then
//begin
  if Assigned(FInternalOnAnimate)
  then FInternalOnAnimate(Self, b_rect.Left-old_b_rect.Left, b_rect.Top-old_b_rect.Top,
                          b_rect.Right-old_b_rect.Right, b_rect.Bottom-old_b_rect.Bottom);
  if Assigned(FOnAnimate)
  then FOnAnimate(Self, b_rect.Left-old_b_rect.Left, b_rect.Top-old_b_rect.Top,
                  b_rect.Right-old_b_rect.Right, b_rect.Bottom-old_b_rect.Bottom);
//end;

  {$ifndef DEBUG_PAINT_SIM_ANIM}
  Timer.Enabled :=FAnimating;
  {$endif}
end;

procedure TMyRollOut.AnimateExpand(Sender: TObject);
var
   Stop, b_Stop: Boolean;
   b_rect, old_b_rect, p_rect: TRect;
   delta: Integer;

begin
  inc(anim_step);

  b_rect :=BoundsRect;
  p_rect :=rPanel.BoundsRect;
  //Bottom is really the Height and Right is really the Width
  p_rect.Bottom :=p_rect.Bottom-p_rect.Top;
  b_rect.Bottom :=b_rect.Bottom-b_rect.Top;
  p_rect.Right :=p_rect.Right-p_rect.Left;
  b_rect.Right :=b_rect.Right-b_rect.Left;
  old_b_rect :=b_rect; //Used to generate OnAnimate events with deltas

  Case FCollapseKind of
  akTop: begin
           b_Stop :=((b_rect.Bottom+anim_delta) >= FExpandedSize);
           Stop :=((p_rect.Bottom+anim_delta) >= (FExpandedSize-FButtonSize));

           if b_Stop
           then b_rect.Bottom :=FExpandedSize
           else inc(b_rect.Bottom, anim_delta);

           if not(Stop) then
           begin
             //Increase the SubPanel from the second step so we have space for Animation
             if (Sender <> nil)
             then begin
                    if not(rPanel.Visible)
                    then p_rect.Bottom :=anim_delta //When we are Collapsed the SubPanel height is 1 pixel because LCL don't accept height=0 and correct it
                    else inc(p_rect.Bottom, anim_delta);
                  end;
           end;
         end;
  akBottom: begin
              b_Stop :=((b_rect.Bottom+anim_delta) >= FExpandedSize);
              Stop :=((p_rect.Bottom+anim_delta) >= (FExpandedSize-FButtonSize));

              if b_Stop
              then begin
                     //When the ExpandedSize is not a mux of anim_delta we may have a rest
                     delta :=FExpandedSize-b_rect.Bottom;
                     dec(b_rect.Top, delta);
                     b_rect.Bottom :=FExpandedSize;
                    end
              else begin
                     dec(b_rect.Top, anim_delta);
                     inc(b_rect.Bottom, anim_delta);
                   end;

              if not(Stop) then
              begin
                //The First Time Increase only the Top of SubPanel so we have space for Animation
                if (Sender = nil)
                then inc(p_rect.Top, anim_delta)
                else begin
                       if not(rPanel.Visible)
                       then p_rect.Bottom :=0; //When we are Collapsed the SubPanel height is 1 pixel because LCL don't accept height=0 and correct it

                       if b_Stop
                       then p_rect.Top:=delta;
                       inc(p_rect.Bottom, anim_delta);
                     end;
              end;
            end;
  akLeft: begin
            b_Stop :=((b_rect.Right+anim_delta) >= FExpandedSize);
            Stop :=((p_rect.Right+anim_delta) >= (FExpandedSize-FButtonSize));

            if b_Stop
            then b_rect.Right :=FExpandedSize
            else inc(b_rect.Right, anim_delta);

            if not(Stop) then
            begin
              //Increase the SubPanel from the second step so we have space for Animation
              if (Sender <> nil)
              then begin
                     if not(rPanel.Visible)
                     then p_rect.Right :=anim_delta
                     else inc(p_rect.Right, anim_delta);
                   end;
            end;
          end;
  akRight: begin
             b_Stop :=((b_rect.Right+anim_delta) >= FExpandedSize);
             Stop :=((p_rect.Right+anim_delta) >= (FExpandedSize-FButtonSize));

             if b_Stop
             then begin
                    delta :=FExpandedSize-b_rect.Right;
                    dec(b_rect.Left, delta);
                    b_rect.Right :=FExpandedSize;
                   end
             else begin
                    dec(b_rect.Left, anim_delta);
                    inc(b_rect.Right, anim_delta);
                  end;

             if not(Stop) then
             begin
               //The First Time Increase only the Left of SubPanel so we have space for Animation
               if (Sender = nil)
               then inc(p_rect.Left, anim_delta)
               else begin
                      if not(rPanel.Visible)
                      then p_rect.Right :=0;

                      if b_Stop
                      then p_rect.Left:=delta;
                      inc(p_rect.Right, anim_delta);
                    end;
             end;
           end;
  end;

  //MaxM: Do not optimize this MUST be in this order
  if Stop
  then begin
         FAnimating :=False;

         //Now PositionButtonAndPanel is Called and the Panel is in the right position
         SetBounds(b_rect.Left, b_rect.Top, b_rect.Right, b_rect.Bottom);

         {$ifdef DEBUG_PAINT_SIM_ANIM}
          if Assigned(Timer.OnStopTimer) then Timer.OnStopTimer(nil);
         {$endif}
        end
  else begin
         FAnimating :=True;

         SetBounds(b_rect.Left, b_rect.Top, b_rect.Right, b_rect.Bottom);
         rPanel.SetBounds(p_rect.Left, p_rect.Top, p_rect.Right, p_rect.Bottom);
         rPanel.Visible :=(Sender <> nil) or FAnimating_Partial;
       end;

//if not(Stop) then
//begin
  if Assigned(FInternalOnAnimate)
  then FInternalOnAnimate(Self, b_rect.Left-old_b_rect.Left, b_rect.Top-old_b_rect.Top,
                          b_rect.Right-old_b_rect.Right, b_rect.Bottom-old_b_rect.Bottom);
  if Assigned(FOnAnimate)
  then FOnAnimate(Self, b_rect.Left-old_b_rect.Left, b_rect.Top-old_b_rect.Top,
                  b_rect.Right-old_b_rect.Right, b_rect.Bottom-old_b_rect.Bottom);
//end;

  {$ifndef DEBUG_PAINT_SIM_ANIM}
  Timer.Enabled :=FAnimating;
  {$endif}
end;

procedure TMyRollOut.EndTimerCollapse(Sender: TObject);
begin
  FCollapsed :=True;
  rPanel.Visible:=False; //Avoid Drawing Over the Button

  if Assigned(FOnCollapse) then
    FOnCollapse(Self);

  UpdateAll;
end;

procedure TMyRollOut.EndTimerExpand(Sender: TObject);
begin
  FCollapsed :=False;
  rPanel.Visible:=True;

  if Assigned(FOnExpand) then
    FOnExpand(Self);

  UpdateAll;
end;


procedure TMyRollOut.UpdateAll;
begin
  Update;
  //FButton.Update;
end;

procedure TMyRollOut.setExpandedSize(Value: integer);
begin
  {$IFDEF DebugInfo}
  debugln('TMyRollOut.setExpandedSize '+IntToStr(Value));
  {$ENDIF}

  if (FExpandedSize = Value) then
    exit;

  if not(FCollapsed) and not(csLoading in ComponentState) then
  begin
    if (csDesigning in ComponentState)
    then begin
           FExpandedSize :=Value;
           SetRelevantSize(Self, FCollapseKind, FExpandedSize);
          end
    else begin
           if (Value > FExpandedSize)
           then begin
                  FExpandedSize :=Value;
                  DoExpand(True);
                end
           else begin
                  FExpandedSize :=Value;
                  DoCollapse(True);
                end;
         end;
   end
  else FExpandedSize :=Value;
end;

function TMyRollOut.GetEnabled: Boolean;
begin
     Result :=inherited Enabled;
     if (FButton.Enabled <> Result) //Paranoic Think
     then FButton.Enabled :=Result;
end;

function TMyRollOut.GetBevelInner: TPanelBevel;
begin
  Result :=rPanel.BevelInner;
end;

function TMyRollOut.GetBevelOuter: TPanelBevel;
begin
  Result :=rPanel.BevelOuter;
end;

function TMyRollOut.GetBevelWidth: TBevelWidth;
begin
  Result :=rPanel.BevelWidth;
end;

procedure TMyRollOut.SetBevelInner(AValue: TPanelBevel);
begin
  rPanel.BevelInner :=AValue;
end;

procedure TMyRollOut.SetBevelOuter(AValue: TPanelBevel);
begin
  rPanel.BevelOuter :=AValue;
end;

procedure TMyRollOut.SetBevelWidth(AValue: TBevelWidth);
begin
  rPanel.BevelWidth :=AValue;
end;

procedure TMyRollOut.setAnimationTotalTime(AValue: Cardinal);
begin
  if (FAnimationTotalTime <> AValue) then
  begin
    FAnimationTotalTime := AValue;
    if not(csLoading in ComponentState)
    then CalculateAnimValues;
  end;
end;

procedure TMyRollOut.SetEnabled(AValue: Boolean);
begin
     inherited Enabled :=AValue;
     FButton.Enabled :=AValue;
end;

procedure TMyRollOut.setButtonSize(Value: integer);
begin
  if FButtonSize = Value then
    exit;

  FButtonSize := Value;

  PositionButtonAndPanel;
end;


procedure TMyRollOut.SetBounds(ALeft, ATop, AWidth, AHeight: integer);
begin
  inherited SetBounds(ALeft, ATop, AWidth, AHeight);

  if not(StopCircleActions) and not(FAnimating) and not(csLoading in ComponentState) then
  begin
    if (csDesigning in ComponentState)
    then begin
           if FCollapsed
           then FButtonSize :=RelevantSize(Self, FButtonPosition)
           else FExpandedSize :=RelevantSize(Self, FCollapseKind);
         end;

    PositionButtonAndPanel;
  end;
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
  PositionButtonAndPanel;

  Collapsed := wascollpased;
  Animated  := wasanimated;

  Invalidate;
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

  if not(csLoading in ComponentState) then
  begin
       FButton.BuildGlyphs;
       FButton.Invalidate;
  end;

  Collapsed := wascollpased;

  Animated := wasanimated;
end;

procedure TMyRollOut.setAnimationSpeed(Value: real);
begin
  korrigiere(Value, 3, 1000);
  FAnimationSpeed := Value;
end;




procedure TMyRollOut.PositionButtonAndPanel;
var
  ButtonRect, PanelRect: TRect;

begin
  //MaxM: Why is Called 2 Times ??

  if StopCircleActions or (csLoading in ComponentState)
  then exit;

  StopCircleActions := True;

  {$ifdef DEBUGINFO}
    ButtonRect :=FButton.BoundsRect;
    PanelRect :=rPanel.BoundsRect;
  {$EndIf}

  case FButtonPosition of
  akTop :begin
           ButtonRect :=Rect(0, 0, Self.Width, FButtonSize);
           PanelRect :=Rect(0, FButtonSize, Self.Width, Self.Height);
         end;
  akLeft :begin
            ButtonRect :=Rect(0, 0, FButtonSize, Self.Height);
            PanelRect :=Rect(FButtonSize, 0, Self.Width, Self.Height);
          end;
  akBottom :begin
              ButtonRect :=Rect(0, Self.Height-FButtonSize, Self.Width, Self.Height);
              PanelRect :=Rect(0, 0, Self.Width, Self.Height-FButtonSize);
            end;
  akRight :begin
             ButtonRect :=Rect(Self.Width-FButtonSize, 0, Self.Width, Self.Height);
             PanelRect :=Rect(0, 0, Self.Width-FButtonSize, Self.Height);
           end;
  end;

  FButton.BoundsRect :=ButtonRect;
  rPanel.BoundsRect :=PanelRect;

  //set anchors
  case FButtonPosition of
  akBottom: FButton.Anchors := [akTop, akLeft, akBottom, akRight] - [akTop];
  akLeft: FButton.Anchors   := [akTop, akLeft, akBottom, akRight] - [akRight];
  akTop: FButton.Anchors    := [akTop, akLeft, akBottom, akRight] - [akBottom];
  akRight: FButton.Anchors  := [akTop, akLeft, akBottom, akRight] - [akLeft];
  (* MaxM: Now we can use Align intestead????
  akTop: FButton.Align:=alTop;
  akLeft: FButton.Align:=alLeft;
  akBottom: FButton.Align:=alBottom;
  akRight: FButton.Align:=alRight;
  *)
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

procedure TMyRollOut.DoCollapse(isPartial: Boolean);
var
   b_rect: TRect;

begin
  if assigned(OnPreCollapse) then
    OnPreCollapse(self);

{$IFDEF DebugInfo}
  debugln('TMyRollOut.DoCollapse FButtonSize=' + IntToStr(FButtonSize));
{$ENDIF}

  Timer.Enabled:=False;

  if FAnimated and not(csDesigning in ComponentState) then
  begin
    //If is a Partial Collapse (Setting the ExpandedSize) use the maximum speed and Stop on FExpandedSize
    if isPartial
    then begin
           Timer.Interval:=AnimationMinInterval;
           anim_delta:=AnimationMinDelta;
           Timer.OnStopTimer:=nil;
           anim_CollapsedSize :=FExpandedSize;
         end
    else begin
           CalculateAnimValues;
           Timer.OnStopTimer:=@EndTimerCollapse;
           anim_CollapsedSize :=FButtonSize;
         end;
    Timer.OnTimer:=@AnimateCollapse;
    anim_step :=0;
    FAnimating:=True;
    FAnimating_Collapsing :=True;
    FAnimating_Partial :=isPartial;

    //Prepare The Sub-Panel size so we have space to do animation (no space needed if AnimationEffectKind = ekNone)
    //the animation will start too
    if (rAnimationEffectKind = ekNone)
    then AnimateCollapse(Self)
    else AnimateCollapse(nil);
   end
  else begin
         FAnimating:=False;
         b_rect :=BoundsRect;

{ TODO 5 : MaxM: akRight, akBottom May result in a negative Value so we must correct it, in wich way? }
         Case FCollapseKind of
         akTop: b_rect.Bottom :=b_rect.Top+FButtonSize;
         akLeft: b_rect.Right :=b_rect.Left+FButtonSize;
         akRight: b_rect.Left :=b_rect.Right-FButtonSize;
         akBottom: b_rect.Top :=b_rect.Bottom-FButtonSize;
         end;

         BoundsRect :=b_rect;

         if not(isPartial)
         then EndTimerCollapse(nil);
       end;
end;

procedure TMyRollOut.DoExpand(isPartial: Boolean);
var
   b_rect: TRect;

begin
  if assigned(OnPreExpand) then
    OnPreExpand(self);

{$IFDEF DebugInfo}
  debugln('TMyRollOut.DoExpand FExpandedSize=' + IntToStr(FExpandedSize));
{$ENDIF}

  Timer.Enabled:=False;

  if FAnimated and not(csDesigning in ComponentState) then
  begin
    //If is a Partial Expand (Setting the ExpandedSize) use the maximum speed
    if isPartial
    then begin
           Timer.Interval:=AnimationMinInterval;
           anim_delta:=AnimationMinDelta;
           Timer.OnStopTimer:=nil;
          end
    else begin
           CalculateAnimValues;
           Timer.OnStopTimer:=@EndTimerExpand;
         end;
    Timer.OnTimer:=@AnimateExpand;
    anim_step :=0;
    FAnimating:=True;
    FAnimating_Collapsing :=False;
    FAnimating_Partial :=isPartial;

    //Prepare The Sub-Panel size so we have space to do animation (no space needed if AnimationEffectKind = ekNone)
    //the animation will start too
    if (rAnimationEffectKind = ekNone)
    then AnimateExpand(Self)
    else AnimateExpand(nil);
  end
  else begin
         FAnimating:=False;
         b_rect :=BoundsRect;

{ TODO 5 : MaxM: akRight, akBottom May result in a negative Value so we must correct it, in wich way? }
         Case FCollapseKind of
         akTop: b_rect.Bottom :=b_rect.Top+FExpandedSize;
         akLeft: b_rect.Right :=b_rect.Left+FExpandedSize;
         akRight: b_rect.Left :=b_rect.Right-FExpandedSize;
         akBottom: b_rect.Top :=b_rect.Bottom-FExpandedSize;
         end;

         BoundsRect :=b_rect;

         if not(isPartial)
         then EndTimerExpand(nil);
       end;
end;


procedure TMyRollOut.AdjustClientRect(var ARect: TRect);
begin
  inherited AdjustClientRect(ARect);

  (*  MaxM: May be useful in DesignTime?
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
      *)
end;

procedure TMyRollOut.MoveControlsToSubPanel;
var
   i: Integer;
   curControl: TControl;

begin
  {$IFDEF DebugInfo}DebugLn('TMyRollOut.MoveControlsToSubPanel');{$endif}

  i :=0;
  while (i < ControlCount) do
  begin
    curControl :=Controls[i];

    if ((curControl is TBoundButton) or (curControl is TMyRollOutSubPanel))
    then inc(i)
    else
    begin
      {$ifdef DebugInfo}DebugLn('  moving '+curControl.Name+':'+curControl.ClassName);{$endif}

      curControl.Parent :=rPanel;
      Case FButtonPosition of
      akTop: curControl.Top :=max(curControl.Top-FButtonSize, 0);
      akLeft: curControl.Left :=max(curControl.Left-FButtonSize, 0);
      //Bottom and Right maybe in correct position
      end;
    end;
  end;
end;

(*
MaxM: Tested for move Components during design Time directly to SubPanel but don't work in any way

function TMyRollOut.DSGN_AddClicked(ADesigner: TIDesigner;
  MouseDownComponent: TComponent; Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer; var AComponentClass: TComponentClass; var NewParent: TComponent
  ): boolean;
begin
  if (MouseDownComponent = Self) then
  begin
     DebugLn('TMyRollOut.DSGN_AddClicked MouseDownComponent=', MouseDownComponent.Name+':'+MouseDownComponent.ClassName,
             ' X,Y=', IntToStr(X)+','+IntToStr(Y),
             ' AComponentClass=', AComponentClass.ClassName);
     if (NewParent=nil)
     then DebugLn('TMyRollOut.DSGN_AddClicked NewParent=NIL')
     else DebugLn('TMyRollOut.DSGN_AddClicked NewParent='+NewParent.Name+':'+NewParent.ClassName);

     new_comp :=True;
     NewParent :=rPanel;
   end;

   Result :=True;
end;
*)

procedure TMyRollOut.Loaded;
begin
  {$ifdef DebugInfo}DebugLn('TMyRollOut.Loaded');{$endif}

  inherited Loaded;
end;

procedure TMyRollOut.CreateWnd;
begin
  {$ifdef DebugInfo}DebugLn('TMyRollOut.CreateWnd');{$endif}

  inherited CreateWnd;

  FButton.BuildGlyphs; //Button Loaded is called Before Self.Loaded and cannot Build Glyphs

  inherited BevelWidth:=0;
  PositionButtonAndPanel;

  if not(csDesigning in ComponentState) then
  begin
       MoveControlsToSubPanel;
       rPanel.Visible :=not(FCollapsed);
  end;

  CalculateAnimValues;
  anim_CollapsedSize :=FButtonSize;
end;

procedure TMyRollOut.Paint;
var
  ARect, PRect: TRect;
  TS: TTextStyle;
  gfDirection: TGradientDirection;

begin
  if (csDesigning in ComponentState) then
  with rPanel do
  begin
    //Do Here the SubPanel Paint because in DesignTime is Invisible (see Create Note)
    ARect := rPanel.BoundsRect;

    // if BevelOuter is set then draw a frame with BevelWidth
    if (BevelOuter <> bvNone)
    then if rBevelRounded
         then Frame3d_Rounded(Self.Canvas, ARect, BevelWidth, 5, 5, BevelOuter, rColorShadow, rColorHighlight, Color)
         else Self.Canvas.Frame3d(ARect, BevelWidth, BevelOuter);

    InflateRect(ARect, -BorderWidth, -BorderWidth);

    // if BevelInner is set then skip the BorderWidth and draw a frame with BevelWidth
    if (BevelInner <> bvNone)
    then if rBevelRounded
         then Frame3d_Rounded(Self.Canvas, ARect, BevelWidth, 5, 5, BevelInner, rColorShadow, rColorHighlight, Color)
         else Self.Canvas.Frame3d(ARect, BevelWidth, BevelInner);

    if (Self.Caption <> '') then
    begin
      TS := Canvas.TextStyle;
      TS.Alignment := BidiFlipAlignment(Self.Alignment, UseRightToLeftAlignment);
      if (BiDiMode <> bdLeftToRight)
      then TS.RightToLeft:= True;
      TS.Layout:= Graphics.tlCenter;
      TS.Opaque:= false;
      TS.Clipping:= false;
      TS.SystemFont:=Canvas.Font.IsDefault;
      if not(Enabled) then
      begin
        Canvas.Font.Color := clBtnHighlight;
        OffsetRect(ARect, 1, 1);
        Self.Canvas.TextRect(ARect, ARect.Left, ARect.Top, Self.Caption, TS);
        Self.Canvas.Font.Color := clBtnShadow;
        OffsetRect(ARect, -1, -1);
       end
      else Self.Canvas.Font.Color := Font.Color;

      Self.Canvas.TextRect(ARect,ARect.Left,ARect.Top, Self.Caption, TS);
    end;
   end
  else
  if FAnimating and not(rAnimationEffectKind = ekNone) then
  begin
    //Calculate the Remaing Rect (between The Sub-Panel and Self)
    PRect := rPanel.BoundsRect;
    ARect := Self.ClientRect;

    {$ifdef DEBUG_PAINT}
     Canvas.Brush.Color:=clMaroon;
     Canvas.Brush.Style:=bsSolid;
     Canvas.FillRect(ARect);
    {$endif}

    Case FCollapseKind of
    akTop: begin
             ARect.Left :=PRect.Left;
             ARect.Right :=PRect.Right;

             if rPanel.Visible
             then ARect.Top :=PRect.Bottom
             else ARect.Top :=PRect.Top; //When the Panel is Invisible use All height

             gfDirection :=gdVertical;
           end;
    akBottom: begin
                ARect.Left :=PRect.Left;
                ARect.Right :=PRect.Right;

                if rPanel.Visible
                then ARect.Bottom :=PRect.Top
                else ARect.Bottom :=PRect.Bottom;
                gfDirection :=gdVertical;
              end;
    akLeft: begin
              ARect.Top :=PRect.Top;
              ARect.Bottom :=PRect.Bottom;

              if rPanel.Visible
              then ARect.Left :=PRect.Right
              else ARect.Left :=PRect.Left; //When the Panel is Invisible use All width

              gfDirection :=gdHorizontal;
            end;
    akRight: begin
               ARect.Top :=PRect.Top;
               ARect.Bottom :=PRect.Bottom;

               if rPanel.Visible
               then ARect.Right :=PRect.Left
               else ARect.Right :=PRect.Right;

               gfDirection :=gdHorizontal;
             end;
    end;

    {$ifdef DEBUG_PAINT}
      Canvas.GradientFill(ARect, clGreen, clLime, gfDirection) ;
    {$else}
      Paint_Effect(Canvas, ARect, gfDirection);
    {$endif}
  end;
end;

procedure TMyRollOut.Paint_Effect(ACanvas: TCanvas; ARect: TRect; gfDirection: TGradientDirection);
var
   totalHeight, slice : Cardinal;
   WRect: TRect;
   cH, cS: TColor;

   //MaxM: GradientFill never Draw the Stop Color so we do a Gradient
   //  in a smallest Rectangle (-1pixel) and Draw the last pixel with Stop Color
   procedure GradientV(AStart, AStop: TColor);
   begin
     dec(WRect.Bottom);
     ACanvas.GradientFill(WRect, AStart, AStop, gdVertical);
     ACanvas.Pen.Color :=AStop;
     ACanvas.MoveTo(WRect.Left, WRect.Bottom);
     ACanvas.LineTo(WRect.Right, WRect.Bottom);
     inc(WRect.Bottom);
   end;

   procedure GradientH(AStart, AStop: TColor);
   begin
     dec(WRect.Right);
     ACanvas.GradientFill(WRect, AStart, AStop, gdHorizontal);
     ACanvas.Pen.Color :=AStop;
     ACanvas.MoveTo(WRect.Right, WRect.Top);
     ACanvas.LineTo(WRect.Right, WRect.Bottom);
     inc(WRect.Right);
   end;

begin
  WRect :=ARect;

  ACanvas.Pen.Style:=psSolid;
  cH :=rPanel.ColorHighlight;
  cS :=rPanel.ColorShadow;

  //MaxM: Code is Duplicated so we can Optimize the Painting speed
  if (gfDirection = gdVertical)  then
  begin
    totalHeight :=ARect.Bottom-ARect.Top;

    Case rAnimationEffectKind of
    ekFoldingDouble: begin           //            HS-HS-SH
                       slice :=totalHeight div 3; WRect.Bottom :=WRect.Top+slice;
                       GradientV(cH, cS);
                       WRect.Top :=WRect.Bottom; WRect.Bottom :=WRect.Top+slice;
                       GradientV(cH, cS);
                       WRect.Top :=WRect.Bottom; WRect.Bottom :=ARect.Bottom;
                       GradientV(cS, cH);
                     end;
    ekFoldingDown: begin             //            HS-SH-HS
                     slice :=totalHeight div 3; WRect.Bottom :=WRect.Top+slice;
                     GradientV(cH, cS);
                     WRect.Top :=WRect.Bottom; WRect.Bottom :=WRect.Top+slice;
                     GradientV(cS, cH);
                     WRect.Top :=WRect.Bottom; WRect.Bottom :=ARect.Bottom;
                     GradientV(cH, cS);
                   end;
    ekCurtain: begin                 //            HS-HS-HS
                 slice :=totalHeight div 3; WRect.Bottom :=WRect.Top+slice;
                 GradientV(cH, cS);
                 WRect.Top :=WRect.Bottom; WRect.Bottom :=WRect.Top+slice;
                 GradientV(cH, cS);
                 WRect.Top :=WRect.Bottom; WRect.Bottom :=ARect.Bottom;
                 GradientV(cH, cS);
               end;
    ekCurtainPersian: begin          //            SH-SH-SH
                        slice :=totalHeight div 3; WRect.Bottom :=WRect.Top+slice;
                        GradientV(cS, cH);
                        WRect.Top :=WRect.Bottom; WRect.Bottom :=WRect.Top+slice;
                        GradientV(cS, cH);
                        WRect.Top :=WRect.Bottom; WRect.Bottom :=ARect.Bottom;
                        GradientV(cS, cH);
                      end;
    ekWaveDoubleExternal: begin      //  |-> SH-SH-HS         SH-HS-HS <-|
                            slice :=totalHeight div 3; WRect.Bottom :=WRect.Top+slice;
                            if (FCollapseKind = akTop)
                            then begin
                                   GradientV(cS, cH);
                                   WRect.Top :=WRect.Bottom; WRect.Bottom :=WRect.Top+slice;
                                   GradientV(cS, cH);
                                   WRect.Top :=WRect.Bottom; WRect.Bottom :=ARect.Bottom;
                                   GradientV(cH, cS);
                                 end
                            else begin
                                   GradientV(cS, cH);
                                   WRect.Top :=WRect.Bottom; WRect.Bottom :=WRect.Top+slice;
                                   GradientV(cH, cS);
                                   WRect.Top :=WRect.Bottom; WRect.Bottom :=ARect.Bottom;
                                   GradientV(cH, cS);
                                 end;
                          end;
    ekWaveDoubleInternal: begin      //  |-> SH-HS-HS         SH-SH-HS <-|
                            slice :=totalHeight div 3; WRect.Bottom :=WRect.Top+slice;
                            if (FCollapseKind = akTop)
                            then begin
                                   GradientV(cS, cH);
                                   WRect.Top :=WRect.Bottom; WRect.Bottom :=WRect.Top+slice;
                                   GradientV(cH, cS);
                                   WRect.Top :=WRect.Bottom; WRect.Bottom :=ARect.Bottom;
                                   GradientV(cH, cS);
                                  end
                            else begin
                                   GradientV(cS, cH);
                                   WRect.Top :=WRect.Bottom; WRect.Bottom :=WRect.Top+slice;
                                   GradientV(cS, cH);
                                   WRect.Top :=WRect.Bottom; WRect.Bottom :=ARect.Bottom;
                                   GradientV(cH, cS);
                                  end;
                          end;
    //ekWaveInternal,          //  |-> SH-HS-SH     Don't work here|
    ekWave: begin                    //             SH-HS
              slice :=totalHeight div 2; WRect.Bottom :=WRect.Top+slice;
              GradientV(cS, cH);
              WRect.Top :=WRect.Bottom; WRect.Bottom :=ARect.Bottom;
              GradientV(cH, cS);
            end;
    ekWave2: begin                    //             HS-SH
               slice :=totalHeight div 2; WRect.Bottom :=WRect.Top+slice;
               GradientV(cH, cS);
               WRect.Top :=WRect.Bottom; WRect.Bottom :=ARect.Bottom;
               GradientV(cS, cH);
             end;
    end;

    //Draw External Borders
    ACanvas.Pen.Color :=cH;
    ACanvas.MoveTo(ARect.Left, ARect.Top);
    ACanvas.LineTo(ARect.Left, ARect.Bottom);
    ACanvas.Pen.Color :=cS;
    ACanvas.MoveTo(ARect.Right-1, ARect.Top);
    ACanvas.LineTo(ARect.Right-1, ARect.Bottom);

  end
  else
  begin
    totalHeight :=ARect.Right-ARect.Left;

    Case rAnimationEffectKind of
    ekFoldingDouble: begin           //            HS-HS-SH
                       slice :=totalHeight div 3; WRect.Right :=WRect.Left+slice;
                       GradientH(cH, cS);
                       WRect.Left :=WRect.Right; WRect.Right :=WRect.Left+slice;
                       GradientH(cH, cS);
                       WRect.Left :=WRect.Right; WRect.Right :=ARect.Right;
                       GradientH(cS, cH);
                     end;
    ekFoldingDown: begin             //            HS-SH-HS
                     slice :=totalHeight div 3; WRect.Right :=WRect.Left+slice;
                     GradientH(cH, cS);
                     WRect.Left :=WRect.Right; WRect.Right :=WRect.Left+slice;
                     GradientH(cS, cH);
                     WRect.Left :=WRect.Right; WRect.Right :=ARect.Right;
                     GradientH(cH, cS);
                   end;
    ekCurtain: begin                 //            HS-HS-HS
                 slice :=totalHeight div 3; WRect.Right :=WRect.Left+slice;
                 GradientH(cH, cS);
                 WRect.Left :=WRect.Right; WRect.Right :=WRect.Left+slice;
                 GradientH(cH, cS);
                 WRect.Left :=WRect.Right; WRect.Right :=ARect.Right;
                 GradientH(cH, cS);
               end;
    ekCurtainPersian: begin          //            SH-SH-SH
                        slice :=totalHeight div 3; WRect.Right :=WRect.Left+slice;
                        GradientH(cS, cH);
                        WRect.Left :=WRect.Right; WRect.Right :=WRect.Left+slice;
                        GradientH(cS, cH);
                        WRect.Left :=WRect.Right; WRect.Right :=ARect.Right;
                        GradientH(cS, cH);
                      end;
    ekWaveDoubleExternal: begin      //  |-> SH-SH-HS         SH-HS-HS <-|
                            slice :=totalHeight div 3; WRect.Right :=WRect.Left+slice;
                            if (FCollapseKind = akLeft)
                            then begin
                                   GradientH(cS, cH);
                                   WRect.Left :=WRect.Right; WRect.Right :=WRect.Left+slice;
                                   GradientH(cS, cH);
                                   WRect.Left :=WRect.Right; WRect.Right :=ARect.Right;
                                   GradientH(cH, cS);
                                 end
                            else begin
                                   GradientH(cS, cH);
                                   WRect.Left :=WRect.Right; WRect.Right :=WRect.Left+slice;
                                   GradientH(cH, cS);
                                   WRect.Left :=WRect.Right; WRect.Right :=ARect.Right;
                                   GradientH(cH, cS);
                                 end;
                          end;
    ekWaveDoubleInternal: begin      //  |-> SH-HS-HS         SH-SH-HS <-|
                            slice :=totalHeight div 3; WRect.Right :=WRect.Left+slice;
                            if (FCollapseKind = akLeft)
                            then begin
                                   GradientH(cS, cH);
                                   WRect.Left :=WRect.Right; WRect.Right :=WRect.Left+slice;
                                   GradientH(cH, cS);
                                   WRect.Left :=WRect.Right; WRect.Right :=ARect.Right;
                                   GradientH(cH, cS);
                                  end
                            else begin
                                   GradientH(cS, cH);
                                   WRect.Left :=WRect.Right; WRect.Right :=WRect.Left+slice;
                                   GradientH(cS, cH);
                                   WRect.Left :=WRect.Right; WRect.Right :=ARect.Right;
                                   GradientH(cH, cS);
                                  end;
                          end;
    //ekWaveInternal,          //  |-> SH-HS-SH     Don't work here|
    ekWave: begin                    //             SH-HS
              slice :=totalHeight div 2; WRect.Right :=WRect.Left+slice;
              GradientH(cS, cH);
              WRect.Left :=WRect.Right; WRect.Right :=ARect.Right;
              GradientH(cH, cS);
            end;
    ekWave2: begin                    //             HS-SH
               slice :=totalHeight div 2; WRect.Right :=WRect.Left+slice;
               GradientH(cH, cS);
               WRect.Left :=WRect.Right; WRect.Right :=ARect.Right;
               GradientH(cS, cH);
             end;
    end;

    //Draw External Borders
    ACanvas.Pen.Color :=cH;
    ACanvas.MoveTo(ARect.Left, ARect.Top);
    ACanvas.LineTo(ARect.Right, ARect.Top);
    ACanvas.Pen.Color :=cS;
    ACanvas.MoveTo(ARect.Left, ARect.Bottom-1);
    ACanvas.LineTo(ARect.Right, ARect.Bottom-1);

  end;

end;

procedure TMyRollOut.Resize;
begin
  inherited Resize;

  if (csDesigning in ComponentState) then
  begin
    {$IFDEF DebugInfo}DebugLn('TMyRollOut.Resize');{$endif}
  end;
end;

procedure TMyRollOut.AlignControls(AControl: TControl; var RemainingClientRect: TRect);
begin
  inherited AlignControls(AControl, RemainingClientRect);

  if (csDesigning in ComponentState) then
  begin
    {$IFDEF DebugInfo}DebugLn('TMyRollOut.AlignControls ',
                              IntToStr(RemainingClientRect.Top)+', '+IntToStr(RemainingClientRect.Left)+', '+
                              IntToStr(RemainingClientRect.Bottom)+', '+IntToStr(RemainingClientRect.Right));{$endif}
  end;
end;

procedure TMyRollOut.InsertControl(AControl: TControl; Index: integer);
begin
  {$IFDEF DebugInfo}
  DebugLn('TMyRollOut.InsertControl '+IntToStr(Index), AControl.Name+':'+AControl.ClassName);
  {$endif}

  if (csDesigning in ComponentState) or (csLoading in ComponentState)
      or (AControl is TBoundButton) or (AControl is TMyRollOutSubPanel)
  then inherited InsertControl(AControl, Index)
  else begin
         {$ifdef DebugInfo}DebugLn('  moving '+AControl.Name);{$endif}

         AControl.Parent :=rPanel;
         Case FButtonPosition of
         akTop: AControl.Top :=max(AControl.Top-FButtonSize, 0);
         akLeft: AControl.Left :=max(AControl.Left-FButtonSize, 0);
         //Bottom and Right maybe in correct position
         end;
       end;
end;

constructor TMyRollOut.Create(TheOwner: TComponent);
begin
  StopCircleActions := True;

  inherited;

  FButtonSize := 27;
  FAnimated := True;
  FAnimating :=False;
  FCollapseKind := akTop;
  FVisibleTotal := True;
  FCollapsed := False;
  FButtonPosition := akTop;
  FCollapsedButtonColor := clSkyBlue;
  FExpandedButtonColor := RGBToColor(23, 136, 248);
  FExpandedSize :=200;
  Height  := FExpandedSize;
  Width   := 200;
  FAnimationTotalTime:=300;
  FAnimationSpeed := 20;
  rAnimationEffectKind :=ekFoldingDouble;
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
    ControlStyle := ControlStyle + [csNoFocus, csNoDesignSelectable];
    FButton.OnClick := @self.ButtonClick;
    end;

  rPanel := TMyRollOutSubPanel.Create(Self);
  with rPanel do
    begin
    Parent  := Self;
    Name    := 'subPanel';
    Caption := 'Caption';
    ControlStyle := ControlStyle + [csAcceptsControls, csNoDesignVisible];

    //MaxM:
    //The SubPanel is Invisible during Designing because some User Controls, like TLabel,
    // is Hided because the user controls have Self as Parent (i did not find a way to change this)
    //and are under the SubPanel.
    // Changing the ZOrder take no effect because the SubPanel cover all the free space.
    // In this situation we need to Paint the Border too :-O to simulate the final aspect.
    Visible :=not(csDesigning in ComponentState);
    end;


  (*if Assigned(GlobalDesignHook) then
  begin
       GlobalDesignHook.AddHandlerAddClicked(@DSGN_AddClicked);
  end;*)

  StopCircleActions := False;
end;



destructor TMyRollOut.Destroy;
begin
  Timer.Enabled := False;
  Timer.Free;

  if (ComponentState * [csLoading, csDesigning] = []) then
  begin
    FButton.Free;  // bringt einen Fehler in der Designtime wenn ich das hier mache
    rPanel.Free;
  end;

  (*if Assigned(GlobalDesignHook) then
  begin
       GlobalDesignHook.RemoveAllHandlersForObject(Self);
  end;*)

  inherited Destroy;
end;

procedure Register;
begin
  RegisterComponents('Misc', [TMyRollOut]);
  RegisterComponents('Misc', [TExpandPanels]);
end;

initialization
              {$I pexpandpanels.lrs}
              {$I expandpanels_glyphs.lrs}

end.
