unit uCreate;

interface

uses
  uAtmosphericDrag, uIntegrator, uGEO_Potential, uSunPressure, uEpheremides,
  uSputnik, uControl;

procedure CreateObjects;
procedure DestroyObjects;

implementation

procedure CreateObjects;
begin
  Everhart := TEverhart.Create;
  AtmosphericDrag := TAtmosphericDrag.Create;
  GEO_Potential := TGEO_Potential.Create;
  SunPressure := TSunPressure.Create;
  Epheremides := TEpheremides.Create;
  Sputnik := TSputnik.Create;
  Control := TControl.Create;
end;

procedure DestroyObjects;
begin
  Everhart.Destroy;
  AtmosphericDrag.Destroy;
  GEO_Potential.Destroy;
  SunPressure.Destroy;
  Epheremides.Destroy;
  Sputnik.Destroy;
  Control.Destroy;
end;

initialization

CreateObjects;

finalization

DestroyObjects;

end.
