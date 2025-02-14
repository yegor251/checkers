Unit Stack;

Interface

Uses
    Classes, SysUtils, Forms, Dialogs, ComCtrls,Vcl.Graphics, ClassCell;

Type
    TCellInfo = Record
        Image: TPicture;
        isQueen:Boolean;
    End;

    TAoAoCellInfo = Array[0..7] of Array[0..7] Of TCellInfo;

    TDataOfMap = Record
        Map: TMap;
        Cells: TAoAoCellInfo;
        CurrPlayer: Integer;
    End;

    PNode = ^TNode;

    TNode = Record
        Data: TDataOfMap;
        Next: PNode;
    End;

    TStack = Class
    Private
        FTop: PNode;
    Public
        IsEmpty: Boolean;
        Constructor Create;
        Destructor Destroy; Override;
        Procedure Push(Value: TDataOfMap);
        Function Pop: TDataOfMap;
    End;

Implementation

Constructor TStack.Create;
Begin
    FTop := Nil;
    IsEmpty:= True;
End;

Destructor TStack.Destroy;
Begin
    While FTop <> Nil Do
        Pop;
End;

Procedure TStack.Push(Value: TDataOfMap);
Var
    NewNode: PNode;
Begin
    New(NewNode);
    NewNode^.Data := Value;
    NewNode^.Next := FTop;
    FTop := NewNode;
    IsEmpty:= False;
End;

Function TStack.Pop: TDataOfMap;
Var
    TempNode: PNode;
Begin
    If not IsEmpty Then
    begin
        Result := FTop^.Data;
        TempNode := FTop;
        FTop := FTop^.Next;
        Dispose(TempNode);
        if FTop=nil then
            IsEmpty:=True;
    end;
End;


End.
