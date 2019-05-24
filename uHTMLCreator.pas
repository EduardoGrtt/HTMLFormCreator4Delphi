unit uHTMLCreator;

interface

uses
  Classes, Generics.Collections;

type
  {Criar classes para cada Type}
  THTMLInputTypeEnum = (itButton, itCheckBox, itColor, itDate, itDateTime, itEmail, itFile, itHidden, itImage, itMonth, itNumber,
    itPassword, itRadio, itRange, itReset, itSearch, itSubmit, itTel, itText, itTime, itUrl, itWeek);
  THTMLInputTypeHelper = record helper for THTMLInputTypeEnum
  strict private const
    arInputTypesNames: array[THTMLInputTypeEnum] of string = ('button','checkbox','color','date','datetime-local','email','file',
      'hidden','image','month','number','password','radio','range','reset','search','submit','tel','text','time','url','week');
  public
    function GetName: string;
  end;

  THTMLInputItem = class
    ID: string;
    &Label: string;
    Name: string;
    &Type: THTMLInputTypeEnum;
    Value: string;
    function Generate: string;
  end;

  THTMLInputGroup = class
  private
    FInputs: TObjectList<THTMLInputItem>;
  public
    var Caption: string;
    property Inputs: TObjectList<THTMLInputItem> read FInputs;
    function Generate: string;
    constructor Create;
    destructor Destroy; override;
  end;

  THTMLFormCreator = class
  private
    FKeys: TList<string>;
    FGroups: TObjectDictionary<string,THTMLInputGroup>;
  public
    var Title: string;
    var Subtitle: string;
    var Action: string;
    procedure AddGroup(_AGroup: THTMLInputGroup);
    procedure AddOrSetGroup(_AGroup: THTMLInputGroup);
    function FindGroup(_ACaption: string): THTMLInputGroup;
    function TryFindGroup(_ACaption: string; out _AGroup: THTMLInputGroup): Boolean;
//    property Groups: TObjectList<THTMLInputGroup> read FGroups;
    function Generate: string;
    constructor Create;
    destructor Destroy; override;
  end;

implementation

uses
  System.SysUtils;

{ THTMLCreator }

procedure THTMLFormCreator.AddGroup(_AGroup: THTMLInputGroup);
begin
  if FGroups.ContainsKey(_AGroup.Caption) then
    raise Exception.Create('Error Message');

  FKeys.Add(_AGroup.Caption);
  FGroups.Add(_AGroup.Caption, _AGroup);
end;

procedure THTMLFormCreator.AddOrSetGroup(_AGroup: THTMLInputGroup);
begin
  if not FGroups.ContainsKey(_AGroup.Caption) then
    FKeys.Add(_AGroup.Caption);
  FGroups.AddOrSetValue(_AGroup.Caption, _AGroup);
end;

constructor THTMLFormCreator.Create;
begin
  FKeys := TList<string>.Create;
  FGroups := TObjectDictionary<string, THTMLInputGroup>.Create;
end;

destructor THTMLFormCreator.Destroy;
begin
  FKeys.Free;
  FGroups.Free;
  inherited;
end;

function THTMLFormCreator.FindGroup(_ACaption: string): THTMLInputGroup;
begin
  Result := nil;
  if FGroups.ContainsKey(_ACaption) then
    Result := FGroups.Items[_ACaption];
end;

function THTMLFormCreator.Generate: string;
var
  AHTML, AKey: string;
begin
  AHTML := '';
  for AKey in FKeys do
  begin
    if FGroups.ContainsKey(AKey) then
    begin
      AHTML := AHTML + FGroups.Items[AKey].Generate;
    end;
  end;

  Result :=  '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">' +
            '<html>' +
            '  <head>' +
            Format('    <title>%s</title>', [Title]) +
            '  </head>' +
            '  <style>' +
            '    table {border: 1px solid black; width:40%;}' +
            '    th {background-color: DodgerBlue; color: white; height: 30px;text-align: center}' +
            '    tr {text-align: center;}' +
            '    tr:nth-child(even) {background-color: #F2F2F2;}' +
            '    tr:hover {background-color: LightGray;}' +
            '    .submitbutton {border-radius: 8px; background-color: DodgerBlue; padding: 10px; width: 12em; color: white;font-weight: bold}' +
            '  </style>' +
            '  <body>' +
            '    <div align="center">' +
            Format('    <h1>%s</h1>', [Title]) +
            '    <h2>Configurações</h2>' +
            '    <form name="content" method="post" action="' + Action + '" >' +
            AHTML +
            Format('<center><input type="%s" class="submitbutton" value="Submit"/></center>',[itSubmit.GetName]) +
            '    </form>' +
            '    </div>' +
            '  </body>' +
            '</html>';
end;

function THTMLFormCreator.TryFindGroup(_ACaption: string; out _AGroup: THTMLInputGroup): Boolean;
begin
  _AGroup := FindGroup(_ACaption);
  Result := (_AGroup <> nil);
end;

{ THTMLInputGroup }

constructor THTMLInputGroup.Create;
begin
  FInputs := TObjectList<THTMLInputItem>.Create;
end;

destructor THTMLInputGroup.Destroy;
begin
  FInputs.Free;
  inherited;
end;

function THTMLInputGroup.Generate: string;
var
  AInput: THTMLInputItem;
begin
  Result := '<table>';
  Result := Result + Format('<tr><th colspan="2">%s</th></tr>', [Caption]);
  for AInput in FInputs do
  begin
    Result := Result + AInput.Generate;
  end;
  Result := Result + '<tr></tr>';
  Result := Result + '</table>';
  Result := Result + '<br/>';
end;

{ THTMLInputTypeHelper }

function THTMLInputTypeHelper.GetName: string;
begin
  Result :=  arInputTypesNames[Self];
end;

{ THTMLInputItem }

function THTMLInputItem.Generate: string;
var
  AValue: string;
begin
  AValue := Value;
  case &Type of
    itCheckBox:
      begin
        if StrToIntDef(AValue, 0) = 0 then
          AValue := ''
        else
          AValue := 'checked="checked"';
      end;
    itPassword:
      begin
        AValue := '';
      end
  else
    AValue := Format('value="%s"', [AValue]);
  end;
  Result :=
    Format('<tr><td><label for="%s">%s:</label></td><td><input id="%s" name="%s" type="%s" %s/></td></tr>',
    [ID, &Label, ID, Name, &Type.GetName, AValue]);
end;

end.
