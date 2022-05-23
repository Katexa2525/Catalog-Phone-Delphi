unit PhoneCatalog;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Menus, Vcl.Grids,
  Vcl.ComCtrls, Vcl.ToolWin, System.ImageList, Vcl.ImgList, ComObj;

const
  FileName = 'Catalog.dat'; // константа с именем для типизированного файла - база данных
  FileTextName = 'CatalogPhone.txt'; //константа с именем для текстового файла

type
  PCatalog = ^TCatalog;
  // тип данных по каталогу телефонов
  TFileCatalog = packed record
    PhoneName: string[30];
    TypeName: String[30];
    YearVihoda: integer;
    Price: Currency;
    OS: String[20];
    DisplaySize: integer;
    DisplayWidth: integer; // разрешение, ширина
    DisplayHigth: integer; // разрешение, длина
    OperationMemory: integer;
    VstroyennayaMemory: integer;
    IsFrontCamera: string[3];
    Discription: String[255]; // описание самого телефона
  end;
  // тип двусвязного списка
  TCatalog = packed record
    Data: TFileCatalog;
    Next: PCatalog;
    Prev: PCatalog
  end;
  // тип для признака сохранения данных - в типизированный файл (по умолчанию), или в текстовый, или в Excel
  TypeFileToSave = (toTypedFile, toTextFile, toExcel);

    TForm_Main = class(TForm)
    Button_Find: TButton;
    Button_Filter: TButton;
    Button_Sort: TButton;
    StringGrid_Catalog: TStringGrid;
    Button_SaveToFile: TButton;
    ToolBar1: TToolBar;
    ToolButton_add: TToolButton;
    ToolButton_edit: TToolButton;
    ToolButton_del: TToolButton;
    ToolButton4: TToolButton;
    ImageList1: TImageList;
    ToolButton_find: TToolButton;
    ToolButton1: TToolButton;
    ToolButton_filter: TToolButton;
    ToolButton_txt: TToolButton;
    ToolButton_excel: TToolButton;
    ToolButton2: TToolButton;
    ToolButton_close: TToolButton;
    PopupMenu_txt: TPopupMenu;
    MenuItem_SaveTxt: TMenuItem;
    MenuItem_ReadTxt: TMenuItem;
    procedure Button_CloseClick(Sender: TObject);
    procedure ShowItemsCatalog;
    procedure FormShow(Sender: TObject);
    function AddItemCatalog(FCount: Cardinal; NPtr: PCatalog): PCatalog;
    procedure Button_SaveToFileClick(Sender: TObject);
    procedure StringGrid_CatalogDblClick(Sender: TObject);
    procedure SaveItemsInFile(NPtr: PCatalog; isSave: boolean; Pr:TypeFileToSave);
    function FindItemFromGrid(NPtr: PCatalog):PCatalog;
    procedure ToolButton_addClick(Sender: TObject);
    procedure ToolButton_editClick(Sender: TObject);
    procedure ToolButton_delClick(Sender: TObject);
    procedure ToolButton_closeClick(Sender: TObject);
    procedure MenuItem_ReadTxtClick(Sender: TObject);
    procedure MenuItem_SaveTxtClick(Sender: TObject);
    procedure ToolButton_excelClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FileCatalog: File of PCatalog; // файловая переменная
  CatalogPhone: PCatalog;
  FFirst, FLast: PCatalog; // метки для вершины и дна связанного списка
  Form_Main: TForm_Main;
  PrTypeFileToSave :TypeFileToSave;

implementation

uses AddItem, FormTextFile;

{$R *.dfm}

////// Функции для работы с двусвязным списком в памяти /////////////////

// добавление элемента в список
function TForm_Main.AddItemCatalog(FCount: Cardinal; NPtr: PCatalog): PCatalog;
begin
  // Новый элемент
  Try
    New(NPtr);
    // Переназначение ссылок
    If FCount = 0 then
    Begin
      // инициализация вершины и дна списка
      FFirst := NPtr;
      FLast := NPtr;
      NPtr^.Prev := nil;
      NPtr^.Next := nil;
    End
    Else if FCount > 0 then
    Begin // организация списка, вставляет новый элемент в конец
      FLast^.Next := NPtr;
      NPtr^.Prev := FLast;
      NPtr^.Next := nil;
      FLast := NPtr;
    End;
    Result := NPtr;
  Except
    Result := nil;
    Exit;
  End;
