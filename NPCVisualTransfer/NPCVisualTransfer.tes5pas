{
  NPC Visual Transfer

  Allows to replace the visuals of one NPC to Another
}
unit NPCVisualTransfer;
uses mteFunctions;
const
  //,"Head Parts",HCLF,NAM6,NAM7,QNAM,"Tint Layers",OBND,NAM9,NAMA,FTST
  copyGRUPS = 'TXTS,"Head Parts",HCLF,NAM6,NAM7,QNAM,"Tint Layers",OBND,NAM9,NAMA,FTST';
  bethESMs = 'skyrim.esm'#13'dawnguard.esm'#13'dragonborn.esm'#13'hearthfires.esm'#13'update.esm';
  bethBSAs = 'skyrim - animations.bsa'#13'skyrim - meshes.bsa'#13'Skyrim - textures.bsa'#13'skyrim - misc.bsa'#13'dawnguard.bsa'#13'dragonborn.bsa'#13'hearthfires.bsa'#13'update.bsa';
  lMeshPath = 'meshes\actors\character\facegendata\facegeom\';
  lTexPath = 'textures\actors\character\facegendata\facetint\';
  moDataFolder = 'VNPC_Data';
  ScriptName = 'NPC Visual Transfer';
var 
  SourceNPC, DestNPC, PatchFile, DestFL: IInterface;
  sourceNPCIDs, destNPCIDs, slElementToXFer, slCurrentNPCs, slLocalForms, slCurrPass, slNextPass, slTotalElements, slNewMasters, slNewElements, slGrandTotalForms,slNewXfers: TStringList;
  bTrue, bFalse, bQuit, bUsingMO, bCreatingModFolders, bAdvancedTransfer, bFirstTime, bDebug: boolean;
  iDebugType, intNextID: integer;
  //NPC Specific Bools
  bCustomRace, bOpAnim, bCreature, bDidRenumber, bDragon: boolean;
  bFirstTransfer: boolean;
  moPath,nmmPath, xferPath, sSourceNPCName, sDestNPCName, sSourceSelection, nifPath, ddsPath, nifFile, ddsFile: String;
  slContainers: TwbFastStringList;
  t: TDateTime;

function Initialize: integer;
var 
  i: integer;
begin
  t := Now;
  Application.HintHidePause := 30000;
  iDebugType := 10;
  bTrue := true;
  bFalse := false;
  bQuit := false;
  bFirstTime := false;
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

function Finalize: integer;
var
  bAbort: boolean;
