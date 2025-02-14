Unit GameUnit;

Interface

Uses
    Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
    Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, System.ImageList, JPEG,
    Vcl.ImgList, Vcl.ExtCtrls, ClassCell, Stack, Vcl.Imaging.Pngimage, PicturesUnit, Math,
    Vcl.ExtDlgs;

Type

    TGameForm = Class(TForm)
        BackButton: TButton;
        Score1: TLabel;
        Score2: TLabel;
        NameLabel1: TLabel;
        NameLabel2: TLabel;
        Image1: TImage;
        Image2: TImage;
        GiveUpButton2: TButton;
        GiveUpButton1: TButton;
        Procedure FormCreate(Sender: TObject);
        Procedure OnFigurePress(Sender: TObject);
        Procedure CreateMap();
        Procedure BackButtonClick(Sender: TObject);
        Procedure GiveUpButton2Click(Sender: TObject);
        Procedure GiveUpButton1Click(Sender: TObject);
    Private
        { Private declarations }
    Public
        Procedure Init();
    End;

Const
    MapSize: Integer = 8;

Var
    GameForm: TGameForm;
    Cells: TAoAoCell;
    SimpleSteps: TAoCell;
    Map: TMap;
    Stack: TStack;

    CurrentPlayer, CountEatSteps: Integer;
    PrevButton, PressedButton: TCell;
    IsMoving, IsContinue, IsCombo, IsHasEat: Boolean;
    IsFirstGame: Boolean;
    CellSize: Integer;

Implementation

{$R *.dfm}

Uses
    ViewUnit;

Procedure GiveUp(Player: Integer);
Begin
    For Var I := 0 To High(Map) Do
        For Var J := 0 To High(Map) Do
            If Map[I][J] = Player Then
                Map[I][J] := 0;
End;

Procedure UpdateQuantityOfCheckers();
Var
    NumPlayer1, NumPlayer2: Integer;
Begin
    NumPlayer1 := 0;
    NumPlayer2 := 0;
    For Var I := 0 To High(Map) Do
        For Var J := 0 To High(Map) Do
            If Map[I][J] = 1 Then
                Inc(NumPlayer1)
            Else
                If Map[I][J] = 2 Then
                    Inc(NumPlayer2);
    GameForm.Score1.Caption := Inttostr(NumPlayer1);
    GameForm.Score2.Caption := Inttostr(NumPlayer2);
End;

Function CopyArray(Arr: TAoAoCell): TAoAoCellInfo; Overload;
Var
    NewArr: TAoAoCellInfo;
Begin
    For Var I := 0 To MapSize - 1 Do
        For Var J := 0 To MapSize - 1 Do
        Begin
            NewArr[I][J].Image := Arr[I][J].GetImage;
            NewArr[I][J].IsQueen := Arr[I][J].GetQueenParam();
        End;

    Result := NewArr;
End;

Function CopyArray(Arr: TMap): TMap; Overload;
Var
    NewArr: TMap;
Begin
    For Var I := 0 To MapSize - 1 Do
        For Var J := 0 To MapSize - 1 Do
            NewArr[I][J] := Arr[I][J];

    Result := NewArr;
End;

Procedure DeleteEaten(EndButton, StartButton: TCell);
Var
    Count, StartIndexX, StartIndexY, CurrCount, I, J: Integer;
