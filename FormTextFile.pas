unit FormTextFile;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TForm_TextFile = class(TForm)
    Memo1: TMemo;
    ButtonClose: TButton;
    procedure ButtonCloseClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form_TextFile: TForm_TextFile;

implementation

{$R *.dfm}

uses PhoneCatalog;

procedure TForm_TextFile.ButtonCloseClick(Sender: TObject);
begin
  // закрываю форму
  Close;
end;

// при показе формы читаю из тектового файла и вывожу в Memo элемент на форме
procedure TForm_TextFile.FormShow(Sender: TObject);
var
    FText : TextFile; // файловая переменная для чтения из текстового файла
    s : String;
begin
    // очищаю Memo
    Memo1.Lines.Clear;
    Memo1.WordWrap := False;
    // связываю тектовую переменную с файлом
    AssignFile(FText, FileTextName);
    try
      // открываю файл
      Reset(FText);

      // прохожусь по файлу пока не конец файла
      while (not EOF(FText)) do begin
        //читаю строку
        Readln(FText, s);
        //  вывожу строку в Memo элемент
        Memo1.Lines.Add(s);
      end;
    finally
      CloseFile(FText);
    end;
end;

end.
