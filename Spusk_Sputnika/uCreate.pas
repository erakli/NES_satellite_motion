unit uCreate;

interface

uses
  uAtmosphericDrag, {uIntegrator, uGEO_Potential,} uGEO_Potential_new,
  uSunPressure, {uEpheremides,} uEpheremides_new, uSputnik, uControl,
  uDormanPrince;

procedure CreateObjects;
procedure DestroyObjects;

implementation

procedure CreateObjects;
begin
//  Everhart := TEverhart.Create;
  Integrator := TDormanPrince.Create;
  AtmosphericDrag := TAtmosphericDrag.Create;
  GEO_Potential_new := TGEO_Potential_new.Create;
  SunPressure := TSunPressure.Create;
  //Epheremides := TEpheremides.Create;
	EphCreation(3); // создаём объект эферемид для получения координат Земли
  Control := TControl.Create;

  Sputnik := TSputnik.Create;
end;

procedure DestroyObjects;
begin
//  Everhart.Destroy;
	Integrator.Destroy;
  AtmosphericDrag.Destroy;
  GEO_Potential_new.Destroy;
  SunPressure.Destroy;
  //Epheremides.Destroy;
  Earth_Moon.Destroy;
  Control.Destroy;

  Sputnik.Destroy;
end;

initialization

CreateObjects;

finalization

DestroyObjects;

end.
