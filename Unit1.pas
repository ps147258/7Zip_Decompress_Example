//
// 中文    - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//
// 使用 7Zip 解壓縮檔案範例
//
// 類型：範例
// 編寫：Wei-Lun Huang
// 版權：2025 Wei-Lun Huang
//
// 用途：
//   使用修改後的 JclCompression 單元模組 JclCompressionEnhanced 讀取與解壓縮檔案
//
// 最後變更日期：2025年06月10日
//
//
// English - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//
// Example of using 7Zip to decompress an archive
//
// Type: Example
// Author: Wei-Lun Huang
// Copyright: 2025 Wei-Lun Huang
//
// Purpose:
//   Use the modified JclCompression unit JclCompressionEnhanced to decompress files.
//
// Last changed: June 10, 2025
//

unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, Winapi.ShellAPI,
  System.SysUtils, System.Variants, System.Classes, System.UITypes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.StdCtrls,
  Vcl.Mask, Vcl.Menus, Vcl.FileCtrl, Vcl.Clipbrd,
  JvExMask, JvToolEdit, JvBaseDlg, JvSelectDirectory,

  // 使用 FileTimeToLocalDateTime 轉換 TFileTime 至 TDateTime 本機時間
  // Use FileTimeToLocalDateTime to convert TFileTime to TDateTime local time
  JclDateTime,

  // 修改後的 JclCompression，使用 7Zip 解壓縮介面
  // Modified JclCompression, using 7Zip decompression interface
  JclCompressionEnhanced;

//
// 中文：
// 需要 7-Zip 的動態函數庫 "7z.dll"、"7za.dll" 或 "7zxa.dll" 其中一個。
// 但載入時以 "7z.dll" 檔名載入，所以檔名需要更改為 "7z.dll"。
//
// 然後置於本程式執行時的工作路徑下，常見做法是與本程式 exe 置於相同資料夾。
// 或者您的系統變數 PATH 能夠找到  "7z.dll"，但有分 64位元 與 32位元 所以不建議。
//
// "7z.dll"、"7za.dll"、"7zxa.dll" 功能有差異：
//   7z.dll   壓縮 7z 格式，解壓縮支援多種格式
//   7za.dll  壓縮 7z 格式，解壓縮僅支援 7z 格式
//   7zxa.dll 僅支援 7z 解壓縮
//
// 關於 JclCompressionEnhanced
//   以最小限度修改加入檢查檔案是否已存在的功能
//   若檔案已存在則引發 TJclSevenzipDecompressArchive.OnFileExist
//   但過程中若設定 OverwriteMode: TJclCompressionFileOverwrite
//   為 cfoSkipAll 或 cfoOverwriteAll 將不再詢問。
//   若設定為 cfoAbort，則中止後續解壓作業。
//
//
// English:
//
// Need one of 7-Zip's dynamic-link libraries: "7z.dll", "7za.dll", or "7zxa.dll".
// However, when loading, it's loaded as "7z.dll",
// so the filename needs to be changed to "7z.dll".
//
// Then, place it in the working directory where this program executes.
// The common practice is to put it in the same folder as this program's .exe file.
// Alternatively, your system's PATH variable could locate "7z.dll",
// but this isn't recommended due to the 64-bit and 32-bit distinctions.
//
// There are functional differences between "7z.dll", "7za.dll" and "7zxa.dll":
//   7z.dll: Compresses 7z format, supports decompression of various formats.
//   7za.dll: Compresses 7z format, supports decompression of 7z format only.
//   7zxa.dll: Supports 7z decompression only.
//
// About JclCompressionEnhanced
//   Added the functionality to check if a file already exists with minimal modifications.
//   If the file exists, it will trigger TJclSevenzipDecompressArchive.OnFileExist.
//   If OverwriteMode is set to cfoSkipAll or cfoOverwriteAll during this process,
//   no further prompting will occur.
//
//   If OverwriteMode = cfoAbort, subsequent decompression operations will be aborted.
//

