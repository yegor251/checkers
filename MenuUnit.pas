Unit MenuUnit;

Interface

Uses
    Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
    Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, System.ImageList, JPEG,
    Vcl.ImgList, Vcl.ExtCtrls, Vcl.Imaging.Pngimage, PicturesUnit, Stack;

Type
    TMenuForm = Class(TForm)
        WhiteCheckerImage: TImage;
        BlackCheckerImage: TImage;
        BlackImage: TImage;
        WhiteImage: TImage;
        QueenImage: TImage;
        StartButton: TButton;
        NameEdit1: TEdit;
        NameEdit2: TEdit;
        Info1: TLabel;
        Info2: TLabel;
        HaveStepImage: TImage;
        RedImage: TImage;
        YellowImage: TImage;
        ContinueButton: TButton;
        ViewButton: TButton;
        Procedure FormCreate(Sender: TObject);
        Procedure StartButtonClick(Sender: TObject);
        Procedure FormCloseQuery(Sender: TObject; Var CanClose: Boolean);
        Procedure ContinueButtonClick(Sender: TObject);
        Procedure ViewButtonClick(Sender: TObject);
    Private
        { Private declarations }
    Public
        { Public declarations }
    End;

Var
    MenuForm: TMenuForm;

Implementation

{$R *.dfm}

Uses
    GameUnit, ViewUnit;

Procedure DownloadPictures();
Var
    Png: TPngImage;
    X, Y: Integer;
    Bitmap: TBitmap;
Begin
    BlackColor := MenuForm.BlackImage.Picture;

    WhiteColor := MenuForm.WhiteImage.Picture;

    RedColor := MenuForm.RedImage.Picture;

    YellowColor := MenuForm.YellowImage.Picture;

    BlackChecker := MenuForm.BlackCheckerImage.Picture;

    WhiteChecker := MenuForm.WhiteCheckerImage.Picture;

    Queen := MenuForm.QueenImage.Picture;

    HaveStep := MenuForm.HaveStepImage.Picture;

End;

Procedure TMenuForm.StartButtonClick(Sender: TObject);
Begin
    GameForm.Init();
    GameForm.Show;
    If NameEdit1.Text = '' Then
        GameForm.NameLabel1.Caption := 'Player1'
    Else
        GameForm.NameLabel1.Caption := NameEdit1.Text;
    If NameEdit2.Text = '' Then
        GameForm.NameLabel2.Caption := 'Player2'
    Else
        GameForm.NameLabel2.Caption := NameEdit2.Text;
End;

Procedure TMenuForm.ContinueButtonClick(Sender: TObject);
Begin
    GameForm.Show;
    If NameEdit1.Text = '' Then
        GameForm.NameLabel1.Caption := 'Player1'
    Else
        GameForm.NameLabel1.Caption := NameEdit1.Text;
    If NameEdit2.Text = '' Then
        GameForm.NameLabel2.Caption := 'Player2'
    Else
        GameForm.NameLabel2.Caption := NameEdit2.Text;
End;

Procedure TMenuForm.FormCloseQuery(Sender: TObject; Var CanClose: Boolean);
Begin
    CanClose := MessageBox(MenuForm.Handle, '������ �����?', '�����', MB_YESNO + MB_ICONQUESTION) = ID_YES;
End;

Procedure TMenuForm.FormCreate(Sender: TObject);
Begin
    DownloadPictures();
    MenuForm.Width := 650;
    MenuForm.Height := 450;
End;

Procedure TMenuForm.ViewButtonClick(Sender: TObject);
Begin
    ViewForm.Show();
End;

End.
