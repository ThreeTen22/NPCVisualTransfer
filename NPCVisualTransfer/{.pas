{
  New script template, only shows processed records
  Assigning any nonzero value to Result will terminate script
}
unit userscript;
uses mtefunctions;

var
tl,ml,tril,fl, slContainers: TStringList;
iPatch: IInterface;

function Initialize: integer;
begin
	InitGlobals();
	Main();
end;


procedure InitGlobals();
begin
	iPatch := FileSelect('Select Yo Patch');
	tl := TStringList.Create;
	tl.Sorted := true;
	tl.Duplicates := dupIgnore;
	fl := TStringList.Create;
	ml := TStringList.Create;
	ml.Sorted := true;
	ml.Duplicates := dupIgnore;
	tril := TStringList.Create;
	tril.Sorted := true;
	tril.Duplicates := dupIgnore;
	slContainers := TStringList.Create;
	ResourceContainerList(slContainers);
end;

procedure Main();
var
	slTemp: TStringList;
begin
	FilesToSL(fl);
	AddMastersToFile(iPatch, fl,false);
	CreateOverrides('TXST','Textures (RGB/A)','actors',tl);
	CreateOverrides('HDPT','DATA - Flags','1',slTemp);
	GrabNifPaths(GroupBySignature(iPatch, 'HDPT'),ml,tril);
	//GetNifTextures(GroupBySignature(iPatch, 'HDPT'), tl);
	CopyAssetsFromSL('meshes\',ml);
	CopyAssetsFromSL('textures\',tl);
	CopyAssetsFromSL('meshes\',tril);
	OpenExplorerWindow(TempPath);
end;


procedure GrabNifPaths(iGRP: IInterface; sl1, sl2:TStringList);
var
	i,z: Integer;	
	iEle, iSubEle, iCont: IInterface;
	sEV: String;
begin
	for i := 0 to Pred(ElementCount(iGrp)) do begin
		iEle := ElementByIndex(iGrp, i);
		sEV := Lowercase(GetEditValue(ElementByPath(iEle,'Model\MODL')));
		ml.Append(sEV);
		iSubEle := ElementByName(iEle,'Parts');
		for z := 0 to Pred(ElementCount(iSubEle)) do begin
			iCont := ElementByIndex(iSubEle, z);
			sEV := Lowercase(GetEditValue(ElementByIndex(iCont, 1)));
			tril.Append(sEV);
		end;
	end;

end;

procedure FilesToSL(sl:TStringList);
var
	i: Integer;
	iFile: IInterface;
begin
	if not Assigned(sl) then sl := TStringList.Create;
	sl.AddObject(GetFileName(FileByLoadOrder(0)), TObject(FileByLoadOrder(0)));
	for i := 1 to FileCount-1 do begin
		iFile := FileByLoadOrder(i);
		if (HasGroup(iFile, 'HDPT') = true) or (HasGroup(iFile,'TXST') = true) then begin
			sl.AddObject(GetFileName(iFile), TObject(iFile));	
		end;
	end;
end;

procedure CreateOverrides(sSig,sEleName,sMatch:String;sl:TStringList);
var
	i,z:Integer;
	iFile, iGrp, iEle: IInterface;
begin
	for i := Pred(fl.Count) downto 0 do begin
		iFile := ObjectToElement(fl.Objects[i]);
		iGrp := GroupBySignature(iFile, sSig);
		for z := 0 to Pred(ElementCount(iGrp)) do begin
			iEle := ElementByIndex(iGrp,z);
			if CheckEleByEVPos(iEle, sEleName,sMatch,sl) then begin
				wbCopyElementToFile(iEle,iPatch,false,true);
			end;
		end;	
	end;
end;

function CheckEleByEVPos(e: IInterface; sEleName,sPos:String;sl:TStringList): boolean;
var
 r,g: IInterface;
 i: integer;
 rec: String;
 bMesh : Boolean;
begin
	Result := false;
	bMesh := not Assigned(sl); 
	r := ElementByName(e, sEleName);
	for i := 0 to Pred(ElementCount(r)) do begin
	  	if bMesh then g := r else
	  	g := ElementByIndex(r, i);
	  	rec := GetEditValue(g);
	  	AddMessage(rec);
	  	if Pos(lowercase(sPos), lowercase(rec)) = 1 then begin
	   		Result := true;
	   		if bMesh then Exit;
	   		if Result then sl.Append(lowercase(rec));
	  	end;
	end;
end;

procedure CopyRefBySig(e,iFile: IInterface; sig: string);
var
	i: Integer;
	g: IInterface;
begin
	for i := Pred(ReferencedByCount(e)) downto 0 do begin
			g := ReferencedByIndex(e, i);
			if SameText(Signature(g),sig) then
				wbCopyElementToFile(g, iFile,false,true);
	end;
	
end;

procedure CopyAssetsFromSL(sFolder: String; sl:TStringList);
var
	i: Integer;	
begin
	for i := 0 to Pred(sl.Count) do begin
		//AddMessage(ExtractFilePath(sl[i])+ '  '+ ExtractFileName(sl[i]));
		TryToCopy(sFolder+ExtractFilePath(sl[i]),ExtractFileName(sl[i]));
	end;
end;

procedure OpenExplorerWindow(sFilepath: String);
begin
	ShellExecute(0, nil, 'explorer.exe', sFilepath,nil,SW_SHOWNORMAL);
end;

function Finalize: integer;
var
 r: integer;
begin
	tl.free;
	fl.free;
	ml.free;
	tril.free;
	RemoveFilter();
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
    for i := Pred(slRes.Count) downto 0 do begin
      if slContainers.IndexOf(slRes[i]) > -1 then begin
        ForceDirectories(TempPath+filePath);
        Result := slRes[i];  
        Break;
      end;
    end;
    if Pos('.nif', Result) > 0 then begin
    	slRes.Clear;
    	NifTextureList(ResourceOpenData(Result, filePath+fileName), slRes);
    	for i := 0 to Pred(slRes.Count) do begin
    		if Pos('textures/', Lowercase(slRes[i])) <> 1 then 
    			slRes[i] := 'textures/'+slRes[i];
    		tl.Append(slRes[i]);
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

function NormalizePath(value: string; atype: integer): string;
begin
  if value = '' then
    Exit;
  // uncomment to not show errors on full paths
  //if not SameText(Copy(value, 1, 3), 'c:\') then
  if Copy(value, 1, 1) = '\' then
    Delete(value, 1, 1);
  if SameText(Copy(value, 1, 5), 'data\') then
    value := Copy(value, 6, Length(value));
  if (atype = atMesh) and not (Copy(value, 1, 7) = 'meshes\') then
    value := 'meshes\' + value
  else if (atype = atAnimation) and not (Copy(value, 1, 7) = 'meshes\') then
    value := 'meshes\' + value
  else if (atype = atTexture) and not (Copy(value, 1, 9) = 'textures\') then
    value := 'textures\' + value
  else if (atype = atSound) and not (Copy(value, 1, 6) = 'sound\') then
    value := 'sound\' + value
  else if (atype = atMusic) and not (Copy(value, 1, 6) = 'music\') then
    value := 'music\' + value
  else if (atype = atSpeedTree) and not (Copy(value, 1, 6) = 'trees\') then
    value := 'trees\' + value;
  Result := value;
end;

procedure ProcessMeshTextures(aMesh, aContainer, aDescr: string);
var
  s: string;
  i: integer;
  slTextures : TStringList;
begin
	slTextures := TStringList.Creae;
  // suppress possible errors for invalid meshes
  try
    NifTextureList(ResourceOpenData(aContainer, aMesh), slTextures);
  except on E: Exception do
    AddMessage('NIF: ' + E.Message + ' ' + aMesh);
  end;
  slTextures.AddStrings(sl); // remove duplicates
  for i := 0 to Pred(slTextures.Count) do begin
    s := NormalizePath(LowerCase(slTextures[i]), atTexture);
    ProcessResource(s, 'Texture for ' + aDescr + ': ' + aMesh, atTexture);
  end;
  slTextures.Clear;
end;

end.
