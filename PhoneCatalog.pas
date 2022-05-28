unit PhoneCatalog;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Menus, Vcl.Grids,
  Vcl.ComCtrls, Vcl.ToolWin, System.ImageList, Vcl.ImgList, ComObj;

const
  FileName = 'Catalog.dat';
  // константа с именем для типизированного файла - база данных
  FileTextName = 'CatalogPhone.txt'; // константа с именем для текстового файла

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
    Prev: PCatalog end;
    // тип для признака сохранения данных - в типизированный файл (по умолчанию), или в текстовый, или в Excel
    TypeFileToSave = (toTypedFile, toTextFile, toExcel);
    // тип для признака сортировки: toASC - по возрастанию, toDESC - по убыванию
    TypeToSort = (toASC, toDESC);

    TForm_Main = class(TForm)StringGrid_Catalog: TStringGrid;
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
    ToolButton3: TToolButton;
    ToolButton_about: TToolButton;
    procedure Button_CloseClick(Sender: TObject);
    procedure ShowItemsCatalog;
    procedure ShowItemsSortCatalog;
    procedure FormShow(Sender: TObject);
    function AddItemCatalog(FCount: Cardinal; NPtr: PCatalog): PCatalog;
    procedure StringGrid_CatalogDblClick(Sender: TObject);
    procedure SaveItemsInFile(NPtr: PCatalog; isSave: boolean; Pr: TypeFileToSave);
    function FindItemFromGrid(NPtr: PCatalog): PCatalog;
    procedure ToolButton_addClick(Sender: TObject);
    procedure ToolButton_editClick(Sender: TObject);
    procedure ToolButton_delClick(Sender: TObject);
    procedure ToolButton_closeClick(Sender: TObject);
    procedure MenuItem_ReadTxtClick(Sender: TObject);
    procedure MenuItem_SaveTxtClick(Sender: TObject);
    procedure ToolButton_excelClick(Sender: TObject);
    procedure StringGrid_CatalogFixedCellClick(Sender: TObject; ACol, ARow: integer);
    procedure SetColumnHeaders(StringGrid_Catalog: TStringGrid);
    procedure ToolButton_aboutClick(Sender: TObject);
    function GetBestValue(Ptr_1, PtrBestValue:PCatalog; PrSort: TypeToSort; NCol:integer): PCatalog;
    function IsValuesDifferent(Ptr_1, PtrBestValue:PCatalog; NCol:integer): boolean;
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
  PrTypeFileToSave: TypeFileToSave;
  PrTypeToSort: TypeToSort;

implementation

uses AddItem, FormTextFile, AboutProgram;

{$R *.dfm}
/// /// Функции для работы с двусвязным списком в памяти /////////////////

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
function FindItemList(pPhoneName, pTypeName, pOS: string; NPtr: PCatalog)
  : PCatalog;
var
  ptr, ptrTemp: PCatalog;
begin
  ptr := NPtr.Next;
  while ptr <> nil do
  begin
    if (ptr.Data.PhoneName = pPhoneName) and (ptr.Data.TypeName = pTypeName) and
      (ptr.Data.OS = pOS) then
    begin
      break; // выход из цикла, если нашли
    end
    else
    begin
      ptrTemp := ptr.Next;
      ptr := ptrTemp;
    end;
  end;
  // если вернуло пустой указатель (nil), то не нашли элементи с этими входными параметрами функции
  Result := ptr; // возвращаем элемент списка
end;

// функция удаления указанного элемента из списка
function DeleteItem(NPtr: PCatalog): boolean;
begin
  If NPtr = nil then
  Begin
    Result := False; // элемент не удален
    Exit;
  End;

  // Переназначение ссылок
  If NPtr^.Prev = nil then
    FFirst := NPtr^.Next
  Else
    NPtr^.Prev^.Next := NPtr^.Next;

  If NPtr^.Next = nil then
    FLast := NPtr^.Prev
  Else
    NPtr^.Next^.Prev := NPtr^.Prev;

  // Удаление из памяти элемента
  Dispose(NPtr);
  // возвращаю True, если удачно удален элемент
  Result := True;
end;

