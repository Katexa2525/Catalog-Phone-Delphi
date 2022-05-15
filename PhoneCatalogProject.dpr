program PhoneCatalogProject;

uses
  Vcl.Forms,
  PhoneCatalog in 'PhoneCatalog.pas' {Form_Main},
  AddItem in 'AddItem.pas' {Form_AddItem};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm_Main, Form_Main);
  Application.CreateForm(TForm_AddItem, Form_AddItem);
  Application.Run;
end.
