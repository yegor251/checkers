Unit ViewUnit;

Interface

Uses
    Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
    Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Grids;

Type
    Winner = Record
        Name: String[20];
        Score: Integer;
    End;

    TViewForm = Class(TForm)
        ViewStringGrid: TStringGrid;
        Procedure FormCreate(Sender: TObject);
    Private
        { Private declarations }
    Public
        Procedure AddNewWinner(NewWinner: Winner);
    End;

    { Const
      Path: String = '\\Mac\Home\Desktop\kursach\list.txt'; }

Var
    ViewForm: TViewForm;
    WinnersFile: File Of Winner;
    Size: Integer;
    Path: String;

Implementation

{$R *.dfm}

Procedure FillingStringGrid();
Var
    TempWinner: Winner;
Begin
    Assign(WinnersFile, Path);
    Reset(WinnersFile);
    Seek(WinnersFile, 0);
    Size := 1;
    While Not EOF(WinnersFile) Do
    Begin
        Read(WinnersFile, TempWinner);
        Inc(Size);
        ViewForm.ViewStringgrid.RowCount := Size;
        ViewForm.ViewStringGrid.Cells[0, Size - 1] := TempWinner.Name;
        ViewForm.ViewStringGrid.Cells[1, Size - 1] := Inttostr(TempWinner.Score);
    End;
    CloseFile(WinnersFile);
End;

Procedure TViewForm.AddNewWinner(NewWinner: Winner);
Begin
    Reset(WinnersFile);
    Seek(WinnersFile, Size - 1);
    Write(WinnersFile, NewWinner);
    Inc(Size);
    ViewForm.ViewStringgrid.RowCount := Size;
    ViewForm.ViewStringGrid.Cells[0, Size - 1] := NewWinner.Name;
    ViewForm.ViewStringGrid.Cells[1, Size - 1] := Inttostr(NewWinner.Score);
    CloseFile(WinnersFile);
End;

Procedure TViewForm.FormCreate(Sender: TObject);
Var
    F: TextFile;
Begin
    Path := ExtractFilePath(ParamStr(0)) + 'list.txt';
    if not FileExists(Path) then
    Begin
        AssignFile(F, Path);
        Rewrite(F);
        CloseFile(F);
    End;
    ViewStringgrid.Cells[0, 0] := '���';
    ViewStringgrid.ColWidths[0] := 360;
    ViewStringgrid.Cells[1, 0] := '���������';
    ViewStringgrid.ColWidths[1] := 144;
    ViewForm.Width := 525;
    ViewForm.Height := 525;
    FillingStringgrid();
End;

End.