// процедура очистки памяти от элементов списка
procedure ClearList;
var
  Second: PCatalog;
begin
  If FFirst = nil then
    Exit;

  Repeat
    Second := FFirst^.Next;
    Dispose(FFirst);
    FFirst := Second;
  Until FFirst = nil;
  FLast := nil;
end;

// Cчитает количество элементов списка
function CalculateItems: Cardinal;
var
  i: Cardinal;
  ptr: PCatalog;
begin
  i := 0;
  ptr := FFirst;
  While ptr <> FLast do
  Begin
    ptr := ptr^.Next;
    Inc(i);
  End;
  Result := i;
end;

//Вставка нового элемента PtrNew после элемента с адресом NPtr
Procedure AddAfterItem(NPtr: PCatalog; DataNew: TFileCatalog);
var
  PtrNew:PCatalog;
begin // Нельзя добавлять в конец
  if (NPtr=nil) or (NPtr^.Next=nil) then exit;
  New(PtrNew);
  PtrNew^.Data:=DataNew;
  PtrNew^.Next:=NPtr^.Next;
  PtrNew^.Prev:=NPtr;
  NPtr^.Next:=PtrNew;
  PtrNew^.Next^.Prev:=PtrNew;
end;

//Вставка нового элемента PtrNew перед элементом с адресом NPtr
Procedure AddBeforeItem(NPtr: PCatalog; DataNew: TFileCatalog);
var
  PtrNew:PCatalog;
begin // Нельзя добавлять в начало
  if (NPtr=nil) or (NPtr^.Prev=nil) then exit;
  New(PtrNew);
  PtrNew^.Data:=DataNew;
  PtrNew^.Next:=NPtr;
  PtrNew^.Prev:=NPtr^.Prev;
  NPtr^.Prev^.Next:=PtrNew;
  NPtr^.Prev:=PtrNew;
end;

//Вставка нового NPtr элемента в конец очереди, где NPtrEnd последний элемент
Procedure AddItemEndList(var NPtr,NPtrEnd:PCatalog; DataNew: TFileCatalog);
var
  PtrNew:PCatalog;
begin
  New(PtrNew);
  PtrNew^.Data:=DataNew;
  PtrNew^.Next:=nil;
  if NPtrEnd=nil then
  begin
    PtrNew^.Prev:=nil;
    NPtr:=PtrNew;
    NPtrEnd:=PtrNew;
  end
  else
  begin
    PtrNew^.Prev:=NPtrEnd;
    NPtrEnd^.Next:=PtrNew;
    NPtrEnd:=PtrNew;
  end;
end;

// Меняю местами элементы El1 и El2 в списке.
procedure ChangeItems(El1, El2: PCatalog);
var
  DataTemp: TFileCatalog; // запись с данными
begin
  DataTemp:=El1^.Data;
  // удаляю El1, чтобы вставить его данные после El2 через новый указатель
  if DeleteItem(El1)=true then
    AddItemEndList(El2, FLast, DataTemp);
end;

// сортировка выбором: ищу наименьший элемент, который затем меняется местами с элементом из начала списка,
// далее находится наименьший из оставшихся элементов и меняется местами со вторым элементом и тд
procedure SortItems(PrSort: TypeToSort; NCol:integer);
var
  ptr, Ptr_1, PtrBestValue: PCatalog;
begin
  ptr := FFirst^.Next;
  While ptr <> nil do // первый цикл с начала списка
  Begin
    PtrBestValue := ptr; // значение наименьшего элемента
    // проход до конца списка со следующего элемента и нахождение мин элемента
    Ptr_1 := ptr^.Next;
    While Ptr_1 <> nil do // второй цикл со следующего элемента списка
    begin
      // получаю значение наименьшего или наибольшего элемента в зависимости от типа сортировки
      PtrBestValue := Form_Main.GetBestValue(Ptr_1, PtrBestValue, PrSort, NCol);
      // к след элементу
      Ptr_1 := Ptr_1^.Next;
    end;
    // наименьший элемент PtrBestValue найден, переставляю с елементом Ptr
    if Form_Main.IsValuesDifferent(ptr, PtrBestValue, NCol)=True then begin
      ChangeItems(ptr, PtrBestValue);
      ptr := FFirst^.Next; // начинаю сначала
    end
    else
      ptr := ptr^.Next; // к след элементу
  End;
  // перерисовываю форму по двусвязному списку из памяти
  Form_Main.ShowItemsSortCatalog();