type
  TForm1 = class(TForm)
    ListView1: TListView;
    JvFilenameEdit1: TJvFilenameEdit;
    PopupMenu1: TPopupMenu;
    DecompressSelected: TMenuItem;
    DecompressAll: TMenuItem;
    StatusBar1: TStatusBar;
    N1: TMenuItem;
    CopyNameSelected: TMenuItem;
    CopyNameAll: TMenuItem;
    N2: TMenuItem;
    SelectAll: TMenuItem;
    UnselectAll: TMenuItem;
    InvertSelection: TMenuItem;
    FileOpenDialog1: TFileOpenDialog;
    procedure FormDestroy(Sender: TObject);
    procedure JvFilenameEdit1Change(Sender: TObject);
    procedure ListView1Data(Sender: TObject; Item: TListItem);
    procedure ListView1Change(Sender: TObject; Item: TListItem; Change: TItemChange);
    procedure DecompressSelectedClick(Sender: TObject);
    procedure DecompressAllClick(Sender: TObject);
    procedure CopyNameSelectedClick(Sender: TObject);
    procedure CopyNameAllClick(Sender: TObject);
    procedure SelectAllClick(Sender: TObject);
    procedure UnselectAllClick(Sender: TObject);
    procedure InvertSelectionClick(Sender: TObject);
    procedure PopupMenu1Popup(Sender: TObject);
  private
    { Private declarations }
    FFilename: string;                            // 目前開啟的檔案
    FFileStream: TFileStream;                     // 壓縮檔串流
    FDecompressor: TJclSevenzipDecompressArchive; // 解壓器

    // 關於 FFileStream 與 FDecompressor
    // TJclSevenzipDecompressArchive 可以直接以檔名方式開啟壓縮檔，
    // 但本程式在處理壓縮檔格式判斷前先開啟壓縮檔建立 FFileStream，
    // 成功後再以 FFileStream 建立 FDecompressor。
    //
    // About FFileStream and FDecompressor
    // TJclSevenzipDecompressArchive can open compressed archives directly by filename.
    // but, this program first opens the compressed archive to create an FFileStream
    // before determining its format. If successful, it then uses the FFileStream to
    // create an FDecompressor.


    // 若磁碟中以存在檔案時引發的事件，關聯至 FDecompressor.OnFileExist
    // Event triggered when a file already exists on disk, associated with FDecompressor.OnFileExist
    procedure OnFileExist(Sender: TObject; Index: Integer; const FileName: TFileName;
      var OverwriteMode: TJclCompressionFileOverwrite);

    // 更新清單選取數量的狀態列訊息
    // Updates the status bar message with the number of selected items in the list.
    procedure RefreshStatusSelectCount;

    // 複製清單中的檔案名稱至剪貼簿，OnlySelect = True(只有選取的) | False(全部)
    // Copies filenames from the list to the clipboard.
    // OnlySelect = True(selected only) | False(all).
    procedure CopyNamesToClipboard(OnlySelect: Boolean);

    // 解壓縮檔案，OnlySelect = True(只有選取的) | False(全部)
    // Decompresses files. OnlySelect = True(selected only) | False(all).
    procedure DecompressFiles(OnlySelect: Boolean);

    procedure CloseFile;                                 // 關閉壓縮檔
    function OpenFile(const AFilename: string): Boolean; // 開啟壓縮檔
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}


// 時間格式轉換 (改為使用 JclDateTime.FileTimeToLocalDateTime)
// Time format conversion (changed to use JclDateTime.FileTimeToLocalDateTime)
//function FileTimeToDateTime(FileTime: TFileTime): TDateTime;
//var
//  ModifiedTime: TFileTime;
//  SystemTime: TSystemTime;
//begin
//  if FileTimeToLocalFileTime(FileTime, ModifiedTime) then  // 轉換至本地時間
//    if FileTimeToSystemTime(ModifiedTime, SystemTime) then // TFileTime 轉換為 TSystemTime
//      Exit(SystemTimeToDateTime(SystemTime));              // TSystemTime 轉換為 TDateTime
//
//  // 至此未離開則表示失敗，將回傳值清零，其結果應為 1899年12月30日 00:00
//  // If the process hasn't exited by this point, it indicates failure.
//  // The return value will be reset to zero, which should result in 1899-12-30 00:00.
//  FillChar(Result, SizeOf(Result), 0);
//end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  CloseFile;
end;