end;

// функция поиска элемента списка по названию, типу, операционной системе
// начинаем с первого элемента заглушки двусвязного списка NPtr
function FindItemList(pPhoneName, pTypeName, pOS:string; NPtr: PCatalog):PCatalog;
var
  ptr, ptrTemp: PCatalog;
begin
  ptr := NPtr.Next;
  while ptr <> nil do
  begin
    if (ptr.Data.PhoneName=pPhoneName) and (ptr.Data.TypeName=pTypeName) and
       (ptr.Data.OS=pOS) then begin
      break; // выход из цикла, если нашли
    end
    else begin
      ptrTemp := ptr.Next;
      ptr := ptrTemp;
    end;
  end;
  // если вернуло пустой указатель (nil), то не нашли элементи с этими входными параметрами функции
  Result := ptr; // возвращаем элемент списка
end;

// функция удаления указанного элемента из списка
function DeleteItem(NPtr: PCatalog): Boolean;
begin
  If NPtr=nil then
  Begin
    Result:=False; // элемент не удален
    Exit;
  End;

    //Переназначение ссылок
  If NPtr^.Prev=nil then
    FFirst:=NPtr^.Next
  Else
    NPtr^.Prev^.Next:=NPtr^.Next;

  If NPtr^.Next=nil then
    FLast:=NPtr^.Prev
  Else
    NPtr^.Next^.Prev:=NPtr^.Prev;

    //Удаление из памяти элемента
  Dispose(NPtr);
  // возвращаю True, если удачно удален элемент
  Result:=True;
end;

///////////////////////////////////////////////////////////////

procedure TForm_Main.ShowItemsCatalog; // просмотр файла
var
  num: Cardinal; // номер элемента файла
  i: integer;
  NPtr: PCatalog;
  TypedFile: File of TFileCatalog; // файловая переменная
  FCatalog: TFileCatalog;
  P: ^PCatalog;
begin
  // инициализация двусвязного списка
  CatalogPhone := AddItemCatalog(0, CatalogPhone);
  // открытие файла и ассоциация с переменной FileName
  AssignFile(TypedFile, FileName);
  try
    num := 0;
    Inc(num);
    Reset(TypedFile);
    while not Eof(TypedFile) do
    begin
      Read(TypedFile, FCatalog); // читаем элемент из файла
      // добавляю элемент в список
      CatalogPhone := AddItemCatalog(num, NPtr);
      // заполняю данными
      CatalogPhone.Data.PhoneName := FCatalog.PhoneName;
      CatalogPhone.Data.TypeName := FCatalog.TypeName;
      CatalogPhone.Data.YearVihoda := FCatalog.YearVihoda;
      CatalogPhone.Data.Price := FCatalog.Price;
      CatalogPhone.Data.OS := FCatalog.OS;
      CatalogPhone.Data.DisplaySize := FCatalog.DisplaySize;
      CatalogPhone.Data.DisplayWidth := FCatalog.DisplayWidth;
      CatalogPhone.Data.DisplayHigth := FCatalog.DisplayHigth;
      CatalogPhone.Data.OperationMemory := FCatalog.OperationMemory;
      CatalogPhone.Data.VstroyennayaMemory := FCatalog.VstroyennayaMemory;
      CatalogPhone.Data.IsFrontCamera := FCatalog.IsFrontCamera;
      CatalogPhone.Data.Discription := FCatalog.Discription;
      // записываю данные в грид из элемента списка
      with StringGrid_Catalog do
      begin
        i := RowCount-1 ; // строка для записи в грид
        Cells[0, i] := IntToStr(num);
        Cells[1, i] := CatalogPhone.Data.PhoneName;
        Cells[2, i] := CatalogPhone.Data.TypeName;
        Cells[3, i] := IntToStr(CatalogPhone.Data.YearVihoda);
        Cells[4, i] := CurrToStr(CatalogPhone.Data.Price);
        Cells[5, i] := CatalogPhone.Data.OS;
        Cells[6, i] := IntToStr(CatalogPhone.Data.DisplaySize);
        Cells[7, i] := IntToStr(CatalogPhone.Data.DisplayWidth);
        Cells[8, i] := IntToStr(CatalogPhone.Data.DisplayHigth);
        Cells[9, i] := IntToStr(CatalogPhone.Data.OperationMemory);
        Cells[10, i] := IntToStr(CatalogPhone.Data.VstroyennayaMemory);
        Cells[11, i] := CatalogPhone.Data.IsFrontCamera;
        Cells[12, i] := CatalogPhone.Data.Discription;
        RowCount := RowCount + 1; // Увеличиваем количество строк на 1
        //P := @CatalogPhone^; // адрес в памяти элемента списка
      end;
      Inc(num);
    end;
  finally
    CloseFile(TypedFile);
    StringGrid_Catalog.RowCount:=StringGrid_Catalog.RowCount - 1; // Увеличиваем количество строк на 1
  end;