end;

function TForm_Main.GetBestValue(Ptr_1, PtrBestValue:PCatalog; PrSort: TypeToSort; NCol:integer): PCatalog;
begin
  case NCol of
   1: begin
     if ((AnsiCompareStr(Ptr_1.Data.PhoneName, PtrBestValue.Data.PhoneName)<0) and (PrSort = TypeToSort.toASC)) or
        ((AnsiCompareStr(Ptr_1.Data.PhoneName, PtrBestValue.Data.PhoneName)>0) and (PrSort = TypeToSort.toDESC)) then
      PtrBestValue := Ptr_1 // значение наименьшего или наибольшего элемента
   end;
   2: begin
     if ((AnsiCompareStr(Ptr_1.Data.TypeName, PtrBestValue.Data.TypeName)<0) and (PrSort = TypeToSort.toASC)) or
        ((AnsiCompareStr(Ptr_1.Data.TypeName, PtrBestValue.Data.TypeName)>0) and (PrSort = TypeToSort.toDESC)) then
      PtrBestValue := Ptr_1 // значение наименьшего или наибольшего элемента
   end;
   3: begin
     if ((Ptr_1.Data.YearVihoda < PtrBestValue.Data.YearVihoda) and (PrSort = TypeToSort.toASC)) or
        ((Ptr_1.Data.YearVihoda > PtrBestValue.Data.YearVihoda) and (PrSort = TypeToSort.toDESC)) then
      PtrBestValue := Ptr_1 // значение наименьшего или наибольшего элемента
   end;
   4: begin
    if ((Ptr_1.Data.Price < PtrBestValue.Data.Price) and (PrSort = TypeToSort.toASC)) or
       ((Ptr_1.Data.Price > PtrBestValue.Data.Price) and (PrSort = TypeToSort.toDESC)) then
      PtrBestValue := Ptr_1; // значение наименьшего или наибольшего элемента
   end;
   5: begin
     if ((AnsiCompareStr(Ptr_1.Data.OS, PtrBestValue.Data.OS)<0) and (PrSort = TypeToSort.toASC)) or
        ((AnsiCompareStr(Ptr_1.Data.OS, PtrBestValue.Data.OS)>0) and (PrSort = TypeToSort.toDESC)) then
      PtrBestValue := Ptr_1 // значение наименьшего или наибольшего элемента
   end;
   6: begin
    if ((Ptr_1.Data.DisplaySize < PtrBestValue.Data.DisplaySize) and (PrSort = TypeToSort.toASC)) or
       ((Ptr_1.Data.DisplaySize > PtrBestValue.Data.DisplaySize) and (PrSort = TypeToSort.toDESC)) then
      PtrBestValue := Ptr_1; // значение наименьшего или наибольшего элемента
   end;
   7: begin
    if ((Ptr_1.Data.DisplayWidth < PtrBestValue.Data.DisplayWidth) and (PrSort = TypeToSort.toASC)) or
       ((Ptr_1.Data.DisplayWidth > PtrBestValue.Data.DisplayWidth) and (PrSort = TypeToSort.toDESC)) then
      PtrBestValue := Ptr_1; // значение наименьшего или наибольшего элемента
   end;
   8: begin
     if ((Ptr_1.Data.DisplayHigth < PtrBestValue.Data.DisplayHigth) and (PrSort = TypeToSort.toASC)) or
        ((Ptr_1.Data.DisplayHigth > PtrBestValue.Data.DisplayHigth) and (PrSort = TypeToSort.toDESC)) then
       PtrBestValue := Ptr_1; // значение наименьшего или наибольшего элемента
   end;
   9: begin
    if ((Ptr_1.Data.OperationMemory < PtrBestValue.Data.OperationMemory) and (PrSort = TypeToSort.toASC)) or
       ((Ptr_1.Data.OperationMemory > PtrBestValue.Data.OperationMemory) and (PrSort = TypeToSort.toDESC)) then
      PtrBestValue := Ptr_1; // значение наименьшего или наибольшего элемента
   end;
   10: begin
    if ((Ptr_1.Data.VstroyennayaMemory < PtrBestValue.Data.VstroyennayaMemory) and (PrSort = TypeToSort.toASC)) or
       ((Ptr_1.Data.VstroyennayaMemory > PtrBestValue.Data.VstroyennayaMemory) and (PrSort = TypeToSort.toDESC)) then
      PtrBestValue := Ptr_1;// значение наименьшего или наибольшего элемента
   end;
   11: begin
     if ((AnsiCompareStr(Ptr_1.Data.IsFrontCamera, PtrBestValue.Data.IsFrontCamera)<0) and (PrSort = TypeToSort.toASC)) or
        ((AnsiCompareStr(Ptr_1.Data.IsFrontCamera, PtrBestValue.Data.IsFrontCamera)>0) and (PrSort = TypeToSort.toDESC)) then
      PtrBestValue := Ptr_1 // значение наименьшего или наибольшего элемента
   end;
   12: begin
     if ((AnsiCompareStr(Ptr_1.Data.Discription, PtrBestValue.Data.Discription)<0) and (PrSort = TypeToSort.toASC)) or
        ((AnsiCompareStr(Ptr_1.Data.Discription, PtrBestValue.Data.Discription)>0) and (PrSort = TypeToSort.toDESC)) then
      PtrBestValue := Ptr_1 // значение наименьшего или наибольшего элемента
   end;
  end;

  Result := PtrBestValue;