Begin
    Count := Abs((EndButton.CellImage.Top Div Cellsize) - (StartButton.CellImage.Top Div Cellsize));
    //���������� ����������� �������� ������� ����� �������� ������������ �������� � ��������� ������, �������� �� ������ ������
    StartIndexX := (EndButton.CellImage.Top Div Cellsize) - (StartButton.CellImage.Top Div Cellsize);
    //���������� ������� ����� �������� ������������ �������� � ��������� ������, �������� �� ������ ������
    StartIndexY := (EndButton.CellImage.Left Div Cellsize) - (StartButton.CellImage.Left Div Cellsize);
    //���������� ������� ����� ������ ������������ �������� � ��������� ������, �������� �� ������ ������
    If StartIndexX < 0 Then //���� ������������� �����
        StartIndexX := -1//������������� StartIndexX � -1
    Else
        StartIndexX := 1; //� ��������� ������ � 1
    If StartIndexY < 0 Then //���� ������������� �����
        StartIndexY := -1//������������� StartIndexY � -1
    Else
        StartIndexY := 1; //� ��������� ������ � 1
    CurrCount := 0; //������������� CurrCount � 0
    I := StartButton.CellImage.Top Div Cellsize + StartIndexX; //��������� ��������� �������� I
    J := StartButton.CellImage.Left Div Cellsize + StartIndexY; //��������� ��������� �������� J
    While (Currcount < Count - 1) Do //���� CurrCount ������ Count - 1
    Begin
        Map[I, J] := 0; //������������� �������� ������ �� ����� � 0
        Cells[I][J].SetImage(Nil); //������� ����������� ������
        Cells[I][J].SetQueenParam(False); //������� �������� Queen ������
        I := I + StartIndexX; //����������� I �� StartIndexX
        J := J + StartIndexY; //����������� J �� StartIndexY
        Inc(CurrCount); //����������� CurrCount �� 1
    End;
    UpdateQuantityOfCheckers(); //��������� ���������� �����
End;

Procedure SwitchButtonToQueen(Cell: TCell);
Var
    X, Y: Integer;
Begin
    Y := Cell.CellImage.Top Div Cellsize;
    X := Cell.CellImage.Left Div Cellsize;
    If (Map[Y][X] = 1) And (Y = MapSize - 1) Then
        Cell.SetQueenParam(True);
    If (Map[Y][X] = 2) And (Y = 0) Then
        Cell.SetQueenParam(True);
End;

Procedure CloseSteps();
Begin
    For Var I := 0 To MapSize - 1 Do
        For Var J := 0 To MapSize - 1 Do
            If (I + J) Mod 2 = 1 Then
                Cells[I][J].SetBackColor(BlackColor);
End;

Function IsInsideBorders(Ti, Tj: Integer): Boolean;
Begin
    If (Ti >= MapSize) Or (Tj >= MapSize) Or (Ti < 0) Or (Tj < 0) Then
        Result := False
    Else
        Result := True;
End;

Function IsButtonHasEatStep(IcurrFigure, JcurrFigure: Integer; IsOneStep: Boolean): Boolean;
Var
    EatStep: Boolean;
    I, J: Integer;
    IsNotLeave: Boolean;
    IsNotExit: Boolean;
