unit AboutProgram;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TForm_About = class(TForm)
    Label1: TLabel;
    Edit_naim: TEdit;
    Label2: TLabel;
    Label3: TLabel;
    Button_close: TButton;
    Memo_description: TMemo;
    Edit_developer: TEdit;
    procedure Button_closeClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form_About: TForm_About;

implementation

{$R *.dfm}

procedure TForm_About.Button_closeClick(Sender: TObject);
begin
  Close;
end;

end.