end;

function TForm_Main.IsValuesDifferent(Ptr_1, PtrBestValue:PCatalog; NCol:integer): boolean;
begin
  case NCol of
   1: begin
     if AnsiCompareStr(Ptr_1.Data.PhoneName, PtrBestValue.Data.PhoneName)<>0 then
      Result := True;
   end;
   2: begin
     if AnsiCompareStr(Ptr_1.Data.TypeName, PtrBestValue.Data.TypeName)<>0 then
      Result := True;
   end;
   3: begin
     if Ptr_1.Data.YearVihoda <> PtrBestValue.Data.YearVihoda then
      Result := True;
   end;
   4: begin
    if Ptr_1.Data.Price <> PtrBestValue.Data.Price then
      Result := True;
   end;
   5: begin
     if AnsiCompareStr(Ptr_1.Data.OS, PtrBestValue.Data.OS)<>0 then
      Result := True;
   end;
   6: begin
    if Ptr_1.Data.DisplaySize <> PtrBestValue.Data.DisplaySize then
      Result := True;
   end;
   7: begin
    if Ptr_1.Data.DisplayWidth <> PtrBestValue.Data.DisplayWidth then
      Result := True;
   end;
   8: begin
     if Ptr_1.Data.DisplayHigth <> PtrBestValue.Data.DisplayHigth then
       Result := True;
   end;
   9: begin
    if Ptr_1.Data.OperationMemory <> PtrBestValue.Data.OperationMemory then
      Result := True;
   end;
   10: begin
    if Ptr_1.Data.VstroyennayaMemory <> PtrBestValue.Data.VstroyennayaMemory then
      Result := True;
   end;
   11: begin
     if AnsiCompareStr(Ptr_1.Data.IsFrontCamera, PtrBestValue.Data.IsFrontCamera)<>0 then
      Result := True;
   end;
   12: begin
     if AnsiCompareStr(Ptr_1.Data.Discription, PtrBestValue.Data.Discription)<>0 then
      Result := True;
   end;
   else Result := False;
  end;
end;

// процедура отображения списка из памяти в отсортированном виде
procedure TForm_Main.ShowItemsSortCatalog;
var
  ptr: PCatalog;
  i: integer;
  num: Cardinal;