Begin
    EatStep := False;
    J := JcurrFigure + 1;
    IsNotLeave := True;
    IsNotExit := True;
    I := IcurrFigure - 1;
    While (I >= 0) And IsNotLeave And IsNotExit Do
    Begin
        If IsInsideBorders(I, J) Then
        Begin
            If (Map[I][J] <> 0) And (Map[I][J] <> CurrentPlayer) Then
            Begin
                EatStep := True;
                If Not IsInsideBorders(I - 1, J + 1) Then
                    EatStep := False
                Else
                    If Map[I - 1][J + 1] <> 0 Then
                        EatStep := False
                    Else
                    Begin
                        Result := EatStep;
                        IsNotExit := False;
                    End;
            End;
        End;
        If J < 7 Then
            Inc(J)
        Else
            IsNotLeave := False;
        If IsOneStep Then
            IsNotLeave := False;
        Dec(I);
    End;

    J := JcurrFigure - 1;
    I := IcurrFigure - 1;
    IsNotLeave := True;
    While (I >= 0) And IsNotLeave And IsNotExit Do
    Begin
        If IsInsideBorders(I, J) Then
        Begin
            If (Map[I][J] <> 0) And (Map[I][J] <> CurrentPlayer) Then
            Begin
                EatStep := True;
                If Not IsInsideBorders(I - 1, J - 1) Then
                    EatStep := False
                Else
                    If Map[I - 1][J - 1] <> 0 Then
                        EatStep := False
                    Else
                    Begin
                        Result := EatStep;
                        IsNotExit := False;
                    End;

            End;
        End;
        If J > 0 Then
            Dec(J)
        Else
            IsNotLeave := False;
        If IsOneStep Then
            IsNotLeave := False;
        Dec(I);
    End;

    J := JcurrFigure - 1;
    I := IcurrFigure + 1;
    IsNotLeave := True;
    While (I <= MapSize - 1) And IsNotLeave And IsNotExit Do
    Begin
        If IsInsideBorders(I, J) Then
        Begin
            If (Map[I][J] <> 0) And (Map[I][J] <> CurrentPlayer) Then
            Begin
                EatStep := True;
                If Not IsInsideBorders(I + 1, J - 1) Then
                    EatStep := False
                Else
                    If Map[I + 1][J - 1] <> 0 Then
                        EatStep := False
                    Else
                    Begin
                        Result := EatStep;
                        IsNotExit := False;
                    End;

            End;
        End;
        If J > 0 Then
            Dec(J)
        Else
            IsNotLeave := False;
        If IsOneStep Then
            IsNotLeave := False;
        Inc(I);
    End;

    J := JcurrFigure + 1;
    I := IcurrFigure + 1;
    IsNotLeave := True;
    While (I <= MapSize - 1) And IsNotLeave And IsNotExit Do
    Begin
        If IsInsideBorders(I, J) Then
        Begin
            If (Map[I][J] <> 0) And (Map[I][J] <> CurrentPlayer) Then
            Begin
                EatStep := True;
                If Not IsInsideBorders(I + 1, J + 1) Then
                    EatStep := False
                Else
                    If Map[I + 1][J + 1] <> 0 Then
                        EatStep := False
                    Else
                    Begin
                        Result := EatStep;
                        IsNotExit := False;
                    End;
            End;
        End;
        If J < 7 Then
            Inc(J)
        Else
            IsNotLeave := False;
        If IsOneStep Then
            IsNotLeave := False;
        Inc(I);
    End;
    Result := EatStep;
End;

Procedure ActivateHavingMoveButton();
Var
    I, J: Integer;
    IsNotExit: Boolean;
Begin
    IsNotExit := True;
    If IsCombo Then
        IsNotExit := False;
    For I := 0 To MapSize - 1 Do
        For J := 0 To MapSize - 1 Do
        Begin
            If (Map[I][J] = CurrentPlayer) And IsButtonHasEatStep(I, J, True) Then
            Begin
                Cells[I][J].Activate();
                IsNotExit := False;
            End;
        End;
    If IsNotExit Then
    Begin
        For I := 0 To MapSize - 1 Do
            For J := 0 To MapSize - 1 Do
            Begin
                If (Map[I][J] = 1) And (CurrentPlayer = 1) And ((IsInsideBorders(I + 1, J - 1) And (Map[I + 1][J - 1] = 0)) Or
                    (IsInsideBorders(I + 1, J + 1) And (Map[I + 1][J + 1] = 0))) Then
                    Cells[I][J].Activate()
                Else
                    If (Map[I][J] = 2) And (CurrentPlayer = 2) And
                        ((IsInsideBorders(I - 1, J - 1) And (Map[I - 1][J - 1] = 0)) Or
                        (IsInsideBorders(I - 1, J + 1) And (Map[I - 1][J + 1] = 0))) Then
                        Cells[I][J].Activate()
                    Else
                        If (Map[I][J] = CurrentPlayer) And Cells[I][J].GetQueenParam Then
                            Cells[I][J].Activate();
            End;
    End;
End;

