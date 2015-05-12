procedure DeleteReleventRecords(iNPCToDelete: IInterface);
var
i,s: integer;
ev: string;
iGRUP, iFLST, iFormIDs iElement: IInterface;
begin
  iGRUP := GroupBySignature(PatchFile, 'FLST'):
  for i:= 0 to Pred(ElementCount(iGRUP)) do begin
    iFLST := ElementByIndex(iGRUP, i);
    ev := geev(iFLST,'FormIDs\[0]');
    if ev = HexFormID(iNPCToDelete) then break;
    ev := ''
  end;
  if ev = '' then exit;
  iFormIDs := ElementByIP(iFLST 'FormIDs');
  while ElementCount(iFormIDs > 0) do begin 
    iElement := RemoveByIndex(iFormIDs, 0);
    Remove(iElement);
  end;
  Remove(iFLST);
end;
