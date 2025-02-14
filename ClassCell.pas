Unit ClassCell;

Interface

Uses
    PngImage, Vcl.Graphics, Vcl.ExtCtrls, PicturesUnit;

Type
    TCell = Class
    Private
        BackColor, Image: TPicture;
        IsQueen: Boolean;
    Public
        CellImage: TImage;
        Constructor Create(Curr: TImage);
        Procedure SetBackColor(Color: TPicture);
        Procedure SetImage(Curr: TPicture);
        Procedure ReDraw();
        Function GetImage(): TPicture;
        Function GetBackColor(): TPicture;
        Function GetCellImage(): TImage;
        Procedure SetCellImage(Curr: TImage);
        Procedure SetQueenParam(Curr: Boolean);
        Function GetQueenParam(): Boolean;
        Procedure Activate();
        Procedure Deactivate();
    End;

    TAoI = Array Of Integer;
    TAoCell = Array Of TCell;
    TAoAoCell = Array [0 .. 7] Of Array [0 .. 7] Of TCell;
    TMap = Array [0 .. 7] Of Array [0 .. 7] Of Integer;

Implementation

Constructor TCell.Create(Curr: TImage);
Begin
    IsQueen := False;
    CellImage := Curr;
End;

Procedure TCell.Activate();
Begin
    CellImage.Enabled := True;
    ReDraw();
End;

Procedure TCell.Deactivate();
Begin
    CellImage.Enabled := False;
    ReDraw();
End;

Procedure TCell.SetQueenParam(Curr: Boolean);
Begin
    IsQueen := Curr;
    ReDraw();
End;

Function TCell.GetQueenParam(): Boolean;
Begin
    Result := IsQueen;
End;

Function TCell.GetCellImage(): TImage;
Begin
    Result := CellImage;
End;

Function TCell.GetBackColor(): TPicture;
Begin
    Result := BackColor;
End;

Function TCell.GetImage(): TPicture;
Begin
    Result := Image;
End;

Procedure TCell.SetCellImage(Curr: TImage);
Begin
    CellImage := Curr;
End;

Procedure TCell.SetBackColor(Color: TPicture);
Begin
    BackColor := Color;
    ReDraw();
End;

Procedure TCell.SetImage(Curr: TPicture);
Begin
    Image := Curr;
    ReDraw();
End;

Procedure TCell.ReDraw();
var
    TempPicture: TPicture;
Begin    
    CellImage.Canvas.Draw(0, 0, BackColor.Graphic);
    If Image <> Nil Then
    begin
        if CellImage.Enabled then
            CellImage.Canvas.Draw(0, 0, HaveStep.Graphic);       	
        CellImage.Canvas.Draw(0, 0, Image.Graphic);
    end;
    If IsQueen Then
    Begin
        CellImage.Canvas.Draw(0, 0, Queen.Graphic);
    End;   
End;

End.