Procedure DeactivateAllButtons();
Begin
    For Var I := 0 To 7 Do
        For Var J := 0 To 7 Do
            Cells[I][J].Deactivate;
End;
              
Procedure GoBackStep();
Var
    Data: TDataOfMap;
    CellInfoArr: TAoAoCellInfo;  
Begin                               
    CloseSteps();            
    Data := Stack.Pop();
    CellInfoArr := Data.Cells;
    For Var I := 0 To MapSize - 1                          Do
        For Var J := 0 To MapSize - 1 Do
        Begin
            Cells[I][J].SetImage(CellInfoArr[I][J].Image);
            Cells[I][J].SetQueenParam(CellInfoArr[I][J].IsQueen);
        End;
    Map := Data.Map;
    CurrentPlayer := Data.CurrPlayer;
    DeactivateAllButtons();
    ActivateHavingMoveButton();
    UpdateQuantityOfCheckers();
    If Stack.IsEmpty Then
        GameForm.BackButton.Enabled := False;
End;
             
Procedure TGameForm.BackButtonClick(Sender: TObject);
Begin                               
    GoBackStep();
End;

Procedure TGameForm.CreateMap();
Var
    CurrImg: TImage;
    I, J: Integer;
    Cell: TCell;
Begin
    IsFirstGame := False;
    For I := 0 To MapSize - 1 Do
    Begin
        For J := 0 To MapSize - 1 Do
        Begin
            CurrImg := TImage.Create(GameForm);
            CurrImg.Parent := GameForm;
            CurrImg.Left := J * CellSize;
            CurrImg.Top := I * CellSize;
            CurrImg.Width := CellSize;
            CurrImg.Height := CellSize;
            Cell := TCell.Create(CurrImg);
            Cell.CellImage.Stretch := False;
            If ((I + J) Mod 2 = 0) Then
                Cell.SetBackColor(WhiteColor)
            Else
            Begin
                Cell.CellImage.OnClick := OnFigurePress;
                Cell.SetBackColor(BlackColor);
                If Map[I][J] = 1 Then
                    Cell.SetImage(WhiteChecker)
                Else
                    If Map[I][J] = 2 Then
                        Cell.SetImage(BlackChecker);
            End;
            Cell.SetQueenParam(False);
            Cells[I][J] := Cell;
        End;
    End;
End;

Procedure TGameForm.Init();
Begin
    For Var I := 0 To 7 Do //���� �� ������� �� �����
    Begin
        For Var J := 0 To 7 Do //���� �� �������� �� �����
        Begin
            If (I Mod 2 = 0) And (J Mod 2 = 0) Then //���� ��� ������� ������
                Map[I, J] := 0//������������� �������� ������ � 0
            Else
                If (I Mod 2 = 1) And (J Mod 2 = 1) Then //���� ��� ������� ��������
                    Map[I, J] := 0//������������� �������� ������ � 0
                Else
                    If I < 3 Then //���� ������ ������ ������ 3
                        Map[I, J] := 1//������������� �������� ������ � 1
                    Else
                        If I > 4 Then //���� ������ ������ ������ 4
                            Map[I, J] := 2//������������� �������� ������ � 2
                        Else
                            Map[I, J] := 0; //� ��������� ������ ������������� �������� ������ � 0
        End;
    End;

    If IsFirstGame Then //���� ��� ������ ����
        GameForm.Createmap(); //������� �����

    For Var I := 0 To 7 Do //���� �� ������� �� �����
    Begin
        For Var J := 0 To 7 Do //���� �� �������� �� �����
        Begin
            Cells[I][J].SetQueenParam(False);
            Cells[I][J].SetImage(Nil);
            If Map[I][J] = 1 Then
                Cells[I][J].SetImage(WhiteChecker)
            Else
                If Map[I][J] = 2 Then
                    Cells[I][J].SetImage(BlackChecker);
        End;
    End;

    IsMoving := False; //������������� ���� �������� � false
    IsHasEat := False; //������������� ���� ������� ��������� ����� � false
    CurrentPlayer := 1; //������������� �������� ������ � 1
    CountEatSteps := 0; //������������� ������� ��������� ����� � 0
    IsContinue := False; //������������� ���� ����������� � false
    Setlength(SimpleSteps, 0); //������������� ����� ������� ������� ����� � 0
    PressedButton := TCell.Create(Nil); //������� ����� ������ ��� ������� ������
    PrevButton := TCell.Create(Nil); //������� ����� ������ ��� ���������� ������
    IsCombo := False; //������������� ���� ����� � false
    DeactivateAllButtons; //������������ ��� ������
    ActivateHavingMoveButton; //���������� ��������� ������
    Stack := TStack.Create(); //������� ����� ����
    UpdateQuantityOfCheckers; //��������� ���������� �����
End;

Function CollectMapInfo(): TDataOfMap;
Var
    Data: TDataOfMap;
Begin
    Data.Map := CopyArray(Map);
    Data.Cells := CopyArray(Cells);
    Data.CurrPlayer := CurrentPlayer;
    Result := Data;
End;

Procedure TGameForm.FormCreate(Sender: TObject);
Begin
    CellSize := (GameForm.Height Div 9);
    GameForm.Height := Floor(CellSize * 8.55);
    GameForm.Width := Floor(CellSize * 10);
    IsFirstGame := True;
    Init();
    ActiveControl := Nil;
End;

Procedure ResetGame();
Var
    Player1, Player2: Integer; //���������� ���������� ��� ������������ ���������� ����� � ������� ������
    TempWinner: Winner;
Begin
    Player1 := 0; //������������� ���������� Player1 ��� False
    Player2 := 0; //������������� ���������� Player2 ��� False
    For Var I := 0 To MapSize - 1 Do //���� �� ������� �� �����
        For Var J := 0 To MapSize - 1 Do //���� �� �������� �� �����
        Begin
            If Map[I][J] = 1 Then //���� � ������ ��������� ����� ������ 1
                Inc(Player1)//����������� Player1
            Else
                If Map[I][J] = 2 Then //���� � ������ ��������� ����� ������ 2
                    Inc(Player2); //����������� Player2
        End;

    If Player1 = 0 Then //���� � ������ 1 ��� �����
    Begin
        Application.MessageBox(PChar('������� ' + GameForm.NameLabel2.Caption), '������', 0); //������� ��������� � ������ ������ 2
        TempWinner.Name := GameForm.NameLabel2.Caption;
        TempWinner.Score := Player2;
        ViewForm.AddNewWinner(TempWinner);
    End
    Else
        If Player2 = 0 Then //���� � ������ 2 ��� �����
        Begin
            Application.MessageBox(PChar('������� ' + GameForm.NameLabel1.Caption), '������', 0); //������� ��������� � ������ ������ 1
            TempWinner.Name := GameForm.NameLabel1.Caption;
            TempWinner.Score := Player1;
            ViewForm.AddNewWinner(TempWinner);
        End;

    If (Player1 = 0) Or (Player2 = 0) Then //���� � ������ �� ������� ��� �����
    Begin
        Stack.Free; //����������� ������, ���������� ������

        GameForm.Init(); //�������������� �����
        GameForm.Close(); //��������� �����
    End;
End;

Procedure TGameForm.GiveUpButton2Click(Sender: TObject);
Begin
    GiveUp(2);
    ResetGame();
End;

Procedure TGameForm.GiveUpButton1Click(Sender: TObject);
Begin
    GiveUp(1);
    ResetGame();
End;

Procedure SwitchPlayer();
Begin
    If CurrentPlayer = 1 Then
        CurrentPlayer := 2
    Else
        CurrentPlayer := 1;
    ResetGame();
End;

