program PhoneCatalogProject;

uses
  Vcl.Forms,
  PhoneCatalog in 'PhoneCatalog.pas' {Form_Main},
  AddItem in 'AddItem.pas' {Form_AddItem},
  FormTextFile in 'FormTextFile.pas' {Form_TextFile},
  AboutProgram in 'AboutProgram.pas' {Form_About};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm_Main, Form_Main);
  Application.CreateForm(TForm_AddItem, Form_AddItem);
  Application.CreateForm(TForm_TextFile, Form_TextFile);
  Application.CreateForm(TForm_About, Form_About);
  Application.Run;
end.
