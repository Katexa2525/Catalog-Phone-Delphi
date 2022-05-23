program PhoneCatalogProject;

uses
  Vcl.Forms,
  PhoneCatalog in 'PhoneCatalog.pas' {Form_Main},
  AddItem in 'AddItem.pas' {Form_AddItem},
  FormTextFile in 'FormTextFile.pas' {Form_TextFile};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm_Main, Form_Main);
  Application.CreateForm(TForm_AddItem, Form_AddItem);
  Application.CreateForm(TForm_TextFile, Form_TextFile);
  Application.Run;
end.