Procedure CloseSimpleSteps(SimpleSteps: TAoCell);
Begin
    If Length(SimpleSteps) > 0 Then
        For Var I := 0 To High(SimpleSteps) Do
        Begin
            SimpleSteps[I].SetBackColor(BlackColor);
            SimpleSteps[I].Deactivate();
        End;
End;

Procedure ShowProceduralEat(I, J: Integer; IsOneStep: Boolean);
Var
    DirX, DirY, Il, Jl, Ik, Jk: Integer;
    IsEmpty, CloseSimple: Boolean;
    ToClose: TAoCell;
    Temp: TAoI;
    IsNotLeave: Boolean;
Begin
    IsNotLeave := True;
    DirX := I - PressedButton.CellImage.Top Div CellSize;
    DirY := J - PressedButton.CellImage.Left Div CellSize;
    If DirX < 0 Then
        DirX := -1
    Else
        DirX := 1;
    If DirY < 0 Then
        DirY := -1
    Else
        DirY := 1;

    Il := I;
    Jl := J;
    IsEmpty := True;
    While IsInsideBorders(Il, Jl) And IsNotLeave Do
    Begin
        If (Map[I][J] <> 0) And (Map[Il][Jl] <> CurrentPlayer) Then
        Begin
            IsEmpty := False;
            IsNotLeave := False;
        End;
        If IsNotLeave Then
        Begin
            Il := Il + DirX;
            Jl := Jl + DirY;
        End;
        If IsOneStep Then
            IsNotLeave := False;
    End;
    IsNotLeave := True;

    If Not IsEmpty Then
    Begin
        Setlength(ToClose, 0);
        CloseSimple := False;
        Ik := Il + DirX;
        Jk := Jl + DirY;
        While IsInsideBorders(Ik, Jk) And IsNotLeave Do
        Begin
            If Map[Ik, Jk] = 0 Then
            Begin
                Setlength(Temp, 2);
                Temp[0] := DirX;
                Temp[1] := DirY;
                If IsButtonHasEatStep(Ik, Jk, IsOneStep) Then
                Begin
                    CloseSimple := True
                End
                Else
                Begin
                    Setlength(ToClose, Length(ToClose) + 1);
                    ToClose[High(ToClose)] := Cells[Ik, Jk];
                End;
                Cells[Ik, Jk].SetBackColor(YellowColor);
                Cells[Ik, Jk].Activate();
                Inc(CountEatSteps);
            End
            Else
                IsNotLeave := False;
            If IsOneStep Then
                IsNotLeave := False;
            Jk := Jk + DirY;
            Ik := Ik + DirX;
        End;
        If (Length(ToClose) > 0) And CloseSimple Then
            CloseSimpleSteps(ToClose);
    End;
End;

Function DeterminePath(Ti, Tj: Integer): Boolean;
Var
    Answ: Boolean;
Begin
    If (Map[Ti][Tj] = 0) And Not IsContinue Then //���� ������ �� ����� ����� � �� ������������ �������� �����
    Begin
        Cells[Ti][Tj].SetBackColor(YellowColor); //������������� ������ ���� ���� ��� ������
        Cells[Ti][Tj].Activate(); //���������� ������
        Setlength(Simplesteps, Length(Simplesteps) + 1); //����������� ����� ������� Simplesteps �� 1
        Simplesteps[High(Simplesteps)] := Cells[Ti, Tj]; //��������� ������� ������ � ������ Simplesteps
        Answ := True; //������������� Answ � True
    End
    Else
    Begin
        If Map[Ti][Tj] <> CurrentPlayer Then //���� ������ �� ����� �� ����������� �������� ������
        Begin
            ShowProceduralEat(Ti, Tj, True); //�������� ��������� ShowProceduralEat
        End;
        Answ := False; //������������� Answ � False
    End;
    Result := Answ; //���������� ��������� Answ
End;