begin
  StringGrid_Catalog.RowCount := 2; // удаляю строки грида
  num := 1;
  // проходимся по двусвязному списку
  ptr := FFirst.Next;
  while ptr <> nil do
  begin
    // записываю данные в грид из элемента списка
    with StringGrid_Catalog do
    begin
      i := RowCount - 1; // строка для записи в грид
      Cells[0, i] := IntToStr(num);
      Cells[1, i] := ptr.Data.PhoneName;
      Cells[2, i] := ptr.Data.TypeName;
      Cells[3, i] := IntToStr(ptr.Data.YearVihoda);
      Cells[4, i] := CurrToStr(ptr.Data.Price);
      Cells[5, i] := ptr.Data.OS;
      Cells[6, i] := IntToStr(ptr.Data.DisplaySize);
      Cells[7, i] := IntToStr(ptr.Data.DisplayWidth);
      Cells[8, i] := IntToStr(ptr.Data.DisplayHigth);
      Cells[9, i] := IntToStr(ptr.Data.OperationMemory);
      Cells[10, i] := IntToStr(ptr.Data.VstroyennayaMemory);
      Cells[11, i] := ptr.Data.IsFrontCamera;
      Cells[12, i] := ptr.Data.Discription;
      RowCount := RowCount + 1; // Увеличиваем количество строк на 1
    end;
    Inc(num);
    // к след элементу
    ptr := ptr^.Next;
  end;
  StringGrid_Catalog.RowCount := StringGrid_Catalog.RowCount - 1;
  // удаляю лишнюю строку
end;

/// ////////////////////////////////////////////////////////////

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
      Read(TypedFile, FCatalog); // читаю элемент из файла
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
        i := RowCount - 1; // строка для записи в грид
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
      end;
      Inc(num);
    end;
  finally
    CloseFile(TypedFile);
    StringGrid_Catalog.RowCount := StringGrid_Catalog.RowCount - 1;
    // удаляю лишнюю строку
  end;
end;

function TForm_Main.FindItemFromGrid(NPtr: PCatalog): PCatalog;
var
  numRow: integer;
begin
  numRow := StringGrid_Catalog.Row; // получаю выделенную строку таблицы
  // проверяю, выбрана ли строка данных в гриде, а не заголовочная часть
  if (StringGrid_Catalog.Cells[1, numRow] = 'Название') and
    (StringGrid_Catalog.Cells[2, numRow] = 'Тип') and
    (StringGrid_Catalog.Cells[5, numRow] = 'Операционная система') then
  begin
    MessageDlg('Выберите строку данных для редактирования!', mtInformation,
      [mbOk], 0, mbOk);
    Result := nil;
  end
  else
    CatalogPhone := FindItemList(StringGrid_Catalog.Cells[1, numRow],
      StringGrid_Catalog.Cells[2, numRow], StringGrid_Catalog.Cells[5,
      numRow], FFirst);

  Result := CatalogPhone;
end;

// двойной щелчок по строке грида для получения формы редактирования
procedure TForm_Main.StringGrid_CatalogDblClick(Sender: TObject);
begin
  CatalogPhone := FindItemFromGrid(FFirst);
  AddItem.Form_AddItem.Tag := 1; // признак редактирования для формы
  AddItem.Form_AddItem.ShowModal();
end;

// нажатие на наименование колонки грида. буду применять для сортировки
procedure TForm_Main.StringGrid_CatalogFixedCellClick(Sender: TObject;
  ACol, ARow: integer);
begin
  // когда кликаю на колонку, устанавливается знак сортировки по возрастанию ˄ или по убыванию ˅
  if ACol > 0 then
  begin // если не нулевая колонка
    if (Pos('˄', StringGrid_Catalog.Cells[ACol, 0]) = 0) or (Pos('˅', StringGrid_Catalog.Cells[ACol, 0]) > 0) then
    begin
      SetColumnHeaders(StringGrid_Catalog);
      StringGrid_Catalog.Cells[ACol, 0] := StringGrid_Catalog.Cells[ACol, 0] + ' ˄';
      SortItems(TypeToSort.toASC, ACol); // сортировка по возрастанию
    end
    else
    begin
      SetColumnHeaders(StringGrid_Catalog);
      StringGrid_Catalog.Cells[ACol, 0] := StringGrid_Catalog.Cells[ACol, 0] + ' ˅';
      SortItems(TypeToSort.toDESC, ACol); // сортировка по убыванию
    end;
  end
  else
  begin
    Form_Main.StringGrid_Catalog.RowCount := 2; // удаляю строки грида
    SetColumnHeaders(StringGrid_Catalog); // удаляю все значки сортировки
    Form_Main.ShowItemsCatalog; // перерисовываю данные грида из файла
  end;
  //
  // MessageDlg('Нажата колонка №'+ IntToStr(ACol), mtInformation, [mbOk], 0, mbOk);
