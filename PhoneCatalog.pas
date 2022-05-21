unit PhoneCatalog;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Menus, Vcl.Grids,
  Vcl.ComCtrls, Vcl.ToolWin, System.ImageList, Vcl.ImgList;

const
  FileName = 'Catalog.dat'; // константа с именем для типизированного файла
  FileTextName = 'CatalogPhone.txt'; //константа с именем для текстового файла

type
  PCatalog = ^TCatalog;
  // тип данных по каталогу телефонов
  TFileCatalog = packed record
    PhoneName: string[30];
    TypeName: String[30];
    YearVihoda: integer;
    Price: integer;
    OS: String[20];
    DisplaySize: integer;
    DisplayWidth: integer; // разрешение, ширина
    DisplayHigth: integer; // разрешение, длина
    OperationMemory: integer;
    VstroyennayaMemory: integer;
    IsFrontCamera: boolean;
    Discription: String[255]; // описание самого телефона
    PhonePhoto: String[255];
  end;
  // тип двусвязного списка
  TCatalog = packed record
    Data: TFileCatalog;
    Next: PCatalog;
    Prev: PCatalog
  end;

    TForm_Main = class(TForm)Button_Close: TButton;
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
    ToolButton3: TToolButton;
    ToolButton2: TToolButton;
    ToolButton5: TToolButton;
    procedure Button_CloseClick(Sender: TObject);
    procedure ShowItemsCatalog;
    procedure FormShow(Sender: TObject);
    function AddItemCatalog(FCount: Cardinal; NPtr: PCatalog): PCatalog;
    procedure Button_SaveToFileClick(Sender: TObject);
    procedure StringGrid_CatalogDblClick(Sender: TObject);
    procedure SaveItemsInFile(NPtr: PCatalog; isSave: boolean);
    function FindItemFromGrid(NPtr: PCatalog):PCatalog;
    procedure ToolButton_addClick(Sender: TObject);
    procedure ToolButton_editClick(Sender: TObject);
    procedure ToolButton_delClick(Sender: TObject);
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

implementation

uses AddItem;

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
      CatalogPhone.Data.PhonePhoto := FCatalog.PhonePhoto;
      // записываю данные в грид из элемента списка
      with StringGrid_Catalog do
      begin
        i := RowCount-1 ; // строка для записи в грид
        Cells[0, i] := IntToStr(num);
        Cells[1, i] := CatalogPhone.Data.PhoneName;
        Cells[2, i] := CatalogPhone.Data.TypeName;
        Cells[3, i] := IntToStr(CatalogPhone.Data.YearVihoda);
        Cells[4, i] := IntToStr(CatalogPhone.Data.Price);
        Cells[5, i] := CatalogPhone.Data.OS;
        Cells[6, i] := IntToStr(CatalogPhone.Data.DisplaySize);
        Cells[7, i] := IntToStr(CatalogPhone.Data.DisplayWidth);
        Cells[8, i] := IntToStr(CatalogPhone.Data.DisplayHigth);
        Cells[9, i] := IntToStr(CatalogPhone.Data.OperationMemory);
        Cells[10, i] := IntToStr(CatalogPhone.Data.VstroyennayaMemory);
        Cells[11, i] := BoolToStr(CatalogPhone.Data.IsFrontCamera);
        Cells[12, i] := CatalogPhone.Data.Discription;
        Cells[13, i] := CatalogPhone.Data.PhonePhoto;
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

// добавление элемента в список
procedure TForm_Main.ToolButton_addClick(Sender: TObject);
begin
  AddItem.Form_AddItem.Tag:=0; // признак добавления для формы
  AddItem.Form_AddItem.ShowModal();
end;

// редактирование элемента из списка
procedure TForm_Main.ToolButton_editClick(Sender: TObject);
begin
 CatalogPhone:=FindItemFromGrid(FFirst);
  AddItem.Form_AddItem.Tag:=1; // признак редактирования для формы
  AddItem.Form_AddItem.ShowModal();
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
      Form_Main.SaveItemsInFile(FFirst, true);
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
  SaveItemsInFile(FFirst, true);
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
  StringGrid_Catalog.Cells[5, 0] := 'Оперативная система';
  StringGrid_Catalog.Cells[6, 0] := 'Размер диагонали';
  StringGrid_Catalog.Cells[7, 0] := 'Ширина';
  StringGrid_Catalog.Cells[8, 0] := 'Высота';
  StringGrid_Catalog.Cells[9, 0] := 'Оперативная память';
  StringGrid_Catalog.Cells[10, 0] := 'Встроенная память';
  StringGrid_Catalog.Cells[11, 0] := 'Фронтальная камера';
  StringGrid_Catalog.Cells[12, 0] := 'Описание';
  StringGrid_Catalog.Cells[13, 0] := 'Фото';
  StringGrid_Catalog.Cells[14, 0] := 'Адрес в списке';
  //
  ShowItemsCatalog(); // формируем данные для грида
end;

procedure TForm_Main.SaveItemsInFile(NPtr: PCatalog; isSave: boolean);
var
  ptr, ptrTemp: PCatalog;
  TypedFile: File of TFileCatalog; // файловая переменная
  FCatalog: TFileCatalog;
begin
  if isSave then
  begin
    // открытие файла и ассоциация с переменной FileName
    AssignFile(TypedFile, FileName);
    try
      // FileMode := 1; // режим записи
      Rewrite(TypedFile); // создаю новый файл, перезаписываю старый, если есть
      // Seek(FileCatalog, FileSize(FileCatalog)); // перемещаемся в конец файла
      // проходимся по двусвязному списку
      ptr := NPtr.Next;
      while ptr <> nil do
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
        FCatalog.PhonePhoto := ptr.Data.PhonePhoto;
        //
        Write(TypedFile, FCatalog); // вставляем новый элемент
        ptrTemp := ptr.Next;
        ptr := ptrTemp;
      end;
    finally
      CloseFile(TypedFile);
    end;
  end;
end; { вызов процедуры добавления элемента (листинг 6.5) }

procedure TForm_Main.Button_SaveToFileClick(Sender: TObject);
begin
  // сохраняю в файл
  SaveItemsInFile(FFirst, true);
  // ShowMessage('Данные сохранены в файл');
  MessageDlg('Данные сохранены в файл', mtInformation, [mbOk], 0, mbOk);
end;


end.
