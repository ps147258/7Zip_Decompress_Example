[English](#English) | [中文](#中文)
***
# English:
## About JclCompressionEnhanced
JclCompressionEnhanced is a modified unit of JclCompression from Project JEDI. 
It adds functionality to check for the existence of destination files during decompression and allows to specify how to handle them.

This is not a standalone unit; it internally uses other Project JEDI units and the Sevenzip unit.
Therefore, you must at least have the Project JEDI JCL library installed first.
https://github.com/project-jedi/jcl

Project JEDI GitHub: https://github.com/project-jedi


## File Existence Handling Options
TJclCompressionFileOverwrite\
cfoSkip: Skips the current file, but will prompt again (triggers OnFileExist) if another existing file is encountered.\
cfoSkipAll: Skips all subsequent existing files without further prompting (does not trigger OnFileExist).\
cfoOverwrite: Overwrites the current file, but will prompt again (triggers OnFileExist) if another existing file is encountered.\
cfoOverwriteAll: Overwrites all subsequent existing files without further prompting (does not trigger OnFileExist).\
cfoAbort: Aborts the operation, skipping all remaining files.

TJclDecompressArchive.OnFileExist
TJclUpdateArchive.OnFileExist
```delphi
procedure OnFileExist(Sender: TObject; Index: Integer; const FileName: TFileName; 
  var OverwriteMode: TJclCompressionFileOverwrite);
var
  ret: Integer;
begin
  ret := MessageDlg('Overwrite file?', mtConfirmation, [mbYes, mbYesToAll, mbNo, mbNoToAll, mbCancel], 0, mbIgnore);
  case ret of
    mrYes       : OverwriteMode := cfoOverwrite;    // Overwrite the file
    mrYesToAll  : OverwriteMode := cfoOverwriteAll; // Overwrite all files
    mrNo        : OverwriteMode := cfoSkip;         // Skip the file
    mrNoToAll   : OverwriteMode := cfoSkipAll;      // Skip all files
    else          OverwriteMode := cfoAbort;        // Abort all remaining decompression operations
  end;
end;
```
> [!TIP]
> For details, please refer to the DecompressFiles and OnFileExist functions in Unit1.pas of this example.

***
# 中文：
## 關於 JclCompressionEnhanced

JclCompressionEnhanced 為修改 Project JEDI 中 JclCompression 的單元。
增加了對解壓縮目的檔存在的檢查，並且能指定處理方式。

非獨立單元，內部仍使用 Project JEDI 的其他單元與 Sevenzip 單元，所以至少必須先安裝 Project JEDI 的 jcl 單元庫。
https://github.com/project-jedi/jcl

Project JEDI GitHub: https://github.com/project-jedi


## 檔案已存在的處理方式說明：
TJclCompressionFileOverwrite = (\
  cfoSkip,         // 跳過檔案，但下次仍詢問(引發 OnFileExist)\
  cfoSkipAll,      // 跳過所有檔案，之後不詢問(不引發 OnFileExist)\
  cfoOverwrite,    // 覆蓋檔案，但下次仍詢問(引發 OnFileExist)\
  cfoOverwriteAll, // 覆蓋所有檔案，之後不詢問(不引發 OnFileExist)\
  cfoAbort         // 中止，跳過所有檔案\
);

TJclDecompressArchive.OnFileExist
TJclUpdateArchive.OnFileExist
```delphi
procedure OnFileExist(Sender: TObject; Index: Integer; const FileName: TFileName; 
  var OverwriteMode: TJclCompressionFileOverwrite);
var
  ret: Integer;=
begin=
  ret := MessageDlg('是否覆蓋檔案？', mtConfirmation, [mbYes, mbYesToAll, mbNo, mbNoToAll, mbCancel], 0, mbIgnore);
  case ret of
    mrYes     : OverwriteMode := cfoOverwrite;    // 覆蓋檔案
    mrYesToAll: OverwriteMode := cfoOverwriteAll; // 覆蓋所有檔案
    mrNo      : OverwriteMode := cfoSkip;         // 跳過檔案
    mrNoToAll : OverwriteMode := cfoSkipAll;      // 跳過所有檔案
    else        OverwriteMode := cfoAbort;        // 中止剩下的所有解壓縮操作
  end;
end;
```
> [!TIP]
> 詳細請查看本範例 Unit1.pas 中 DecompressFiles 與 OnFileExist 函數區塊
