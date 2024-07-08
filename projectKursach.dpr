program projectKursach;

uses
  Vcl.Forms,
  MenuUnit in 'MenuUnit.pas' {MenuForm},
  Stack in 'Stack.pas',
  PicturesUnit in 'PicturesUnit.pas',
  GameUnit in 'GameUnit.pas' {GameForm},
  Vcl.Themes,
  Vcl.Styles,
  ViewUnit in 'ViewUnit.pas' {ViewForm};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  TStyleManager.TrySetStyle('Tablet Dark');
  Application.CreateForm(TMenuForm, MenuForm);
  Application.CreateForm(TGameForm, GameForm);
  Application.CreateForm(TViewForm, ViewForm);
  Application.Run;
end.