Procedure ShowDiagonal(IcurrFigure, JcurrFigure: Integer; IsOneStep: Boolean = False);
Var
    I, J: Integer;
    Temp: TAoI;
Begin
    Setlength(Temp, 2);
    J := JcurrFigure + 1;
    For I := IcurrFigure - 1 DownTo 0 Do
    Begin
        If (CurrentPlayer = 1) And IsOneStep And Not IsContinue And Not IsButtonHasEatStep(IcurrFigure, JcurrFigure, IsOneStep) Then
            Break;
        If IsInsideBorders(I, J) Then
        Begin
            If Not DeterminePath(I, J) Then
                Break;
        End;
        If J < 7 Then
            Inc(J)
        Else
            Break;
        If IsOneStep Then
            Break;
    End;

    J := JcurrFigure - 1;
    For I := IcurrFigure - 1 DownTo 0 Do
    Begin
        If (CurrentPlayer = 1) And IsOneStep And Not IsContinue And Not IsButtonHasEatStep(IcurrFigure, JcurrFigure, IsOneStep) Then
            Break;
        If IsInsideBorders(I, J) Then
        Begin
            If Not DeterminePath(I, J) Then
                Break;
        End;
        If J > 0 Then
            Dec(J)
        Else
            Break;
        If IsOneStep Then
            Break;
    End;

    J := JcurrFigure - 1;
    For I := IcurrFigure + 1 To MapSize - 1 Do
    Begin
        Temp[0] := 1;
        Temp[1] := -1;
        If (CurrentPlayer = 2) And IsOneStep And Not IsContinue And Not IsButtonHasEatStep(IcurrFigure, JcurrFigure, IsOneStep) Then
            Break;
        If IsInsideBorders(I, J) Then
        Begin
            If Not DeterminePath(I, J) Then
                Break;
        End;
        If J > 0 Then
            Dec(J)
        Else
            Break;
        If IsOneStep Then
            Break;
    End;

    J := JcurrFigure + 1;
    For I := IcurrFigure + 1 To MapSize - 1 Do
    Begin
        If (CurrentPlayer = 2) And IsOneStep And Not IsContinue And Not IsButtonHasEatStep(IcurrFigure, JcurrFigure, IsOneStep) Then
            Break;
        If IsInsideBorders(I, J) Then
        Begin
            If Not DeterminePath(I, J) Then
                Break;
        End;
        If J < 7 Then
            Inc(J)
        Else
            Break;
        If IsOneStep Then
            Break;
    End;
End;

Procedure ShowSteps(IcurrFigure, JcurrFigure: Integer; IsOnestep: Boolean);
Begin
    SimpleSteps := Nil;
    ShowDiagonal(IcurrFigure, JcurrFigure, IsOnestep);
    If CountEatSteps > 0 Then
        CloseSimpleSteps(SimpleSteps)
End;

Procedure ShowPossibleSteps();
Var
    IsOneStep, IsEatStep: Boolean;
Begin
    IsOneStep := True;
    IsEatStep := False;
    DeactivateAllButtons();          //���
    For Var I := 0 To MapSize-1 Do
        For Var J := 0 To MapSize-1 Do
        Begin
            If (Map[I, J] = Currentplayer) Then
            Begin
                If Cells[I][J].GetQueenParam() Then
                    IsOneStep := False
                Else
                    IsOneStep := True;
                If IsButtonHasEatStep(I, J, IsOneStep) Then
                Begin
                    IsEatStep := True;
                    Cells[I][J].Activate();
                End;
            End;
        End;
    If Not IseatStep Then
        ActivateHavingMoveButton();
End;

Function IsFigureOnWay(X1, Y1, X2, Y2: Integer): Boolean;
Var
    Answ: Boolean;