end;

procedure TForm_Main.ToolButton_aboutClick(Sender: TObject);
begin
  AboutProgram.Form_About.ShowModal();
end;

procedure TForm_Main.ToolButton_addClick(Sender: TObject);
begin
  AddItem.Form_AddItem.Tag := 0; // признак добавления для формы
  AddItem.Form_AddItem.ShowModal();
end;

// выход из приложения
procedure TForm_Main.ToolButton_closeClick(Sender: TObject);
begin
  // сохраняю в файл перед выходом
  SaveItemsInFile(FFirst, True, toTypedFile);
  // очищая память от элементов списка
  ClearList;
  // закрываю форму и приложение
  Close;
end;

// редактирование элемента из списка
procedure TForm_Main.ToolButton_editClick(Sender: TObject);
begin
  CatalogPhone := FindItemFromGrid(FFirst);
  if CatalogPhone <> nil then
  begin
    AddItem.Form_AddItem.Tag := 1; // признак редактирования для формы
    AddItem.Form_AddItem.ShowModal();
  end;
end;

// выгрузка в Excel
procedure TForm_Main.ToolButton_excelClick(Sender: TObject);
begin
  // сохраняю в excel файл
  SaveItemsInFile(FFirst, True, toExcel);
end;

// удаление элемента из списка
procedure TForm_Main.ToolButton_delClick(Sender: TObject);
begin
  if MessageDlg('Желаете удалить элемент списка?', mtConfirmation,
    [mbYes, mbNo], 0, mbNo) = mrYes then
  begin
    // сначала находим элемент в двусвязном списке по данным из грида
    CatalogPhone := FindItemFromGrid(FFirst);
    // удаляем элемент из списка и из памяти, перераспределяя ссылки
    if DeleteItem(CatalogPhone) then
    begin
      // сохраняю в файл из памяти списка с измененным элементом
      Form_Main.SaveItemsInFile(FFirst, True, toTypedFile);
      // отображаю из файла в грид на главной форме
      Form_Main.StringGrid_Catalog.RowCount := 2; // удаляю строки грида
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
  SaveItemsInFile(FFirst, True, toTypedFile);
  // закрываю форму и приложение
  Close;
end;

procedure TForm_Main.SetColumnHeaders(StringGrid_Catalog: TStringGrid);
begin
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
end;

procedure TForm_Main.FormShow(Sender: TObject);
begin
  // задаю кол-во столбцов грида
  StringGrid_Catalog.ColCount := 14;
  // заглавия столбцов
  SetColumnHeaders(StringGrid_Catalog);
  // формирую данные для грида
  ShowItemsCatalog();
end;

// прочитать данные из txt файла
procedure TForm_Main.MenuItem_ReadTxtClick(Sender: TObject);
begin
  FormTextFile.Form_TextFile.ShowModal();
end;

// сохранить в тектовый файл
procedure TForm_Main.MenuItem_SaveTxtClick(Sender: TObject);
begin
  SaveItemsInFile(FFirst, True, toTextFile);
  MessageDlg('Данные сохранены в текстовый файл ' + FileTextName + '!',
    mtInformation, [mbOk], 0, mbOk);
end;

// процедура записи в типизированный или текстовый файл
procedure TForm_Main.SaveItemsInFile(NPtr: PCatalog; isSave: boolean;
  Pr: TypeFileToSave);
const
  xlHAlignCenter = -4108;
  xlVAlignCenter = -4108;