procedure TForm1.RefreshStatusSelectCount;
begin
  // 顯示已選取的數量
  // Display the number of selected items
  StatusBar1.Panels.Items[1].Text := 'Selected: ' + ListView1.SelCount.ToString;
end;

procedure TForm1.CloseFile;
begin
  Caption := '';
  ListView1.Clear;
  if Assigned(FDecompressor) then
    FreeAndNil(FDecompressor);
  if Assigned(FFileStream) then
    FreeAndNil(FFileStream);
end;

procedure TForm1.JvFilenameEdit1Change(Sender: TObject);
var
  s: string;
begin
  s := JvFilenameEdit1.FileName;
  if not FileExists(s) then
    Exit;

  // 開啟檔案，如果成功開啟，則在視窗標題顯示開啟的檔案，否則將視窗標題清除。
  // Open file, if successful, display the opened file in the window title;
  // otherwise, clear the window title.
  if OpenFile(s) then
    Caption := s
  else
    Caption := '';
end;

procedure TForm1.ListView1Data(Sender: TObject; Item: TListItem);
var
  Index: Integer;
  PackedItem: TJclCompressionItem; // 壓縮資料內容項目
  LastWriteTime: TDateTime;
  s: string;
begin
  if not Assigned(FDecompressor) then Exit; // 若解壓器不存在則退出

  Index := Item.Index;                      // 目前項目的索引

  // 若索引超出解壓器內容項目數量範圍則退出
  // Exit if the index is out of range for the decompressor's content items.
  if (Index >= FDecompressor.ItemCount) or (Index < 0) then Exit;

  PackedItem := FDecompressor.Items[Index]; // 取得解壓器內指定索引的項目
  Item.Caption := PackedItem.PackedName;    // 取得壓縮內容的檔名

  //
  // 如果是資料夾則不顯示大小，否則顯示原始檔案大小
  //
  // If it's a folder, don't display the size; otherwise, show the original file size.
  //
  if PackedItem.Directory then
    Item.SubItems.Add('')
  else
    Item.SubItems.Add(FormatCurr(',0', PackedItem.FileSize));


  try
    // 轉換至本地時間並且為 TDateTime 時間格式
    // Convert to local time and in TDateTime format
    LastWriteTime := FileTimeToLocalDateTime(PackedItem.LastWriteTime);

    // 格式化時間為字串
    // Format time as a string
    s := FormatDateTime('yyyy/mm/dd hh:nn:ss', LastWriteTime);
  except
    // 表示時間轉換錯誤，並使錯誤不被拋出
    // Indicate a time conversion error and prevent the error from being thrown
    s := '<DateTime Error>';
  end;

  // 顯示檔案最修改日期
  // Display the file's last modified date
  Item.SubItems.Add(s);

end;

procedure TForm1.ListView1Change(Sender: TObject; Item: TListItem; Change: TItemChange);
begin
  RefreshStatusSelectCount;
end;

procedure TForm1.OnFileExist(Sender: TObject; Index: Integer;
  const FileName: TFileName; var OverwriteMode: TJclCompressionFileOverwrite);
const
  // 檔案覆蓋確認
  Overwrite_T = 'Coverage Confirmation';
  // 檔案已經存在，您是否想覆蓋該檔案？
  Overwrite_M = 'The file already exists. Do you want to overwrite it?';
var
  ret: Integer;
  s: string;
