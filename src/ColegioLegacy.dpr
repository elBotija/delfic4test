program ColegioLegacy;

uses
  Forms,
  UDataModule in 'UDataModule.pas' {DM: TDataModule},
  UMain in 'UMain.pas' {frmMain},
  UAsistencia in 'UAsistencia.pas' {frmAsistencia},
  UNotas in 'UNotas.pas' {frmNotas};

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'Sistema de Gestion Escolar Legacy v1.2';
  Application.CreateForm(TDM, DM);
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
