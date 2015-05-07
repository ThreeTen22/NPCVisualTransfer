{
  NPC Visual Transfer

	Allows to replace the visuals, and just the visuals of one NPC to Another
}
unit NPCVisualTransfer;
uses mteFunctions;
const
  MinElementsToModify = 'RNAM,"Head Parts",HCLF,WNAM,NAM6,NAM7,QNAM,"Tint Layers",OBND,NAM9,NAMA,FTST,ANAM';
  bethESMs = 'skyrim.esm'#13'dawnguard.esm'#13'dragonborn.esm'#13'hearthfires.esm';
  bethBSAs = 'Skyrim -'#13'Dawnguard.bsa'#13'Dragonborn.bsa'#13'Hearthfires.bsa';
  lMeshPath = 'meshes\actors\character\facegendata\facegeom\';
  lTexPath = 'textures\actors\character\facegendata\facetint\';
  moFileName = 'VNPC_FaceGeomData';
var 
	sourceNPCIDs, destNPCIDs: TStringList;
  SourceNPC, DestNPC, PatchFile: IInterface;
  slResList,slElementToXFer,slCurrentNPCs: TStringList;
  slAssets: TwbFastStringList;
  bTrue, bFalse, bQuit, bUsingMO, bCreatingModFolders, bAdvancedTransfer: Boolean;
  xferPath, sSourceNPCName, sDestNPCName: String;
  slContainers: TwbFastStringList;


function GrabWinningRecordFromSelection(input: String): IInterface;
var
  i: Integer;
  sHexID: String;
  iiMasterRecord: IInterface;
begin
 // if Length(input) < 8 then exit;
  sHexID := CopyFromTo(input, Length(input)-7, Length(input));
  AddMessage(sHexID);
  iiMasterRecord := RecordByHex(sHexID);
  if OverrideCount(iiMasterRecord) > 0 then begin
    Result := WinningOverride(MasterOrSelf(iiMasterRecord));
  end else
    Result := MasterOrSelf(iiMasterRecord);
end;

procedure ChangeFlag(i:integer; sSourceFlags:string; var sDestFlags:string);
var
  c: char;
begin
  AddMessage('Source: '+ sSourceFlags[i]+ ' Dest: '+ sDestFlags[i]);
  if (sSourceFlags[i] <> sDestFlags[i]) then begin
    if sDestFlags[i] = '0' then c := '1' else c := '0';
    SetChar(sDestFlags, i, c);
  end;
end;


function AdditionalOptions(): integer;
var
  i: Integer;
  frm: TForm;
  sSourceFlags,sDestFlags : String;
  c: char;
begin
  sSourceFlags := geev(SourceNPC, 'ACBS\Flags');
  sDestFlags := geev(DestNPC, 'ACBS\Flags');
  while Length(sSourceFlags) < 32 do
    sSourceFlags := sSourceFlags + '0';
  while Length(sDestFlags) < 32 do
    sDestFlags := sDestFlags + '0';

  AddMessage(sDestFlags);
  //Gender Index: 1
  ChangeFlag(1,sSourceFlags,sDestFlags);
  //Opposite Animation Index: 20 
  ChangeFlag(20,sSourceFlags,sDestFlags);
  seev(DestNPC,'ACBS\Flags', sDestFlags);
  //frm := TForm.Create(nil);
  //frm.Caption := 'Select '+ grup;
  //frm.Width := 556;
  //frm.Height := 480;
  //frm.Position := poScreenCenter;

end;

procedure GrabActorsFromFile(iiFile: IInterface);
var
  j: Integer;
  npcGRUP, indexRecord: IInterface;
  npcName: String;
begin
  slCurrentNPCs.Clear;
  npcGRUP := GroupBySignature(iiFile, 'NPC_');
  if Assigned(npcGRUP) then begin
    for j := 0 to Pred(ElementCount(npcGRUP)) do begin
      indexRecord := ElementByIndex(npcGRUP, j);
      npcName := geev(indexRecord, 'FULL');
      if npcName = '' then
      npcName := '_'+geev(indexRecord, 'EDID');
      npcName := IntToStr(j)+' '+npcName + ' : ' + HexFormID(indexRecord);
      slCurrentNPCs.Append(npcName);
    end;
  end else
  slCurrentNPCs.Append(' ');