end;

function TForm_Main.FindItemFromGrid(NPtr: PCatalog):PCatalog;
var
  numRow:integer;
begin
  numRow:=StringGrid_Catalog.Row; // получаю выделенную строку таблицы
  // проверяю, выбрана ли строка данных в гриде, а не заголовочная часть
  if (StringGrid_Catalog.Cells[1,numRow]='Название') and (StringGrid_Catalog.Cells[2,numRow]='Тип') and
     (StringGrid_Catalog.Cells[5,numRow]='Операционная система') then
    begin
      MessageDlg('Выберите строку данных для редактирования!', mtInformation, [mbOk], 0, mbOk);
      Result:= nil;
    end
  else
    CatalogPhone:=FindItemList(StringGrid_Catalog.Cells[1,numRow],
                               StringGrid_Catalog.Cells[2,numRow],
                               StringGrid_Catalog.Cells[5,numRow], FFirst);

  Result:= CatalogPhone;
end;

// двойной щелчок по строке грида для получения формы редактирования
procedure TForm_Main.StringGrid_CatalogDblClick(Sender: TObject);
begin
  CatalogPhone:=FindItemFromGrid(FFirst);
  AddItem.Form_AddItem.Tag:=1; // признак редактирования для формы
  AddItem.Form_AddItem.ShowModal();
end;

procedure TForm_Main.ToolButton_addClick(Sender: TObject);
begin
  AddItem.Form_AddItem.Tag:=0; // признак добавления для формы
  AddItem.Form_AddItem.ShowModal();
end;

// выход из приложения
procedure TForm_Main.ToolButton_closeClick(Sender: TObject);
begin
  // сохраняю в файл перед выходом
  SaveItemsInFile(FFirst, true, toTypedFile);
  // закрываю форму и приложение
  Close;
end;

// редактирование элемента из списка
procedure TForm_Main.ToolButton_editClick(Sender: TObject);
begin
  CatalogPhone:=FindItemFromGrid(FFirst);
  if CatalogPhone <> nil then
  begin
    AddItem.Form_AddItem.Tag:=1; // признак редактирования для формы
    AddItem.Form_AddItem.ShowModal();
  end;
end;

// выгрузка в Excel
procedure TForm_Main.ToolButton_excelClick(Sender: TObject);
begin
  // сохраняю в excel файл
  SaveItemsInFile(FFirst, true, toExcel);
end;

// удаление элемента из списка
procedure TForm_Main.ToolButton_delClick(Sender: TObject);
begin
if MessageDlg('Желаете удалить элемент списка?',mtConfirmation, [mbYes, mbNo], 0, mbNo) = mrYes then
  begin
    // сначала находим элемент в двусвязном списке по данным из грида
    CatalogPhone:=FindItemFromGrid(FFirst);
    // удаляем элемент из списка и из памяти, перераспределяя ссылки
    if DeleteItem(CatalogPhone) then
    begin
      // сохраняю в файл из памяти списка с измененным элементом
      Form_Main.SaveItemsInFile(FFirst, true, toTypedFile);
      // отображаю из файла в грид на главной форме
      Form_Main.StringGrid_Catalog.RowCount:=2; // удаляю строки грида
      // формируем заново из файла
      Form_Main.ShowItemsCatalog();
      MessageDlg('Элемент успешно удален!', mtInformation, [mbOk], 0, mbOk);
    end;
    StringGrid_Catalog.SetFocus;
  end;
end;

procedure TForm_Main.Button_CloseClick(Sender: TObject);
begin
  // сохраняю в файл перед выходом
  SaveItemsInFile(FFirst, true, toTypedFile);
  // закрываю форму и приложение
  Close;
