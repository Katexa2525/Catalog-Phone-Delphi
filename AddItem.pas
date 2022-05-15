unit AddItem;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TForm_AddItem = class(TForm)
    Button_Cancel: TButton;
    Button_Save: TButton;
    Label1: TLabel;
    Edit_PhoneName: TEdit;
    Label2: TLabel;
    Edit_DisplayHight: TEdit;
    Edit_Price: TEdit;
    Edit_DisplaySize: TEdit;
    Edit_DisplayWidth: TEdit;
    Edit_YearVihoda: TEdit;
    Edit_OperationMemory: TEdit;
    Edit_VstrMemory: TEdit;
    Edit_OS: TEdit;
    Label3: TLabel;
    Label4: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    ComboBox_TypePhone: TComboBox;
    GroupBox1: TGroupBox;
    RadioButton_Yes: TRadioButton;
    RadioButton_No: TRadioButton;
    Memo_Description: TMemo;
    Label5: TLabel;
    procedure Button_CancelClick(Sender: TObject);
    procedure Button_SaveClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form_AddItem: TForm_AddItem;

implementation

{$R *.dfm}

uses PhoneCatalog;

procedure TForm_AddItem.Button_CancelClick(Sender: TObject);
begin
  Close;
end;

// сохранение
procedure TForm_AddItem.Button_SaveClick(Sender: TObject);
var
  num: integer;
  NPtr: PCatalog;
begin
  // добавляем элемент в список
  if Tag = 0 then // 0 - значит форма для добавления применяется
    CatalogPhone := Form_Main.AddItemCatalog(1, CatalogPhone);
  // данные из формы в элемент списка
  CatalogPhone.Data.PhoneName := Form_AddItem.Edit_PhoneName.Text;
  CatalogPhone.Data.TypeName := Form_AddItem.ComboBox_TypePhone.Text;
  CatalogPhone.Data.YearVihoda := StrToInt(Form_AddItem.Edit_YearVihoda.Text);
  CatalogPhone.Data.Price := StrToInt(Form_AddItem.Edit_Price.Text);
  CatalogPhone.Data.OS := Form_AddItem.Edit_OS.Text;
  CatalogPhone.Data.DisplaySize := StrToInt(Form_AddItem.Edit_DisplaySize.Text);
  CatalogPhone.Data.DisplayWidth := StrToInt(Form_AddItem.Edit_DisplayWidth.Text);
  CatalogPhone.Data.DisplayHigth := StrToInt(Form_AddItem.Edit_DisplayHight.Text);
  CatalogPhone.Data.OperationMemory := StrToInt(Form_AddItem.Edit_OperationMemory.Text);
  CatalogPhone.Data.VstroyennayaMemory := StrToInt(Form_AddItem.Edit_VstrMemory.Text);
  if Form_AddItem.RadioButton_Yes.Checked then
    CatalogPhone.Data.IsFrontCamera := True
  else
    CatalogPhone.Data.IsFrontCamera := False;
  CatalogPhone.Data.Discription := Form_AddItem.Memo_Description.Text;
  if Tag = 0 then // 0 - значит форма для добавления применяется
  begin
    // добавляем в грид на главной форме запись
    with Form_Main.StringGrid_Catalog do
    begin
      RowCount := RowCount + 1; // Увеличиваем количество строк на 1
      num := RowCount - 1;
      Cells[0, num] := IntToStr(RowCount - 1);
      Cells[1, num] := Form_AddItem.Edit_PhoneName.Text;
      Cells[2, num] := Form_AddItem.ComboBox_TypePhone.Text;
      Cells[3, num] := Form_AddItem.Edit_YearVihoda.Text;
      Cells[4, num] := Form_AddItem.Edit_Price.Text;
      Cells[5, num] := Form_AddItem.Edit_OS.Text;
      Cells[6, num] := Form_AddItem.Edit_DisplaySize.Text;
      Cells[7, num] := Form_AddItem.Edit_DisplayWidth.Text;
      Cells[8, num] := Form_AddItem.Edit_DisplayHight.Text;
      Cells[9, num] := Form_AddItem.Edit_OperationMemory.Text;
      Cells[10, num] := Form_AddItem.Edit_VstrMemory.Text;
      if Form_AddItem.RadioButton_Yes.Checked then
        Cells[11, num] := 'Да'
      else
        Cells[11, num] := 'Нет';
      Cells[12, num] := Form_AddItem.Memo_Description.Text;
      Cells[13, num] := '';
    end;
  end
  else // если редактирование формы
  begin
    // сохраняю в файл из памяти списка с измененным элементом
    Form_Main.SaveItemsInFile(FFirst, true);
    // отображаю из файла в грид на главной форме
    Form_Main.StringGrid_Catalog.RowCount:=2; // удаляю строки грида
    // формируем заново из файла
    Form_Main.ShowItemsCatalog();
  end;
  // закрываем форму добавления / редактирования
  Close;
end;

procedure TForm_AddItem.FormShow(Sender: TObject);
begin
  if Tag = 1 then // форма для редактирования
  begin
    Caption := 'Редактирование элемента';
    // данные из формы в элемент списка
    Form_AddItem.Edit_PhoneName.Text := CatalogPhone.Data.PhoneName;
    Form_AddItem.ComboBox_TypePhone.Text := CatalogPhone.Data.TypeName;
    Form_AddItem.Edit_YearVihoda.Text := IntToStr(CatalogPhone.Data.YearVihoda);
    Form_AddItem.Edit_Price.Text := IntToStr(CatalogPhone.Data.Price);
    Form_AddItem.Edit_OS.Text := CatalogPhone.Data.OS;
    Form_AddItem.Edit_DisplaySize.Text :=  IntToStr(CatalogPhone.Data.DisplaySize);
    Form_AddItem.Edit_DisplayWidth.Text := IntToStr(CatalogPhone.Data.DisplayWidth);
    Form_AddItem.Edit_DisplayHight.Text := IntToStr(CatalogPhone.Data.DisplayHigth);
    Form_AddItem.Edit_OperationMemory.Text := IntToStr(CatalogPhone.Data.OperationMemory);
    Form_AddItem.Edit_VstrMemory.Text := IntToStr(CatalogPhone.Data.VstroyennayaMemory);
    if CatalogPhone.Data.IsFrontCamera then
      Form_AddItem.RadioButton_Yes.Checked := True
    else
      Form_AddItem.RadioButton_Yes.Checked := False;
    Form_AddItem.Memo_Description.Text := CatalogPhone.Data.Discription;
  end
  else begin
    Caption := 'Добавление нового элемента';
    Form_AddItem.Edit_PhoneName.Text := '';
    Form_AddItem.ComboBox_TypePhone.Text := '';
    Form_AddItem.Edit_YearVihoda.Text := '';
    Form_AddItem.Edit_Price.Text := '';
    Form_AddItem.Edit_OS.Text := '';
    Form_AddItem.Edit_DisplaySize.Text :=  '';
    Form_AddItem.Edit_DisplayWidth.Text := '';
    Form_AddItem.Edit_DisplayHight.Text := '';
    Form_AddItem.Edit_OperationMemory.Text := '';
    Form_AddItem.Edit_VstrMemory.Text := '';
    Form_AddItem.RadioButton_Yes.Checked := False;
    Form_AddItem.Memo_Description.Text := '';
  end;
end;

// end;

end.
