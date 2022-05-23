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
  // �������� �����
  Close;
end;

// ��� ������ ����� ����� �� ��������� ����� � ������ � Memo ������� �� �����
procedure TForm_TextFile.FormShow(Sender: TObject);
var
    FText : TextFile; // �������� ���������� ��� ������ �� ���������� �����
    s : String;
begin
    // ������ Memo
    Memo1.Lines.Clear;
    Memo1.WordWrap := False;
    // �������� �������� ���������� � ������
    AssignFile(FText, FileTextName);
    try
      // �������� ����
      Reset(FText);

      // ��������� �� ����� ���� �� ����� �����
      while (not EOF(FText)) do begin
        //����� ������
        Readln(FText, s);
        //  ������ ������ � Memo �������
        Memo1.Lines.Add(s);
      end;
    finally
      CloseFile(FText);
    end;
end;

end.