end;

procedure TForm_Main.FormShow(Sender: TObject);
begin
  // задаю кол-во столбцов грида
  StringGrid_Catalog.ColCount := 14;
  // заглавия столбцов
  StringGrid_Catalog.Cells[1, 0] := 'Название';
  StringGrid_Catalog.Cells[2, 0] := 'Тип';
  StringGrid_Catalog.Cells[3, 0] := 'Год выхода';
  StringGrid_Catalog.Cells[4, 0] := 'Цена';
  StringGrid_Catalog.Cells[5, 0] := 'Операционная система';
  StringGrid_Catalog.Cells[6, 0] := 'Размер диагонали';
  StringGrid_Catalog.Cells[7, 0] := 'Ширина';
  StringGrid_Catalog.Cells[8, 0] := 'Высота';
  StringGrid_Catalog.Cells[9, 0] := 'ОЗУ';
  StringGrid_Catalog.Cells[10, 0] := 'ПЗУ';
  StringGrid_Catalog.Cells[11, 0] := 'Фронтальная камера';
  StringGrid_Catalog.Cells[12, 0] := 'Описание';
  //
  ShowItemsCatalog(); // формируем данные для грида
end;


// прочитать данные из txt файла
procedure TForm_Main.MenuItem_ReadTxtClick(Sender: TObject);
begin
  FormTextFile.Form_TextFile.ShowModal();
end;

// сохранить в тектовый файл
procedure TForm_Main.MenuItem_SaveTxtClick(Sender: TObject);
begin
  SaveItemsInFile(FFirst, true, toTextFile);
  MessageDlg('Данные сохранены в текстовый файл '+FileTextName+'!', mtInformation, [mbOk], 0, mbOk);
end;

// процедура записи в типизированный или текстовый файл
procedure TForm_Main.SaveItemsInFile(NPtr: PCatalog; isSave: boolean; Pr:TypeFileToSave);
const
  xlHAlignCenter = -4108;
  xlVAlignCenter = -4108;
var
  ptr, ptrTemp: PCatalog;
  FText : TextFile; // файловая переменная для записи в текстовый файл
  TypedFile: File of TFileCatalog; // файловая переменная
  FCatalog: TFileCatalog;
  StrToTextFile, CameraStr:string;
  ExcelObj, Workbook, Sheet, Range: variant;  // переменная для объекта Excel
  BeginCol, BeginRow : integer;