begin
  s := FileName + sLineBreak + Overwrite_M;
  ret := MessageDlg(PChar(s), mtConfirmation, [mbYes, mbYesToAll, mbNo, mbNoToAll, mbCancel], 0, mbIgnore);
  case ret of
    mrYes     : OverwriteMode := cfoOverwrite;    // 覆蓋檔案
    mrYesToAll: OverwriteMode := cfoOverwriteAll; // 覆蓋所有檔案
    mrNo      : OverwriteMode := cfoSkip;         // 跳過檔案
    mrNoToAll : OverwriteMode := cfoSkipAll;      // 跳過所有檔案
    else        OverwriteMode := cfoAbort;        // 中止剩下的所有解壓縮操作
  end;
end;

procedure TForm1.DecompressFiles(OnlySelect: Boolean);
const
  // 開啟資料夾
  OpenFolderInExplorer_T = 'Open folder';
  // 您是否想立即在檔案瀏覽器(Explorer)中開啟資料夾？
  OpenFolderInExplorer_M = 'Do you want to open the folder in Explorer now?';
var
  Directory: string;
  I, Count: Integer;
  ListItems: TListItems;
begin
  if not FileOpenDialog1.Execute(Self.Handle) then   // 顯示資料夾選取對話框
    Exit;

  Count := ListView1.SelCount;
  if Count <= 0 then
    Exit;

  Directory := FileOpenDialog1.FileName;             // 輸出資料夾 路徑
  try
    FDecompressor.OnFileExist := OnFileExist;        // 當檔案存在時引發的事件
    if OnlySelect then
    begin
      //
      // 同步介面清單中選取項目至解壓器的項目清單
      // Synchronize selected items in the interface list with the decompressor's item list.
      //
      ListItems := ListView1.Items;
      for I := 0 to ListItems.Count - 1 do
        FDecompressor.Items[I].Selected := ListItems[I].Selected;

      // 解壓縮選取的項目
      // Decompress selected items
      FDecompressor.ExtractSelected(Directory, True)

      // 假設想解壓縮在記憶體中的範例：
      // If you want to decompress in memory. Example:
      //
      // AIndex         要解壓縮的索引; Index of items in the archive
      // AMemoryStream  儲存的串流緩衝; An established 0 size stream
      // procedure Decompress(AIndex: Inetger; AMemoryStream: TMemoryStream);
      // var
      //   Item: TJclCompressionItem;
      // begin
      //   if not Assigned(AMemoryStream) then
      //     raise Exception.Create('The TMemoryStream object has not been created yet.');
      //   Item := FDecompressor.Items[AIndex];
      //   Item.Stream := AMemoryStream;    // 設定項目解壓時資料儲存的緩衝串流
      //   Item.OwnsStream := False;        // 設定該緩衝串流為非依託釋放物件
      //   Item.Selected := True;           // 設定本項目為選取狀態
      //   FDecompressor.ExtractSelected(); // 開始解壓縮選取的項目
      // end;
    end
    else
    begin
      // 解壓縮所有項目
      // Decompress all
      FDecompressor.ExtractAll(Directory, True);
    end;
  except on E: Exception do
    MessageBox(Self.Handle, PChar(E.Message), nil, MB_OK or MB_DEFBUTTON1 or MB_ICONWARNING);
  end;

  // 詢問使育者是否開啟 輸出資料夾
  // Ask the user if they want to open the output folder.
  if MessageBox(Self.Handle, OpenFolderInExplorer_M, OpenFolderInExplorer_T, MB_YESNO or MB_DEFBUTTON1) <> IDYES then
    Exit;

  // 以 檔案瀏覽器(Explorer.exe) 開啟 輸出資料夾
  // Open the output folder using File Explorer (Explorer.exe).
  ShellExecute(Handle, 'open', 'Explorer.exe', PChar(Directory), nil, 1);
end;

procedure TForm1.DecompressSelectedClick(Sender: TObject);
begin
  // 解壓縮檔案，僅清單中選取的 // True(Only selected items)
  DecompressFiles(True);
end;

procedure TForm1.DecompressAllClick(Sender: TObject);
begin
  // 解壓縮所有檔案  // False(All items)
  DecompressFiles(False);