var
  ptr, ptrTemp: PCatalog;
  FText: TextFile; // файловая переменная для записи в текстовый файл
  TypedFile: File of TFileCatalog; // файловая переменная
  FCatalog: TFileCatalog;
  StrToTextFile, CameraStr: string;
  ExcelObj, Workbook, Sheet, Range: variant; // переменная для объекта Excel
  BeginCol, BeginRow: integer;
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
        Rewrite(TypedFile)
        // создаю новый типизированный файл, перезаписываю старый, если есть
      else if Pr = toTextFile then
      begin
        Rewrite(FText);
        // создаю новый текстовый файл, перезаписываю старый, если есть
        // Колонки с названиями в текстовом файле
        StrToTextFile :=
          '          Название           |             Тип             | Год выхода | Цена | Операционная система | Размер диагонали | Ширина | Высота | ОЗУ | ПЗУ | Фронтальная камера | Описание ';
        // Запись в текстовый файл названия колонок
        Writeln(FText, StrToTextFile);
      end
      else if Pr = toExcel then
      begin
        ExcelObj := CreateOleObject('Excel.Application');
        // запускаем excel приложение и ассоциацию на переменную ExcelObj
        ExcelObj.Application.EnableEvents := False;
        // Отключаю реакцию Excel на события, чтобы ускорить вывод информации
        ExcelObj.DisplayAlerts := False; // отключаю все сообщения Excel
        Workbook := ExcelObj.WorkBooks.Add;
        // добавляем книгу и ассоциацию на переменную Workbook
        Sheet := Workbook.Sheets.item[1];
        // получаю первый лист в книге и ассоциацию на переменную Sheet, куда и буду писать данные
        // заголовок и наименования столбцов
        BeginCol := 1; // первый столбец
        BeginRow := 3; // начинаю с третьей строки
        Sheet.Cells(1, BeginCol) := 'Каталог телефонов'; // заголовок на листе
        Range := Sheet.Cells[1, BeginCol];
        Range.Font.Bold := True; // жирный шрифт
        Range.Font.Size := 14; // размер шрифта
        Sheet.Cells(BeginRow, 1) := 'Название';
        Sheet.Cells(BeginRow, 2) := 'Тип';
        Sheet.Cells(BeginRow, 3) := 'Год выхода';
        Sheet.Cells(BeginRow, 4) := 'Цена';
        Sheet.Cells(BeginRow, 5) := 'Операционная система';
        Sheet.Cells(BeginRow, 6) := 'Размер диагонали';
        Sheet.Cells(BeginRow, 7) := 'Ширина';
        Sheet.Cells(BeginRow, 8) := 'Высота';
        Sheet.Cells(BeginRow, 9) := 'ОЗУ';
        Sheet.Cells(BeginRow, 10) := 'ПЗУ';
        Sheet.Cells(BeginRow, 11) := 'Фронтальная камера';
        Sheet.Cells(BeginRow, 12) := 'Описание';
        // оформление заголовков столбцов
        Range := Sheet.Range['A3:L3'];
        // выбран диапозон ячеек заголовков столбцов
        Range.HorizontalAlignment := xlHAlignCenter;
        // центрирование по горизонтали
        Range.VerticalAlignment := xlVAlignCenter; // центрирование по вертикали
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
        /// ///////////////////////////////////////////////////////
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
        /// ////////////////////////////////////////
        else if Pr = toTextFile then // запись в текстовый файл
        begin
          // формирую строку для записи в текстовый файл
          StrToTextFile := ptr.Data.PhoneName;
          // добавляю пробелы, чтобы красиво смотрелось в тектовом файле
          if Length(ptr.Data.PhoneName) < 30 then StrToTextFile := StrToTextFile + StringOfChar(' ', 30 - Length(ptr.Data.PhoneName));
          StrToTextFile := StrToTextFile + ptr.Data.TypeName;
          if Length(ptr.Data.TypeName) < 30 then StrToTextFile := StrToTextFile + StringOfChar(' ', 30 - Length(ptr.Data.TypeName));
          StrToTextFile := StrToTextFile + IntToStr(ptr.Data.YearVihoda);
          if Length(IntToStr(ptr.Data.YearVihoda)) < 13 then StrToTextFile := StrToTextFile + StringOfChar(' ', 13 - Length(IntToStr(ptr.Data.YearVihoda)));
          StrToTextFile := StrToTextFile + CurrToStr(ptr.Data.Price);
          if Length(CurrToStr(ptr.Data.Price)) < 7 then StrToTextFile := StrToTextFile + StringOfChar(' ', 7 - Length(CurrToStr(ptr.Data.Price)));
          StrToTextFile := StrToTextFile + ptr.Data.OS;
          if Length(ptr.Data.OS) < 23 then StrToTextFile := StrToTextFile + StringOfChar(' ', 23 - Length(ptr.Data.OS));
          StrToTextFile := StrToTextFile + IntToStr(ptr.Data.DisplaySize);
          if Length(IntToStr(ptr.Data.DisplaySize)) < 19 then StrToTextFile := StrToTextFile + StringOfChar(' ', 19 - Length(IntToStr(ptr.Data.DisplaySize)));
          StrToTextFile := StrToTextFile + IntToStr(ptr.Data.DisplayWidth);
          if Length(IntToStr(ptr.Data.DisplayWidth)) < 9 then StrToTextFile := StrToTextFile + StringOfChar(' ', 9 - Length(IntToStr(ptr.Data.DisplayWidth)));
          StrToTextFile := StrToTextFile + IntToStr(ptr.Data.DisplayHigth);
          if Length(IntToStr(ptr.Data.DisplayHigth)) < 9 then StrToTextFile := StrToTextFile + StringOfChar(' ', 9 - Length(IntToStr(ptr.Data.DisplayHigth)));
          StrToTextFile := StrToTextFile + IntToStr(ptr.Data.OperationMemory);
          if Length(IntToStr(ptr.Data.OperationMemory)) < 6 then StrToTextFile := StrToTextFile + StringOfChar(' ', 6 - Length(IntToStr(ptr.Data.OperationMemory)));
          StrToTextFile := StrToTextFile + IntToStr(ptr.Data.VstroyennayaMemory);
          if Length(IntToStr(ptr.Data.VstroyennayaMemory)) < 6 then StrToTextFile := StrToTextFile + StringOfChar(' ', 6 - Length(IntToStr(ptr.Data.VstroyennayaMemory)));
          StrToTextFile := StrToTextFile + ptr.Data.IsFrontCamera;
          if Length(ptr.Data.IsFrontCamera) < 21 then StrToTextFile := StrToTextFile + StringOfChar(' ', 21 - Length(ptr.Data.IsFrontCamera));
          StrToTextFile := StrToTextFile + ptr.Data.Discription;
          // запись в текстовый файл сформированной строки
          Writeln(FText, StrToTextFile);
        end
        /// /////////////////////////////////////////////////////////
        else if Pr = toExcel then
        begin // запись в excel файл
          Sheet.Cells(BeginRow, 1) := ptr.Data.PhoneName;
          Sheet.Cells(BeginRow, 2) := ptr.Data.TypeName;
          Sheet.Cells(BeginRow, 3) := ptr.Data.YearVihoda;
          Sheet.Cells(BeginRow, 4) := ptr.Data.Price;
          Sheet.Cells(BeginRow, 5) := ptr.Data.OS;
          Sheet.Cells(BeginRow, 6) := ptr.Data.DisplaySize;
          Sheet.Cells(BeginRow, 7) := ptr.Data.DisplayWidth;
          Sheet.Cells(BeginRow, 8) := ptr.Data.DisplayHigth;
          Sheet.Cells(BeginRow, 9) := ptr.Data.OperationMemory;
          Sheet.Cells(BeginRow, 10) := ptr.Data.VstroyennayaMemory;
          Sheet.Cells(BeginRow, 11) := ptr.Data.IsFrontCamera;
          Sheet.Cells(BeginRow, 12) := ptr.Data.Discription;
          Inc(BeginRow);
        end;
        // переход к следующему элементу
        ptrTemp := ptr.Next;
        ptr := ptrTemp;
      end;
      if Pr = toExcel then
        ExcelObj.Visible := True;
      // Делаю Excel видимым после прохода по двусвязному списку
    finally
      if Pr = toTypedFile then // закрываю типизированный файл
        CloseFile(TypedFile)
      else if Pr = toTextFile then // закрываю текстовый файл
        CloseFile(FText);
    end;
  end;
end; { вызов процедуры добавления элемента (листинг 6.5) }

end.
