program ColegioLegacy;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms,
  UDataModule in 'UDataModule.pas' {DM: TDataModule},
  UMain in 'UMain.pas' {frmMain},
  UAsistencia in 'UAsistencia.pas' {frmAsistencia},
  UNotas in 'UNotas.pas' {frmNotas};

{$R *.res}

begin
  RequireDerivedFormResource := True;
  Application.Scaled := True;
  Application.Initialize;
  Application.CreateForm(TDM, DM);
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