begin
  if isSave then
  begin
    if Pr = toTypedFile then
      // открытие файла и ассоциация с переменной FileName типизированного файла
      AssignFile(TypedFile, FileName)
    else if Pr = toTextFile then
      // открытие файла и ассоциация с переменной FText текстового файла
      AssignFile(FText, FileTextName);
    try
      if Pr = toTypedFile then
        Rewrite(TypedFile) // создаю новый типизированный файл, перезаписываю старый, если есть
      else if Pr = toTextFile then begin
        Rewrite(FText); // создаю новый текстовый файл, перезаписываю старый, если есть
        // Колонки с названиями в текстовом файле
        StrToTextFile:='          Название           |             Тип             | Год выхода | Цена | Операционная система | Размер диагонали | Ширина | Высота | ОЗУ | ПЗУ | Фронтальная камера | Описание ';
        // Запись в текстовый файл названия колонок
        Writeln(FText, StrToTextFile);
      end
      else if Pr = toExcel then begin
        ExcelObj:=CreateOleObject('Excel.Application'); // запускаем excel приложение и ассоциацию на переменную ExcelObj
        ExcelObj.Application.EnableEvents := false; // Отключаю реакцию Excel на события, чтобы ускорить вывод информации
        ExcelObj.DisplayAlerts := False; // отключаю все сообщения Excel
        Workbook:=ExcelObj.WorkBooks.Add; // добавляем книгу и ассоциацию на переменную Workbook
        Sheet:=Workbook.Sheets.item[1]; // получаю первый лист в книге и ассоциацию на переменную Sheet, куда и буду писать данные
        // заголовок и наименования столбцов
        BeginCol:=1; // первый столбец
        BeginRow:=3; // начинаю с третьей строки
        Sheet.Cells(1,BeginCol):='Каталог телефонов';  // заголовок на листе
        Range := Sheet.Cells[1,BeginCol];
        Range.Font.Bold := True; // жирный шрифт
        Range.Font.Size:=14; // размер шрифта
        Sheet.Cells(BeginRow, 1):='Название';
        Sheet.Cells(BeginRow, 2):='Тип';
        Sheet.Cells(BeginRow, 3):='Год выхода';
        Sheet.Cells(BeginRow, 4):='Цена';
        Sheet.Cells(BeginRow, 5):='Операционная система';
        Sheet.Cells(BeginRow, 6):='Размер диагонали';
        Sheet.Cells(BeginRow, 7):='Ширина';
        Sheet.Cells(BeginRow, 8):='Высота';
        Sheet.Cells(BeginRow, 9):='ОЗУ';
        Sheet.Cells(BeginRow, 10):='ПЗУ';
        Sheet.Cells(BeginRow, 11):='Фронтальная камера';
        Sheet.Cells(BeginRow, 12):='Описание';
        // оформление заголовков столбцов
        Range := Sheet.Range['A3:L3']; // выбран диапозон ячеек заголовков столбцов
        Range.HorizontalAlignment:=xlHAlignCenter; // центрирование по горизонтали
        Range.VerticalAlignment:=xlVAlignCenter;  // центрирование по вертикали
        Range.Font.Bold := True; // жирный шрифт
        // настраиваю ширину столбцов
        Sheet.Range['B:B'].ColumnWidth := 15;
        Sheet.Range['C:C'].ColumnWidth := 15;
        Sheet.Range['D:D'].ColumnWidth := 15;
        Sheet.Range['E:E'].ColumnWidth := 26;
        Sheet.Range['F:F'].ColumnWidth := 20;
        Sheet.Range['K:K'].ColumnWidth := 25;
        Sheet.Range['L:L'].ColumnWidth := 42;
        Sheet.Range['A:A'].ColumnWidth := 18;
        Inc(BeginRow);
      end;
      // проходимся по двусвязному списку
      ptr := NPtr.Next;
      while ptr <> nil do
      begin
        //////////////////////////////////////////////////////////
        if Pr = toTypedFile then // запись в типизированный файл
        begin
          FCatalog.PhoneName := ptr.Data.PhoneName;
          FCatalog.TypeName := ptr.Data.TypeName;
          FCatalog.YearVihoda := ptr.Data.YearVihoda;
          FCatalog.Price := ptr.Data.Price;
          FCatalog.OS := ptr.Data.OS;
          FCatalog.DisplaySize := ptr.Data.DisplaySize;
          FCatalog.DisplayWidth := ptr.Data.DisplayWidth;
          FCatalog.DisplayHigth := ptr.Data.DisplayHigth;
          FCatalog.OperationMemory := ptr.Data.OperationMemory;
          FCatalog.VstroyennayaMemory := ptr.Data.VstroyennayaMemory;
          FCatalog.IsFrontCamera := ptr.Data.IsFrontCamera;
          FCatalog.Discription := ptr.Data.Discription;
          // запись в файл
          Write(TypedFile, FCatalog); // вставляем новый элемент
        end
        ///////////////////////////////////////////
        else if Pr = toTextFile then // запись в текстовый файл
        begin
          // формирую строку для записи в текстовый файл
          StrToTextFile:=ptr.Data.PhoneName;
          // добавляю пробелы, чтобы красиво смотрелось в тектовом файле
          if Length(ptr.Data.PhoneName)<30 then StrToTextFile:=StrToTextFile+StringOfChar(' ',30-Length(ptr.Data.PhoneName));
          StrToTextFile:=StrToTextFile+ptr.Data.TypeName;
          if Length(ptr.Data.TypeName)<30 then StrToTextFile:=StrToTextFile+StringOfChar(' ',30-Length(ptr.Data.TypeName));
          StrToTextFile:=StrToTextFile+IntToStr(ptr.Data.YearVihoda);
          if Length(IntToStr(ptr.Data.YearVihoda))<13 then StrToTextFile:=StrToTextFile+StringOfChar(' ',13-Length(IntToStr(ptr.Data.YearVihoda)));
          StrToTextFile:=StrToTextFile+CurrToStr(ptr.Data.Price);
          if Length(CurrToStr(ptr.Data.Price))<7 then StrToTextFile:=StrToTextFile+StringOfChar(' ',7-Length(CurrToStr(ptr.Data.Price)));
          StrToTextFile:=StrToTextFile+ptr.Data.OS;
          if Length(ptr.Data.OS)<23 then StrToTextFile:=StrToTextFile+StringOfChar(' ',23-Length(ptr.Data.OS));
          StrToTextFile:=StrToTextFile+IntToStr(ptr.Data.DisplaySize);
          if Length(IntToStr(ptr.Data.DisplaySize))<19 then StrToTextFile:=StrToTextFile+StringOfChar(' ',19-Length(IntToStr(ptr.Data.DisplaySize)));
          StrToTextFile:=StrToTextFile+IntToStr(ptr.Data.DisplayWidth);
          if Length(IntToStr(ptr.Data.DisplayWidth))<9 then StrToTextFile:=StrToTextFile+StringOfChar(' ',9-Length(IntToStr(ptr.Data.DisplayWidth)));
          StrToTextFile:=StrToTextFile+IntToStr(ptr.Data.DisplayHigth);
          if Length(IntToStr(ptr.Data.DisplayHigth))<9 then StrToTextFile:=StrToTextFile+StringOfChar(' ',9-Length(IntToStr(ptr.Data.DisplayHigth)));
          StrToTextFile:=StrToTextFile+IntToStr(ptr.Data.OperationMemory);
          if Length(IntToStr(ptr.Data.OperationMemory))<6 then StrToTextFile:=StrToTextFile+StringOfChar(' ',6-Length(IntToStr(ptr.Data.OperationMemory)));
          StrToTextFile:=StrToTextFile+IntToStr(ptr.Data.VstroyennayaMemory);
          if Length(IntToStr(ptr.Data.VstroyennayaMemory))<6 then StrToTextFile:=StrToTextFile+StringOfChar(' ',6-Length(IntToStr(ptr.Data.VstroyennayaMemory)));
          StrToTextFile:=StrToTextFile+ptr.Data.IsFrontCamera;
          if Length(ptr.Data.IsFrontCamera)<21 then StrToTextFile:=StrToTextFile+StringOfChar(' ',21-Length(ptr.Data.IsFrontCamera));
          StrToTextFile:=StrToTextFile+ptr.Data.Discription;
          // запись в текстовый файл сформированной строки
          Writeln(FText, StrToTextFile);
        end
        ////////////////////////////////////////////////////////////
        else if Pr = toExcel then begin // запись в excel файл
          Sheet.Cells(BeginRow, 1):=ptr.Data.PhoneName;
          Sheet.Cells(BeginRow, 2):=ptr.Data.TypeName;
          Sheet.Cells(BeginRow, 3):=ptr.Data.YearVihoda;
          Sheet.Cells(BeginRow, 4):=ptr.Data.Price;
          Sheet.Cells(BeginRow, 5):=ptr.Data.OS;
          Sheet.Cells(BeginRow, 6):=ptr.Data.DisplaySize;
          Sheet.Cells(BeginRow, 7):=ptr.Data.DisplayWidth;
          Sheet.Cells(BeginRow, 8):=ptr.Data.DisplayHigth;
          Sheet.Cells(BeginRow, 9):=ptr.Data.OperationMemory;
          Sheet.Cells(BeginRow, 10):=ptr.Data.VstroyennayaMemory;
          Sheet.Cells(BeginRow, 11):=ptr.Data.IsFrontCamera;
          Sheet.Cells(BeginRow, 12):=ptr.Data.Discription;
          Inc(BeginRow);
        end;
        // переход к следующему элементу
        ptrTemp := ptr.Next;
        ptr := ptrTemp;
      end;
      if Pr = toExcel then
        ExcelObj.Visible := true; // Делаю Excel видимым после прохода по двусвязному списку
    finally
      if Pr = toTypedFile then // закрываю типизированный файл
        CloseFile(TypedFile)
      else if Pr = toTextFile then // закрываю текстовый файл
        CloseFile(FText);
    end;
  end;
end; { вызов процедуры добавления элемента (листинг 6.5) }

procedure TForm_Main.Button_SaveToFileClick(Sender: TObject);
begin
  // сохраняю в файл
  SaveItemsInFile(FFirst, true, toTypedFile);
  // ShowMessage('Данные сохранены в файл');
  MessageDlg('Данные сохранены в файл', mtInformation, [mbOk], 0, mbOk);
end;


end.