end;

procedure TForm1.CopyNamesToClipboard(OnlySelect: Boolean);
var
  s, Tmp: string;
  I: Integer;
  PackedItem: TJclCompressionItem; // 壓縮資料內容項目
begin
  s := '';
  for I := 0 to FDecompressor.ItemCount - 1 do
  begin
    PackedItem := FDecompressor.Items[I]; // 依索引取得解壓器內指定項目
    if OnlySelect and not PackedItem.Selected then
      Continue;

    Tmp := PackedItem.PackedName;         // 壓縮檔的相對路徑與檔名

    //
    // 增加一行字串，資料夾且該路徑尾端以"\"做結尾，表示此路徑為資料夾
    // Add a string indicating that the path is a folder, with the path ending in a backslash.
    //
    if PackedItem.Directory then
    begin
      if not Tmp.EndsWith('\') then
      begin
        s := s + Tmp + '\' + sLineBreak;
        Continue;
      end;
    end;

    //
    // 增加一行字串，檔案路徑
    // Add a string for the file path.
    //
    s := s + Tmp + sLineBreak;
  end;

  // 將字串傳送至剪貼簿
  // Send string to clipboard
  Clipboard.AsText := s;
end;

procedure TForm1.CopyNameSelectedClick(Sender: TObject);
begin
  // 複製清單中所有檔案名稱至剪貼簿 // True(Only selected items)
  CopyNamesToClipboard(True);
end;

procedure TForm1.CopyNameAllClick(Sender: TObject);
begin
  // 複製清單中選取檔案名稱至剪貼簿 // False(All items)
  CopyNamesToClipboard(False);
end;

procedure TForm1.SelectAllClick(Sender: TObject);
begin
  ListView1.SelectAll; // 清單全選
end;

procedure TForm1.UnselectAllClick(Sender: TObject);
begin
  ListView1.ClearSelection; // 取消所有選取
end;

procedure TForm1.InvertSelectionClick(Sender: TObject);
var
  Items: TListItems;
  I: Integer;
begin
  Items := ListView1.Items;
  Items.BeginUpdate;
  try
    for I := 0 to Items.Count - 1 do
      Items[I].Selected := not Items[I].Selected; // 反轉選取狀態
  finally
    Items.EndUpdate;
  end;
end;

function TForm1.OpenFile(const AFilename: string): Boolean;
var
  // 區塊處理用的臨時變數
  // Temporary variable for block processing.
  I, J, K: Integer;
  b: Boolean;

  ExtFormats: Integer;                               // 附檔名可能的格式介面數量
  CompressionFormats: TJclCompressionArchiveFormats; // 支援的壓縮格式介面清單
  DecompressList: TJclDecompressArchiveClassArray;   // 解壓縮介面的清單
  Decompress: TJclDecompressArchiveClass;            // 解壓縮介面
  LastError: string;                                 // 最後的錯誤訊息
begin
  Result := False;
  CloseFile; // 釋放已開啟的檔案
  FFilename := AFilename;
  try
    // 取得支援的壓縮格式介面清單
    // Get the list of supported compression format interfaces.
    CompressionFormats := GetArchiveFormats;

    // 開啟檔案，解壓縮只需要讀取，因此以讀取模式、禁止其他寫入操作方式開啟檔案
    // Open file for decompression, only reading is required,
    // so open the file in read mode with exclusive write access.
    FFileStream := TFileStream.Create(AFilename, fmOpenRead, fmShareDenyWrite);

    // 以檔案副檔名取得可能的格式介面
    // Get possible format interfaces based on the file extension.
    DecompressList := CompressionFormats.FindDecompressFormats(FFilename);

    // 取得依副檔名取得可能的格式介面數
    // Get the number of possible format interfaces based on the file extension.
    ExtFormats := Length(DecompressList);

    // 擴展介面清單緩衝區至解壓介面總數
    // Expand the interface list buffer to the total number of decompression interfaces.
    SetLength(DecompressList, CompressionFormats.DecompressFormatCount);

    //
    // 取得所有解壓介面，但略過前面已取得的。
    // Get all decompression interfaces, skipping those already obtained.
    //

    // 以由附檔名而取得的格式介面數作為填入介面清單的起始索引
    // 因為元素由 0 開始，因此陣列的填入數量將等同於下一個起始索引
    //
    // Use the number of format interfaces obtained from the file extension as
    // the starting index for populating the interface list.
    // Since elements are 0-indexed, the number of elements filled into the
    // array will be equal to the next starting index.
    K := ExtFormats;
    for I := 0 to CompressionFormats.DecompressFormatCount - 1 do
    begin
      // 依指定索引取得解壓介面(Decompress)
      Decompress := CompressionFormats.DecompressFormats[I];

      //
      // 判斷解壓介面(Decompress)是否已存在清單(DecompressList)中
      // Determine if the Decompress already exists in the DecompressList.
      //
      b := True;
      for J := 0 to ExtFormats - 1 do
      begin
        //
        // 若清單(DecompressList)中已存在目標解壓介面(Decompress)則
        // 設定 b = False 表示此解壓介面已存在，然後退出此迴圈
        //
        // If the target decompression interface (Decompress) already exists in
        // the list (DecompressList), set b = False to indicate that this
        // decompression interface already exists, then exit this loop.
        //
        if DecompressList[J] = Decompress then
        begin
          b := False;
          Break;
        end;
      end;

      //
      // 如尚未加入解壓介面則加入清單中
      // If the decompression interface has not yet been added, add it to the list.
      //
      if b then
      begin
        DecompressList[K] := Decompress;
        Inc(K);
      end;
    end;

    //
    // 依解壓介面清單順序嘗試取得檔案的解壓器
    // Attempt to get the file's decompressor according to the order of the decompression interface list.
    //
    for I := 0 to Length(DecompressList) - 1 do
    begin
      Decompress := DecompressList[I];
      try
        // 依解壓縮介面取得檔案的解壓器
        // Get the file's decompressor based on the decompression interface.
        FDecompressor := TJclSevenzipDecompressArchive(Decompress.NewInstance).Create(FFileStream, 0, False);

        FDecompressor.ListFiles; // 枚舉與取得檔案資訊
        LastError := '';         // 至此沒發生例外則表示已成功取得對應解壓器
        Break;                   // 退出此解壓器嘗試取得的迴圈
      except on E: Exception do
        begin                             // 若發生例外
          LastError := E.Message;         // 覆蓋錯誤訊息，作為最後一次的錯誤資訊
          if Assigned(FDecompressor) then // 若解壓器物件空間已被建立
            FreeAndNil(FDecompressor)     // 釋放該解壓器物件
        end;
      end;
    end;

    if not LastError.IsEmpty then         // 若存在錯誤訊息
      raise Exception.Create(LastError);  // 拋出錯誤訊息

    //
    // 同步顯示清單的數量為壓縮內容的項目數量
    // Synchronize the displayed list quantity to match the number of items in the compressed content.
    //
    K := FDecompressor.ItemCount;
    ListView1.Items.Count := K;
    StatusBar1.Panels.Items[0].Text := 'Count: ' + K.ToString;

  except
    on E: Exception do        // 若發生例外
    begin
      CloseFile;              // 釋放檔案
      ShowMessage(E.Message); // 顯示錯誤訊息
    end;
  end;
end;

procedure TForm1.PopupMenu1Popup(Sender: TObject);
var
  b: Boolean;
  I: Integer;
  Items: TMenuItem;
begin
  //
  // 如果存在解壓器且有內容則啟用所有選單項目，否則停用選單中所有項目
  //
  // If a decompressor exists and has content, enable all menu items;
  // otherwise, disable all items in the menu.
  //
  b := Assigned(FDecompressor) and (ListView1.SelCount > 0);

  Items := PopupMenu1.Items;
  for I := 0 to Items.Count - 1 do
    Items[I].Enabled := b;
end;

end.
