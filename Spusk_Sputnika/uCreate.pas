unit uCreate;

interface

uses
  uAtmosphericDrag, uIntegrator, uGEO_Potential, uGEO_Potential_new,
  uSunPressure, {uEpheremides,} uEpheremides_new, uSputnik, uControl;

procedure CreateObjects;
procedure DestroyObjects;

implementation

procedure CreateObjects;
begin
  Everhart := TEverhart.Create;
  AtmosphericDrag := TAtmosphericDrag.Create;
  GEO_Potential := TGEO_Potential_new.Create;
  SunPressure := TSunPressure.Create;
  //Epheremides := TEpheremides.Create;
	EphCreation(3); // создаём объект эферемид для получения координат Земли
  Sputnik := TSputnik.Create;
  Control := TControl.Create;
end;

procedure DestroyObjects;
begin
  Everhart.Destroy;
  AtmosphericDrag.Destroy;
  GEO_Potential.Destroy;
  SunPressure.Destroy;
  //Epheremides.Destroy;
  Earth_Moon.Destroy;
  Sputnik.Destroy;
  Control.Destroy;
end;

initialization

CreateObjects;

finalization

DestroyObjects;

end.
