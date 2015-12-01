program Spusk_Sputnika;

uses
  Vcl.Forms,
  UI_unit in 'UI_unit.pas' {Main_Window},
  uKepler_Conversation in 'uKepler_Conversation.pas',
  uConstants in 'uConstants.pas',
  uGEO_Potential in 'uGEO_Potential.pas',
  uSputnik in 'uSputnik.pas',
  uIntegrator in 'uIntegrator.pas',
  uAtmosphericDrag in 'uAtmosphericDrag.pas',
  uCreate in 'uCreate.pas',
  uTime in 'uTime.pas',
  uFunctions in 'uFunctions.pas',
  uMatrix_Operations in 'uMatrix_Operations.pas',
  uMatrix_Conversation in 'uMatrix_Conversation.pas',
  uTest_Module in 'uTest_Module.pas',
  uSunPressure in 'uSunPressure.pas',
  uEpheremides in 'uEpheremides.pas',
  uPrecNut in 'uPrecNut.pas',
  uStarTime in 'uStarTime.pas',
  uTLE_conversation in 'uTLE_conversation.pas',
  uControl in 'uControl.pas',
  uPrecNut_InitialParam in 'uPrecNut_InitialParam.pas',
  uTypes in 'uTypes.pas',
  uEpheremides_new in 'uEpheremides_new.pas',
  uAtmospericDrag_Coeff in 'uAtmospericDrag_Coeff.pas',
  uGauss in 'uGauss.pas',
  uGEO_Potential_new in 'uGEO_Potential_new.pas',
  uMatrix in 'uMatrix.pas',
  uModel in 'uModel.pas',
  uDormanPrince in 'uDormanPrince.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;

end.