end;

procedure RemoveNPC(iiNPC: IInterface);
var
  dHex, dFileName: string;
begin
  dHex := '00'+ CopyFromTo(HexFormID(iiNPC),3,8);
  dFileName := GetFileName(GetFile(MasterOrSelf(iiNPC)));
  DeleteFile(xferPath+moFileName+'\'+lMeshPath+dFileName+'\'+dHex+'.nif');
  DeleteFile(xferPath+moFileName+'\'+lTexPath+dFileName+'\'+dHex+'.dds');
  AddMessage('-Removing NPC');
  Remove(iiNPC);
end;

procedure ActorSelect(grup,prompt,prompt2: string; tsSourceList,tsDestList: TStringList; var iiSourceNPC:IInterface; var iiDestNPC: IInterface);
var
  frm: TForm;
  lbl, lbl2: TLabel;
  lbActors: TListBox;
  lbActors2: TListBox;
  btnOk, btnCancel, btnRemoveNPC: TButton;
  cbActors: TComboBox;
  i,modals: integer;
  s, input1,input2: string;
begin
  frm := TForm.Create(nil);
  GrabActorsFromFile(PatchFile);
  try
    frm.Caption := 'Select '+ grup;
    frm.Width := 556;
    frm.Height := 480;
    frm.Position := poScreenCenter;
    
    lbl := TLabel.Create(frm);
    lbl.Parent := frm;
    lbl.Width := 200;
    if Pos(#13, prompt) > 0 then begin
      lbl.Height := 60;
    end
    else begin
      lbl.Height := 30;
      frm.Height := 160;
    end;
    lbl.Left := 10;
    lbl.Top := 8;
    lbl.Caption := prompt;
    lbl.Autosize := false;
    lbl.Wordwrap := True;
    
    lbActors := TListBox.Create(frm);
    lbActors.Parent := frm;
    lbActors.Top := lbl.Top + lbl.Height + 6;
    lbActors.Left := 10;
    lbActors.Width := 230;
    lbActors.Height := 300;

    lbActors2 := TListBox.Create(frm);
    lbActors2.Parent := frm;
    lbActors2.Top := lbActors.Top;
    lbActors2.Left := lbActors.Left+lbActors.Width + 60;
    lbActors2.Width := 230;
    lbActors2.Height := lbActors.Height;

    lbl2 := TLabel.Create(frm);
    lbl2.Parent := frm;
    lbl2.Height := lbl.Height;
    lbl2.Left := lbActors2.Left;
    lbl2.Width := 200;
    lbl2.Top := 8;
    lbl2.Caption := prompt2;
    lbl2.Autosize := false;
    lbl2.Wordwrap := True;

    lbActors.Items.Add(' ');
    lbActors2.Items.Add(' ');
    for i := 0 to tsSourceList.Count-1 do begin
      lbActors.Items.Add(tsSourceList[i]);
    end;
    for i := 0 to tsDestList.Count-1 do begin
      lbActors2.Items.Add(tsDestList[i]);
    end;
    
    btnOk := TButton.Create(frm);
    btnOk.Parent := frm;
    btnOk.Left := lbActors.Left + ((lbActors2.Left+lbActors2.Width-lbActors.Left)/2)-btnOk.Width-8;
    btnOk.Top := lbActors.Top + lbActors.Height + 10;
    btnOk.Caption := 'Transfer';
    btnOk.ModalResult := mrOk;
    
    btnCancel := TButton.Create(frm);
    btnCancel.Parent := frm;
    btnCancel.Caption := 'Quit';
    btnCancel.ModalResult := mrCancel;
    btnCancel.Left := btnOk.Left + btnOk.Width + 16;
    btnCancel.Top := btnOk.Top;
    lbActors.ItemIndex := 0;
    lbActors2.ItemIndex := 0;

    cbActors := TComboBox.Create(frm);
    cbActors.Parent := frm;
    cbActors.Style := csDropDown;
    cbActors.Sorted := false;
    cbActors.AutoDropdown := True;
    cbActors.Left := lbActors.Left + lbActors.Width/2;
    cbActors.Width := lbActors.Width;
    cbActors.Top := btnOk.Top + btnOk.Height+16;
    cbActors.Text := 'NPC To Remove...';

    for i := 0 to slCurrentNPCs.Count-1 do begin
      cbActors.Items.Add(slCurrentNPCs[i]);
    end;
    
    btnRemoveNPC := TButton.Create(frm);
    btnRemoveNPC.Parent := frm;
    btnRemoveNPC.Caption := 'Remove Transfered NPC';
    btnRemoveNPC.Width := 150;
    btnRemoveNPC.Left := cbActors.Left + +cbActors.Width+10;
    btnRemoveNPC.Top := cbActors.Top;
    btnRemoveNPC.ModalResult := mrYes;

    modals := frm.ShowModal;
    if modals = mrOk then begin
      input1 := lbActors.Items[(lbActors.ItemIndex)];
      input2 := lbActors2.Items[(lbActors2.ItemIndex)];
      if (input1 = ' ') or (input2 = ' ') then Exit;
        iiSourceNPC := GrabWinningRecordFromSelection(input1);
        iiDestNPC := GrabWinningRecordFromSelection(input2);
      if Equals(GetFile(iiDestNPC), PatchFile) then begin
        Remove(iiDestNPC);
        iiDestNPC := GrabWinningRecordFromSelection(input2);
        AddMessage('Removing NPC');
      end;
      sSourceNPCName := geev(iiSourceNPC, 'FULL');
      if sSourceNPCName = '' then
        sSourceNPCName := geev(iiSourceNPC, 'EDID');
  
      sDestNPCName := geev(iiDestNPC, 'FULL');
      if sDestNPCName = '' then
        sDestNPCName := geev(iiDestNPC, 'EDID');
      //DEBUG
        //iiSourceNPC := RecordByHex('02001D90');
        //iiDestNPC := RecordByHex('00013255');
      //ENDDEBUG
      AddRequiredElementMasters(iiDestNPC, PatchFile, false);
      AddRequiredElementMasters(iiSourceNPC, PatchFile, false);
      iiDestNPC := wbCopyElementToFile(iiDestNPC,PatchFile,false,true);
      end 
    else if modals = mrYes then begin
      input1 := cbActors.Text;
      if not (input1 = 'NPC To Remove...') then begin
        RemoveNPC(ElementByIndex(GroupBySignature(PatchFile,'NPC_'), StrToInt(input1[1])));
      end;
    end
    else begin
      AddMessage('== User Has Quit ==');
      bQuit := true;
    end;
  finally
    frm.Free;
  end;
end;

procedure MoveRenameFaceGeom(sHex,sFile,dHex,dFile: String);
var
  tXferPath: String;
begin
  tXferPath := xferPath+moFileName+'\';
  ForceDirectories(tXferPath+lMeshPath+dFile+'\');
  ForceDirectories(tXferPath+lTexPath+dFile+'\');

  wCopyFile(TempPath+lMeshPath+sFile+'\'+sHex+'.nif',tXferPath+lMeshPath+dFile+'\'+dHex+'.nif', true);
  wCopyFile(TempPath+lTexPath+sFile+'\'+sHex+'.dds',tXferPath+lTexPath+dFile+'\'+dHex+'.dds', true);
  wCopyFile(TempPath+lMeshPath+sFile+'\'+sHex+'.nif',tXferPath+lMeshPath+dFile+'\'+dHex+'.nif', false);
  wCopyFile(TempPath+lTexPath+sFile+'\'+sHex+'.dds',tXferPath+lTexPath+dFile+'\'+dHex+'.dds', false);
end;



procedure TransferFaceGenData();
var
  i: Integer;
  sourceLocalHexID, destLocalHexID, destFileName, sourceFilename: String;
  tempFile: IInterface;
begin
  AddMessage('Inside Of TransferFaceGenData');
  sourceLocalHexID := '00'+ CopyFromTo(HexFormID(SourceNPC), 3, 8);
  destLocalHexID := '00'+ CopyFromTo(HexFormID(DestNPC), 3, 8);
  tempFile := MasterOrSelf(DestNPC);
  destFileName := GetFileName(tempFile);
  tempFile := MasterOrSelf(SourceNPC);
  sourceFilename := GetFileName(tempFile);
  ExtractFaceGeom(sourceNPC);
  MoveRenameFaceGeom(sourceLocalHexID, sourceFilename, destLocalHexID, destFileName);
end;


procedure TransferElements();
var
  i: integer;
  path: string;
  iiDest, iiSource, elementToAdd: IInterface;
begin
  iiDest := DestNPC;
  iiSource := SourceNPC;
  for i := 0 to Pred(slElementToXFer.Count) do begin
    RemoveSubElement(iiDest,slElementToXFer[i]);
  end;
  
  for i := 0 to Pred(slElementToXFer.Count) do begin
    CopySubElement(iiSource, iiDest,slElementToXFer[i]);
  end;
  AdditionalOptions();
end;

procedure RemoveSubElement(iiRecord: IInterface; elementName: String);
var
  elementToClean: IInterface;
begin
  elementToClean := ElementByIP(iiRecord, elementName);
  if Assigned(elementToClean) then begin
    AddMessage('Removed : '+elementName);
    Remove(elementToClean);
  end;
end;

procedure CopySubElement(iiS,iiD: IInterface; elementName: String);
var
  elementToCopy: IInterface;
begin
  elementToCopy := ElementByIP(iiS, elementName);
  if Assigned(elementToCopy) then begin
    AddMessage('Transfering : '+elementName);
    AddRequiredElementMasters(elementToCopy,iiD, false);
    wbCopyElementToRecord(elementToCopy,iiD,false,true);
  end;
end;

function ExtractFaceGeom(iiNpc: IInterface): boolean;
var
  i: Integer;
  bFound: Boolean;
  oFName, mFName, ovShortName, mstrShortName, bsaToCheck, hexID: String;
  nifPath, nifFile, ddsPath,ddsFile: String;
  iiNPCMaster: IInterface;
begin
  bFound := false;
  oFName := GetFileName(GetFile(iiNPC));
  ovShortName := CopyFromTo(oFName, 1,Length(oFName)-4)+'.bsa';
  iiNPCMaster := MasterOrSelf(iiNPC);
  mFName := GetFileName(GetFile(iiNPCMaster));
  hexID := '00'+ CopyFromTo(HexFormID(iiNPC), 3, 8);

  nifPath := lMeshPath+mFName+'\';
  nifFile := hexID+'.nif';
  ddsPath := lTexPath+mFName+'\';
  ddsFile := hexID+'.dds';

  AddMessage('ExtractFaceGeom: hexID: '+ hexID);
  
  TryToCopy(nifPath, nifFile);
  TryToCopy(ddsPath, ddsFile);

  //ForceDirectories(TempPath+lMeshPath+mFName+'\');
  //ForceDirectories(TempPath+lTexPath+mFName+'\');
  //First check if it is in a bsa and if it is which bsa could it be - if it is in a bsa then extract it - the override one takes precidence - otherwise grab it from data
  //for i := Pred(slContainers.Count) downto 0 do begin
  //  bsaToCheck := SimpleName(slContainers[i]);
  //  if Pos(bsaToCheck,bethBSAs) > 0 then continue;
  //    try
  //      ResourceCopy(DataPath+bsaToCheck,nifString,TempPath);
  //    except
  //      on E: Exception do begin
  //      AddMessage('Mesh Not In ' + bsaToCheck);
  //      end;
  //    finally
  //    end;
  //    try
  //      ResourceCopy(DataPath+bsaToCheck,ddsString ,TempPath);
  //    except
  //      on E: Exception do begin
  //       AddMessage('DDS Not In ' + bsaToCheck);
  //      end;
  //    finally
  //    end;
  //end;
  //wCopyFile(DataPath+nifString,TempPath+nifString, false);
  //wCopyFile(DataPath+ddsString,TempPath+ddsString, false);
  //wCopyFile(DataPath+nifString,TempPath+nifString, false);
  //wCopyFile(DataPath+ddsString,TempPath+ddsString, false);
  //Result := bFound;
end;

function TryToCopy(filePath, fileName: String): String;
var
  i: Integer;
  slRes: TStringList;
  fileString: String;
begin
  slRes := TStringList.Create;
  
  try
  ResourceCount(filePath+fileName, slRes);

  for i := Pred(slRes.Count) downto 0 do
    if slContainers.IndexOf(slRes[i]) <> -1 then begin
      Result := slRes[i];
      Break;
    end;
  if (Result <> '') then ResourceCopy(Result, filePath+fileName, TempPath);

  ForceDirectories(TempPath+filePath+fileName);
  wCopyFile(DataPath+filePath+fileNam,TempPath+filePath+fileNam, false);
  wCopyFile(DataPath+filePath+fileNam,TempPath+filePath+fileNam, false);
  except
    on E:Exception do
    slRes.Free;
  finally
    slRes.Free;
  end; 
end;

procedure GrabActors();
var
  i,j: integer;
  npcName, npcRace, filename: string;
  npcGRUP, indexRecord: IInterface;
begin
  sourceNPCIDs := TStringList.Create;
  sourceNPCIDs.Duplicates := dupIgnore;
  sourceNPCIDs.Sorted := true;
  destNPCIDs := TStringList.Create;
  destNPCIDs.Duplicates := dupIgnore;
  destNPCIDs.Sorted := true;
  for i := 0 to FileCount - 1 do begin
  npcGRUP := GroupBySignature(FileByIndex(i), 'NPC_');
    if Assigned(npcGRUP) then begin
      for j := 0 to Pred(ElementCount(npcGRUP)) do begin
        indexRecord := ElementByIndex(npcGRUP,j);
        if geev(indexRecord, 'ACBS\Flags\Unique') = '' then continue;
        npcName := geev(indexRecord, 'FULL');
        if npcName = '' then
        npcName := '_'+geev(indexRecord, 'EDID');
        npcName := npcName + ' : ' + HexFormID(indexRecord);
        destNPCIDs.Append(npcName);
        indexRecord := MasterOrSelf(indexRecord);
        filename := Lowercase(GetFileName(GetFile(indexRecord)));
        //Checks to see if the actor originates from bethesdas esms - if so then skip.
        //if Pos(filename,bethESMs) > 0 then continue;
        //npcRace := geev(indexRecord,'RNAM');
        //if Pos('RACE:00',npcRace) > 0 then continue;
        sourceNPCIDs.Append(npcName);
      end;
    end;
  end;
end;

procedure FreeGlobalLists();
begin
  if Assigned(sourceNPCIDs) then
  sourceNPCIDs.Free;
  if Assigned(destNPCIDs) then
  destNPCIDs.Free;
  if Assigned(slResList) then
  slResList.Free;
  if Assigned(slContainers) then
  slContainers.Free;
  if Assigned(slElementToXFer) then
  slElementToXFer.Free;
  if Assigned(slCurrentNPCs) then
  slCurrentNPCs.Free;
end;


  

// Moved over from mtefunction.pas with a fix due to a small error from a released version. 
function RecordByHex(id: string): IInterface;
var
  f: IInterface;
begin
  f := FileByLoadOrder(StrToInt('$' + Copy(id, 1, 2)));
  Result := RecordByFormID(f, StrToInt('$' + id), true);
end;


function SimpleName(aName: string): string;
begin
  Result := ExtractFileName(aName);
  if Result = '' then
    Result := 'Data';
end;

function CheckFileName(sFileName: string): boolean;
begin
  Result := false;
  if Pos('.esp.esp',Lowercase(sFileName)) > 0 then begin
    MessageDlg('ERROR: You''ve accidentally added a .esp when inputting your filename; resulting in the filename:'#13+sFileName+#13'Script Will Now Quit.'#13'When exiting please make sure to deselect '+sFileName+' So the file does not get created!',mtError, [mbOk], 0);
    bQuit := true;
    AddMessage('-Created Faulty Filename');
    Result := true;
  end;
end;

procedure GatherIniInfo();
var
  ini: TMemIniFile;
  cFilePath, moPath, fileNameString: string;
  moButton, moButton2, filenameOK: integer;
begin
  xferPath := '';
  bUsingMO := false;
  cFilePath := FileSearch('npcvt_Config.ini', DataPath);
  try
  //If Ini file isnt there - make it and set gv otherwise set gv from ini file
    if cFilePath = '' then begin
      moButton := MessageDlg('Welcome To NPC Visual Transfer:'#13'Since this is the first time you are runnning this script lets do some setup:'#13#13'Do You Use Mod Organizer?',mtConfirmation, [mbYes, mbNo], 0);
      if moButton = mrYes then begin
        bUsingMO := true;
        moPath := SelectDirectory('Please Select The Directory Where Mod Organizer Is Installed','',GamePath,'');
        if (moPath = '') then begin 
          AddMessage('== User Has Cancelled Directory Selection: Quitting ==');
          bQuit := true;
          Exit;
        end;
          xferPath := moPath;
          if not StrEndsWith(xferPath,'\mods\') then
          xferPath := xferPath + '\mods\';
      end else begin
        MessageDlg('ERROR:  Incompatible mod manager'#13#13'As of now, this script will only work for users who use mod organizer.'#13'For more information as to why, please visit the nexus modpage.', mtError, [mbOk], 0);
        AddMessage('-user does not have mod organizer');
        bQuit := true;
        Exit;
      end;
      PatchFile := FileByName('NPCVisualTransfer.esp');
      if not Assigned(PatchFile) then
      PatchFile := FileSelect('Please select/create the file which will'#13'house all of your NPC overrides.');
      if Assigned(PatchFile) then fileNameString := GetFileName(PatchFile)
      else begin
        AddMessage('-User Did Not Select Or Create A File: Quitting');
        bQuit := true;
        Exit;
      end;
      if CheckFileName(fileNameString) then Exit;
      ini := TMemIniFile.Create(DataPath+'npcvt_Config.ini');
      ini.WriteString('GENERAL', 'sXferPath', xferPath);
      ini.WriteString('GENERAL', 'sPatchFilename', fileNameString);
      ini.WriteBool('GENERAL', 'bUsingMO',bUsingMO);
      ini.UpdateFile;
      MessageDlg('Configuration Complete.'#13'An ini File has been created in your Skyrim''s Data directory named npcvt_Config.ini.',mtConfirmation, [mbOk], 0);
    end 
    else begin
      ini := TMemIniFile.Create(DataPath+'npcvt_Config.ini');
      xferPath := ini.ReadString('GENERAL','sXferPath',DataPath);
      bUsingMO := ini.ReadBool('GENERAL','bUsingMO', false);
      fileNameString := ini.ReadString('GENERAL','sPatchFilename','NONE');
      PatchFile := FileByName(fileNameString);
      if not Assigned(PatchFile) then begin
        PatchFile := FileByName(Lowercase(fileNameString));
          if not Assigned(PatchFile) then 
          PatchFile := FileSelect(fileNameString+' is not loaded into TES5Edit.'#13'Select/Create a different file to use or cancel to quit');
          if not Assigned(PatchFile) then begin
            AddMessage('-User Did Not Select Or Create A File: Quitting');
            bQuit := true;
            Exit;
          end 
          else begin
            fileNameString := GetFileName(PatchFile);
            if CheckFileName(fileNameString) then Exit;
            ini.WriteString('GENERAL','sPatchFilename',fileNameString);
            ini.UpdateFile;
          end;
      end;
      moButton := MessageDlg('NPC Visual Transfer Reminder: '#13#13'1: Was '+moFileName+' modfolder deselected in Mod Organizer before running this script?'#13#13'2: Is '+GetFileName(PatchFile)+' below all NPC related mods in your loadorder?', mtConfirmation, [mbYes, mbNo], 0);
      if not(moButton = mrYes) then begin
        MessageDlg('Please do that now.  Script will now exit.', mtError, [mbOk], 0);
        AddMessage('-Did not setup correctly');
        bQuit := true;
        Exit;
      end;
    end;
  finally
    if Assigned(ini) then ini.Free;
  end;
end;


function Initialize: integer;
var 
  i: integer;
begin
  bTrue := true;
  bFalse := false;
  bQuit := false;
  for i := 0 to 60 do AddMessage('');
  AddMessage('== NPC Visual Transfer ==');
  AddMessage('== Checking TES5Edit Version ==');
  if (wbVersionNumber < 50397184) or (wbAppName <> 'TES5') then begin
    EditOutOfDateLocal('3.1.0', 'http://www.nexusmods.com/skyrim/mods/25859/');
    Result := -1;
    Exit;
  end;
  AddMessage('-'+ GetVersionStringLocal(wbVersionNumber));
  AddMessage('-Version: OK!');
  AddMessage('== Gathering Ini Data ==');
  GatherIniInfo();
  if bQuit then begin
   Result := -1;
   Exit;
  end;
end;
//COPIED FROM MTEFUNCTIONS AND MODIFIED TO FIT NEEDS

function Finalize: integer;
begin
  try
    AddMessage('== Gathering NPC Information ==');
    AddMessage('-This will take a bit of time');
    slContainers := TwbFastStringList.Create;
    slCurrentNPCs := TStringList.Create;
    ResourceContainerList(slContainers);
    slElementToXFer := TStringList.Create;
    slElementToXFer.DelimitedText := MinElementsToModify;
    GrabActors();
    if bQuit then begin
     Result := -1;
     Exit;
    end;
    while bQuit = false do begin
      SourceNPC := nil;
      DestNPC := nil;
      ActorSelect('NPC','Select the standalone NPC whose visuals'#13'you wish to use','Select the NPC who will receive'#13'the new visuals', sourceNPCIDs,destNPCIDs, sourceNPC, destNPC);
      if bQuit then continue;
      if Assigned(SourceNPC) and Assigned(DestNPC) then begin
          TransferElements();
          TransferFaceGenData();
      end;
      if not(Assigned(SourceNPC)) and not(Assigned(DestNPC)) then AddMessage('Nothing Selected');
    end;
  except
    on E: Exception do FreeGlobalLists();
  finally
  
    FreeGlobalLists();
    CleanMasters(PatchFile);
  end;
  //if not Assigned(SourceNPC) then Result := -1;
end;

//Ported over from mtefunctions.pas and modified so it does not raise errors with 3.1
function GetVersionStringLocal(v: integer): string;
begin
  Result := Format('%sEdit version %d.%d.%d', [
    wbAppName,
    Int(v) shr 24,
    Int(v) shr 16 and $FF,
    Int(v) shr 8 and $FF
  ]);
end;
//Ported over from mtefunctions.pas and modified so it does not raise errors with 3.1
procedure EditOutOfDateLocal(minimumVersion: String; url: string);
var
  frm: TForm;
  lbl: TLabel;
  btnOk, btnCancel: TButton;
  v: integer;
  s: string;
begin
  frm := TForm.Create(nil);
  try
    frm.Caption := 'xEdit out of Date!';
    frm.Width := 300;
    frm.Height := 150;
    frm.Position := poScreenCenter;
    try
      s := GetVersionStringLocal(wbVersionNumber);
    except on Exception do
      s := wbAppName + 'Edit 3.0.31 or earlier';
    end;
    lbl := TLabel.Create(frm);
    lbl.Parent := frm;
    lbl.Top := 8;
    lbl.Left := 8;
    lbl.WordWrap := True;
    lbl.Width := 270;
    lbl.Caption := 
      'You''re using '+s+', but this script requires TES5Edit '+minimumVersion+' or newer.  '
      'Click the Update button to be directed to get the latest version.';
    AddMessage('You''re using '+s+', but this script requires '+wbAppName+'Edit '+minimumVersion+' or newer.');
    AddMessage('You can get the latest version at '+url);
    
    btnOk := TButton.Create(frm);
    btnOk.Parent := frm;
    btnOk.Top := lbl.Top + lbl.Height + 16;
    btnOk.Left := 40;
    btnOk.Caption := 'Update';
    btnOk.ModalResult := mrOk;
    btnOk.Hint := 'Click to open '+url+' in '#13#10+
    'your internet browser so you can download the latest xEdit beta version.';
    btnOk.ShowHint := true;
    
    btnCancel := TButton.Create(frm);
    btnCancel.Parent := frm;
    btnCancel.Top := btnOk.Top;
    btnCancel.Left := btnOk.Left + btnOk.Width + 20;
    btnCancel.Caption := 'Cancel';
    btnCancel.ModalResult := mrCancel;
    
    frm.Height := btnOk.Top + btnOk.Height + 50;
    
    if frm.ShowModal = mrOk then begin
      ShellExecute(TForm(frm).Handle, 'open', 
        url, '', '', SW_SHOWNORMAL);
    end;
  finally 
    frm.Free;
  end;
end;

end.