begin
  AddMessage('== Gathering NPC Information ==');
  InitAllGlobals();
  GrabActors();
  if bQuit then begin
      Result := -1;
      Exit;
  end;
  while bQuit = false do begin
    ResetGlobals();
    GrabActorsFromFile(PatchFile, slCurrentNPCs);
    ActorSelect('NPC','Select the standalone NPC whose visuals'#13'you wish to use','Select the NPC who will receive'#13'the new visuals',SourceNPC, DestNPC);
    if bQuit then continue;
    if Assigned(SourceNPC) and Assigned(DestNPC) then begin
      if Equals(SourceNPC, DestNPC) then begin 
          AddMessage('-There are no overrides for '+ sDestNPCName + ': Nothing to Transfer.');
          continue;
      end;
      Debug('PatchFile: '+ GetFileName(PatchFile),0);
      Debug('SourceNPC:' + Name(SourceNPC)+'SourceFile: '+GetFileName(GetFile(SourceNPC)),0);
      Debug('DestNPC:' + Name(DestNPC)+'DestFile: '+GetFileName(GetFile(DestNPC)),0);
      GatherPatchingInfo();
      bAbort := AdditionalOptions();
      if bAbort then begin 
          AddMessage('- User Aborted Current Process');
          continue;
      end; 
      Debug('PatchFile: '+ GetFileName(PatchFile),0);
      Debug('SourceNPC:' + Name(SourceNPC)+'SourceFile: '+GetFileName(GetFile(SourceNPC)),0);
      Debug('DestNPC:' + Name(DestNPC)+'DestFile: '+GetFileName(GetFile(DestNPC)),0);
      DestFL := CreateTransferFormList();
      intNextID := genv(ElementByPath(PatchFile, '[TES4:00000000]\HEDR - Header'), 'Next Object ID');
      GetLocalFormIDsFromFile(PatchFile, slLocalForms);
      slGrandTotalForms.AddStrings(slLocalForms);
      GetLocalFormIDsFromFile(GetFile(SourceNPC), slGrandTotalForms);
      TransferRecords(SourceNPC, GetFile(SourceNPC), 8);
      TransferElements();
      TransferFaceGenData();
      MakeOfficial();
      if bDidRenumber then begin
          RemoveFromActorList();
          MessageDlg(ScriptName+ ' Warning:'#13#13'Transferring '+sSourceNPCName+'''s visuals required renumbering formIDs related to that NPC.  To prevent any errors '+sSourceNPCName+' will no longer be selectable in the main menu.  If you wish to transfer '+sSourceNPCName+'''s visuals on more/different characters then please save and quit, then relaunch this script.',mtWarning,[mbOk],0);
      end;
    end;
  end;
  CleanMasters(PatchFile);
  SortMasters(PatchFile);
  RemoveMasters();
  slNewMasters.Delimiter := #13;
  if bUsingMO then begin
    if bFirstTime then
      ShowMessage('As this is your first time running this program, I have gone ahead and created a new modfolder called '+moDataFolder+'.  After hitting the refresh button in Mod Organizer this will appear in the left pane at the very bottom.  You will need to activate this folder in order for the approprate head mesh/textures to work.'#13#13'Note: Please do not RENAME or MERGE this modfolder unless you are completely uninstalling '+ScriptName+' and DO NOT SAVE any other esp but '+GetFileName(PatchFile)+' or you will have to reinstall them!'+''#13#13'If you wish, you can deactivate the following plugins:'#13''+slNewMasters.DelimitedText+''#13'but do not deactivate the mods themselves.')
    else
      ShowMessage('All NPC FaceGenData has been saved to the '+moDataFolder+' modfolder.  Remember: Do not save any Plugins other than'+GetFileName(PatchFile)+' and REACTIVATE '+ moDataFolder+''#13#13'If you wish, you can deactivate the following plugins:'#13''+slNewMasters.Text+'but do not deactivate the mods themselves.');
  end else begin
    if bFirstTime then
      ShowMessage('As this is your first time running this program, I have gone ahead and created a new folder called '+moDataFolder+'.  This is where I will backup facegendata y.  '#13#13'Note: Please do not RENAME or REMOVE this folder unless you are completely uninstalling '+ScriptName+ ' and DO NOT SAVE any other esp but '+GetFileName(PatchFile)+ 'or you will have to reinstall them!'+''#13#13'If you wish, you can deactivate the following plugins'#13''+slNewMasters.DelimitedText+'but do not uninstall any of the mod''s textures or meshes.')
    else
      ShowMessage('All Backup NPC FaceGenData has been saved to the '+moDataFolder+' folder.  Remember: Do not save any Plugins other than '+GetFileName(PatchFile)+''#13'If you wish, you can deactivate the following plugins'#13''+slNewMasters.Text+''#13'but do not uninstall any of the mod''s textures or meshes.');
  end;
  MakeBackUp();
  FreeGlobalLists();
  Application.HintHidePause := 1000;
  RemoveFilter();
end;

procedure GatherPatchingInfo();
var
  raceInt: Integer;
  sl:TStringList;
begin
  sl := TStringList.Create;
  //Add All Vanilla Beast/Dragon Races
  sl.DelimitedText := '3411,78311,78312,78313,78315,78317,78318,78319,78320,78321,78322,78323,78325,78326,78327,78328,78329,78330,78331,78332,78333,78334,78335,78336,78337,78338,78339,78340,78341,78342,78344,78345,78346,320775,321413,341111,425176,449689,457802,466538,633404,692637,749461,752024,761815,763205,802527,830995,850075,910597,966168,987522,989892,1012188,1019999,1068869,1076240,1078794,1081970,1088636';
  if genv(SourceNPC, 'RNAM') = 77442 then bDragon := true
  else 
  if (sl.IndexOf(IntToStr(genv(SourceNPC, 'RNAM'))) > -1) then bCreature := true;


end;

procedure TransferDiagScript(iNPC:IInterface);
var
  Ele, pcDiag: IInterface;
begin
    Ele := ElementByIp(iNPC, 'VMAD');
    pcDiag := ElementByIP(RecordByFormID(FileByIndex(0),247164,false),'VMAD');
  if not Assigned(Ele) then begin
    wbCopyElementToRecord(pcDiag, iNPC, false,true);
  end else begin
    Ele := ElementByIP(iNPC, 'VMAD\Data\Scripts');
    ElementAssign(Ele,HighInteger,ElementByIP(pcDiag,'Data\Scripts\Script'), false);
  end;
end;



procedure MakeOfficial();
var
  i: Integer;
  s, s2: string;
begin
  DateTimeToString(s2, 'mm dd yy hh mm',t);
  s := geev(DestFL,'EDID');
  seev(DestFL, 'EDID', s+' - Created on '+s2);
  slev(DestFL,'FormIDs',slNewElements);
end;

procedure MakeBackUp();
begin
  if DirectoryExists(TempPath) then BackupTempPath();
end;

procedure BackupTempPath();
var

  fdate: string;
  temp: TStringList;
begin
  temp := TStringList.Create;
  temp.Add(' ');
  DateTimeToString(fdate, 'mm dd y hh mm',t);
  CopyDirectory(TempPath+'OverwrittenFaceGens\', DataPath+moDataFolder+'\'+fdate+'\OverwrittenFaceGens\',temp,true);
  CopyDirectory(TempPath+'TransferredFaceGens\', DataPath+moDataFolder+'\'+fdate+'\TransferredFaceGens\',temp,true);
  temp.free;
end;

procedure asfrm.edFilterOnChange1(Sender: TObject);
var
  p: TObject;
  filter: string;
  i: integer;
begin
  p := Sender.Parent;
  if Sender.Modified = true then begin
    filter := LowerCase(Sender.Text);
    p.Components[2].Items.Clear;
    if Sender.Text = '' then p.Components[2].Items.AddStrings(sourceNPCIDs) else
    for i := 0 to sourceNPCIDs.Count-1 do begin
      if Pos(filter,LowerCase(sourceNPCIDs[i])) > 0 then p.Components[2].Items.Add(sourceNPCIDs[i]);
    end;
    p.Components[2].ItemIndex := -1;
    p.Components[2].Refresh;
  end;
  EnableTrans(Sender);
end;


procedure asfrm.edFilterOnChange2(Sender: TObject);
var
  p: TObject;
  filter: string;
  i: integer;
begin
  p := Sender.Parent;
  if Sender.Modified = true then begin
    filter := LowerCase(p.Components[3].Text);
    p.Components[4].Items.Clear;
    if p.Components[3].Text = '' then p.Components[4].Items.AddStrings(destNPCIDs) else
    for i := 0 to destNPCIDs.Count-1 do begin
      if Pos(filter,LowerCase(destNPCIDs[i])) > 0 then p.Components[4].Items.Add(destNPCIDs[i]);
    end;
   p.Components[4].ItemIndex := -1;
   p.Components[4].Refresh;
  end;
  EnableTrans(Sender);
end;

procedure clearEdit(Sender: TObject);
begin
  Sender.Text := '';
  Sender.Refresh;
end;

procedure lb2Enable(Sender: TObject);
var
  p: TObject;
begin
  if (Sender.ItemIndex <> (-1)) then begin
  p := Sender.Parent;
  p.Components[3].Enabled := true;
  p.Components[4].Enabled := true;
  p.Components[5].Enabled := true;
  p.Components[3].Refresh;
  p.Components[4].Refresh;
  p.Components[5].Refresh;
  end;
  EnableTrans(Sender);
end;

procedure EnableTrans(Sender: TObject);
var
  p: TObject;
begin
  p := Sender.Parent;
  if (p.Components[2].ItemIndex <> -1) and (p.Components[4].ItemIndex <> -1) then 
    p.Components[6].Enabled := true
  else 
    p.Components[6].Enabled := false;
  p.Components[6].Refresh;
end;

function ActorSelect(grup,prompt,prompt2: string; var iiSourceNPC:IInterface; var iiDestNPC: IInterface): integer;
var
  cbActors: TComboBox;
  i,z,modals: integer;
  s, input1,input2: string;
  masterFile: IInterface; 
  asfrm: TForm;
  btnOk, btnCancel, btnRemoveNPC, btnUseBackup: TButton;
  lbl, lbl2: TLabel;
  lBox, lBox2: TListBox;
  tEdit1, tEdit2: TEdit;
begin
  Debug('Inside ActorSelect',0);
  try
    asfrm := TForm.Create(nil);
    asfrm.Caption := 'Select '+ grup;
    asfrm.Width := 556;
    asfrm.Height := 510;
    asfrm.Position := poScreenCenter;

    lbl := TLabel.Create(asfrm);
    lbl.Parent := asfrm;
    lbl.Width := 200;
    if Pos(#13, prompt) > 0 then begin
      lbl.Height := 60;
    end
    else begin
      lbl.Height := 30;
      asfrm.Height := 160;
    end;
    lbl.Left := 10;
    lbl.Top := 8;
    lbl.Caption := prompt;
    lbl.Autosize := false;
    lbl.Wordwrap := True;

    tEdit1 := tEdit.Create(asfrm);
    tEdit1.Parent := asfrm;
    tEdit1.Left := 10;
    tEdit1.Top := lbl.Top+lbl.Height+3;
    tEdit1.Width := 230;

    lBox := TListBox.Create(asfrm);
    lBox.Parent := asfrm;
    lBox.Top := tEdit1.Top + tEdit1.Height + 3;
    lBox.Left := 10;
    lBox.Width := 230;
    lBox.Height := 300;
    lBox.Sorted := false;
    lBox.Items.AddStrings(sourceNPCIDs);
    lBox.OnClick := lb2Enable;

    tEdit2 := tEdit.Create(asfrm);
    tEdit2.Parent := asfrm;
    tEdit2.Left := lBox.Left+lBox.Width + 60;
    tEdit2.Top := lbl.Top+lbl.Height+3;
    tEdit2.Width := 230;
    tEdit2.Enabled := false;

    lBox2 := TListBox.Create(asfrm);
    lBox2.Parent := asfrm;
    lBox2.Top := lBox.Top;
    lBox2.Left := tEdit2.left;
    lBox2.Width := 230;
    lBox2.Height := 300;
    lBox2.Sorted := false;
    lBox2.Items.AddStrings(destNPCIDs);
    lBox2.Enabled := false;
    lBox2.OnClick := EnableTrans;

    lbl2 := TLabel.Create(asfrm);
    lbl2.Parent := asfrm;
    lbl2.Height := lbl.Height;
    lbl2.Left := lBox2.Left;
    lbl2.Width := 200;
    lbl2.Top := 8;
    lbl2.Caption := prompt2;
    lbl2.Autosize := false;
    lbl2.Wordwrap := True;
    lbl2.Enabled := false;
    
    btnOk := TButton.Create(asfrm);
    btnOk.Parent := asfrm;
    btnOk.Left := asfrm.Width div 2 - btnOk.Width - 16;
    btnOk.Top := lBox.Top + lBox.Height + 10;
    btnOk.Caption := 'Transfer';
    btnOk.ModalResult := mrOk;
    btnOk.Enabled := false;
    
    btnCancel := TButton.Create(asfrm);
    btnCancel.Parent := asfrm;
    btnCancel.Caption := 'Quit';
    btnCancel.ModalResult := mrCancel;
    btnCancel.Left := btnOk.Left + btnOk.Width + 16;
    btnCancel.Top := btnOk.Top;

    cbActors := TComboBox.Create(asfrm);
    cbActors.Parent := asfrm;
    cbActors.Style := csDropDown;
    cbActors.Sorted := false;
    cbActors.AutoDropdown := True;
    cbActors.Width := asfrm.ClientWidth div 2;
    cbActors.Left := asfrm.ClientWidth/4;
    cbActors.Top := btnOk.Top + btnOk.Height+16;
    cbActors.Text := 'Select A Transferred NPC Within...';
    if slCurrentNPCs.Count > 0 then cbActors.Items.AddStrings(slCurrentNPCs);

    
    btnRemoveNPC := TButton.Create(asfrm);
    btnRemoveNPC.Parent := asfrm;
    btnRemoveNPC.Caption := 'Remove Transferred NPC';
    btnRemoveNPC.Width := 170;
    if bUsingMO then
      btnRemoveNPC.Left :=(asfrm.ClientWidth/2)-(btnRemoveNPC.Width/2)
    else
      btnRemoveNPC.Left := (lBox.Left+(lbox.Width/2))-(btnRemoveNPC.Width/2)+10;
    btnRemoveNPC.Top := cbActors.Top+30;
    btnRemoveNPC.ModalResult := mrYes;
    btnRemoveNPC.ShowHint := true;
    btnRemoveNPC.Hint := 'This will remove your NPC from this patch and revert his/her visuals.';

    if not bUsingMO then begin
      btnUseBackup := TButton.Create(asfrm);
      btnUseBackup.Parent := asfrm;
      btnUseBackup.Caption := 'Restore NPC FaceGenData';
      btnUseBackup.Width := 170;
      btnUseBackup.Left := (lBox2.Left+(lbox2.Width/2))-(btnUseBackup.Width/2)-10;
      btnUseBackup.Top := cbActors.Top+30;
      btnUseBackup.ShowHint := true;
      btnUseBackup.Hint := 'Use this when your transferred NPC''s HeadMesh/FaceTint was accidentally overwritten by another mod.';
      btnUseBackup.ModalResult := mrRetry;
    end;

    tEdit1.Text := 'Filter By Name Or FormID...';
    tEdit2.Text := 'Filter By Name Or FormID...';
    tEdit1.OnChange := edFilterOnChange1;
    tEdit2.OnChange := edFilterOnChange2;
    tEdit1.OnClick := clearEdit;
    tEdit2.OnClick := clearEdit;
    btnOk.Enabled := false;
    modals := asfrm.ShowModal;
    if modals = mrOk then begin
      Debug(Format('ListBoxes: %d, %d',[lBox.ItemIndex, lBox2.ItemIndex]),5);
      if (lBox.ItemIndex = -1) or (lBox2.ItemIndex = -1) then begin 
        AddMessage('Please Have An NPC selected in both lists.');
        Exit;
      end;
      input1 := lBox.Items[(lBox.ItemIndex)];
      sSourceSelection := input1;
      input2 := lBox2.Items[(lBox2.ItemIndex)];

      iiSourceNPC := GrabWinningRecordFromSelection(input1);
      iiDestNPC := GrabWinningRecordFromSelection(input2);
      sSourceNPCName := geev(iiSourceNPC, 'FULL');
      if sSourceNPCName = '' then
        sSourceNPCName := EditorID(iiSourceNPC);
      sDestNPCName := geev(iiDestNPC, 'FULL');
      if sDestNPCName = '' then
        sDestNPCName := EditorID(iiDestNPC);
      
      if Equals(GetFile(iiDestNPC), PatchFile) then begin
        iiDestNPC := MasterOrSelf(iiDestNPC);
        i := OverrideCount(iiDestNPC); 
        Debug('Inside SameFile  ov: '+ IntToStr(i),1);
        if i = 1 then begin
        iiDestNPC := MasterOrSelf(iiDestNPC);
        end
        else iiDestNPC := OverrideByIndex(MasterOrSelf(iiDestNPC), i-2); 
      end;

      if Equals(GetFile(iiSourceNPC), PatchFile) then begin
        iiSourceNPC := MasterOrSelf(iiSourceNPC);
        Debug('Inside of patch',1);
        i := OverrideCount(iiSourceNPC); 
        if i = 1 then begin
        iiSourceNPC := MasterOrSelf(iiSourceNPC);
        end
        else iiSourceNPC := OverrideByIndex(MasterOrSelf(iiSourceNPC), i-2); 
      end;

      if Equals(iiSourceNPC, iiDestNPC) then begin
        iiDestNPC := MasterOrSelf(iiDestNPC);
        Debug('Inside of SameEsp',1);
        i := OverrideCount(iiDestNPC);
        if i = 0 then Exit 
        else if i = 1 then iiDestNPC := MasterOrSelf(iiDestNPC)
        else iiDestNPC := OverrideByIndex(MasterOrSelf(iiDestNPC), i-2); 
      end;
    end 
    else if modals = mrYes then begin
      input1 := cbActors.Text;
      if (input1 <> 'Select A Transferred NPC Within...') then begin
        RemoveNPC(ElementByIndex(GroupBySignature(PatchFile,'NPC_'), cbActors.ItemIndex), true);
      end else AddMessage('Please Select A Transferred NPC...');
    end
    else if modals = mrRetry then begin
      input1 := cbActors.Text;
      if (input1 <> 'Select A Transferred NPC Within...') then begin
        RestoreTransferredFaceGen(ElementByIndex(GroupBySignature(PatchFile,'NPC_'), cbActors.ItemIndex));
      end else AddMessage('Please Select A Transferred NPC...');
    end
    else begin
      AddMessage('== User Has Quit ==');
      bQuit := true;
    end;
  finally
    asfrm.free;
  end;
end;

procedure rg1.SetComboBox(Sender:TObject);
var
  p: TObject; 
begin
  p := Sender.Parent.Parent;
  if Sender.Caption = 'Manual' then begin
  p.Components[1].Enabled := true;
  p.Components[1].Text := '--- Please Select A Plugin Within ---';
  end else begin
  p.Components[1].Enabled := false;
  p.Components[1].ItemIndex := (-1);
  p.Components[1].Text := '--- Auto: '+GetFileName(DestNPC)+' ---';
  end;
end;
{
procedure rg2.SetComboBox(Sender:TObject);
var
  p: TObject; 
begin
  p := Sender.Parent.Parent;
  if Sender.Caption = 'Manual' then begin
  p.Components[3].Enabled := true;
  p.Components[3].Text := '--- Please Select A Path Within ---';
  end else begin
  p.Components[3].Enabled := false;
  p.Components[3].ItemIndex := (-1);
  p.Components[3].Text := '--- Auto: '+GetFileName(DestNPC)+' ---';
  end;
end;
}

function AdditionalOptions(): boolean;
var
  i, z, modal: Integer;
  inx: IInterface;
  sSourceFlags,sDestFlags : String;
  c: char;
  frm2: TForm;
  grp, grp1: TGroupBox;
  rgt, rg1, rg2: TRadioGroup;
  cBox1, cBox2, cBox3: TCheckBox;
  rbDef, rbOn, rbOff: TRadioButton;
  btnOK,btnCanc: TButton;
  tcBox: TComboBox;
  tmNotes: TMemo;
begin
  Result := false;
  Debug('Inside AdditionalOptions', 0);
  try 
    frm2 := TForm.Create(nil);
    frm2.Height := 290;
    frm2.Width := 540;
    frm2.Position := poScreenCenter;
    frm2.Caption := 'Additonal Options';
  
    rg1 := cRadioGroup(frm2, frm2, 10, 10,50,275,'File Source For: '+sDestNPCName);
    rg1.Items.Add('Auto');
    rg1.Items.Add('Manual');
    rg1.Columns := 2;
    rg1.Anchors := [akTop, akRight];
    rg1.ItemIndex := 0;
    rg1.ShowHint := true;
    rg1.Hint := 'Default: Auto - Selecting the Auto option will automatically grab the winning override record, or 2nd highest override if the same npc is selected'#13'This option is mainly used for people who have an npc whose visual they want to use, without sacrificing their non-visual modifications provided'#13'by other patches.'#13'Ex.  If I Select Lydia in both columns in the last form, and select UnOfficalSkyrimPatch.esp here (if installed) then'#13'I will effectively transfer both the visuals and USKP changes to the new override.';
    TRadioButton(rg1.Components[0]).OnClick := SetComboBox;
    TRadioButton(rg1.Components[1]).OnClick := SetComboBox;

    tcBox := TComboBox.Create(frm2);
    tcBox.Parent := frm2;
    tcBox.Top := rg1.top + rg1.height+5;
    tcBox.Left := 10;
    tcBox.Height := 50;
    tcBox.Width := 260;
    tcBox.Sorted := false;
    tcBox.Anchors := [akTop, akRight];
    tcBox.Enabled := false;
    tcBox.ItemIndex := (-1);
    tcBox.Text := '--- Auto: '+GetFileName(DestNPC)+' ---';


    inx := MasterOrSelf(DestNPC);
    tcBox.Items.AddObject(GetFileName(inx), TObject(inx));
    for i := 0 to OverrideCount(inx)-1 do begin
      inx := MasterOrSelf(DestNPC);
      inx := OverrideByIndex(inx, i);
      if Equals(GetFile(inx), PatchFile) then continue;
      tcBox.Items.AddObject(GetFileName(inx),TObject(inx));
    end;
  
    grp := cGroup(frm2, frm2, 10,rg1.left+10,180, 245, 'Optional Tweaks','');
    grp.left := frm2.ClientWidth-grp.Width-10;
    grp.Anchors := [akTop, akRight];
    grp1 := cGroup(frm2, grp, 20, 10, 100,220,'Outfit '#38' Inventory','');
  
    cBox1 := cCheckBox(frm2, grp1, 20, 10, 200,'Transfer Default Outfits.', cbUnchecked,'This will transfer '+sSourceNPCName+'''s default outfits along with his/her visuals.');


    cBox2 := cCheckBox(frm2,grp1, cBox1.top+cBox1.height+20, 10, 200,'Transfer npc inventory',cbUnchecked,'This will transfer '+sSourceNPCName+'''s initial inventory along with his/her visuals.'); 
    
    rgt := cRadioGroup(frm2,grp,grp1.top+grp1.height+10,10,50,grp1.width+15,'Opposite Gender Animations');
    rgt.Items.Add('Auto');
    rgt.Items.Add('On');
    rgt.Items.Add('Off');
    rgt.Columns := 3;
    rgt.ShowHint := true;
    rgt.ItemIndex := 0;
    rgt.Hint := 'Default: Auto'#13'Auto will automatically turn opposite animations on or off based on '+sSourceNPCName+'''s _NPC record';
  
    btnOk := cButton(frm2, frm2,grp.top+grp.height+10,0,0,0,'Apply');
    btnOk.Left := grp.Left + (btnOk.width/4);
    btnOk.ModalResult := mrOk;
    btncanc := cButton(frm2, frm2,grp.top+grp.height+10,0,0,0,'Cancel');
    btncanc.Left := grp.Left + (grp.ClientWidth/2)+(btnCanc.width/4);
    btncanc.ModalResult := mrCancel;


    tmNotes := ConstructMemo(frm2, frm2,tcBox.Top+tcBox.Height+5,10, 245-(tcBox.Top+tcBox.Height+15),260,true,true,ssBoth,'');
    FillNotes(tmNotes);
    if bDragon or bCreature then begin
      cBox1.State := cbChecked;
      cBox1.Enabled := false;
      rgt.Enabled := false;
    end;


    modal := frm2.ShowModal;

    if not(modal = mrOK) then Result := true;
    if Result = true then exit;
  
    if cBox1.State = cbChecked then begin
      slElementToXFer.Append('DOFT');
      slElementToXFer.Append('SOFT');
    end;
  
    if cBox2.State = cbChecked then begin
      slElementToXfer.Append('Items');
    end;

    if tcBox.ItemIndex > 0 then DestNPC := ObjectToElement(tcBox.Items[tcBox.ItemIndex]);
  finally
    frm2.free;
  end;
  if Result = true then exit;
  AddRequiredElementMasters(DestNPC, PatchFile, false);
  AddRequiredElementMasters(SourceNPC, PatchFile, false);
  RemoveNPC(OverrideByFile(DestNPC,PatchFile), true);
  slNewMasters.Append(GetFileName(GetFile(SourceNPC)));
  DestNPC := wbCopyElementToFile(DestNPC,PatchFile,false,true);

  sSourceFlags := geev(SourceNPC, 'ACBS\Flags');
  sDestFlags := geev(DestNPC, 'ACBS\Flags');
  while Length(sSourceFlags) < 32 do
    sSourceFlags := sSourceFlags + '0';
  while Length(sDestFlags) < 32 do
    sDestFlags := sDestFlags + '0';

  //Gender Index: 1
  ChangeFlag(1,sSourceFlags,sDestFlags, 0);
  //Opposite Animation Index: 20 
  ChangeFlag(20,sSourceFlags,sDestFlags, i);
  seev(DestNPC,'ACBS\Flags', sDestFlags);
end;
{
    rg2 := cRadioGroup(frm2, frm2, tcBox.top+tcBox.height+10, 10,50,260,'Record Source For '+sDestNPCName);
    rg2.Items.Add('Auto');
    rg2.Items.Add('Manual');
    rg2.Columns := 2;
    rg2.Anchors := [akTop, akRight];
    rg2.ItemIndex := 0;
    rg2.ShowHint := true;
    rg2.Hint := 'Default: Auto - Selecting the Auto option will automatically grab the winning override record, or 2nd highest override if the same npc is selected'#13'This option is mainly used for people who have an npc whose visual they want to use, without sacrificing their non-visual modifications provided'#13'by other patches.'#13'Ex.  If I Select Lydia in both columns in the last form, and select UnOfficalSkyrimPatch.esp here (if installed) then'#13'I will effectively transfer both the visuals and USKP changes to the new override.';
    TRadioButton(rg2.Components[0]).OnClick := SetComboBox;
    TRadioButton(rg2.Components[1]).OnClick := SetComboBox;
}

function GrabWinningRecordFromSelection(input: String): IInterface;
var
  i: Integer;
  sHexID: String;
  iiMasterRecord: IInterface;
begin
  // if Length(input) < 8 then exit;
  Debug('Inside GrabWinningRecordFromSelection', 0);
  sHexID := CopyFromTo(input, Length(input)-7, Length(input));
  Debug(sHexID, 1);
  iiMasterRecord := RecordByHex(sHexID);
  if not Assigned(iiMasterRecord) then exit;
  if OverrideCount(iiMasterRecord) > 0 then Result := WinningOverride(MasterOrSelf(iiMasterRecord))
  else Result := MasterOrSelf(iiMasterRecord);      
end;

procedure ChangeFlag(i:integer; sSourceFlags:string; var sDestFlags:string; changeType: integer);
var
  c: char;
begin
  Debug('Inside ChangeFlag',0);
  Debug('Source: '+sSourceFlags[i]+' Dest: '+ sDestFlags[i], 1);
  if changeType = 0 then begin
    if (sSourceFlags[i] <> sDestFlags[i]) then begin
      if sDestFlags[i] = '0' then c := '1' else c := '0';
      SetChar(sDestFlags, i, c);
    end;
  end 
  else if changeType = 1 then
    SetChar(sDestFlags, i, '1')
  else if changeType = 2 then
    SetChar(sDestFlags, i, '0');
end;


procedure GrabActors();
var
  i: integer;
begin
  AddMainEverything(sourceNPCIDs);
  sourceNPCIDs.sorted := true;
  for i := 1 to FileCount - 2 do begin
    GrabActorsFromFile(FileByLoadOrder(i), sourceNPCIDs);
  end;
  destNPCIDs.AddStrings(sourceNPCIDs);
end; 


procedure GrabActorsFromFile(iiFile: IInterface; sl: TStringList);
var
  j: Integer;
  npcGRUP, indexRecord: IInterface;
  npcName: String;
begin
  Debug('Inside GrabActorsFromFile', 0);
  npcGRUP := GroupBySignature(iiFile, 'NPC_');
  if Assigned(npcGRUP) then begin
    for j := 0 to Pred(ElementCount(npcGRUP)) do begin
      indexRecord := ElementByIndex(npcGRUP,j);
      if ElementExists(indexRecord, 'FULL') then begin
        npcName := GetElementEditValues(indexRecord, 'FULL');
        npcName := npcName + ' : ' + HexFormID(indexRecord);
        sl.Append(npcName);
      end;
    end;
  end;
end;


procedure RestoreTransferredFaceGen(iiNPC: IInterface);
var
  iFLST: IInterface;
  dHex, dFileName, dTimestamp: string;
begin
  if busingMO then begin
    AddMessage('--Meant For NMM Users Only.');
    Exit;
  end;
  AddMessage('--Restoring FaceGenData From Backup Folder');
  dHex := '00'+ CopyFromTo(HexFormID(iiNPC),3,8);
  dFileName := GetFileName(GetFile(MasterOrSelf(iiNPC)));
  iFLST := GetFLPrefixEleIndex('VNPC:',iiNPC,0);
  dTimestamp := '\'+Copy(EditorID(iFLST), Length(EditorID(iFLST))-13, 14)+'\';
  wCopyFile(DataPath+moDataFolder+dTimestamp+'TransferredFaceGens\'+lMeshPath+dFileName+'\'+dHex+'.nif',DataPath+lMeshPath+dFileName+'\'+dHex+'.nif', false);
  wCopyFile(DataPath+moDataFolder+dTimestamp+'TransferredFaceGens\'+lTexPath+dFileName+'\'+dHex+'.dds',DataPath+lTexPath+dFileName+'\'+dHex+'.dds', false);
  //wCopyFile(DataPath+moDataFolder+dTimestamp+'TransferredFaceGens\'+lMeshPath+dFileName+'\'+dHex+'.nif',DataPath+lMeshPath+dFileName+'\'+dHex+'.nif', false);
  //wCopyFile(DataPath+moDataFolder+dTimestamp+'TransferredFaceGens\'+lTexPath+dFileName+'\'+dHex+'.dds',DataPath+lTexPath+dFileName+'\'+dHex+'.dds', false);
end;


procedure RemoveNPC(iiNPC: IInterface; bHasAssets: boolean);
var
  iFLST: IInterface;
  dHex, dFileName, dTimestamp: string;
begin
  Debug('Inside RemoveNPC',0);
  if not Assigned(iiNPC) then exit; 
  if bHasAssets then begin
    If not GetLoadOrder(GetFile(iiNPC)) = GetLoadOrder(PatchFile) then Exit;
    dHex := '00'+ CopyFromTo(HexFormID(iiNPC),3,8);
    dFileName := GetFileName(GetFile(MasterOrSelf(iiNPC)));
    DeleteFile(xferPath+moDataFolder+'\'+lMeshPath+dFileName+'\'+dHex+'.nif');
    DeleteFile(xferPath+moDataFolder+'\'+lTexPath+dFileName+'\'+dHex+'.dds');
    if not bUsingMO then begin
      AddMessage('--Reverting FaceGenData From Backup Folder');
      iFLST := GetFLPrefixEleIndex('VNPC:',iiNPC,0);
      dTimestamp := '\'+Copy(EditorID(iFLST), Length(EditorID(iFLST))-13, 14)+'\';
      wCopyFile(DataPath+moDataFolder+dTimestamp+'OverwrittenFaceGens\'+lMeshPath+dFileName+'\'+dHex+'.nif',DataPath+lMeshPath+dFileName+'\'+dHex+'.nif', false);
      wCopyFile(DataPath+moDataFolder+dTimestamp+'OverwrittenFaceGens\'+lTexPath+dFileName+'\'+dHex+'.dds',DataPath+lTexPath+dFileName+'\'+dHex+'.dds', false);
      //wCopyFile(DataPath+moDataFolder+dTimestamp+'OverwrittenFaceGens\'+lMeshPath+dFileName+'\'+dHex+'.nif',DataPath+lMeshPath+dFileName+'\'+dHex+'.nif', false);
      //wCopyFile(DataPath+moDataFolder+dTimestamp+'OverwrittenFaceGens\'+lTexPath+dFileName+'\'+dHex+'.dds',DataPath+lTexPath+dFileName+'\'+dHex+'.dds', false);
    end;
  end;
  DeleteReleventRecords(iiNPC);
end;

function GetFLPrefixEleIndex(prefix:string; element :IInterface; indx: integer): IInterface;
var
  i,s: integer;
  ev: string;
  iGRUP, iElement: IInterface;
begin
  iGRUP := GroupBySignature(PatchFile, 'FLST');
  for i:= 0 to Pred(ElementCount(iGRUP)) do begin
    iElement := ElementByIndex(iGRUP, i);
    ev := EditorID(iElement);
    if Pos('VNPC:', ev) < 1 then continue;
    ev := geev(iElement,'FormIDs\['+IntToStr(indx)+']');
    if Pos(HexFormID(element), ev) > 0 then begin
      Result := iElement;
      Exit;
    end;
    ev := '';
  end;
end;

procedure DeleteReleventRecords(iNPCToDelete: IInterface);
var
  i,s: integer;
  iFLST, iFormIDs,iElement: IInterface;
begin
  Debug('Inside DeleteReleventRecords', 0);
  iFLST := GetFLPrefixEleIndex('VNPC:',iNPCToDelete,0);
  if not Assigned(iFLST) then Exit;
  iFormIDs := ElementByPath(iFLST,'FormIDs');
  for i := ElementCount(iFormIDs) - 1 downto 0 do begin
    iElement := ElementByIndex(iFormIDs, i);
    if not Assigned(iElement) then continue;
    RemoveNode(LinksTo(iElement));
  end;
  RemoveNode(iFLST);
end;

procedure TransferFaceGenData();
var
  test: string;
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
  GatherFaceGenPath(sourceNPC);
  AddMessage(nifPath);
  AddMessage(nifFile);
  AddMessage(ddsPath);
  AddMessage(ddsFile);
  test := TryToCopy(nifPath,nifFile);
  Debug('Grabbing File From ' +test, 1);
  test := TryToCopy(ddsPath,ddsFile);
  Debug('Grabbing File From ' +test, 1);
  MoveRenameFaceGen(sourceLocalHexID, sourceFilename, destLocalHexID, destFileName);
end;

function TryToCopy(filePath, fileName: String): String;
var
  i: Integer;
  slRes: TStringList;
  fileString: String;
begin
  Debug('Inside TryToCopy',0);
  slRes := TStringList.Create;
  try
    ResourceCount(filePath+fileName, slRes);
    ForceDirectories(TempPath+filePath);
    for i := Pred(slRes.Count) downto 0 do begin
      if slContainers.IndexOf(slRes[i]) <> -1 then begin
        Result := slRes[i];  
        Break;
      end;
    end;

    if (Result <> '') then ResourceCopy(Result, filePath+fileName, TempPath+filePath+fileName);
  //except
  //  on E:Exception do begin
  //  slRes.Free;
  //  AddMessage('Could Not Copy!');
  //  end;
  finally
    slRes.Free;
  end; 
end;

procedure MoveRenameFaceGen(sHex,sFile,dHex,dFile: String);
var
  tXferPath, tsFile, tdFile, msFile, mdFile: String;
begin
  Debug('Inside MoveRenameFaceGen',0);
  msFile := lMeshPath+sFile+'\'+sHex+'.nif';
  mdFile := lMeshPath+dFile+'\'+dHex+'.nif';
  tsFile := lTexPath+sFile+'\'+sHex+'.dds';
  tdFile := lTexPath+dFile+'\'+dHex+'.dds';
  if bUsingMO then begin 
    tXferPath := xferPath+moDataFolder+'\';
  end else tXferPath := DataPath;

  if (not bUsingMO) then begin
  //Make Backups of what we are overriding.  Only worried about overrides
    AddMessage('-- Backing Up FaceGenData');
    ForceDirectories(TempPath+lMeshPath+sFile+'\');
    ForceDirectories(TempPath+lTexPath+sFile+'\');
    ForceDirectories(TempPath+'OverwrittenFaceGens\'+lMeshPath+dFile+'\');
    ForceDirectories(TempPath+'OverwrittenFaceGens\'+lTexPath+dFile+'\');
    ForceDirectories(TempPath+'TransferredFaceGens\'+lMeshPath+dFile+'\');
    ForceDirectories(TempPath+'TransferredFaceGens\'+lTexPath+dFile+'\');

    wCopyFile(tXferPath+mdFile,TempPath+'OverwrittenFaceGens\'+mdFile, false);
    wCopyFile(tXferPath+tdFile,TempPath+'OverwrittenFaceGens\'+tdFile, false);


    wCopyFile(TempPath+msFile,TempPath+'TransferredFaceGens\'+mdFile, false);
    wCopyFile(TempPath+tsFile,TempPath+'TransferredFaceGens\'+tdFile, false);

  end;
  ForceDirectories(tXferPath+lMeshPath+dFile+'\');
  ForceDirectories(tXferPath+lTexPath+dFile+'\');

  
  wCopyFile(TempPath+msFile,tXferPath+mdFile, true);
  wCopyFile(TempPath+tsFile,tXferPath+tdFile, true);
  wCopyFile(TempPath+msFile,tXferPath+mdFile, false);
  wCopyFile(TempPath+tsFile,tXferPath+tdFile, false);
end;

procedure TransferElements();
var
  i: integer;
  path: string;
  elementToAdd: IInterface;
begin
  Debug('Inside TransferElements',0);
  for i := 0 to Pred(slElementToXFer.Count) do begin
    RemoveSubElement(DestNPC,slElementToXFer[i]);
  end;
  
  for i := 0 to Pred(slElementToXFer.Count) do begin
    CopySubElement(SourceNPC, DestNPC,slElementToXFer[i]);
  end;
end;

procedure RemoveSubElement(iiRecord: IInterface; elementName: String);
var
  elementToClean: IInterface;
begin
  Debug('Inside RemoveSubElement',0);
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
  Debug('Inside CopySubElement',0);
  elementToCopy := ElementByIP(iiS, elementName);
  if Assigned(elementToCopy) then begin
    if not CheckForErrors(0,elementToCopy) then begin
      AddMessage('Transfering : '+elementName);
      try
        AddRequiredElementMasters(elementToCopy,iiD, false);
        wbCopyElementToRecord(elementToCopy,iiD,false,true);
      //except
      //  on E:Exception do AddMessage('Could Not Copy Record!');
      finally
      end;
    end;
  end;
end;

function GatherFaceGenPath(iiNpc: IInterface): boolean;
var
  i: Integer;
  bFound: Boolean;
  oFName, mFName, mstrShortName, bsaToCheck, hexID, test: String;
  iiNPCMaster: IInterface;
begin
  Debug('Inside ExtractFaceGeom',0);
  bFound := false;
  oFName := GetFileName(GetFile(iiNPC));
  iiNPCMaster := MasterOrSelf(iiNPC);
  mFName := GetFileName(GetFile(iiNPCMaster));
  hexID := '00'+ CopyFromTo(HexFormID(iiNPC), 3, 8);

  nifPath := lMeshPath+mFName+'\';
  nifFile := hexID+'.nif';
  ddsPath := lTexPath+mFName+'\';
  ddsFile := hexID+'.dds';
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
    MessageDlg('ERROR: You''ve accidentally added a .esp when inputting your new filename; resulting in the filename:'#13+sFileName+#13'Script Will Now Quit.'#13'When exiting please make sure to deselect '+sFileName+' So the file does not get created!',mtError, [mbOk], 0);
    bQuit := true;
    AddMessage('-Created Faulty Filename');
    Result := true;
  end;
end;

function IsDataFolderLoaded(mPath: string): boolean;
var
  moINI: TMemIniFile;
  selectedProfile: string;
  profile: TStringList;
  i: integer;
begin
  Debug('Inside IsDataFolderLoaded',0);
  Result := false;
  moINI := TMemIniFile.Create(mPath+'\ModOrganizer.ini');
  selectedProfile := moINI.ReadString('General','selected_profile','');
  moINI.free;
  if (selectedProfile <> '') then begin
    profile := TStringList.Create;
    profile.LoadFromFile(moPath+'\profiles\'+selectedProfile+'\modlist.txt');
    for i := 0 to Pred(profile.Count) do begin
      if Pos(('+'+moDataFolder),profile[i]) > 0 then Result := true;
    end;
    profile.free;
  end;
end;

function CreateTransferFormList(): IInterface;
var 
  fl, flo: IInterface;
begin
  Debug('Inside CreateTrasnferFormList',0);
  fl := RecordByFormID(FileByIndex(0),101404,false);
  flo := wbCopyElementToFile(fl,PatchFile,true,true);
  seev(flo, 'EDID', 'VNPC: '+sDestNPCName+'''s records');
  Add(flo,'FormIDs',false);
  slTotalElements.Append(HexFormID(DestNPC));
  slev(flo,'FormIDs',slTotalElements);
  Result := flo;
end;

{
  TransferRecords:
    Procedure is broken up into three sections.
      1st: Detect the web of references that relate to SourceNPC.  So it will grab not only direct references, but references of those direct ref. and so on) 
      2nd: Check if any relevent records's FileFormID will conflict with any FileFormID inside of PatchFile.  If so, it will renumber it.
      3rd: Copy over the records to PatchFile
}

procedure TransferRecords(iCheckNPC, iFileToCheck: IInterface; maxPasses: integer);
var
  i,ii, z,zz, s, s2: Integer;
  sRecord, sLocalRecord: String;
  ElementToCheck, ElementToCopy,iElementToChange: IInterface;
begin
  Debug('Inside TransferRecords',0);
  bFirstTransfer := true;
  z := 0;
  if (Pos(Lowercase(GetFileName(iFileToCheck)), bethESMs)) > 0 then Exit;
  if not HasGroup(iFileToCheck, 'ARMO') then Exit;
  repeat
    if bFirstTransfer then begin
      Pass(iCheckNPC, iFileToCheck);
      bFirstTransfer := false;
    end 
    else begin
    slCurrPass.Clear;
    slCurrPass.DelimitedText := slNextPass.DelimitedText;
    slNextPass.Clear;
    Debug('Checking For Records Referencing These Forms: '+slCurrPass.DelimitedText, 5);
      for i := Pred(slCurrPass.Count) downto 0 do begin
        ElementToCheck := RecordByFormID(iFileToCheck, StrToInt('$'+slCurrPass[i]), true);
        Pass(ElementToCheck, iFileToCheck);
      end;
    end;
    Inc(z);
    if z = 1 then AddMessage('--Finished 1st Pass')
    else if z = 2 then AddMessage('--Finished 2nd Pass')
    else if z = 3 then AddMessage('--Finished 3rd Pass')
    else AddMessage('--Finished '+IntToStr(z)+'th Pass');
    Debug('TransferRecords: Z : '+ IntToStr(z),2);
  until (slNextPass.Count = 0) or (z = maxPasses);

  ii := (-1);
  Debug('slTotalElements: ' + slTotalElements.DelimitedText, 3);
  while ii < Pred(slTotalElements.Count) do begin
    Inc(ii);
    sRecord := slTotalElements[ii];
    sLocalRecord := '00'+Copy(sRecord, 3, 6);
    Debug('Local Record To Check: '+ sLocalRecord +' '+ IntToStr(ii), 3);
    If slLocalForms.IndexOf(sLocalRecord) > (-1) then begin
      If sRecord = HexFormID(DestNPC) then continue;
      iElementToChange := RecordByHex(sRecord);
      if not Assigned(iElementToChange) then continue;
      iElementToChange := nil;
      bDidRenumber := true;
      ChangeRecordIDAndAdd(sRecord);
      zz := slTotalElements.IndexOf(sRecord);
      //slTotalElements.Delete(zz);
    end;
  end;
  for i := 0 to Pred(slTotalElements.Count) do begin
    ElementToCopy := nil;
    ElementToCopy := RecordByHex(slTotalElements[i]);
    if Assigned(ElementToCopy) then begin
      If Equals(GetFile(ElementToCopy), PatchFile) then continue;
      AddRequiredElementMasters(ElementToCopy, PatchFile, false);
      ElementToCopy := wbCopyElementToFile(ElementToCopy, PatchFile, false, true);
      slNewElements.Append(HexFormID(ElementToCopy));
    end;
  end;
  //slNewElements.Insert(0,HexFormID(DestNPC));
end;

procedure Pass(iElementToCheck: IInterface; iFileToCheck: IInterface);
var
  i: integer;
  grups: TStringList;
begin
  grups := TStringList.Create;
  grups.DelimitedText := 'RACE,ARMO,HDPT,ARMA,OTFT,TXST,FLST';
  for i := Pred(grups.Count) downto 0 do begin
    Debug('Checking GRUP record: '+ grups[i],3);
    CopyRefElementsByGRUP(grups[i], iElementToCheck);
  end;
  grups.free;
end;

procedure CopyRefElementsByGRUP(GrupToCheck: string; referenceToCheck: IInterface);
var 
  i, iGrupSize: integer;
  iGRUP, iIndexElement: IInterface;
begin
  Debug('Inside CopyRefElementsByGRUP',0);
  iGRUP := GroupBySignature(GetFile(SourceNPC),GrupToCheck);
  iGrupSize := ElementCount(iGRUP);
  for i := 0 to Pred(iGrupSize) do begin
    //Debug(' LookingAtElement: '+ Name(iIndexElement), 1);
    iIndexElement := ElementByIndex(iGRUP, i);
    if IsReferencing(iIndexElement, referenceToCheck) then begin
      QueueCopy(iIndexElement, PatchFile, slTotalElements);
    end;
  end;
end;

function IsReferencing(elementToCheck, referenceToCheck: IInterface): boolean;
var
  i, refCount: integer;
  indexRef: IInterface;
begin
  Debug('Inside IsReferencing',0);
  //Debug('IsReferencing: '+(HexFormID(elementToCheck)+ '_'+HexFormID(referenceToCheck)),3);
  Result := false;
  refCount := ReferencedByCount(elementToCheck);
  for i := 0 to Pred(refCount) do begin
    indexRef := ReferencedByIndex(elementToCheck, i);
    //if FormID(indexRef) = FormID(referenceToCheck) then begin
    if Equals(indexRef, referenceToCheck) then begin
      //Debug('IsReferencing: FileNames: '+GetFileName(GetFile(indexRef))+ '',1);
      Result := true;
      Exit;
    end;
  end;
end;

procedure QueueCopy(iElementToAdd, iDestFile: IInterface; var slTotal:TStringList);
var
  i: Integer;
  e, eFile: IInterface;
  s: string;
begin
  Debug('Inside QueueCopyAndAdd',0);
  if not CheckForErrors(0,iElementToAdd) then begin
    s := HexFormID(iElementToAdd);
    if slTotal.IndexOf(s) < 0 then begin
      slNextPass.Insert(0,s);
      //if Signature(iElementToAdd) = 'FLST' then 
      slTotal.Append(s);
      //else
      //slTotal.Append(HexFormID(iElementToAdd));
      Debug('-Referenced Record Found!',5);
      Debug('--Adding Record To Transfer Queue: '+Name(iElementToAdd), 5);
    end;
  end;
end;

procedure ChangeRecordIDAndAdd(iFormString: string);
var
  newFormIDS: String;
  oldFormID, NewFormID: cardinal;
  i: integer;
  iElementToChange, iFile: IInterface;
begin
  Debug('Inside ChangeRecordIDAndAdd', 0);
  iElementToChange := RecordByHex(iFormString);
  If Equals(GetFile(iElementToChange), PatchFile) then Exit;
  i := 0;
  repeat
    Inc(i);
    NewFormID := intNextID + i;
    NewFormIDS := IntToHex(NewFormID, 8);
  until slGrandTotalForms.IndexOf(NewFormIDS) = (-1);
  intNextID := NewFormID;
  NewFormID := (StrToInt('$'+Copy(iFormString,1,2))*16777216) + NewFormID;
  //slNewLocals.Append(IntToHex(NewFormID,8));
  RenumberRecord(iElementToChange,NewFormID);
  slTotalElements.Append(IntToHex(NewFormID, 8));
  slGrandTotalForms.Append(NewFormIDS);
end;

//taken From MergePlugin v1.9
procedure RenumberRecord(e: IInterface; NewFormID: Cardinal);
var
  OldFormID, prc: Cardinal;
  iRef: IInterface;
begin
  Debug('Inside of RenumberRecord', 0);
  OldFormID := GetLoadOrderFormID(e);
  // change references, then change form
  Debug('RenumberRecord: '+ Name(e) + ' '+ 'ReferenceCount: '+IntToStr(ReferencedByCount(e)),  3);
  Debug('RenumberRecord: OldFormID: '+ IntToHex(OldFormID, 8) + '  NewFormID:'+ IntToHex(NewFormID, 8), 3);

  for prc := ReferencedByCount(e)-1 downto 0 do begin
    if ReferencedByCount(e) = 0 then break;
    iRef := ReferencedByIndex(e,prc);
    if Equals(GetFile(iRef),PatchFile) then continue;
    CompareExchangeFormID(iRef, OldFormID, NewFormID);
    prc := ReferencedByCount(e)-1;
  end;
  SetLoadOrderFormID(e, NewFormID);
end;

procedure GatherNPCInfo();
var 
  sSourceFlags, sDestFlags: string;
begin
  sSourceFlags := geev(SourceNPC, 'ACBS\Flags');
  sDestFlags := geev(DestNPC, 'ACBS\Flags');
   while Length(sSourceFlags) < 32 do
    sSourceFlags := sSourceFlags + '0';
  while Length(sDestFlags) < 32 do
    sDestFlags := sDestFlags + '0';
    
  if Pos(':00',geev(SourceNPC, 'RNAM')) < 1 then bCustomRace := true;
  if sSourceFlags[19] = 1 then bOpAnim := true;
end;

procedure InitAllGlobals();
begin
  slContainers := TwbFastStringList.Create;
  slCurrentNPCs := TStringList.Create;
  ResourceContainerList(slContainers);
  slElementToXFer := TStringList.Create;
  slLocalForms := TStringList.Create;
  slLocalForms.Sorted := true;
  slGrandTotalForms := TStringList.Create;
  slGrandTotalForms.Sorted := true;
  slGrandTotalForms.CaseSensitive := false;
  slCurrPass := TStringList.Create;
  slCurrPass.Sorted := true;
  slCurrPass.Duplicates := dupIgnore;
  slNextPass := TStringList.Create;
  slTotalElements := TStringList.Create;
  slTotalElements.Sorted := true;
  slTotalElements.Duplicates := dupIgnore;
  slNewMasters := TStringList.Create;
  slNewMasters.Sorted := true;
  slNewMasters.Duplicates := dupIgnore;
  sourceNPCIDs := TStringList.Create;
  sourceNPCIDs.Duplicates := dupIgnore;
  sourceNPCIDs.Sorted := true;
  destNPCIDs := TStringList.Create;
  destNPCIDs.Duplicates := dupIgnore;
  destNPCIDs.Sorted := false;
  slNewElements := TStringList.Create;
  slNewElements.Duplicates := dupIgnore;
  slNewXfers := TStringList.Create;
  ResetGlobals();
end;

procedure ResetGlobals();
begin
  slElementToXFer.Clear;
  slElementToXFer.DelimitedText := 'RNAM,WNAM,ANAM,"Head Parts",HCLF,NAM6,NAM7,QNAM,"Tint Layers",OBND,NAM9,NAMA,FTST';
  slCurrPass.Clear;
  slNextPass.Clear;
  slTotalElements.Clear;
  slCurrentNPCs.Clear;
  slLocalForms.Clear;
  slNewElements.Clear;
  slGrandTotalForms.Clear;
  bCustomRace := false;
  bOpAnim:= false;
  bCreature := false;
  bDragon := false;
  SourceNPC := nil;
  DestNPC := nil;
  bDidRenumber := false;
  nifPath := '';
  ddsPath := '';
  nifFile := '';
  ddsFile := '';
end;

procedure FreeGlobalLists();
begin
  sourceNPCIDs.free;
  destNPCIDs.free;
  slElementToXFer.free;
  slCurrentNPCs.free;
  slLocalForms.free;
  slCurrPass.free;
  slNextPass.free;
  slTotalElements.free;
  slNewMasters.free;
  slNewElements.free;
  slGrandTotalForms.free;
  slContainers.free;
  slNewXfers.free;
end;


//Grabs all the local FormID by hex from a file and adds it to a stringlist
//Note : This will not work if the file contains 
procedure GetLocalFormIDsFromFile(iFile: IInterface; slRecords: TStringList);
var
  i: integer;
  iRecord: IInterface;
begin
  Debug('Inside GetLocalFormIDsFromFile '+GetFileName(iFile), 0);
  if ElementTypeString(iFile) <> 'etFile' then exit;
  if Pos(Lowercase(GetFileName(iFile)), bethESMs) > 0 then exit;
  //start at one as we dont care for the file header which is always at 0
  for i := 1 to RecordCount(iFile) do begin
    iRecord := RecordByIndex(iFile, i);
    slRecords.Append(LocalHex(iRecord));
  end;
end;

function LocalHex(iElement: IInterface): string;
var
  hexID: string;
begin
  hexID := HexFormID(iElement);
  Result := CopyFromTo(hexID,3,8);
  Result := '00'+ Result;
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
  frm1: TForm;
  lbl: TLabel;
  btnOk, btnCancel: TButton;
  v: integer;
  s: string;
begin
  frm := TForm.Create(nil);
  try
    frm1.Caption := 'xEdit out of Date!';
    frm1.Width := 300;
    frm1.Height := 150;
    frm1.Position := poScreenCenter;
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
    
    frm1.Height := btnOk.Top + btnOk.Height + 50;
    
    if frm1.ShowModal = mrOk then begin
      ShellExecute(TForm(frm).Handle, 'open', 
        url, '', '', SW_SHOWNORMAL);
    end;
  finally 
    frm1.Free;
  end;
end;
//TAKEN FROM CHECK FOR ERRORS.PAS - REMOVED MESSAGES AS THEY DO NOT NEED IT
function CheckForErrors(aIndent: Integer; aElement: IInterface): Boolean;
var
  Error : string;
  i     : Integer;
begin
  Error := Check(aElement);
  Result := Error <> '';
  if Result then begin
    Error := Check(aElement);
    AddMessage(StringOfChar(' ', aIndent * 2) + Name(aElement) + ' -> ' + Error);
  end;

  for i := ElementCount(aElement) - 1 downto 0 do
    Result := CheckForErrors(aIndent + 1, ElementByIndex(aElement, i)) or Result;
end;

procedure Debug(s: string; i: integer);
begin
  if (i = iDebugType) or (iDebugType < 0) then AddMessage('DEBUG:  '+s);
end;

procedure RemoveFromActorList();
var
  i: Integer;
begin
  i := sourceNPCIDs.IndexOf(sSourceSelection);
  sourceNPCIDs.Delete(i);
  destNPCIDs.Delete(i);
end;

procedure RemoveMasters();
var
  i, z, g: integer;
  iGRUP, iElement: IInterface;
begin
  Debug('Removing Masters: ', 3);
  iGRUP := GroupBySignature(PatchFile, '_NPC');
  for z := 0 to Pred(ElementCount(iGRUP)) do begin
    iElement := ElementByIndex(iGRUP, z);
    g := slNewMaster.IndexOf(GetFileName(GetFile(iElement)));
    if g > (-1) then slNewMasters.Delete(g); 
  end;

  i := 0;
  while i < slNewMasters.Count do begin 
    if Pos(LowerCase(slNewMasters[i]), bethESMs) > 0 then begin
      slNewMasters.Delete(i);
      Pred(i);
    end else begin
      RemoveMaster(PatchFile, slNewMasters[i]);
      Inc(i)
    end;
  end;
end;


procedure GatherIniInfo();
var
  i: integer;
  ini: TMemIniFile;
  sl: TStringList;
  cFilePath, fileNameString: string;
  moButton, moButton2, filenameOK: integer;
begin
  xferPath := DataPath;
  bUsingMO := false;
  cFilePath := FileSearch('npcvt_Config.ini', DataPath);
  //try
  if cFilePath = '' then begin
    bFirstTime := true;
    moButton := MessageDlg('Welcome To NPC Visual Transfer:'#13'Since this is the first time you are runnning this script lets do some setup:'#13#13'Do You Use Mod Organizer?',mtConfirmation, [mbYes, mbNo], 0);
    if moButton = mrYes then begin
      bUsingMO := true;
      moPath := SelectDirectory('Select The Folder Containing ModOrganizer.exe','',DataPath,'');
      if (moPath = '') then begin 
        AddMessage('== User Has Cancelled Directory Selection: Quitting ==');
        bQuit := true;
        Exit;
      end;
      sl := TStringList.Create;
      sl.Delimiter := '\\';
      sl.StrictDelimiter := true;
      ini := TMemIniFile.Create(moPath+'\ModOrganizer.ini');
      sl.DelimitedText := ini.ReadString('Settings','mod_directory',DataPath);
      ini.free; 
      xferPath := '';     
      for i := 0 to Pred(sl.Count) do
        if sl[i] <> '' then xferPath := xferPath + sl[i]+'\';
      sl.free;
    end 
    else begin
      MessageDlg('Note:  Due to the nature of non-virtualized directories it will be on you to remember what NPCs you have modified and make sure their FaceGenData and assets do not get overwritten.'#13#13'A good rule of thumb is that if you are going to alter an NPC that was modified by this script, use the "remove transferred NPC" button before doing so.' , mtWarning, [mbOk], 0);
      AddMessage('-user does not have mod organizer');
      bUsingMO := false;
    end;
    PatchFile := FileByName('NPCVisualTransfer.esp');
    if not Assigned(PatchFile) then
      PatchFile := FileSelect('Please select/create the file which will'#13'house all of your NPC overrides.');
    if Assigned(PatchFile) then begin
      fileNameString := GetFileName(PatchFile);
    end else begin
      AddMessage('-User Did Not Select Or Create A File: Quitting');
      bQuit := true;
      Exit;
    end;
    BuildRef(PatchFile);
    if CheckFileName(fileNameString) then Exit;
    ini := TMemIniFile.Create(DataPath+'npcvt_Config.ini');
    ini.WriteString('GENERAL', 'sMOPath', moPath);
    ini.WriteString('GENERAL', 'sXferPath', xferPath);
    ini.WriteString('GENERAL', 'sPatchFilename', fileNameString);
    ini.WriteBool('GENERAL', 'bUsingMO',bUsingMO);
    ini.UpdateFile;
    ini.free;
    if bUsingMO then begin
    MessageDlg('Configuration Complete.'#13'An ini File has been created in your overwrite folder named npcvt_Config.ini. Either keep it in the overwrite folder or move it into your NPCVisualTransfer modfolder.'#13'I have also made a new modfolder called '+moDataFolder+'. This is where the modified npc''s head texture/mesh will be saved.  Please do not modify, rename, or merge that folder in any way or this script will assume you are starting from scratch again!',mtInformation, [mbOk], 0);
    end else
    MessageDlg('Configuration Complete.'#13'An ini File has been created in your Data folder named npcvt_Config.ini. Please do not move/rename that file in any way.'#13'I have also made a new folder in your Skyrim''s Data folder called '+moDataFolder+'. This is where the modified npc''s head texture/mesh will be saved. Along with a backup of FaceGenData every transfer.   Please do not modify, rename, or merge that folder in any way or this script will assume you are starting from scratch again!  (You can remove backups though if it gets cluttered)',mtInformation, [mbOk], 0);
  end 
  else 
  begin
    ini := TMemIniFile.Create(DataPath+'npcvt_Config.ini');
    moPath := ini.ReadString('GENERAL', 'sMOPath', '');
    xferPath := ini.ReadString('GENERAL','sXferPath',DataPath);
    bUsingMO := ini.ReadBool('GENERAL','bUsingMO', false);
    fileNameString := ini.ReadString('GENERAL','sPatchFilename','NONE');
    ini.free;
    if bUsingMO then begin 
      if IsDataFolderLoaded(moPath) then begin
        MessageDlg('VNPC ERROR: '+moDataFolder+' is active in mod organizer.'#13#13'Please deactivate '+moDataFolder+' in mod organizer then run this script again.',mtError, [mbOk], 0);
        AddMessage(moDataFolder+' is still active in mod organizer.  Please deactivate that folder and run the patch again');
        bQuit := true;
        Exit;
      end;
      moButton := MessageDlg('NPC Visual Transfer Reminder: '#13#13'1: Is '+moDataFolder+' below all NPC-related ModFolders?'#13#13'2: Is '+GetFileName(PatchFile)+' below all NPC-related mods in your loadorder?', mtConfirmation, [mbYes, mbNo], 0);
      if not(moButton = mrYes) then begin
          MessageDlg('Please check that now, otherwise some transfers will not work. Script will now exit.', mtError, [mbOk], 0);
          AddMessage('-Did not setup correctly');
          bQuit := true;
          Exit;
      end;
    end;
    PatchFile := FileByName(fileNameString);
    if not Assigned(PatchFile) then 
    begin
      PatchFile := FileByName(Lowercase(fileNameString));
      if not Assigned(PatchFile) then 
      PatchFile := FileSelect(fileNameString+' is not loaded into TES5Edit.  Select/Create a'#13'different file to use or cancel to quit.  Do not create'#13'a new file until VNPC_Data has been deleted!');
      if not Assigned(PatchFile) then begin
          AddMessage('-User Did Not Select Or Create A File: Quitting');
          bQuit := true;
          Exit;
      end 
      else begin
        BuildRef(PatchFile);
        fileNameString := GetFileName(PatchFile);
        if CheckFileName(fileNameString) then Exit;
        ini := TMemIniFile.Create(DataPath+'npcvt_Config.ini');
        ini.WriteString('GENERAL','sPatchFilename',fileNameString);
        ini.UpdateFile;
        ini.free;
      end;
    end;
  end;
end;

procedure FillNotes(m:TMemo);
var bNotSame: boolean;
begin
  bNotSame := not SameText(GetElementEditValues(SourceNPC,'RNAM'),GetElementEditValues(DestNPC,'RNAM'));
  AddMessage('Element: '+GetElementEditValues(SourceNPC,'RNAM'));
  m.Lines.Add('__________');
  m.Lines.Add('WARNINGS  \');
  if (bDragon and bNotSame) then begin
    m.Lines.Add('- You are transfering the visuals of a dragon onto a non-dragon NPC.  Please be aware that while the NPC will show up in game, you will be unable to interact with it.');
    m.Lines.Add('---Please be very careful if you are transfering this visual to a potential follower that is managed by AFT or a similar follower manager.  While my modifications do not persist after reverting, their modifications might.');
    m.Lines.Add(' ');
  end;
  if (bCreature and bNotSame) then begin
    m.Lines.Add('- You are transfering the visuals of a creature/animal onto a different animal or non-animal NPC.  Please be aware that while the NPC will show up in game, you will be unable to interact with it and it might not move or attack.');
    m.Lines.Add('---Please be very careful if you are transfering this visual to a potential humanoid follower that is managed by AFT or a similar follower manager.  While these modifications do not persist after reverting, their modifications might.');
    m.Lines.Add(' ');
  end;
  m.Lines.Add('__________');
  m.Lines.Add('NOTES         \');
  if ((Pos('RACE:00',GetElementEditValues(SourceNPC,'RNAM')) > 0) and (bNotSame)) then begin
    m.Lines.Add('- This visual transfer will require changing your race to something other than the traditional humanoid races.  Usually this is because '+sSourceNPCName+' is using a custom skeleton.nif or is a vampire/werewolf.  While 99% of the time this is not a big deal, this might affect Vampire and Beast transformations if using vampire/werewolf overhauls and managers.');
    m.Lines.Add(' ');
  end;
  if bCreature or bDragon then begin
    m.Lines.Add(' - Transfer Default Outfits and Opposite Gender Animations have been locked and managed internally to ensure compatibility.');
    m.Lines.Add(' ');
  end;
end;

procedure AddMainEverything(sl: TStringList);
begin
  sl.DelimitedText := '"Abelone : 0008774F","Acolyte Jenssen : 000D3E79","Adara : 00013385","Addvar : 00013255","Addvild : 00019DC7","Adeber : 000661AD","Adelaisa Vendicci : 0001411D","Adisla : 0001411E","Adonato Leotelli : 0001413C","Adrianne Avenicci : 00013BB9","Aduri Sarethi : 00019BFF","Advard : 0007F692","Adventurer : 00055BA7","Adventurer : 00074BC0","Adventurer : 00083279","Adventurer : 000860C3","Adventurer : 000860C4","Adventurer : 000860C5","Adventurer : 000860C6","Adventurer : 000860C7","Adventurer : 000A4CB5","Adventurer : 000C176B","Adventurer : 000E4D2D","Adventurer : 000ED575","Adventurer : 0010553F","Aela the Huntress : 0001A696","Aeri : 0001360B","Aerin : 00013346","Affable Gent : 000FC198","Afflicted : 00064A42","Afflicted Devotee : 00043AB8","Afflicted Refugee : 000BEDE5","Afflicted Remnants : 000BEDE3","Afflicted Remnants : 000BEDE4","Agent Lorcalin : 000DD99E","Agna : 000A9599","Agni : 000135E5","Agnis : 00020044","Agrius : 00083B19","Ahjisi : 000CE086","Ahkari : 0001B1D6","Ahlam : 00013BBE","Ahtar : 0001325F","Aia Arria : 0001325C","Aicantar : 0001402E","Aicantar''s Spider : 0005CF36","Ainethach : 00013B69","Alain Dufont : 0001B074","Alchemist : 00099805","Alding : 00052268","Alduin : 00032B94","Alduin : 0008E4F1","Alea Quintus : 0002E3EF","Alessandra : 00013347","Alethius : 000C370C","Alexia Vici : 00060B29","Alfarinn : 0009B7AB","Alfhild Battle-Born : 00013BB0","Alik''r Prisoner : 000215F5","Alik''r Warrior : 00020071","Alik''r Warrior : 00055FB2","Alik''r Warrior : 00058B3F","Alik''r Warrior : 0006762E","Alik''r Warrior : 00108CF5","Alik''r Warrior : 0010F5A1","Alik''r Warrior : 0010F5AA","Alpha Wolf : 0009931A","Alva : 000135E6","Alvor : 00013475","Amaund Motierre : 0003B43A","Amaund Motierre : 0004E64F","Ambarys Rendar : 0001413E","Amren : 00013BAA","Ancano : 0001E7D7","Ancient Dragon : 000F811C","Ancient Dragon : 000F811E","Ancient Vampire : 00033851","Anders : 000FF224","Andurs : 00013BA8","Angeline Morrard : 00013260","Anger : 0009F851","Angi : 000CAB2F","Angrenor Once-Honored : 00014137","Angvid : 000AE77D","Anise : 000DDF86","Annekke Crag-Jumper : 00013666","Anoriath : 00013B97","Anska : 000443F3","Anton Virane : 00013387","Anuriel : 00013349","Anwen : 00013386","Apprentice Conjurer : 0006D22F","Apprentice Conjurer : 000E0FBE","Apprentice Fire Mage : 00045C5F","Apprentice Fire Mage : 000E0FBF","Apprentice Ice Mage : 00045C60","Apprentice Ice Mage : 000E0FC0","Apprentice Necromancer : 000548FF","Apprentice Necromancer : 000E0FC1","Apprentice Storm Mage : 00045C61","Apprentice Storm Mage : 000E0FC2","Aquillius Aeresius : 000D6AD8","Aranea Ienith : 00028AD0","Arcadia : 00013BA4","Arch Conjurer : 001091A8","Arch Conjurer : 001091AD","Arch Cryomancer : 001091AA","Arch Cryomancer : 001091AF","Arch Electromancer : 001091AC","Arch Electromancer : 001091B1","Arch Necromancer : 001091AB","Arch Necromancer : 001091B0","Arch Pyromancer : 001091A9","Arch Pyromancer : 001091AE","Arcturus : 0004D6CA","Ardwen : 000BED8A","Argi Farseer : 00013602","Argis the Bulwark : 000A2C8C","Argonian : 000457FB","Argonian : 000457FE","Argonian : 00105552","Argonian : 00105554","Argonian : 00105561","Argonian : 00106118","Ari : 000411CF","Aringoth : 0001334A","Arivanya : 00014127","Arnbjorn : 0001BDB0","Arnbjorn : 00032896","Arngeir : 0002C6C7","Arniel Gane : 0001C19D","Arniel''s Shade : 0006A152","Arnskar Ember-Master : 00029DAD","Arob : 00013B7B","Arondil : 00037D80","Arrald Frozen-Heart : 00084552","Arvel the Swift : 00039646","Arvel the Swift : 00099991","Asbjorn Fire-Tamer : 00019DF2","Ascendant Conjurer : 0006D232","Ascendant Conjurer : 000E0FCD","Ascendant Necromancer : 000551AE","Ascendant Necromancer : 000E0FD0","Asgeir Snow-Shod : 0001334B","Aslfur : 000135E7","Aspiring Mage : 000753CB","Assassin : 001051FB","Assur : 0001C18A","Asta : 00015D2B","Astrid : 0001BDB4","Astrid : 0004D6D0","Ataf : 00013295","Atahbah : 0001B1DA","Atar : 000622E5","Athis : 0001A6D5","Atmah : 000B8786","Atub : 00019E18","AudioTemplateAtronachFlame : 000B5D82","AudioTemplateAtronachFrost : 0005ED6F","AudioTemplateAtronachStorm : 000ABF38","AudioTemplateBear : 0008A3C2","AudioTemplateChaurus : 0005C305","AudioTemplateCow : 0004D2A8","AudioTemplateDragon : 0002F2F0","AudioTemplateDragonPriest : 00046B83","AudioTemplateDragonQuiet : 0010FD64","AudioTemplateDraugr : 000BF452","AudioTemplateDwarvenCenturion : 0008CF6D","AudioTemplateDwarvenSphere : 0006CE2F","AudioTemplateDwarvenSpider : 0007EDC9","AudioTemplateElk : 000FFA08","AudioTemplateFalmer : 0006759A","AudioTemplateGiant : 000C4E2F","AudioTemplateGoat : 0005E3D2","AudioTemplateHagraven : 000C0D8A","AudioTemplateHorker : 0004737E","AudioTemplateHorse : 000F9644","AudioTemplateHorseCarriage : 00084784","AudioTemplateIceWraith : 0004D2C2","AudioTemplateMammoth : 0001C060","AudioTemplateMudcrab : 0003E8A1","AudioTemplateSabreCat : 00017F39","AudioTemplateSkeever : 00017F3A","AudioTemplateSkeleton : 000BFB2A","AudioTemplateSpiderFrostbite : 00038A33","AudioTemplateSpiderFrostbiteGiant : 000BF55C","AudioTemplateSpriggan : 000A91FF","AudioTemplateTroll : 00038A31","AudioTemplateWerewolf : 000F7EAD","AudioTemplateWisp : 000D3ADA","AudioTemplateWitchlight : 000D3ADD","AudioTemplateWolf : 000A85C7","Augur of Dunlain : 0002BCE8","Aval Atheron : 00014140","Aventus Aretino : 00014132","Avrusa Sarethi : 00019BFE","Avulstein Gray-Mane : 00013B9A","Azura : 00028AE9","Azzada Lylvieve : 00019A2A","Azzadal : 000B3C81","Babette : 0001D4B7","Badnir : 000AE779","Bagrak : 00019955","Balagog gro-Nolob : 00038C6E","Balbus : 000B5D42","Balgruuf the Greater : 00013BBD","Balimund : 0001334C","Bandit : 00039CF4","Bandit Chief : 0001B0D8","Bandit Chief : 0001B0DB","Bandit Chief : 0001B0DC","Bandit Chief : 0001B0DD","Bandit Chief : 0001B0DE","Bandit Chief : 0001B0E1","Bandit Chief : 0001B0EB","Bandit Chief : 0003DF17","Bandit Chief : 000C0037","Bandit Chief : 000E1646","Bandit Highwayman : 0001E60D","Bandit Highwayman : 00037C35","Bandit Highwayman : 00039D4A","Bandit Leader : 00090739","Bandit Marauder : 0001E611","Bandit Marauder : 00037C43","Bandit Marauder : 00039D58","Bandit Outlaw : 0001BCD9","Bandit Outlaw : 00037C2D","Bandit Outlaw : 00039D38","Bandit Plunderer : 0001E610","Bandit Plunderer : 00037C3C","Bandit Plunderer : 00039D51","Bandit Thug : 0001BCDA","Bandit Thug : 00037C2E","Bandit Thug : 00039D43","Banning : 0009A7A8","Baral Sendu : 000E799D","Barbas : 0001BFC5","Barkeep : 000D823D","Barknar : 000BC079","Bassianus Axius : 000136C1","Batum gra-Bar : 000CE09C","Bear : 00023A8A","Beautiful Barbarian : 00087B9E","Beem-Ja : 0006CD5B","Beirand : 00013261","Beitild : 00013612","Belchimac : 00013B6B","Belethor : 00013BA1","Belrand : 000B9981","Belyn Hlaalu : 00014138","Bendt : 000E77CB","Benkum : 0001E94C","Benor : 000135E8","Bergritte Battle-Born : 00013BB3","Bern : 000CF3A4","Bersi Honey-Hand : 0001334D","Betrid Silver-Blood : 00013388","Big Laborer : 00087B96","Birna : 0001C187","Bjartur : 00013262","Bjorlam : 00013669","Blackblood Marauder : 000DC8D8","Blackblood Marauder : 000DC8D9","Blackblood Marauder : 000DC8DA","Blackblood Marauder : 000DC8DB","Blackblood Marauder : 000DC8DC","Black-Briar Mercenary : 00046E84","Black-Briar Mercenary : 000AD09C","Blasphemous Priest : 00087B91","Blood Dragon : 000F80FD","Blood Horker : 000DAE86","Blood Horker : 000DAE8C","Blood Horker : 000E6D71","Blood Horker : 000E6D73","Blood Horker : 000E6D74","Blood Horker : 000E6D75","Blood Horker : 000E6D76","Blooded Vampire : 0003384E","Bodil : 000876DC","Bodyguard : 0009F85E","Bodyguard : 000B91A6","Boethiah Cultist : 0004D8D1","Boethiah Cultist : 0004D8D2","Boethiah Cultist : 0004D8D3","Boethiah Cultist : 0004D8D4","Boethiah Cultist : 0004D8D5","Boethiah Cultist : 000B0E87","Bolar : 0001B076","Bolfrida Brandy-Mug : 00014126","Bolgeir Bearclaw : 00013264","Bolli : 0001334E","Bolund : 00013651","Bor : 000C78E1","Borgakh the Steel Heart : 00019959","Borgny : 000877B2","Borkul the Beast : 0001338A","Borri : 0002C6CE","Borvir : 00013BC2","Bothela : 0001338B","Boti : 000136BE","Bottar : 000B94A9","Bounty Collector : 000F812A","Bounty Hunter : 000BC09F","Bounty Hunter : 000BC0A0","Bounty Hunter : 000BC0A1","Braig : 00013389","Braith : 00013BA9","Brandish : 000CD64C","Brand-Shei : 0001334F","Brelas : 00069F38","Brelyna Maryon : 0001C196","Brenuin : 00013BA7","Breton : 000457F6","Breton : 000457FF","Breton : 001034F3","Breton : 001034FB","Breton : 001034FC","Breya : 0004C724","Breya : 0004C754","Briehl : 000585FB","Brill : 0001A6A2","Brina Merilis : 0001A6B7","Britte : 000136B9","Brond : 00014144","Brother Verulus : 0001338C","Brunwulf Free-Winter : 00014149","Bryling : 00013265","Brynjolf : 0001B07D","Bulfrek : 00013613","Cairine : 000D66FE","Calcelmo : 0001338E","Calder : 000A2C90","Calixto Corrium : 0001414A","Camilla Valerius : 0001347B","Captain Aldis : 00041FB8","Captain Aquilius : 000154E7","Captain Avidius : 000C603D","Captain Hargar : 0001E38B","Captain Lonely-Gale : 00014134","Captain Metilius : 0001C9F7","Captain Valmir : 0007E5B4","Captain Wayfinder : 00013296","Captive : 000649CA","Carlotta Valentia : 00013B99","Carriage Driver : 00021207","Carriage Driver : 000424AE","Carriage Driver : 0004252C","Cart Driver : 0009A079","Cart Driver : 000F6EF3","Cave Bear : 00023A8B","Cedran : 0001338F","Challenger : 0006E02C","Champion of Boethiah : 000834FE","Chaurus : 000A5600","Chaurus Reaper : 00023A8F","Chicken : 000A91A0","Chief Burguk : 00013B79","Chief Larak : 00019951","Chief Mauhulakh : 0001B075","Chief Yamarz : 0003BC26","Christer : 00090738","Cicero : 0001BDB1","Cicero : 000550F0","Cicero : 0009BCAF","Clavicus Vile : 0001C4E4","Clinton Lylvieve : 00019A2C","Coldhearted Gravedigger : 00087B9D","Colette Marence : 0001C19A","College Guard : 00105CBB","Commander Caius : 00038257","Commander Maro : 0001D4B5","Commoner : 0003DC4C","Companion Ghost : 000AB102","Companion Ghost : 000AB104","Companion Ghost : 000DE516","Companion Ghost : 000DE517","Companion Ghost : 000DE518","Companion Ghost : 000DE519","Confidence : 0009F844","Conjurer : 0006D231","Conjurer : 000E0FC8","Conjurer Adept : 0006D230","Conjurer Adept : 000E0FC3","Constance Michel : 00013350","Corpse : 0008A89C","Corpse : 0008A89D","Corpse : 0008A89E","Corpse : 0008A89F","Corpulus Vinius : 00013266","Corrupt Agent : 00087B8C","Corrupted Shade : 000EB870","Corrupted Shade : 000EB876","Corrupted Shade : 000EBA05","Corrupted Shade : 000F5BB9","Corrupted Shade : 000F5BBA","Corrupted Shade : 000F5BBB","Corsair : 0005B615","Corsair : 000E5F38","Corsair : 00100566","Corsair : 00100567","Cosnach : 00013390","Courier : 00039F83","Courier : 0006A11A","Courier : 001065EE","Courier : 001065EF","Courier : 001065F0","Cow : 00023A90","Cow : 0006681E","Cow : 000C39F1","Cow Hand : 000510C2","Cryomancer : 00045CBF","Cryomancer : 000E0FD4","Curalmil : 00048B55","Curwe : 0001A6B3","Curwe : 0007F42A","Cynric Endell : 000D4FD8","Dagny : 0001434B","Dagur : 0001C183","Daighre : 00013391","Dalan Merchad : 000132A4","Danica Pure-Spring : 00013BA5","Dark Brotherhood Assassin : 0009D761","Dark Brotherhood Initiate : 00015CFA","Dark Brotherhood Initiate : 00015CFE","Dark Elf : 000457F7","Dark Elf : 00045800","Dark Elf : 001034FE","Dark Elf : 001034FF","Dawnstar Guard : 0002D794","Dawnstar Guard : 0002D795","Dawnstar Guard : 000874FB","Dawnstar Guard : 000874FC","Dawnstar Guard : 000874FD","Dawnstar Guard : 000874FE","Dawnstar Guard : 0008757D","Daynas Valen : 0004CEDF","Dead Scholar : 000B6425","Deeja : 00013268","Deekus : 00020040","Deep-In-His-Cups : 000BBDA0","Deer : 000CF89D","Deer : 000D249A","Degaine : 00013392","Delacourt : 00072663","Delphine : 00013478","Delvin Mallory : 0001CB78","Dengeir of Stuhn : 0001365A","Derkeethus : 0001403E","Dervenin : 0001327C","Desperate Gambler : 00087B8E","Dinya Balu : 00013352","Dirge : 0001336D","Dishonored Skald : 00087B92","Dog : 00023A92","DomnaMagia : 00058FB7","Donnel : 000D673A","Dorian : 000AF524","Dorthe : 00013477","Dragon : 0001CA03","Dragon : 000354CA","Dragon : 00096E48","Dragon : 000EAFB4","Dragon Cultist : 000CD63E","Dragon Priest : 00023A93","Dragon Priest : 0010FC15","Drahff : 00095F7E","Drascua : 000240D7","Draugr : 0003B547","Draugr Death Overlord : 0004247E","Draugr Death Overlord : 0004247F","Draugr Deathlord : 0003B54B","Draugr Deathlord : 00044C5B","Draugr Overlord : 0004247B","Draugr Scourge : 0003B54A","Draugr Scourge Lord : 0004247D","Draugr Thrall : 000ABA9C","Draugr Thrall : 000ABAA0","Draugr Thrall : 000ABAA1","Draugr Thrall : 000ABAA2","Draugr Wight : 0003B549","Draugr Wight Lord : 0004247C","Dravin Llanith : 00013353","Dravynea the Stoneweaver : 0001365F","Drelas : 000E76C9","Dremora : 0001F3AA","Dremora Caitiff : 00016EF0","Dremora Caitiff : 00016EF6","Dremora Caitiff : 00016F04","Dremora Churl : 00023A95","Dremora Churl : 00025D1C","Dremora Churl : 00025D1D","Dremora Kynreeve : 00016F6A","Dremora Kynreeve : 00016FE2","Dremora Kynreeve : 00016FF3","Dremora Kynval : 00016F40","Dremora Kynval : 00016F46","Dremora Kynval : 00016F69","Dremora Lord : 0010DDEE","Dremora Markynaz : 00016FF4","Dremora Markynaz : 00016FF6","Dremora Markynaz : 00016FF7","Dremora Messenger : 00017ED7","Dremora Valkynaz : 00016FF9","Dremora Valkynaz : 00016FFA","Dremora Valynaz : 00016FF8","Drennen : 0004C734","Drennen : 0004C751","Drevis Neloren : 0001C198","Drifa : 00013354","Drokt : 00026DF0","Dro''marash : 0001B1CF","Drunk Cultist : 0001CB2E","Dryston : 000D6711","Duach : 00013393","Dulug : 000C78C0","Dunmer Ghost : 00084D15","Dushnamub : 0001B079","Dwarven Centurion : 000C3CB9","Dwarven Centurion : 0010F9B9","Dwarven Centurion Guardian : 0010E753","Dwarven Centurion Master : 00023A96","Dwarven Sphere : 000C272D","Dwarven Sphere : 000EED25","Dwarven Sphere : 0010EC89","Dwarven Sphere Guardian : 00023A97","Dwarven Sphere Master : 0010EC8E","Dwarven Spider : 00023A98","Dwarven Spider Guardian : 0010EC87","Dwarven Spider Worker : 0010EC86","East Empire Dockmaster : 000132A0","East Empire Dockworker : 0007E5EA","East Empire Dockworker : 0007E5EB","East Empire Mercenary : 00056AFD","East Empire Warden : 000CA6D1","Edda : 00013356","Edith : 000877AF","Edorfin : 0001E957","Eimar : 000B2977","Einarth : 0002C6CC","Eirid : 0001C185","Eisa Blackthorn : 000D001A","Elda Early-Dawn : 0001412A","Elder Dragon : 000F811A","Elder Dragon : 000F811B","Electromancer : 00045CC0","Electromancer : 000E0FD6","Elenwen : 00013269","Elgrim : 00013357","Elisif the Fair : 0001326A","Elk : 00023A91","Elrindir : 00013B9E","Eltrys : 00013394","Elvali Veren : 000B878B","Embry : 0003550B","Emperor Titus Mede II : 0001D4B9","Emperor Titus Mede II : 0001D4BA","Endarie : 0001326F","Endon : 00013395","Endrast : 0003B0E4","Enmon : 00013B6C","Ennis : 0001B3B5","Ennoc : 00013396","Ennodius Papius : 0001360C","Enthir : 0001C19C","Enthralled Wizard : 000F4926","Enthralled Wizard : 000F737C","Enthralled Wizard : 000F7385","Eola : 0001990F","Eorlund Gray-Mane : 00013B9D","Erandur : 0002427D","Erdi : 00013271","Eriana : 0002ABC4","Erik : 000350A7","Erik the Slayer : 00065657","Erikur : 00013272","Eris : 000AF522","Erith : 000133AB","Erj : 00093858","Erlendr : 000EA71F","Esbern : 00013358","Escaped Prisoner : 00071733","Escaped Prisoner : 000BFB44","Estormo : 00034D97","Etienne Rarnis : 0003A1D3","Evette San : 00013273","Eydis : 00013B77","Faendal : 00013480","Faida : 00019A28","Faldrus : 000B85B9","Faleen : 00013397","Falion : 000135E9","Falk Firebeard : 00013274","Falkreath Guard : 0010107B","Falkreath Guard : 00103962","Falmer : 0003B54C","Falmer Gloomlurker : 00029980","Falmer Nightprowler : 0003B54E","Falmer Servant : 000B2D35","Falmer Shadowmaster : 0003B54F","Falmer Skulker : 0003B54D","Familiar : 000640B5","Faralda : 0001C197","Farengar Secret-Fire : 00013BBB","Farkas : 0001A692","Farkas''s Wolf Spirit : 000F6087","Farmer : 000BD759","Farmer : 000BD75E","Farmer : 001034E4","Farmer : 001034E6","Farmer : 00106A61","Faryl Atheron : 00014131","Fastred : 000136BF","Felldir the Old : 00044237","Felldir the Old : 000923F9","Felldir the Old : 000CDA00","Fellow Prisoner : 000967DE","Fenrig : 00038287","Festus Krex : 0001BDB2","Festus Krex : 000E0D6F","Fianna : 000D16DD","Fihada : 00013275","Filnjar : 000136C3","Fire Mage : 00045CA0","Fire Mage : 000E0FC9","Fire Mage Adept : 00045C7A","Fire Mage Adept : 000E0FC4","Fire Spirit : 000F82BC","Fire Storm : 000877EB","Fire Wizard : 00045CBB","Fire Wizard : 000E0FCE","Firir : 000976FB","First Mate : 000E5F37","Fisherman : 00097976","Fjori : 0003D725","Fjori : 000A222B","Fjotra : 0001E82C","Flame Atronach : 000204C0","Flame Atronach : 00023AA6","Flame Atronach : 000F8B11","Flame Thrall : 0007E87D","Flame Thrall : 0009B2AE","Flame Thrall : 000CDECC","Flaming Thrall : 0009CE28","Forsworn : 00043BDC","Forsworn Briarheart : 0004430A","Forsworn Briarheart : 0004430B","Forsworn Briarheart : 0004430C","Forsworn Briarheart : 0004430D","Forsworn Briarheart : 0004430E","Forsworn Briarheart : 0004430F","Forsworn Briarheart : 00044310","Forsworn Briarheart : 00044311","Forsworn Briarheart : 00044312","Forsworn Briarheart : 00044313","Forsworn Forager : 00043BEE","Forsworn Forager : 00043BEF","Forsworn Forager : 00043BF0","Forsworn Looter : 00044262","Forsworn Looter : 00044263","Forsworn Looter : 00044264","Forsworn Pillager : 00044274","Forsworn Pillager : 00044275","Forsworn Pillager : 00044276","Forsworn Ravager : 00044286","Forsworn Ravager : 00044287","Forsworn Ravager : 00044288","Forsworn Shaman : 00043BEA","Forsworn Warlord : 00044298","Forsworn Warlord : 00044299","Forsworn Warlord : 0004429A","Fort Commander : 00051B4B","Fort Commander : 000EA329","Fox : 000829B3","Fox : 0009A744","Frabbi : 00013398","Fralia Gray-Mane : 00013B9C","Francois Beaufort : 00013359","Freir : 00013277","Frida : 00013614","Fridrika : 00013278","Frightened Woman : 000B1CFF","Frodnar : 0001347E","Frofnir Trollsbane : 0003E8AD","Froki Whetted-Blade : 000185F6","From-Deepest-Fathoms : 0001335A","Frorkmar Banner-Torn : 00084553","Frost : 00097E1E","Frost Atronach : 000204C1","Frost Atronach : 00023AA7","Frost Atronach : 0010EE43","Frost Dragon : 000351C3","Frost Spirit : 000F82BA","Frost Thrall : 0007E87E","Frost Thrall : 0009B2AB","Frost Thrall : 000CDECD","Frost Troll : 00023ABB","Frost Troll : 000EBC2E","Frostbite Spider : 00023AAA","Frostbite Spider : 00023AAC","Frostbite Spider : 00041FB4","Frostbite Spider : 0004203F","Frothar : 0001434C","Fruki : 00013615","Fugitive : 00062158","Fultheim : 000DA68A","Fultheim the Fearless : 0002E3E8","Gabriella : 0001BDB8","Gabriella : 0002FB1A","Gadba gro-Largash : 0001B09A","Gadnor : 0002EB58","Gaius Maro : 00044050","Galmar Stone-Fist : 00014128","Galmar Stone-Fist : 000D0570","Gambler : 000D81F3","Ganna Uriel : 0001365D","Garakh : 00019E1C","Garthar : 000B03A3","Garvey : 000D6703","Gaston Bellefort : 000F23B8","Gat gro-Shargakh : 000199B7","Gauldur : 000ECEDA","Gauldur : 000EDB3B","Gavros Plinius : 00034CB8","Geimund : 0001327D","Geirlund : 000C4409","Gelebros : 0003983E","Gemma Uriel : 00014040","General Tullius : 0001327E","General Tullius : 000D0577","Gerda : 000C247E","Gerdur : 0001347C","Gestur Rockbreaker : 00013603","Ghak : 000C78C2","Ghamorz : 000C78CC","Gharol : 00013B7C","Ghorbash the Iron Hand : 00013B81","Ghorza gra-Bagol : 0001339A","Ghost : 000725F6","Ghost : 000B117E","Ghost : 000B1F96","Ghost : 000B1F97","Ghost : 000B1F98","Ghost : 000B1F99","Ghost : 000B1F9A","Ghost : 000B1F9B","Ghost : 000C19F7","Ghost : 000D93A2","Ghost : 000D93A3","Ghost : 000D93A4","Ghost : 000D93A5","Ghost : 000D93A6","Ghost : 000D93A7","Ghost : 00104B5B","Ghost : 00104B5C","Ghost : 00104B5D","Ghost : 00104B5E","Ghost : 00104B5F","Ghost : 00104B60","Ghost : 00104B61","Ghost Adventurer : 000515F5","Ghost Axe : 00071E6B","Ghost of Old Hroldan : 000681A2","Ghunzul : 00013679","Gian the Fist : 0010A062","Gianna : 0004BCC3","Giant : 00023AAE","Giant : 000C97D1","Giant Frostbite Spider : 00023AAB","Giant Frostbite Spider : 00023AAD","Gilfre : 0001367A","Giraud Gemane : 00013281","Girduin : 000B878A","Gisli : 00013282","Gissur : 00039F23","Gjak : 000876DA","Gjuk : 00052269","Gleda the Goat : 0001CB2C","Glenmoril Witch : 000A350A","Glenmoril Witch : 00106269","Gloth : 00028DD6","Goat : 0002EBE2","Goat : 0004359C","Goat : 0005487E","Goat : 000D206E","Golldir : 00019FE8","Gonnar Oath-Giver : 0008455B","Gorm : 000135EA","Gormlaith Golden-Hilt : 00044236","Gormlaith Golden-Hilt : 000923FA","Gormlaith Golden-Hilt : 000CD9F7","Gralnach : 00019C01","Grelka : 000136C5","Grelod the Kind : 0001335E","Greta : 00013283","Grete : 000C083B","Griefstricken Chef : 00087B90","Grim Shieldmaiden : 00087B9B","Grimvar Cruel-Sea : 00014133","Grisvar the Unlucky : 0001339B","Grogmar gro-Burzag : 000136C6","Grok : 0001F3BB","Grosta : 00019C00","Grushnag : 0001B1CD","Guard : 0001BB21","Guardian Saerek : 0003725E","Guardian Torsten : 00037231","Guardian Troll Spirit : 000E7EB2","Gul : 000C78CA","Gularzob : 00019E20","Gulum-Ei : 00013284","Gunding : 000AE77B","Gunjar : 0009B0AD","Gunnar Stone-Eye : 00013643","Guthrum : 00013285","Gwendolyn : 0002C930","Gwilin : 000658D4","Haafingar Guard : 0010636E","Hadring : 00013627","Hadvar : 0002BF9F","Haelga : 0001335F","Hafjorg : 00013360","Hafnar Ice-Fist : 000B8785","Hag : 00074F83","Hag : 00074F84","Hag : 00074F85","Hagraven : 00023AB0","Hakon One-Eye : 00044238","Hakon One-Eye : 000923FB","Hakon One-Eye : 000CDA01","Haldyn : 0001DC04","Hallowed Dead : 000F71E0","Hamal : 0001E765","Hamelyn : 0010A04C","Haming : 00013642","Haming : 000C029C","Haran : 0001C184","Harrald : 00013361","Hathrasil : 0001339C","Headless Horseman : 0010B302","Headsman : 000AA7D6","Headsman : 000BFB43","Headsman : 000BFB60","Heddic Volunnar : 0008AD96","Hefid the Deaf : 0009400E","Heimskr : 00013BAC","Heimvar : 00013286","Helgird : 00014124","Helgi''s Ghost : 000274A5","Helvard : 00013657","Hemming Black-Briar : 00013362","Henrik : 000284F9","Heratar : 000CE089","Herebane Sorenshield : 000F964A","Herluin Lothaire : 00029DAE","Hermir Strong-Heart : 0001412D","Hern : 0001367B","Hero of Sovngarde : 00096FFB","Hero of Sovngarde : 000EA720","Hero of Sovngarde : 00108421","Hero of Sovngarde : 00108430","Hero of Sovngarde : 00108431","Hero of Sovngarde : 00108432","Hero of Sovngarde : 001092D1","Hert : 0001367C","Hevnoraak : 0004D6E7","Hewnon Black-Skeever : 00095FD5","High Elf : 000457F9","High Elf : 00045801","High Elf : 001034F2","High Elf : 00106116","High Elf : 00106117","High King Torygg : 000EA578","Hilde : 00035533","Hillevi Cruel-Sea : 0001411F","Hircine : 0001BB96","Hired Thug : 00035B5E","Hired Thug : 000D783B","Hired Thug : 000D783C","Hjaalmarch Guard : 0002C81B","Hjornskar Head-Smasher : 0008455D","Hjorunn : 00013287","Hod : 0001347D","Hoddreid : 000CE09D","Hofgrir Horse-Crusher : 00013351","Hogni Red-Arm : 000284AC","Holgeir : 0003D722","Holgeir : 0003D724","Horgeir : 00019A1D","Horik Halfhand : 0001A6B9","Horker : 00023AB1","Horker : 000EF607","Horm : 00013288","Horse : 00023AB2","Horse : 00068CFA","Horse : 00068D02","Horse : 00068D03","Horse : 00068D04","Horse : 00068D07","Horse : 00068D5B","Horse : 00068D6B","Horse : 00068D6D","Horse : 00068D6E","Horse : 00072A08","Horse : 00084785","Horse : 0010F7FD","Hrefna : 00013668","Hreinn : 0001339D","Hroar : 00013363","Hroggar : 000135F0","Hroki : 0001339E","Hrolmir : 000F84A2","Hrongar : 00013BBC","Huki Seven-Swords : 00014143","Hulda : 00013BA3","Hunroor : 000EA71D","Hunter : 0002FFEB","Hunter : 0006218C","Hunter : 00073FBE","Hunter of Hircine : 000955B7","Ice Mage : 00045CA1","Ice Mage : 000E0FCA","Ice Mage Adept : 00045C7B","Ice Mage Adept : 000E0FC5","Ice Wizard : 00045CBC","Ice Wizard : 000E0FCF","Ice Wolf : 00023ABF","Ice Wraith : 00023AB3","Iddra : 00013662","Idesa Sadri : 0001411B","Idgrod Ravencrone : 000135EB","Idgrod the Younger : 000135EC","Idolaf Battle-Born : 00013BB2","Igmund : 0001339F","Ilas-Tei : 000D5046","Illdi : 00013289","Illia : 00048C2F","Imedhnain : 000133A1","Imperial : 000457F8","Imperial : 00045802","Imperial : 00103500","Imperial : 00103501","Imperial Archer : 00045BE0","Imperial Captain : 000AAFAC","Imperial Courier : 0003BCC6","Imperial Field Legate : 000205C9","Imperial General : 000559E0","Imperial Guard : 0002123F","Imperial Guard : 0002A3D7","Imperial Guard : 00045853","Imperial Guard Jailor : 0004587C","Imperial Mage : 000F3E76","Imperial Mage : 000F3E77","Imperial Officer : 0001AE44","Imperial Quartermaster : 00016973","Imperial Soldier : 0001FC5D","Imperial Soldier : 00046794","Imperial Soldier : 0006E21C","Imperial Soldier : 0008DE5D","Imperial Soldier : 000AA8D4","Imperial Soldier : 000AA8D5","Imperial Soldier : 000AA8D6","Imperial Soldier : 000AA8D7","Imperial Soldier : 000AA8D8","Imperial Soldier : 000AA8FC","Imperial Soldier : 000AA8FD","Imperial Soldier : 000AA901","Imperial Soldier : 000AA913","Imperial Soldier : 000D67B8","Imperial Soldier : 000D7D7D","Imperial Soldier : 000D7D8E","Imperial Soldier : 000E1E95","Imperial Soldier : 000E491B","Imperial Soldier : 000E4920","Imperial Soldier : 000E6D5C","Imperial Soldier : 000E72BB","Imperial Soldier : 000E77F9","Imperial Soldier : 000E77FD","Imperial Soldier : 000F3E6D","Imperial Soldier : 000F3E6E","Imperial Soldier : 000F3E6F","Imperial Soldier : 000F94A9","Imperial Soldier : 000F94AE","Imperial Soldier : 000F94B5","Imperial Soldier : 000FE510","Imperial Soldier : 00105EE2","Imperial Soldier : 0010A19F","Imperial Soldier : 0010A1A0","Imperial Soldier : 0010A1A1","Imperial Soldier : 0010A1A2","Imperial Soldier : 0010A1AA","Imperial Soldier : 0010A1AB","Imperial Wizard : 0004622A","Indara Caerellia : 0001364F","Indaryn : 00013370","Indolent Farmer : 00087B93","Inge Six Fingers : 0001328A","Ingrid : 0001363F","Ingun Black-Briar : 00013364","Insane College Wizard : 0005AE91","Iona : 000A2C91","Irgnir : 00013617","Irileth : 00013BB8","Irlof : 00052267","Irnskar Ironhand : 0001328B","Isabelle Rolaine : 00039840","Istar Cairn-Breaker : 00084550","Itinerant Lumberjack : 00087B97","Ivarstead Guard : 00021240","Jala : 0001328C","Japhet : 000E63D6","Jaree-Ra : 0001328D","Jawanan : 0001328E","J''darr : 0003B0E7","J''datharr : 0004D12B","Jenassa : 000B9982","Jervar : 0001A69D","Jesper : 00013604","J''Kier : 0002ABC3","Jod : 00013618","Jofthor : 000136BD","Jolf : 000AF38A","Jon Battle-Born : 00013BB1","Jonna : 000135ED","Jora : 00014120","Jordis the Sword-Maiden : 000A2C8F","Jorgen : 000138B6","Joric : 000135EE","Jorleif : 00014135","Jorn : 0001328F","Jouane Manette : 000136B3","Julienne Lylvieve : 00026F0F","Jurgen Windcaller : 000F1A49","Jyrik Gauldurson : 0001BB28","J''zargo : 0001C195","J''zhar : 0003B0E6","Kai Wet-Pommel : 00084568","Kaie : 00054882","Karinda : 0005F865","Karita : 0001361A","Karita : 000BC07C","Karl : 00013619","Karliah : 0001B07F","Katla : 00013290","Kayd : 00013292","Keeper Carcette : 000BFB55","Keerava : 00013365","Kematu : 00021601","Kerah : 000133A2","Kesh the Clean : 00089986","Khajiit : 000457FA","Khajiit : 00045803","Khajiit : 00097DA9","Khajiit : 001034E9","Khajiit : 00105551","Khajiit : 00105553","Khajiit : 00109A7F","Kharag gro-Shurkul : 00013291","Kharjo : 0001B1D2","Khayla : 0001B1D9","Kibell : 0003F21E","Kjar : 00013293","Kjeld : 00013663","Kjeld the Younger : 00013661","Kleppr : 000133A3","Klimmek : 000136C2","Knjakr : 00094000","Knud : 00013294","Kodlak Whitemane : 0001A68E","Kodlak Whitemane : 0009700E","Kodlak''s Wolf Spirit : 00058303","Kodrir : 0001360D","Korir : 0001C188","Kornalus : 00039BB7","Kottir Red-Shoal : 00084556","Krag : 000C084E","Kraldar : 0001C180","Krosis : 00100767","Kust : 0001364C","Kyr : 000D37D1","Laelette the Vampire : 000274A0","Laila Law-Giver : 00013366","Lami : 000135EF","Larina : 000DBD11","Lars Battle-Born : 00013BAF","Lash gra-Dushnikh : 00013B6E","Legate Adventus Caesennius : 000844B1","Legate Constantius Tituleius : 00084539","Legate Emmanuel Admand : 000844D0","Legate Fasendil : 0008454F","Legate Hrollod : 0008454E","Legate Quentin Cipius : 000844D1","Legate Rikke : 000132A1","Legate Rikke : 000D0573","Legate Sevan Telendas : 0008453A","Legate Skulnar : 0008455E","Legate Taurinus Duilis : 000844B2","Leifur : 00013610","Leigelf : 0001361B","Lemkil : 000136B8","Leonara Arius : 00037E04","Leontius Salvius : 00013B76","Liesl : 0001E956","Lieutenant Salvarus : 000C44FF","Lillith Maiden-Loom : 00013BC0","Linwe : 0007D679","Lis : 000A19FE","Lis : 000A19FF","Lisbet : 000133A5","Lisette : 00013297","Little Pelagius : 0009F839","Lob : 00019E1E","Lod : 00013650","Lodi : 000D5636","Lodvar : 00019A22","Logrolf the Willful : 000133A6","Lokir : 0004679A","Lond : 0001361C","Lortheim : 00014145","Louis Letrush : 00013368","Lowlife : 0005CBE9","Luaffyn : 00047CAD","Lu''ah Al-Skaven : 0002333A","Lucan Valerius : 0001347A","Lucerne : 0002ABBE","Lucky Lorenz : 000ECF85","Lund : 000E76CA","Lurbuk : 0001AA63","Lydia : 000A2C8E","Lynly Star-Sung : 000136BC","Madanach : 000133A7","Madena : 0001361D","Madesi : 0001B072","Ma''dran : 0001B1D1","Madwoman : 000BA1E5","Mage : 001095E1","Magic Anomaly : 00079915","Magic Anomaly : 000B6F94","Mahk : 000C78BE","M''aiq the Liar : 000954BF","Ma''jhad : 0001B1D5","Makhel Abbas : 0008F35A","Malacath : 00019E16","Malborn : 00036194","Malborn : 00085300","Malfunctioning Dwarven Sphere : 0010E752","Malkoran : 0009CB66","Malkoran''s Shade : 000EBE2E","Mallus Maccius : 0002BA8E","Malthyr Elenil : 0001414E","Malur Seloth : 0001C182","Maluril : 00020046","Malyn Varen : 00028AD2","Malyn Varen : 00028AD3","Mammoth : 00023AB4","Mammoth Guardian Spirit : 000E7EAF","Mani : 0004815C","Maramal : 0001335B","Ma''randru-jo : 0001B1D7","Marauder : 000E9628","Marauder : 000E962B","Marcurio : 000B9980","Margret : 0009C8A8","Marise Aravel : 00013369","Markarth City Guard : 000210CE","Markarth City Guard : 00036F05","Markarth City Guard : 000537F2","Markarth City Guard : 0005CF3F","Markarth City Guard : 0008713A","Markarth City Guard : 0008B319","Markarth City Guard : 0009E47F","Markarth City Guard : 000AC9CA","Master Conjurer : 0006D233","Master Conjurer : 000E0FD3","Master Necromancer : 000551AF","Master Necromancer : 000E0FD5","Master Vampire : 0002E098","Master Vampire : 0002E12A","Master Vampire : 0002E1B1","Master Vampire : 0002E1B8","Ma''tasarr : 000CE09B","Mathies : 0001364E","Matlara : 00013640","Maul : 000371D6","Maurice Jondrelle : 0001C605","Maven Black-Briar : 0001336A","Ma''zaka : 00013298","Mazgak : 000CE082","Medresi Dran : 0003B5B2","Meeko : 000D95E9","Mehrunes Dagon : 000252AA","Melaran : 00013299","Melka : 00039B3E","Mena : 00013B6D","Mephala : 0005BF3D","Mercenary : 0007EB38","Mercer Frey : 0001B07C","Meridia : 0004E4DF","Michel Lylvieve : 00019A2E","Mikael : 0001A670","Mikrul Gauldurson : 000AB6FF","Mila Valentia : 00013BAD","Minette Vinius : 0001329B","Mirabelle Ervine : 0001C1A0","Mirmulnir : 0001CA05","Mistwatch Bandit : 000C0113","Mistwatch Bandit : 000C0114","Mistwatch Bandit : 000C0115","Mistwatch Bandit : 000C0116","Mistwatch Bandit : 000C0124","Mistwatch Bandit : 000C0125","Mistwatch Bandit : 000C0126","Mistwatch Bandit : 000D3BDF","Mithorpa Nasyal : 0001A6AF","Mjoll the Lioness : 0001336B","Mogdurz : 000C78DF","Moira : 0001CB33","Molag Bal : 00022F16","Molgrom Twice-Killed : 0001336C","Morokei : 000F496C","Morthal Guard : 000604F4","Morthal Guard : 000604FE","Morthal Guard : 000604FF","Morthal Guard : 00060500","Morthal Guard : 00109AAC","Morven : 000D6719","Moth gro-Bagol : 00055A5E","Mralki : 000136B6","Mudcrab : 00021875","Mudcrab : 000E4010","Mudcrab : 000E4011","Mudcrab Guardian Spirit : 000E662B","Muiri : 0001406B","Mul gro-Largash : 0001B07A","Mulush gro-Shugurz : 000133A9","Murbul : 00013B7A","Muril : 00034D99","Nagrub : 00013B7F","Nahagliiv : 000FE431","Nahkriin : 000F849B","Nana Ildene : 000133A0","Narfi : 000136C0","Naris the Wicked : 000427A6","Narri : 00013654","Nazeem : 00013BBF","Nazir : 0001C3AB","Nazir : 0004DDA0","Necromage : 000551AD","Necromage : 000E0FCB","Necromancer : 00028502","Necromancer Adept : 000551AC","Necromancer Adept : 000E0FC6","Neetrenaza : 0001412F","Nelacar : 0001E7D5","Nelkir : 0001434D","Nenya : 00013659","Nepos the Nose : 000133AA","Nerien : 000233D2","Nerien : 000A4E85","Nervous Patron : 00087B8B","Niels : 000411D0","Night Mother Voice NPC : 0003BB85","Nightingale Sentinel : 0001BB5D","Nightingale Sentinel : 000DEEDF","Nightingale Sentinel : 000E0CDD","Nikulas : 000EA71E","Nils : 0001414B","Nilsine Shatter-Shield : 0001412C","Niluva Hlaalu : 0001336E","Nimphaneth : 0009BB45","Nimriel : 0002C926","Niranye : 00014123","Niruin : 0001CD91","Nirya : 0001C19B","Nivenor : 0001336F","Njada Stonearm : 0001A6D9","Noble : 00102D62","Noble : 00102D63","Nobleman : 0005A92D","Nobleman : 0005A92F","Noblewoman : 0005A930","Nocturnal : 0001A2CF","Nord : 000457F5","Nord : 00045804","Nord : 000E3EAD","Nord : 00103502","Nord : 00103503","Northwatch Archer : 0009F35F","Northwatch Guard : 00027F78","Northwatch Guard : 000C07C2","Northwatch Interrogator : 0009F360","Northwatch Mage : 000C4EB1","Northwatch Prisoner : 000C1A9E","Northwatch Prisoner : 000C1A9F","Northwatch Prisoner : 000C1AA3","Noster Eagle-Eye : 0001329C","Novice Conjurer : 0006D22E","Novice Fire Mage : 00044CD7","Novice Ice Mage : 00044CD8","Novice Necromancer : 000548FE","Novice Necromancer : 001092F5","Novice Storm Mage : 00044CD9","Nura Snow-Shod : 00013372","Nurelion : 00014148","Nystrom : 000FF208","Octieve San : 0001329D","Odahviing : 00045920","Odar : 0001329E","Odfel : 000136C4","Odvan : 000133AC","Oengul War-Anvil : 00014142","Oglub : 00013B80","Ogmund : 000133AD","Ogol : 00019E22","Olaf One-Eye : 000F1A4A","Olava the Feeble : 00013BAE","Old Orc : 00062128","Olda : 00019A20","Olfina Gray-Mane : 00013B9B","Olfrid Battle-Born : 00013BB4","Olur : 0001995B","Omluag : 000133AE","Ondolemar : 000133AF","Onmund : 0001C194","Orc : 0001E7BB","Orc : 000457FD","Orc : 00045806","Orc : 0008CDA2","Orc : 00105555","Orc : 00105556","Orc : 00105562","Orc : 00109A7E","Orc : 00109A80","Orc Hunter : 0009A544","Orc Hunter : 000D9447","Orchendor : 00045F78","Orcish Invader : 0009DDCE","Orcish Invader : 0009E15C","Orgnar : 00013479","Orini Dral : 00085D44","Orla : 000133B0","Orthorn : 0002A388","Orthus Endario : 0001413B","Otar the Mad : 0003763A","Paarthurnax : 0003C57C","Pack Member : 000CF79E","Pactur : 00013605","Pale Hold Guard : 00043D22","Pantea Ateia : 0001329F","Paratus Decimius : 00034CBA","Pavo Attius : 000133B1","Peddler : 000B5D5A","Peddler : 000BBCD2","Pelagius'' Flame Thrall : 0009B2AD","Pelagius'' Frost Thrall : 0009B2AC","Pelagius the Mad : 0002AC6A","Pelagius the Suspicious : 0009B287","Pelagius the Tormented : 0009F82D","Pelagius''s Storm Thrall : 0009B2A9","Penitus Oculatus Agent : 0007D98C","Perth : 0001996C","Phantom : 00072310","Phinis Gestor : 0001C199","Pit Fan : 000558ED","Pit Fan : 000558EF","Pit Fan : 000558F1","Pit Fan : 000558F3","Pit Fan : 000558F5","Pit Fan : 000558F7","Pit Fan : 00055900","Pit Fan : 00055A1C","Pit Fan : 00055B40","Pit Fan : 00055CEA","Pit Fan : 00055D1A","Pit Fan : 00055D42","Pit Wolf : 000DDCD0","Pit Wolf : 000E160D","Plautis Carvain : 000B8148","Plautis Carvain : 000C03FE","Player Friend : 0002001F","Poacher : 000D96D2","Poacher : 000D96D3","Poor Fishwife : 00087B9A","Potema''s Remains : 0010349B","Potent Flame Atronach : 0004E940","Potent Frost Atronach : 0004E943","Potent Frost Atronach : 0010EE46","Potent Storm Atronach : 0004E944","Potent Storm Atronach : 0010EE47","Priestess of Arkay : 00107572","Prisoner : 00000007","Prisoner : 0001750C","Prisoner : 0001750D","Prisoner : 0001750E","Prisoner : 0001750F","Prisoner : 0002425F","Prisoner : 00024261","Prisoner : 000268FC","Prisoner : 00026904","Prisoner : 00026915","Prisoner : 00026921","Prisoner : 00026927","Prisoner : 0002694E","Prisoner : 00026954","Prisoner : 000361F3","Prisoner : 0005B4F8","Prisoner : 0005EF9A","Prisoner : 0005EF9C","Prisoner : 0005EFA7","Prisoner : 00074B15","Prisoner : 00074B18","Prisoner : 00074BD8","Prisoner : 00074BD9","Prisoner : 00074BDA","Prisoner : 0007514E","Prisoner : 00075152","Prisoner : 0007515E","Prisoner : 00079BE6","Prisoner : 00079BEB","Prisoner : 00079BEC","Prisoner : 00079BED","Prisoner : 00079BEE","Prisoner : 00079C54","Prisoner : 00079C96","Prisoner : 00079C98","Prisoner : 00079CCD","Prisoner : 00079CCE","Prisoner : 00079CD3","Prisoner : 00079CD4","Prisoner : 00079CD5","Prisoner : 00079DD5","Prisoner : 00079E2C","Prisoner : 00079E2F","Prisoner : 00079EE1","Prisoner : 00079EE6","Prisoner : 00079EE8","Prisoner : 00079F25","Prisoner : 00079F4E","Prisoner : 00079F4F","Prisoner : 00079F50","Prisoner : 00079F51","Prisoner : 00079F52","Prisoner : 00079F53","Prisoner : 00079F54","Prisoner : 00079F55","Prisoner : 00079F56","Prisoner : 00079F57","Prisoner : 00079F58","Prisoner : 00079F59","Prisoner : 00079F5A","Prisoner : 00079F5B","Prisoner : 00079F5C","Prisoner : 00079F5D","Prisoner : 00079F5E","Prisoner : 00079F5F","Prisoner : 00079F60","Prisoner : 00079F61","Prisoner : 00079F62","Prisoner : 00079F63","Prisoner : 00079F64","Prisoner : 00079F65","Prisoner : 00079F66","Prisoner : 00079F67","Prisoner : 00079F68","Prisoner : 00079F69","Prisoner : 00079F6A","Prisoner : 00099D21","Prisoner : 00099D22","Prisoner : 00099D4C","Prisoner : 00099D4D","Prisoner : 00099D4E","Prisoner : 00099D4F","Prisoner : 00099D50","Prisoner : 00099D51","Prisoner : 00099D52","Prisoner : 00099D53","Prisoner : 00099D58","Prisoner : 00099D5D","Prisoner : 00099D5E","Prisoner : 00099D5F","Prisoner : 000EF4E7","Prisoner : 0010AB5D","Prisoner : 0010AB5E","Prisoner : 0010AB5F","Prisoner : 0010AB60","Prisoner : 0010AB61","Prisoner : 0010AB62","Prisoner : 0010AB63","Prisoner : 0010AB64","Prisoner : 0010AB65","Prisoner : 0010AB66","Prisoner : 0010AB67","Prisoner : 0010AB68","Prisoner : 0010AB69","Prisoner : 0010AB6A","Prisoner : 0010AB6B","Prisoner : 0010AB6C","Prisoner : 0010AB6D","Prisoner : 0010AB6E","Prisoner : 0010AB6F","Prisoner : 0010AB70","Prisoner : 0010AB71","Prisoner : 0010AB72","Prisoner : 0010AB73","Prisoner : 0010AB74","Prisoner : 0010AB75","Prisoner : 0010AB76","Prisoner : 0010AB77","Prisoner : 0010AB78","Prisoner : 0010AB79","Prisoner : 0010AB7A","Prisoner : 0010AB7B","Prisoner : 0010AB7C","Prisoner : 0010AB7D","Prisoner : 0010AB7E","Prisoner : 0010AB7F","Prisoner : 0010AB80","Prisoner : 0010AB81","Prisoner : 0010AB82","Prisoner : 0010AB83","Prisoner : 0010AB84","Prisoner : 0010AB85","Prisoner : 0010AB86","Prisoner : 0010AB87","Prisoner : 0010AB88","Prisoner : 0010AB89","Prisoner : 0010AB8A","Prisoner : 0010AB8B","Prisoner : 0010AB8C","Prisoner : 0010AB8D","Prisoner : 0010AB8E","Prisoner : 0010AB8F","Prisoner : 0010AB90","Prisoner : 0010AB91","Prisoner : 0010AB92","Prisoner : 0010AB93","Prisoner : 0010AB94","Prisoner : 0010AB95","Prisoner : 0010AB96","Prisoner : 0010AB97","Prisoner : 0010AB98","Prisoner : 0010AB99","Prisoner : 0010AB9A","Prisoner : 0010AB9B","Prisoner : 0010AB9C","Prisoner : 0010AB9D","Prisoner : 0010AB9E","Prisoner : 0010AB9F","Prisoner : 0010ABA0","Prisoner : 0010ABA1","Prisoner : 0010ABA2","Prisoner : 0010ABA3","Prisoner : 0010ABA4","Prisoner : 0010ABA5","Prisoner : 0010ABA6","Prisoner : 0010ABA7","Prisoner : 0010ABA8","Prisoner : 0010ABA9","Prisoner : 0010ABAA","Prisoner : 0010ABAB","Prisoner : 0010ABAC","Proventus Avenicci : 00013BBA","Pumpkin : 000B11A7","Pyromancer : 00045CBE","Pyromancer : 000E0FD2","Quaranir : 0002BA3C","Queen Potema : 00026C52","Quintus Navale : 0001414C","Rabbit : 0006DC9D","Raen : 00083B17","Raerek : 000133B2","Ragnar : 00013B6A","Rahd : 000AC278","Rahgot : 00035351","Ra''jirr : 000D37CF","Ra''kheran : 0002ABC2","Ralof : 0002BF9D","Ramati : 0004815E","Ranmir : 0001C186","Ravam Verethi : 0001413D","Ravyn Imyan : 000B03A4","Razelan : 000368C8","Ra''zhinda : 0001B1D3","Reach Hold Guard : 0001FD69","Reach Hold Guard : 0002429A","Reach Hold Guard : 00061367","Reach Hold Guard : 0009E481","Reburrus Quintilius : 000133B3","Reckless Mage : 00087B98","Red Eagle : 000C1908","Redguard : 00048117","Redguard : 00048118","Redguard : 001034F5","Redguard : 00103504","Redguard : 00103505","Redguard Woman : 000B85AB","Refugee : 000745C7","Refugee : 000745CB","Refugee : 000745CD","Reldith : 000136B4","Restless Draugr : 0003B548","Reveler : 000BD15A","Reveler : 000BD15B","Reveler : 000E842F","Reves : 000F84A4","Revyn Sadri : 0001413A","Rexus : 0005BF2B","Rhiada : 000133B4","Rhorlak : 000799E4","Ria : 0001A6D7","Rift Guard : 00030275","Rift Guard : 000303ED","Rift Guard : 0009415F","Riften Guard : 000300A4","Riften Guard : 00045854","Riften Guard : 000F62EF","Riften Guard : 000F62F0","Riften Guard Jailor : 000458A7","Ri''saad : 0001B1DB","Rissing : 0002ABC0","Ritual Master : 000284F2","Roadside Guard : 00043D21","Rogatus Salvius : 000133B5","Roggi Knot-Beard : 0001403F","Roggvir : 000A3BDB","Rolff Stone-Fist : 0003EFE9","Romlyn Dreth : 00013377","Rondach : 000133B6","Rorik : 000136B2","Rorlund : 000132A2","Ruki : 00038289","Rulindil : 00039F1F","Runa Fair-Shield : 00013378","Rundi : 00013BC1","Rune : 000D4FDE","Runil : 0001364D","Rustleif : 0001361E","Saadia : 00013BA2","Saarthal Miner : 00103532","Saarthal Miner : 00103533","Saarthal Miner : 00103534","Saarthal Miner : 00103535","Saarthal Miner : 00103536","Saarthal Miner : 00103537","Sabine Nytte : 000132A3","Sabjorn : 0002BA8C","Sabre Cat : 00023AB5","Sabre Cat Guardian Spirit : 000E7EAD","Saerlund : 00013379","Saffir : 00013B98","Safia : 00013267","Sahloknir : 00032D9B","Sailor : 000C6011","Salma : 0006CD5A","Salonia Carvain : 000B8149","Salonia Carvain : 000C0401","Salvianus : 00094012","Sam Guevenne : 0001BB9C","Samuel : 0001337A","Sanctuary Guardian : 000942CC","Sanctuary Guardian : 000D5451","Sanguine : 0002E1F2","Sanyon : 0009BB47","Sapphire : 000C19A3","Sarthis Idren : 00085D41","Savos Aren : 0001C19F","Savos Aren : 000D07DB","Sayma : 0001329A","Scavenger : 00062105","Scheming Servant : 00087B8F","Scouts-Many-Marshes : 0001412E","Seasoned Hunter : 00087B99","Self Doubt : 0009F847","Selveni Nethri : 0003A745","Senna : 000133B7","Septimus Signus : 0002D514","Seren : 0001361F","Sergius Turrianus : 0001C23E","Severio Pelagia : 0002C925","Shade : 000F1181","Shadowmere : 0009CCD7","Shadr : 00013371","Shahvee : 0001411A","Sharamph : 00019953","Shavari : 0006C868","Shel : 00013B7D","Sheogorath : 0002AC69","Shor''s Stone Guard : 0002A3D8","Shuftharz : 00019957","Sibbi Black-Briar : 0001337B","Sickly Farmer : 000D74F8","Siddgeir : 00013653","Sifnar Ironkettle : 00029D96","Sigaar : 0009B7AA","Sigar : 000B85BE","Sigdis Gauldurson : 000A6842","Sigdis Gauldurson : 000A6848","Sigdis Gauldurson : 000ECF13","Sigrid : 00013476","Sigurd : 000CDD72","Silana Petreia : 000132A5","Sild the Warlock : 0005197F","Silda the Unseen : 00014121","Sild''s Assistant : 0005198C","Silus Vesuius : 000240CC","Silver Hand : 0002AB87","Silver Hand : 0002AB88","Silver Hand : 0002AB89","Silver Hand : 0004499F","Silver Hand : 0006466C","Silver Hand : 000A9548","Silver Hand : 000AA08A","Silver Hand : 000C7410","Silver Hand : 00108BBB","Silver Hand : 00108BBC","Silver Hand : 00108BBD","Silver Hand : 00108BBE","Silver Hand : 00108BBF","Silver Hand Warrior : 000B8669","Silver Hand Warrior : 000B866A","Silver-Blood Guard : 0003680A","Silver-Blood Mercenary : 000622E1","Silvia : 0004B0AE","Sinderion : 000EEDF1","Sinding : 000136AC","Sinding : 0006C1B7","Sinmir : 000813B5","Sirgar : 00013607","Sissel : 000136BA","Skaggi Scar-Face : 000133B8","Skald : 00013620","Skeever : 00023AB7","Skeever : 000481A0","Skeever : 000EF610","Skeever : 0010195B","Skeever Guardian Spirit : 000E662E","Skeggr : 0007F699","Skeggr : 000F84A3","Skeletal Dragon : 0009192C","Skeleton : 0002D1DE","Skeleton : 0002D1E0","Skeleton : 0002D1FC","Skeleton : 0002D1FD","Skeleton : 0009362B","Skeleton : 000B9FD8","Skeleton : 00104176","Skjor : 0001A690","Skuli : 00013B78","Skulvar Sable-Hilt : 00013BB7","Slaughterfish : 00023AB8","Smuggler : 000DC4E6","Snilf : 0001B071","Snilling : 000132A6","Snorreid : 0007E5EC","Snow Bear : 00023A8C","Snow Fox : 000829B6","Snowy Sabre Cat : 00023AB6","Solaf : 00013652","Soldier : 0009F7EA","Soldier : 0009F7F1","Soldier : 0009F7F2","Solitude Guard : 000853C4","Solitude Guard : 000B3E4F","Solitude Guard : 0010C068","Sond : 00015CC4","Sond : 000B94A3","Sondas Drenim : 0001366B","Sorex Vinius : 000132A7","Sorli the Builder : 00013606","Sosia Tremellia : 000133B9","Spectral Assassin : 000A0E49","Spectral Warhound : 000F9060","Spellsword : 000B11EF","Spirit of the Ancient Traveler : 000F6768","Spriggan : 00023AB9","Spriggan : 0009DA9B","Spriggan Matron : 000F3905","Spriggan Swarm : 0009AA3B","Stalleo : 0004B4AF","Stalleo''s Bodyguard : 0004B4B1","Stalleo''s Bodyguard : 00093A76","Stands-In-Shallows : 00014130","Staubin : 00093821","Steirod : 00019A19","Stenvar : 000B9983","Stig Salt-Plank : 0001DC00","Storm Atronach : 000204C2","Storm Atronach : 00023AA8","Storm Atronach : 0010EE45","Storm Mage : 00045CA2","Storm Mage : 000E0FCC","Storm Mage Adept : 00045C7C","Storm Mage Adept : 000E0FC7","Storm Thrall : 0007E87F","Storm Thrall : 0009B2AA","Storm Thrall : 000CDECE","Storm Wizard : 00045CBD","Storm Wizard : 000E0FD1","Stormcloak Archer : 00045BE4","Stormcloak Courier : 0003BCC7","Stormcloak Field Commander : 000205C8","Stormcloak General : 000559DF","Stormcloak Guard : 0002C81C","Stormcloak Guard : 00100750","Stormcloak Mage : 0004622B","Stormcloak Quartermaster : 00016ACE","Stormcloak Soldier : 00027498","Stormcloak Soldier : 000467BB","Stormcloak Soldier : 0004D366","Stormcloak Soldier : 0005B205","Stormcloak Soldier : 000AA922","Stormcloak Soldier : 000AA924","Stormcloak Soldier : 000AA931","Stormcloak Soldier : 000AA932","Stormcloak Soldier : 000AA933","Stormcloak Soldier : 000AA935","Stormcloak Soldier : 000AA936","Stormcloak Soldier : 000AA942","Stormcloak Soldier : 000AA943","Stormcloak Soldier : 000B1693","Stormcloak Soldier : 000B79BC","Stormcloak Soldier : 000CD6BC","Stormcloak Soldier : 000CD6BD","Stormcloak Soldier : 000E962C","Stormcloak Soldier : 000F778F","Stormcloak Soldier : 000F830A","Stormcloak Soldier : 000F94B1","Stormcloak Soldier : 000F94B2","Stormcloak Soldier : 001098A1","Stormcloak Soldier : 0010A1A4","Stormcloak Soldier : 0010A1A5","Stormcloak Soldier : 0010A1A6","Stormcloak Soldier : 0010A1A7","Stormcloak Soldier : 0010A1A8","Stray Dog : 00109487","Stromm : 00093851","Student : 0006F214","Stump : 0001E62A","Styrr : 000132A8","Subjugated Ghost : 0003481A","Subjugated Ghost : 000515F6","Sudi : 0004815F","Sulla Trebatius : 0003B0E2","Sultry Maiden : 0009F83A","Sulvar the Steady : 00014147","Summerset Shadow : 000C5676","Susanna the Wicked : 0001412B","Suvaris Atheron : 00014122","Svaknir : 00016C87","Svana Far-Shield : 0001337C","Svari : 000132A9","Sven : 0001347F","Swanhvir : 00013608","Sybille Stentor : 000132AA","Sylgja : 000C3A3F","Synda Llanith : 000BB2C0","Syndus : 00029DAA","Synod Researcher : 0008C3CA","Synod Researcher : 000B114F","Taarie : 000132AB","Tacitus Sallustius : 0001402D","Takes-In-Light : 000B878C","Talen-Jei : 00013373","Talib : 00013609","Talsgar the Wanderer : 00083D99","Talvur : 0003A190","Tandil : 00039250","Tasius Tragus : 00019A24","Teeba-Ei : 0001360A","Tekla : 00013656","Telrav : 0001BA08","Temba Wide-Arm : 000658D2","Terek : 0001A673","TestCarryBasket : 000196B8","TestCarryFirewood : 000BECD2","TestCarryFirewood : 000CCE01","TestFurnitureUseIdleLinkedRefNPC : 0002E11F","TestJeffBCarryWaterBucket : 000CCDFC","TestJeremyBig : 0010D140","TestJeremyRegular : 0010D13E","TestJeremySmall : 0010D13F","TestReadingDude : 000591A1","TestWritingDude : 00105593","Thadgeir : 0004E5E9","Thaena : 0001C189","Thaer : 0009B7A6","Thalmor Justiciar : 000B5E11","Thalmor Justiciar : 0010516E","Thalmor Justiciar : 0010516F","Thalmor Prisoner : 000B80FF","Thalmor Soldier : 0002B124","Thalmor Soldier : 000728AC","Thalmor Wizard : 000728AD","The Caller : 0004D246","The Pale Lady : 000D37F4","Thief : 00023EE8","Thief : 000B816E","Thief : 000E93D3","Thief : 000EF9C3","Thief : 00103510","Thief : 001093A5","Thjollod : 000CE088","Thomas : 000C3B25","Thonar Silver-Blood : 000133BA","Thongvor Silver-Blood : 000133BB","Thonjolf : 0001C181","Thonnir : 000135F2","Thorald Gray-Mane : 0001C241","Thorek : 00024278","Thorek : 000341FF","Thorgar : 000AE777","Thoring : 00013621","Thorygg Sun-Killer : 0008455F","Threki the Innocent : 00013367","Thrynn : 000D4FDB","Thug : 000B91B0","Tiber : 00023EF1","Tilma the Haggard : 00013BB6","Tolfdir : 0001C19E","Tonilia : 000B8827","Torbjorn Shatter-Shield : 0001413F","Torkild the Fearsome : 000CE084","Tormir : 0001403D","Torolf : 00013641","Torom : 0002F442","Torsten Cruel-Sea : 00014136","Torture Victim : 00015D02","Torture Victim : 00015D0E","Torture Victim : 00037A28","Torture Victim : 00037A2C","Torturer : 000B9652","Torturer''s Assistant : 000B9655","Torvar : 0001A6DB","Tova Shatter-Shield : 00014125","Tova Shatter-Shield : 000D2B16","Trapper : 000D1685","Trapper : 000D1686","Traveling Dignitary : 00087B9C","Treasure Hunter : 000A17AF","Treasure Hunter : 000D1240","Trilf : 00019A1B","Trius : 00043BAD","Troll : 00023ABA","Troll : 000F077A","Tsavani : 000353C7","Tsrasuna : 000CE081","Tsun : 0004F828","Tulvur : 00014139","Tuthul : 0001996D","Tynan : 000D6718","Tythis Ulen : 0001337D","Uaile : 000133BC","Udefrykte : 000AFBA2","Uglarz : 000E316F","Ugor : 00019E1A","Ulag : 000E2BBF","Ulfberth War-Bear : 00013B9F","Ulfgar the Unending : 000EA71C","Ulfr the Blind : 000812FC","Ulfric Stormcloak : 0001414D","Ulfric Stormcloak : 000D0575","Ulundil : 00014141","Umana : 0003B0E3","Umurn : 00013B7E","Una : 000132AC","Unbound Dremora : 00099F2F","Unemployed Laborer : 00087B94","Ungrien : 0001337E","Unmid Snow-Shod : 000371D7","Uraccen : 000133BD","Urag gro-Shub : 0001C193","Urchin : 0005224B","Urog : 0001B078","Ursine Guardian : 000E7EA9","Urzoga gra-Shugurz : 000133BE","Uthgerd the Unbroken : 000918E2","Vaermina : 000E16CD","Vaermina Devotee : 0007AD00","Vaermina Devotee : 0009DDCD","Vaermina Devotee : 0009DDD2","Vaermina Devotee : 000B91A3","Vagrant : 000A3F8E","Vald : 00072B04","Valdar : 0002C18D","Valdr : 000411BA","Valga Vinicia : 00013655","Valie : 0003B0E1","Valindor : 0001337F","Vals Veran : 00019FE6","Vampire : 00032FE8","Vampire Fledgling : 00032FE7","Vampire Mistwalker : 0003384F","Vampire Nightstalker : 00033850","Vampire''s Thrall : 0002EB0B","Vampire''s Thrall : 0002EC1B","Vampire''s Thrall : 0002ED6B","Vampire''s Thrall : 0002ED6D","Vampire''s Thrall : 0002ED6E","Vampire''s Thrall : 0002ED86","Vampire''s Thrall : 0002EE9D","Vampire''s Thrall : 0002EE9E","Vampire''s Thrall : 0002EED0","Vampire''s Thrall : 0002EED1","Vampire''s Thrall : 0002EED2","Vampire''s Thrall : 0002EED3","Vampire''s Thrall : 0002EED5","Vampire''s Thrall : 0002EED6","Vampire''s Thrall : 0002EED7","Vampire''s Thrall : 0002EED8","Vampire''s Thrall : 0002EEDC","Vampire''s Thrall : 0002EEDD","Vampire''s Thrall : 0002EEDE","Vampire''s Thrall : 0002EEDF","Vampire''s Thrall : 0002EEE0","Vampire''s Thrall : 0002EEE1","Vampire''s Thrall : 0002EEE5","Vampire''s Thrall : 0002EEE6","Vampire''s Thrall : 0002EEE7","Vampire''s Thrall : 0002EEE8","Vampire''s Thrall : 0002EEE9","Vampire''s Thrall : 0002EEEA","Vampire''s Thrall : 0002EEEB","Vampire''s Thrall : 0002EEEC","Vampire''s Thrall : 0002EEED","Vampire''s Thrall : 0002EEEE","Vampire''s Thrall : 00042267","Vampire''s Thrall : 0008E2F7","Vanryth Gatharian : 00029DAF","Vantus Loreius : 0001A6B1","Vantus Loreius : 0007F429","Varnius Junius : 00019A26","Vasha : 0002E3F0","Veezara : 0001C3AA","Veezara : 0002E447","Vekel the Man : 00013380","Velehk Sain : 00075C7F","Venomfang Skeever : 000490F2","Veren Duleri : 0002427C","Veren Duleri : 000341FE","Verner Rock-Chucker : 00013665","Vex : 0001CD90","Viarmo : 000132AD","Vidgrod : 00083B16","Viding : 000CE085","Vidrald : 000C440A","Vigdis Salvius : 000133BF","Vigilance : 0009A7AA","Vigilant of Stendarr : 000BFB54","Vigilant Tyranus : 000A733B","Vignar Gray-Mane : 00013BB5","Viinturuth : 000FE432","Vilkas : 0001A694","Vilkas''s Wolf Spirit : 000F6089","Vilod : 0001363E","Viola Giordano : 00014129","Vipir the Fleet : 0001CD8F","Virkmund : 000135F1","Visiting Noble : 00087B95","Vittoria Vici : 0001327A","Vivienne Onis : 000132AE","Voada : 000133C0","Voice of Boethiah : 0004D91B","Voice of Namira : 0008797F","Vokun : 000327C2","Voldsea Giryon : 0001411C","Volkihar Master Vampire : 0002E1BF","Volkihar Vampire : 00033852","Volsung : 00041930","Vorstag : 000B997F","Vuljotnaak : 000FE430","Vulthuryol : 0007EAC7","Vulwulf Snow-Shod : 00013381","Warehouse Traps Reset Test Guy : 000E9DAB","Wary Outlaw : 00087B8D","Watches-The-Roots : 0004C735","Watches-The-Roots : 0004C757","Werewolf : 0001B150","Werewolf : 00023ABC","Werewolf : 0007871B","Werewolf Beastmaster : 000A092E","Werewolf Beastmaster : 000A1975","Werewolf Brute : 000A092C","Werewolf Brute : 000A1973","Werewolf Savage : 000A092B","Werewolf Savage : 000A1972","Werewolf Skinwalker : 000A092D","Werewolf Skinwalker : 000A1974","Werewolf Vargr : 000A092F","Werewolf Vargr : 000A1976","Weylin : 0009C8AA","White Stag : 00104F46","Whiterun Guard : 000215D5","Whiterun Guard : 00039FD7","Whiterun Guard : 00063F35","Whiterun Guard : 000A27CC","Whiterun Guard : 000A4A3B","Whiterun Guard : 000B799D","Whiterun Guard : 000BD05C","Whiterun Guard : 000D7779","Whiterun Guard : 000EA0A2","Whiterun Guard : 00101996","Whiterun Guard : 00101997","Whiterun Guard : 00108296","Whiterun Guard : 00108298","Whiterun Guard : 00108D8A","Whiterun Guard : 00108D8B","Wilhelm : 000136BB","Willem : 000661AF","Wilmuth : 0009CCD9","Windhelm Guard : 00045C31","Winterhold Guard : 00024B63","Winterhold Guard : 000FCEEB","Winterhold Guard : 000FCEEC","Winterhold Guard : 000FCEED","Wisp : 0002C3C7","Wispmother : 00023ABD","Witch : 00074F74","Witch : 00074F75","Witch : 00074F76","Wizard : 00044CCC","Wizards'' Guard : 000154C7","Wizards'' Guard : 000154C8","Wizards'' Guard : 000154C9","Wizards'' Guard : 000154CA","Wolf : 00023ABE","Wolf : 000753CE","Wolf Guardian Spirit : 000E662D","Wolf Spirit : 000F608C","Wood Cutter : 0002236C","Wood Cutter : 000CE5D0","Wood Elf : 000457FC","Wood Elf : 00045805","Wood Elf : 0010554F","Wood Elf : 00105550","Wood Elf : 00105560","Worshipper : 0005B907","Worshipper : 0005B90D","Worshipper : 0005B937","Wounded Frostbite Spider : 0003A1E0","Wounded Soldier : 000D74F5","Wujeeta : 00013382","Wulfgar : 0002C6CA","Wuunferth the Unliving : 00014146","Wylandriah : 00019DEF","Wyndelius Gatharian : 0005FFDF","Xander : 000AF523","Yag gra-Gortwog : 0003B0E5","Yar gro-Gatuk : 000CE087","Yatul : 0001B077","Yisra : 000D4FF9","Yngvar the Singer : 000133C1","Yngvild Ghost : 00074360","Yngvild Ghost : 00074361","Yngvild Ghost : 000743AE","Yrsarald Thrice-Pierced : 00084551","Ysgramor : 00023EED","Ysgramor : 00098BD1","Ysolda : 00013BAB","Zaria : 0003A19A","Zaynabi : 0001B1D0"';
end;

procedure AddMainUniques(slString: TStringList);
begin
  slString.DelimitedText :='"Abelone : 0008774F","Acolyte Jenssen : 000D3E79","Adara : 00013385","Addvar : 00013255","Addvild : 00019DC7","Adeber : 000661AD","Adelaisa Vendicci : 0001411D","Adisla : 0001411E","Adonato Leotelli : 0001413C","Adrianne Avenicci : 00013BB9","Aduri Sarethi : 00019BFF","Aela the Huntress : 0001A696","Aeri : 0001360B","Aerin : 00013346","Agni : 000135E5","Agnis : 00020044","Ahkari : 0001B1D6","Ahlam : 00013BBE","Ahtar : 0001325F","Aia Arria : 0001325C","Aicantar : 0001402E","Ainethach : 00013B69","Alain Dufont : 0001B074","Alding : 00052268","Alduin : 00032B94","Alduin : 0008E4F1","Alessandra : 00013347","Alexia Vici : 00060B29","Alfarinn : 0009B7AB","Alfhild Battle-Born : 00013BB0","Alik''r Prisoner : 000215F5","Alva : 000135E6","Alvor : 00013475","Amaund Motierre : 0003B43A","Amaund Motierre : 0004E64F","Ambarys Rendar : 0001413E","Amren : 00013BAA","Ancano : 0001E7D7","Anders : 000FF224","Andurs : 00013BA8","Angeline Morrard : 00013260","Angi : 000CAB2F","Angrenor Once-Honored : 00014137","Annekke Crag-Jumper : 00013666","Anoriath : 00013B97","Anton Virane : 00013387","Anuriel : 00013349","Anwen : 00013386","Aquillius Aeresius : 000D6AD8","Aranea Ienith : 00028AD0","Arcadia : 00013BA4","Argi Farseer : 00013602","Argis the Bulwark : 000A2C8C","Aringoth : 0001334A","Arivanya : 00014127","Arnbjorn : 0001BDB0","Arngeir : 0002C6C7","Arniel Gane : 0001C19D","Arniel''s Shade : 0006A152","Arnskar Ember-Master : 00029DAD","Arob : 00013B7B","Arvel the Swift : 00039646","Arvel the Swift : 00099991","Asbjorn Fire-Tamer : 00019DF2","Asgeir Snow-Shod : 0001334B","Aslfur : 000135E7","Assur : 0001C18A","Astrid : 0001BDB4","Astrid : 0004D6D0","Ataf : 00013295","Atahbah : 0001B1DA","Atar : 000622E5","Athis : 0001A6D5","Atmah : 000B8786","Atub : 00019E18","Augur of Dunlain : 0002BCE8","Aval Atheron : 00014140","Aventus Aretino : 00014132","Avrusa Sarethi : 00019BFE","Avulstein Gray-Mane : 00013B9A","Azzada Lylvieve : 00019A2A","Babette : 0001D4B7","Bagrak : 00019955","Balagog gro-Nolob : 00038C6E","Balgruuf the Greater : 00013BBD","Balimund : 0001334C","Banning : 0009A7A8","Barbas : 0001BFC5","Barknar : 000BC079","Bassianus Axius : 000136C1","Beautiful Barbarian : 00087B9E","Beem-Ja : 0006CD5B","Beirand : 00013261","Beitild : 00013612","Belchimac : 00013B6B","Belethor : 00013BA1","Belrand : 000B9981","Belyn Hlaalu : 00014138","Bendt : 000E77CB","Benkum : 0001E94C","Benor : 000135E8","Bergritte Battle-Born : 00013BB3","Bersi Honey-Hand : 0001334D","Betrid Silver-Blood : 00013388","Big Laborer : 00087B96","Birna : 0001C187","Bjartur : 00013262","Bjorlam : 00013669","Blasphemous Priest : 00087B91","Bodil : 000876DC","Bolar : 0001B076","Bolfrida Brandy-Mug : 00014126","Bolgeir Bearclaw : 00013264","Bolli : 0001334E","Bolund : 00013651","Bor : 000C78E1","Borgakh the Steel Heart : 00019959","Borgny : 000877B2","Borkul the Beast : 0001338A","Borri : 0002C6CE","Borvir : 00013BC2","Bothela : 0001338B","Boti : 000136BE","Bottar : 000B94A9","Braig : 00013389","Braith : 00013BA9","Brand-Shei : 0001334F","Brelas : 00069F38","Brelyna Maryon : 0001C196","Brenuin : 00013BA7","Breya : 0004C724","Breya : 0004C754","Briehl : 000585FB","Brill : 0001A6A2","Brina Merilis : 0001A6B7","Britte : 000136B9","Brond : 00014144","Brother Verulus : 0001338C","Brunwulf Free-Winter : 00014149","Bryling : 00013265","Brynjolf : 0001B07D","Bulfrek : 00013613","Cairine : 000D66FE","Calcelmo : 0001338E","Calder : 000A2C90","Calixto Corrium : 0001414A","Camilla Valerius : 0001347B","Captain Aldis : 00041FB8","Captain Lonely-Gale : 00014134","Captain Metilius : 0001C9F7","Captain Valmir : 0007E5B4","Captain Wayfinder : 00013296","Carlotta Valentia : 00013B99","Cedran : 0001338F","Chief Burguk : 00013B79","Chief Larak : 00019951","Chief Mauhulakh : 0001B075","Chief Yamarz : 0003BC26","Christer : 00090738","Cicero : 0001BDB1","Cicero : 000550F0","Cicero : 0009BCAF","Clavicus Vile : 0001C4E4","Clinton Lylvieve : 00019A2C","Coldhearted Gravedigger : 00087B9D","Colette Marence : 0001C19A","Commander Caius : 00038257","Commander Maro : 0001D4B5","Constance Michel : 00013350","Corpulus Vinius : 00013266","Corrupt Agent : 00087B8C","Cosnach : 00013390","Courier : 00039F83","Curwe : 0001A6B3","Curwe : 0007F42A","Cynric Endell : 000D4FD8","Dagny : 0001434B","Dagur : 0001C183","Daighre : 00013391","Dalan Merchad : 000132A4","Danica Pure-Spring : 00013BA5","Dark Brotherhood Initiate : 00015CFA","Dark Brotherhood Initiate : 00015CFE","Deeja : 00013268","Deekus : 00020040","Deep-In-His-Cups : 000BBDA0","Degaine : 00013392","Delacourt : 00072663","Delphine : 00013478","Delvin Mallory : 0001CB78","Dengeir of Stuhn : 0001365A","Derkeethus : 0001403E","Dervenin : 0001327C","Desperate Gambler : 00087B8E","Dinya Balu : 00013352","Dirge : 0001336D","Dishonored Skald : 00087B92","DomnaMagia : 00058FB7","Donnel : 000D673A","Dorian : 000AF524","Dorthe : 00013477","Drahff : 00095F7E","Dravin Llanith : 00013353","Dravynea the Stoneweaver : 0001365F","Drennen : 0004C734","Drennen : 0004C751","Drevis Neloren : 0001C198","Drifa : 00013354","Dro''marash : 0001B1CF","Drunk Cultist : 0001CB2E","Dryston : 000D6711","Duach : 00013393","Dulug : 000C78C0","Dushnamub : 0001B079","East Empire Dockmaster : 000132A0","East Empire Dockworker : 0007E5EA","East Empire Dockworker : 0007E5EB","Edda : 00013356","Edith : 000877AF","Edorfin : 0001E957","Eimar : 000B2977","Einarth : 0002C6CC","Eirid : 0001C185","Elda Early-Dawn : 0001412A","Elenwen : 00013269","Elgrim : 00013357","Elisif the Fair : 0001326A","Elrindir : 00013B9E","Eltrys : 00013394","Elvali Veren : 000B878B","Embry : 0003550B","Emperor Titus Mede II : 0001D4B9","Emperor Titus Mede II : 0001D4BA","Endarie : 0001326F","Endon : 00013395","Endrast : 0003B0E4","Enmon : 00013B6C","Ennis : 0001B3B5","Ennoc : 00013396","Ennodius Papius : 0001360C","Enthir : 0001C19C","Enthralled Wizard : 000F737C","Enthralled Wizard : 000F7385","Eola : 0001990F","Eorlund Gray-Mane : 00013B9D","Erandur : 0002427D","Erdi : 00013271","Erik : 000350A7","Erik the Slayer : 00065657","Erikur : 00013272","Eris : 000AF522","Erith : 000133AB","Erlendr : 000EA71F","Esbern : 00013358","Escaped Prisoner : 000BFB44","Estormo : 00034D97","Etienne Rarnis : 0003A1D3","Evette San : 00013273","Eydis : 00013B77","Faendal : 00013480","Faida : 00019A28","Faleen : 00013397","Falion : 000135E9","Falk Firebeard : 00013274","Faralda : 0001C197","Farengar Secret-Fire : 00013BBB","Farkas : 0001A692","Farmer : 000BD759","Farmer : 000BD75E","Faryl Atheron : 00014131","Fastred : 000136BF","Felldir the Old : 00044237","Felldir the Old : 000CDA00","Fenrig : 00038287","Festus Krex : 0001BDB2","Festus Krex : 000E0D6F","Fianna : 000D16DD","Fihada : 00013275","Filnjar : 000136C3","Fjotra : 0001E82C","Frabbi : 00013398","Fralia Gray-Mane : 00013B9C","Francois Beaufort : 00013359","Freir : 00013277","Frida : 00013614","Fridrika : 00013278","Frodnar : 0001347E","Froki Whetted-Blade : 000185F6","From-Deepest-Fathoms : 0001335A","Frost : 00097E1E","Frothar : 0001434C","Fruki : 00013615","Fultheim : 000DA68A","Gabriella : 0001BDB8","Gabriella : 0002FB1A","Gadba gro-Largash : 0001B09A","Gadnor : 0002EB58","Gaius Maro : 00044050","Galmar Stone-Fist : 00014128","Ganna Uriel : 0001365D","Garakh : 00019E1C","Garthar : 000B03A3","Garvey : 000D6703","Gat gro-Shargakh : 000199B7","Gavros Plinius : 00034CB8","Geimund : 0001327D","Gelebros : 0003983E","Gemma Uriel : 00014040","General Tullius : 0001327E","Gerda : 000C247E","Gerdur : 0001347C","Gestur Rockbreaker : 00013603","Ghak : 000C78C2","Ghamorz : 000C78CC","Gharol : 00013B7C","Ghorbash the Iron Hand : 00013B81","Ghorza gra-Bagol : 0001339A","Ghost of Old Hroldan : 000681A2","Gianna : 0004BCC3","Gilfre : 0001367A","Giraud Gemane : 00013281","Girduin : 000B878A","Gisli : 00013282","Gissur : 00039F23","Gjak : 000876DA","Gjuk : 00052269","Gleda the Goat : 0001CB2C","Gloth : 00028DD6","Goat : 0005487E","Gorm : 000135EA","Gormlaith Golden-Hilt : 00044236","Gormlaith Golden-Hilt : 000CD9F7","Gralnach : 00019C01","Grelka : 000136C5","Grelod the Kind : 0001335E","Greta : 00013283","Griefstricken Chef : 00087B90","Grim Shieldmaiden : 00087B9B","Grimvar Cruel-Sea : 00014133","Grisvar the Unlucky : 0001339B","Grogmar gro-Burzag : 000136C6","Grok : 0001F3BB","Grosta : 00019C00","Grushnag : 0001B1CD","Guardian Troll Spirit : 000E7EB2","Gul : 000C78CA","Gularzob : 00019E20","Gulum-Ei : 00013284","Gunnar Stone-Eye : 00013643","Guthrum : 00013285","Gwendolyn : 0002C930","Gwilin : 000658D4","Hadring : 00013627","Hadvar : 0002BF9F","Haelga : 0001335F","Hafjorg : 00013360","Hafnar Ice-Fist : 000B8785","Hakon One-Eye : 00044238","Hakon One-Eye : 000CDA01","Hamal : 0001E765","Haming : 00013642","Haming : 000C029C","Haran : 0001C184","Harrald : 00013361","Hathrasil : 0001339C","Headsman : 000AA7D6","Headsman : 000BFB43","Headsman : 000BFB60","Hefid the Deaf : 0009400E","Heimskr : 00013BAC","Heimvar : 00013286","Helgird : 00014124","Helgi''s Ghost : 000274A5","Helvard : 00013657","Hemming Black-Briar : 00013362","Herluin Lothaire : 00029DAE","Hermir Strong-Heart : 0001412D","Hern : 0001367B","Hert : 0001367C","Hewnon Black-Skeever : 00095FD5","High King Torygg : 000EA578","Hilde : 00035533","Hillevi Cruel-Sea : 0001411F","Hircine : 0001BB96","Hjorunn : 00013287","Hod : 0001347D","Hofgrir Horse-Crusher : 00013351","Hogni Red-Arm : 000284AC","Horgeir : 00019A1D","Horik Halfhand : 0001A6B9","Horm : 00013288","Hrefna : 00013668","Hreinn : 0001339D","Hroar : 00013363","Hroggar : 000135F0","Hroki : 0001339E","Hrolmir : 000F84A2","Hrongar : 00013BBC","Huki Seven-Swords : 00014143","Hulda : 00013BA3","Hunroor : 000EA71D","Iddra : 00013662","Idesa Sadri : 0001411B","Idgrod Ravencrone : 000135EB","Idgrod the Younger : 000135EC","Idolaf Battle-Born : 00013BB2","Igmund : 0001339F","Ilas-Tei : 000D5046","Illdi : 00013289","Imedhnain : 000133A1","Imperial Mage : 000F3E76","Imperial Mage : 000F3E77","Imperial Soldier : 000D67B8","Imperial Soldier : 000D7D7D","Imperial Soldier : 000D7D8E","Imperial Soldier : 000E1E95","Imperial Soldier : 000E491B","Imperial Soldier : 000E4920","Imperial Soldier : 000E6D5C","Imperial Soldier : 000E72BB","Imperial Soldier : 000E77F9","Imperial Soldier : 000E77FD","Imperial Soldier : 000F3E6D","Imperial Soldier : 000F3E6E","Imperial Soldier : 000F3E6F","Imperial Soldier : 000F94A9","Imperial Soldier : 000F94AE","Imperial Soldier : 00105EE2","Indara Caerellia : 0001364F","Indaryn : 00013370","Indolent Farmer : 00087B93","Inge Six Fingers : 0001328A","Ingrid : 0001363F","Ingun Black-Briar : 00013364","Iona : 000A2C91","Irgnir : 00013617","Irileth : 00013BB8","Irlof : 00052267","Irnskar Ironhand : 0001328B","Isabelle Rolaine : 00039840","Itinerant Lumberjack : 00087B97","Jala : 0001328C","Jaree-Ra : 0001328D","Jawanan : 0001328E","J''datharr : 0004D12B","Jenassa : 000B9982","Jervar : 0001A69D","Jesper : 00013604","Jod : 00013618","Jofthor : 000136BD","Jolf : 000AF38A","Jon Battle-Born : 00013BB1","Jonna : 000135ED","Jora : 00014120","Jordis the Sword-Maiden : 000A2C8F","Jorgen : 000138B6","Joric : 000135EE","Jorleif : 00014135","Jorn : 0001328F","Jouane Manette : 000136B3","Julienne Lylvieve : 00026F0F","Jurgen Windcaller : 000F1A49","J''zargo : 0001C195","J''zhar : 0003B0E6","Karinda : 0005F865","Karita : 0001361A","Karita : 000BC07C","Karl : 00013619","Karliah : 0001B07F","Katla : 00013290","Kayd : 00013292","Keeper Carcette : 000BFB55","Keerava : 00013365","Kematu : 00021601","Kerah : 000133A2","Kesh the Clean : 00089986","Kharag gro-Shurkul : 00013291","Kharjo : 0001B1D2","Khayla : 0001B1D9","Kibell : 0003F21E","Kjar : 00013293","Kjeld : 00013663","Kjeld the Younger : 00013661","Kleppr : 000133A3","Klimmek : 000136C2","Knjakr : 00094000","Knud : 00013294","Kodlak Whitemane : 0001A68E","Kodrir : 0001360D","Korir : 0001C188","Kraldar : 0001C180","Kust : 0001364C","Laila Law-Giver : 00013366","Lami : 000135EF","Lars Battle-Born : 00013BAF","Lash gra-Dushnikh : 00013B6E","Legate Rikke : 000132A1","Leifur : 00013610","Leigelf : 0001361B","Lemkil : 000136B8","Leonara Arius : 00037E04","Leontius Salvius : 00013B76","Liesl : 0001E956","Lillith Maiden-Loom : 00013BC0","Linwe : 0007D679","Lis : 000A19FE","Lis : 000A19FF","Lisbet : 000133A5","Lisette : 00013297","Lob : 00019E1E","Lod : 00013650","Lodi : 000D5636","Lodvar : 00019A22","Logrolf the Willful : 000133A6","Lokir : 0004679A","Lond : 0001361C","Lortheim : 00014145","Louis Letrush : 00013368","Luaffyn : 00047CAD","Lu''ah Al-Skaven : 0002333A","Lucan Valerius : 0001347A","Lucerne : 0002ABBE","Lurbuk : 0001AA63","Lydia : 000A2C8E","Lynly Star-Sung : 000136BC","Madanach : 000133A7","Madena : 0001361D","Madesi : 0001B072","Ma''dran : 0001B1D1","Madwoman : 000BA1E5","Mahk : 000C78BE","M''aiq the Liar : 000954BF","Ma''jhad : 0001B1D5","Malacath : 00019E16","Malborn : 00036194","Mallus Maccius : 0002BA8E","Malthyr Elenil : 0001414E","Malur Seloth : 0001C182","Maluril : 00020046","Malyn Varen : 00028AD2","Malyn Varen : 00028AD3","Mammoth Guardian Spirit : 000E7EAF","Mani : 0004815C","Maramal : 0001335B","Ma''randru-jo : 0001B1D7","Marcurio : 000B9980","Margret : 0009C8A8","Marise Aravel : 00013369","Mathies : 0001364E","Matlara : 00013640","Maul : 000371D6","Maurice Jondrelle : 0001C605","Maven Black-Briar : 0001336A","Ma''zaka : 00013298","Medresi Dran : 0003B5B2","Mehrunes Dagon : 000252AA","Melaran : 00013299","Melka : 00039B3E","Mena : 00013B6D","Mephala : 0005BF3D","Mercer Frey : 0001B07C","Meridia : 0004E4DF","Michel Lylvieve : 00019A2E","Mikael : 0001A670","Mila Valentia : 00013BAD","Minette Vinius : 0001329B","Mirabelle Ervine : 0001C1A0","Mithorpa Nasyal : 0001A6AF","Mjoll the Lioness : 0001336B","Mogdurz : 000C78DF","Moira : 0001CB33","Molag Bal : 00022F16","Molgrom Twice-Killed : 0001336C","Morokei : 000F496C","Morven : 000D6719","Moth gro-Bagol : 00055A5E","Mralki : 000136B6","Muiri : 0001406B","Mul gro-Largash : 0001B07A","Mulush gro-Shugurz : 000133A9","Murbul : 00013B7A","Muril : 00034D99","Nagrub : 00013B7F","Nahkriin : 000F849B","Nana Ildene : 000133A0","Narfi : 000136C0","Narri : 00013654","Nazeem : 00013BBF","Nazir : 0001C3AB","Nazir : 0004DDA0","Neetrenaza : 0001412F","Nelacar : 0001E7D5","Nelkir : 0001434D","Nenya : 00013659","Nepos the Nose : 000133AA","Nerien : 000233D2","Nerien : 000A4E85","Nervous Patron : 00087B8B","Night Mother Voice NPC : 0003BB85","Nightingale Sentinel : 0001BB5D","Nikulas : 000EA71E","Nils : 0001414B","Nilsine Shatter-Shield : 0001412C","Niluva Hlaalu : 0001336E","Nimriel : 0002C926","Niranye : 00014123","Niruin : 0001CD91","Nirya : 0001C19B","Nivenor : 0001336F","Njada Stonearm : 0001A6D9","Nobleman : 0005A92D","Nobleman : 0005A92F","Noblewoman : 0005A930","Nocturnal : 0001A2CF","Nord : 000E3EAD","Noster Eagle-Eye : 0001329C","Nura Snow-Shod : 00013372","Nurelion : 00014148","Nystrom : 000FF208","Octieve San : 0001329D","Odar : 0001329E","Odfel : 000136C4","Odvan : 000133AC","Oengul War-Anvil : 00014142","Oglub : 00013B80","Ogmund : 000133AD","Ogol : 00019E22","Olaf One-Eye : 000F1A4A","Olava the Feeble : 00013BAE","Olda : 00019A20","Olfina Gray-Mane : 00013B9B","Olfrid Battle-Born : 00013BB4","Olur : 0001995B","Omluag : 000133AE","Ondolemar : 000133AF","Onmund : 0001C194","Orchendor : 00045F78","Orgnar : 00013479","Orla : 000133B0","Orthorn : 0002A388","Orthus Endario : 0001413B","Paarthurnax : 0003C57C","Pactur : 00013605","Pantea Ateia : 0001329F","Paratus Decimius : 00034CBA","Pavo Attius : 000133B1","Pelagius the Mad : 0002AC6A","Perth : 0001996C","Phinis Gestor : 0001C199","Plautis Carvain : 000B8148","Plautis Carvain : 000C03FE","Player Friend : 0002001F","Poor Fishwife : 00087B9A","Prisoner : 00000007","Prisoner : 0001750C","Prisoner : 0001750D","Prisoner : 0001750E","Prisoner : 0001750F","Prisoner : 0002425F","Prisoner : 00024261","Prisoner : 000268FC","Prisoner : 00026904","Prisoner : 00026915","Prisoner : 00026921","Prisoner : 00026927","Prisoner : 0002694E","Prisoner : 00026954","Prisoner : 000361F3","Prisoner : 0005B4F8","Prisoner : 0005EF9A","Prisoner : 0005EF9C","Prisoner : 0005EFA7","Prisoner : 00079BE6","Prisoner : 00079BEB","Prisoner : 00079BEC","Prisoner : 00079BED","Prisoner : 00079BEE","Prisoner : 00079C54","Prisoner : 00079C96","Prisoner : 00079C98","Prisoner : 00079CCD","Prisoner : 00079CCE","Prisoner : 00079CD3","Prisoner : 00079CD4","Prisoner : 00079CD5","Prisoner : 00079DD5","Prisoner : 00079E2C","Prisoner : 00079E2F","Prisoner : 00079EE1","Prisoner : 00079EE6","Prisoner : 00079EE8","Prisoner : 00079F25","Prisoner : 00079F4E","Prisoner : 00079F4F","Prisoner : 00079F50","Prisoner : 00079F51","Prisoner : 00079F52","Prisoner : 00079F53","Prisoner : 00079F54","Prisoner : 00079F55","Prisoner : 00079F56","Prisoner : 00079F57","Prisoner : 00079F58","Prisoner : 00079F59","Prisoner : 00079F5A","Prisoner : 00079F5B","Prisoner : 00079F5C","Prisoner : 00079F5D","Prisoner : 00079F5E","Prisoner : 00079F5F","Prisoner : 00079F60","Prisoner : 00079F61","Prisoner : 00079F62","Prisoner : 00079F63","Prisoner : 00079F64","Prisoner : 00079F65","Prisoner : 00079F66","Prisoner : 00079F67","Prisoner : 00079F68","Prisoner : 00079F69","Prisoner : 00079F6A","Prisoner : 00099D21","Prisoner : 00099D22","Prisoner : 00099D4C","Prisoner : 00099D4D","Prisoner : 00099D4E","Prisoner : 00099D4F","Prisoner : 00099D50","Prisoner : 00099D51","Prisoner : 00099D52","Prisoner : 00099D53","Prisoner : 00099D58","Prisoner : 00099D5D","Prisoner : 00099D5E","Prisoner : 00099D5F","Prisoner : 0010AB5D","Prisoner : 0010AB5E","Prisoner : 0010AB5F","Prisoner : 0010AB60","Prisoner : 0010AB61","Prisoner : 0010AB62","Prisoner : 0010AB63","Prisoner : 0010AB64","Prisoner : 0010AB65","Prisoner : 0010AB66","Prisoner : 0010AB67","Prisoner : 0010AB68","Prisoner : 0010AB69","Prisoner : 0010AB6A","Prisoner : 0010AB6B","Prisoner : 0010AB6C","Prisoner : 0010AB6D","Prisoner : 0010AB6E","Prisoner : 0010AB6F","Prisoner : 0010AB70","Prisoner : 0010AB71","Prisoner : 0010AB72","Prisoner : 0010AB73","Prisoner : 0010AB74","Prisoner : 0010AB75","Prisoner : 0010AB76","Prisoner : 0010AB77","Prisoner : 0010AB78","Prisoner : 0010AB79","Prisoner : 0010AB7A","Prisoner : 0010AB7B","Prisoner : 0010AB7C","Prisoner : 0010AB7D","Prisoner : 0010AB7E","Prisoner : 0010AB7F","Prisoner : 0010AB80","Prisoner : 0010AB81","Prisoner : 0010AB82","Prisoner : 0010AB83","Prisoner : 0010AB84","Prisoner : 0010AB85","Prisoner : 0010AB86","Prisoner : 0010AB87","Prisoner : 0010AB88","Prisoner : 0010AB89","Prisoner : 0010AB8A","Prisoner : 0010AB8B","Prisoner : 0010AB8C","Prisoner : 0010AB8D","Prisoner : 0010AB8E","Prisoner : 0010AB8F","Prisoner : 0010AB90","Prisoner : 0010AB91","Prisoner : 0010AB92","Prisoner : 0010AB93","Prisoner : 0010AB94","Prisoner : 0010AB95","Prisoner : 0010AB96","Prisoner : 0010AB97","Prisoner : 0010AB98","Prisoner : 0010AB99","Prisoner : 0010AB9A","Prisoner : 0010AB9B","Prisoner : 0010AB9C","Prisoner : 0010AB9D","Prisoner : 0010AB9E","Prisoner : 0010AB9F","Prisoner : 0010ABA0","Prisoner : 0010ABA1","Prisoner : 0010ABA2","Prisoner : 0010ABA3","Prisoner : 0010ABA4","Prisoner : 0010ABA5","Prisoner : 0010ABA6","Prisoner : 0010ABA7","Prisoner : 0010ABA8","Prisoner : 0010ABA9","Prisoner : 0010ABAA","Prisoner : 0010ABAB","Prisoner : 0010ABAC","Proventus Avenicci : 00013BBA","Quaranir : 0002BA3C","Quintus Navale : 0001414C","Raerek : 000133B2","Ragnar : 00013B6A","Rahgot : 00035351","Ralof : 0002BF9D","Ranmir : 0001C186","Ravam Verethi : 0001413D","Ravyn Imyan : 000B03A4","Razelan : 000368C8","Ra''zhinda : 0001B1D3","Reburrus Quintilius : 000133B3","Reckless Mage : 00087B98","Reldith : 000136B4","Reves : 000F84A4","Revyn Sadri : 0001413A","Rexus : 0005BF2B","Rhiada : 000133B4","Rhorlak : 000799E4","Ria : 0001A6D7","Ri''saad : 0001B1DB","Rogatus Salvius : 000133B5","Roggi Knot-Beard : 0001403F","Roggvir : 000A3BDB","Rolff Stone-Fist : 0003EFE9","Romlyn Dreth : 00013377","Rondach : 000133B6","Rorik : 000136B2","Rorlund : 000132A2","Ruki : 00038289","Rulindil : 00039F1F","Runa Fair-Shield : 00013378","Rundi : 00013BC1","Rune : 000D4FDE","Runil : 0001364D","Rustleif : 0001361E","Saadia : 00013BA2","Sabine Nytte : 000132A3","Sabjorn : 0002BA8C","Sabre Cat Guardian Spirit : 000E7EAD","Saerlund : 00013379","Saffir : 00013B98","Safia : 00013267","Salma : 0006CD5A","Salonia Carvain : 000B8149","Salonia Carvain : 000C0401","Salvianus : 00094012","Sam Guevenne : 0001BB9C","Samuel : 0001337A","Sanguine : 0002E1F2","Sapphire : 000C19A3","Savos Aren : 0001C19F","Savos Aren : 000D07DB","Sayma : 0001329A","Scheming Servant : 00087B8F","Scouts-Many-Marshes : 0001412E","Seasoned Hunter : 00087B99","Senna : 000133B7","Septimus Signus : 0002D514","Seren : 0001361F","Sergius Turrianus : 0001C23E","Severio Pelagia : 0002C925","Shadr : 00013371","Shahvee : 0001411A","Sharamph : 00019953","Shavari : 0006C868","Shel : 00013B7D","Sheogorath : 0002AC69","Shuftharz : 00019957","Sibbi Black-Briar : 0001337B","Sickly Farmer : 000D74F8","Siddgeir : 00013653","Sifnar Ironkettle : 00029D96","Sigaar : 0009B7AA","Sigrid : 00013476","Sigurd : 000CDD72","Silana Petreia : 000132A5","Silda the Unseen : 00014121","Silus Vesuius : 000240CC","Sinding : 0006C1B7","Sinmir : 000813B5","Sirgar : 00013607","Sissel : 000136BA","Skaggi Scar-Face : 000133B8","Skald : 00013620","Skeever Guardian Spirit : 000E662E","Skeggr : 000F84A3","Skeletal Dragon : 0009192C","Skjor : 0001A690","Skuli : 00013B78","Skulvar Sable-Hilt : 00013BB7","Snilling : 000132A6","Snorreid : 0007E5EC","Solaf : 00013652","Sond : 000B94A3","Sondas Drenim : 0001366B","Sorex Vinius : 000132A7","Sorli the Builder : 00013606","Sosia Tremellia : 000133B9","Stands-In-Shallows : 00014130","Steirod : 00019A19","Stenvar : 000B9983","Stig Salt-Plank : 0001DC00","Stump : 0001E62A","Styrr : 000132A8","Sudi : 0004815F","Sulla Trebatius : 0003B0E2","Sulvar the Steady : 00014147","Susanna the Wicked : 0001412B","Suvaris Atheron : 00014122","Svana Far-Shield : 0001337C","Svari : 000132A9","Sven : 0001347F","Swanhvir : 00013608","Sybille Stentor : 000132AA","Sylgja : 000C3A3F","Synda Llanith : 000BB2C0","Syndus : 00029DAA","Taarie : 000132AB","Tacitus Sallustius : 0001402D","Takes-In-Light : 000B878C","Talen-Jei : 00013373","Talib : 00013609","Talsgar the Wanderer : 00083D99","Tandil : 00039250","Tasius Tragus : 00019A24","Teeba-Ei : 0001360A","Tekla : 00013656","Temba Wide-Arm : 000658D2","Terek : 0001A673","Thadgeir : 0004E5E9","Thaena : 0001C189","Thaer : 0009B7A6","Thief : 000E93D3","Thonar Silver-Blood : 000133BA","Thongvor Silver-Blood : 000133BB","Thonjolf : 0001C181","Thonnir : 000135F2","Thorald Gray-Mane : 0001C241","Thorek : 000341FF","Thorgar : 000AE777","Thoring : 00013621","Threki the Innocent : 00013367","Thrynn : 000D4FDB","Tiber : 00023EF1","Tilma the Haggard : 00013BB6","Tolfdir : 0001C19E","Tonilia : 000B8827","Torbjorn Shatter-Shield : 0001413F","Tormir : 0001403D","Torolf : 00013641","Torom : 0002F442","Torsten Cruel-Sea : 00014136","Torture Victim : 00015D02","Torture Victim : 00015D0E","Torture Victim : 00037A28","Torture Victim : 00037A2C","Torturer : 000B9652","Torturer''s Assistant : 000B9655","Torvar : 0001A6DB","Tova Shatter-Shield : 00014125","Tova Shatter-Shield : 000D2B16","Traveling Dignitary : 00087B9C","Trilf : 00019A1B","Tsavani : 000353C7","Tsun : 0004F828","Tulvur : 00014139","Tuthul : 0001996D","Tynan : 000D6718","Tythis Ulen : 0001337D","Uaile : 000133BC","Uglarz : 000E316F","Ugor : 00019E1A","Ulfberth War-Bear : 00013B9F","Ulfgar the Unending : 000EA71C","Ulfric Stormcloak : 0001414D","Ulundil : 00014141","Umana : 0003B0E3","Umurn : 00013B7E","Una : 000132AC","Unemployed Laborer : 00087B94","Ungrien : 0001337E","Unmid Snow-Shod : 000371D7","Uraccen : 000133BD","Urag gro-Shub : 0001C193","Urchin : 0005224B","Urog : 0001B078","Ursine Guardian : 000E7EA9","Urzoga gra-Shugurz : 000133BE","Uthgerd the Unbroken : 000918E2","Vaermina : 000E16CD","Vald : 00072B04","Valdr : 000411BA","Valga Vinicia : 00013655","Valie : 0003B0E1","Valindor : 0001337F","Vanryth Gatharian : 00029DAF","Vantus Loreius : 0001A6B1","Vantus Loreius : 0007F429","Varnius Junius : 00019A26","Veezara : 0001C3AA","Veezara : 0002E447","Vekel the Man : 00013380","Velehk Sain : 00075C7F","Veren Duleri : 000341FE","Verner Rock-Chucker : 00013665","Vex : 0001CD90","Viarmo : 000132AD","Vigdis Salvius : 000133BF","Vigilance : 0009A7AA","Vigilant Tyranus : 000A733B","Vignar Gray-Mane : 00013BB5","Vilkas : 0001A694","Vilod : 0001363E","Viola Giordano : 00014129","Vipir the Fleet : 0001CD8F","Virkmund : 000135F1","Visiting Noble : 00087B95","Vittoria Vici : 0001327A","Vivienne Onis : 000132AE","Voada : 000133C0","Voice of Boethiah : 0004D91B","Voice of Namira : 0008797F","Voldsea Giryon : 0001411C","Vorstag : 000B997F","Vulthuryol : 0007EAC7","Vulwulf Snow-Shod : 00013381","Wary Outlaw : 00087B8D","Watches-The-Roots : 0004C735","Watches-The-Roots : 0004C757","Weylin : 0009C8AA","Wilhelm : 000136BB","Willem : 000661AF","Wilmuth : 0009CCD9","Wood Cutter : 0002236C","Wounded Soldier : 000D74F5","Wujeeta : 00013382","Wulfgar : 0002C6CA","Wuunferth the Unliving : 00014146","Wylandriah : 00019DEF","Xander : 000AF523","Yag gra-Gortwog : 0003B0E5","Yatul : 0001B077","Yisra : 000D4FF9","Yngvar the Singer : 000133C1","Ysgramor : 00023EED","Ysgramor : 00098BD1","Ysolda : 00013BAB","Zaria : 0003A19A","Zaynabi : 0001B1D0","Ohdahviing : 000F6850"';
end;



end.