Begin
    Answ := False;
    If (X2 > X1) And (Y2 > Y1) Then
    Begin
        While X1 < X2 Do
        Begin
            If Map[Y1, X1] > 0 Then
                Answ := True;
            Inc(X1);
            Inc(Y1);
        End;
    End
    Else
        If (X2 > X1) And (Y2 < Y1) Then
        Begin
            While X1 < X2 Do
            Begin
                If Map[Y1, X1] > 0 Then
                    Answ := True;
                Inc(X1);
                Dec(Y1);
            End;
        End
        Else
            If (X2 < X1) And (Y2 > Y1) Then
            Begin
                While X1 > X2 Do
                Begin
                    If Map[Y1, X1] > 0 Then
                        Answ := True;
                    Dec(X1);
                    Inc(Y1);
                End;
            End
            Else
                If (X2 < X1) And (Y2 < Y1) Then
                Begin
                    While X1 > X2 Do
                    Begin
                        If Map[Y1, X1] > 0 Then
                            Answ := True;
                        Dec(X1);
                        Dec(Y1);
                    End;
                End;
    Result := Answ;
End;

Procedure TGameForm.OnFigurePress(Sender: TObject);
Var
    X, Y, Temp, X1, Y1: Integer;
    Image: TImage;
Begin
    Image := TImage(Sender);
    X := Image.Left Div Cellsize;
    Y := Image.Top Div Cellsize;
    PressedButton := Cells[Y][X];

    If ((PrevButton = PressedButton) And IsCombo) Then
        Exit;

    If PrevButton.CellImage <> Nil Then
    Begin
        Prevbutton.SetBackColor(BlackColor);
        X1 := PrevButton.CellImage.Left Div Cellsize;
        Y1 := PrevButton.CellImage.Top Div Cellsize;
    End;

    If (Map[Y, X] <> 0) And (Map[Y][X] = CurrentPlayer) And Not IsCombo Then
    Begin
        CloseSteps();
        Pressedbutton.SetBackColor(RedColor);
        DeactivateAllButtons();
        PressedButton.Activate();
        CountEatSteps := 0;
        ShowSteps(Y, X, Not PressedButton.GetQueenParam);

        If IsMoving Then
        Begin
            CloseSteps();
            Pressedbutton.SetBackColor(BlackColor);
            ShowPossibleSteps();
            IsMoving := False;
        End
        Else
        Begin
            IsMoving := True;
        End;
        ActivateHavingMoveButton;
    End
    Else
    Begin
        If IsMoving Then
        Begin
            Stack.Push(CollectMapInfo());
            BackButton.Enabled := True;
            X1 := PrevButton.CellImage.Left Div Cellsize;
            Y1 := PrevButton.CellImage.Top Div Cellsize;
            IsContinue := False;
            If (Abs(X - X1) > 1) And IsFigureOnWay(X, Y, X1, Y1) Then
            Begin
                IsContinue := True;
                IsCombo := True;
                DeleteEaten(PressedButton, PrevButton);
            End;
            Temp := Map[Y][X];
            Map[Y][X] := Map[Y1][X1];
            Map[Y1][X1] := Temp;
            PressedButton.SetImage(PrevButton.GetImage);
            PrevButton.SetImage(Nil);
            PressedButton.SetQueenParam(PrevButton.GetQueenParam());
            PrevButton.SetQueenParam(False);
            SwitchButtonToQueen(PressedButton);
            CountEatSteps := 0;
            IsMoving := False;
            CloseSteps();
            DeactivateAllButtons();
            ActivateHavingMoveButton;
            ShowSteps(Y, X, Not PressedButton.GetQueenParam());
            If (CountEatSteps = 0) Or Not IsContinue Then
            Begin
                IsCombo := False;
                CloseSteps();
                SwitchPlayer();
                ShowPossibleSteps();
                IsContinue := False;
            End
            Else
                If IsContinue Then
                Begin
                    Pressedbutton.SetBackColor(RedColor);
                    PressedButton.Activate();
                    IsMoving := True;
                End;
        End;
    End;
    PrevButton := Cells[Y][X];
End;

End.
