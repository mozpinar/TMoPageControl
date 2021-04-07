unit MoPagecontrol;

interface
uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, Vcl.ComCtrls, Vcl.Controls,
  Vcl.Themes, System.Types, System.Math;
type
  TMoPageControl = class (TPageControl)
  private
    fCloseButtonMouseDownIndex: Integer;
    fCloseButtonShowPushed: Boolean;
    fUseThemes : boolean;
    fOnMouseLeave2: TNotifyEvent;
    FCloseButtonsRect: array of TRect;
  protected
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure DrawTab(TabIndex: Integer; const Rect: TRect; Active: Boolean); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure DoMouseLeaveX(Sender: TObject);
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property OnMouseLeave2: TNotifyEvent read fOnMouseLeave2 write fOnMouseLeave2;
  end;

procedure Register;
implementation

procedure Register;
begin
  RegisterComponents('MO', [TMoPageControl]);
end;
{ TMoPageControl }

procedure TMoPageControl.DrawTab(TabIndex: Integer; const Rect: TRect; Active: Boolean);
var
  CloseBtnSize: Integer;
  TabCaption: TPoint;
  CloseBtnRect: TRect;
  CloseBtnDrawState: Cardinal;
  CloseBtnDrawDetails: TThemedElementDetails;
  I : Integer;
begin
  if Assigned(OnDrawTab) then
  begin
    OnDrawTab(Self, TabIndex, Rect, Active);
    Exit;
  end;

  SetLength(FCloseButtonsRect, PageCount);
  for I := 0 to Length(FCloseButtonsRect) - 1 do
    fCloseButtonsRect[I] := System.Types.Rect(0, 0, 0, 0);

  if InRange(TabIndex, 0, Length(FCloseButtonsRect)-1) then
  begin
    CloseBtnSize := 14;
    TabCaption.Y := Rect.Top + 3;

    if Active then
    begin
      CloseBtnRect.Top := Rect.Top + 6;
      CloseBtnRect.Right := Rect.Right - 5;
      TabCaption.X := Rect.Left + 6;
    end
    else
    begin
      CloseBtnRect.Top := Rect.Top + 3;
      CloseBtnRect.Right := Rect.Right - 5;
      TabCaption.X := Rect.Left + 3;
    end;

    CloseBtnRect.Bottom := CloseBtnRect.Top + CloseBtnSize;
    CloseBtnRect.Left := CloseBtnRect.Right - CloseBtnSize;
    FCloseButtonsRect[TabIndex] := CloseBtnRect;

    Canvas.FillRect(Rect);
    Canvas.TextOut(TabCaption.X, TabCaption.Y, Pages[TabIndex].Caption);

    I := Canvas.TextWidth(Pages[TabIndex].Caption);
    if I+25>TabWidth then
      TabWidth := I + 10;

    if not fUseThemes then
    begin
      if (FCloseButtonMouseDownIndex = TabIndex) and FCloseButtonShowPushed then
        CloseBtnDrawState := DFCS_CAPTIONCLOSE + DFCS_PUSHED + DFCS_FLAT
      else
        CloseBtnDrawState := DFCS_CAPTIONCLOSE + DFCS_FLAT;

      DrawFrameControl(Canvas.Handle,
        FCloseButtonsRect[TabIndex], DFC_CAPTION, CloseBtnDrawState);
    end
    else
    begin
      Dec(FCloseButtonsRect[TabIndex].Left);

      if (FCloseButtonMouseDownIndex = TabIndex) and FCloseButtonShowPushed then
        CloseBtnDrawDetails := ThemeServices.GetElementDetails(twCloseButtonPushed)
      else
        CloseBtnDrawDetails := ThemeServices.GetElementDetails(twCloseButtonNormal);

      ThemeServices.DrawElement(Canvas.Handle, CloseBtnDrawDetails,
        FCloseButtonsRect[TabIndex]);
    end;
  end;
end;

procedure TMoPageControl.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  I: Integer;
begin
  inherited;

  if Button = mbLeft then
  begin
    for I := 0 to  PageCount-1 do //Length(FCloseButtonsRect) - 1 do
    begin
      if PtInRect(FCloseButtonsRect[I], Point(X, Y)) then
      begin
        fCloseButtonMouseDownIndex := I;
        fCloseButtonShowPushed := True;
        Repaint;
      end;
    end;
  end;
end;

constructor TMoPageControl.Create(AOwner: TComponent);
var I : Integer;
begin
  inherited;
  FCloseButtonMouseDownIndex := -1;
  fUseThemes := False;
  TabWidth := 150;
  OwnerDraw := True;

  OnMouseLeave := DoMouseLeaveX;
end;

procedure TMoPageControl.DoMouseLeaveX(Sender: TObject);
begin
  fCloseButtonShowPushed := False;
  Repaint;
  if Assigned(OnMouseLeave2) then
    OnMouseLeave2(Sender);
end;

procedure TMoPageControl.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  Inside: Boolean;
begin
  Inherited;

  if (ssLeft in Shift) and (FCloseButtonMouseDownIndex >= 0) then
  begin
    Inside := PtInRect(FCloseButtonsRect[FCloseButtonMouseDownIndex], Point(X, Y));

    if FCloseButtonShowPushed <> Inside then
    begin
      FCloseButtonShowPushed := Inside;
      Repaint;
    end;
  end;
end;

procedure TMoPageControl.MouseUp(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
begin
  inherited;

  if (Button = mbLeft) and (FCloseButtonMouseDownIndex >= 0) then
  begin
    if PtInRect(FCloseButtonsRect[FCloseButtonMouseDownIndex], Point(X, Y)) then
    begin
      Pages[FCloseButtonMouseDownIndex].Free;

      FCloseButtonMouseDownIndex := -1;
      Repaint;
    end;
  end;

end;

end.
