unit uGraph;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, VclTee.TeeGDIPlus, VCLTee.TeEngine,
  VCLTee.TeeSurfa, VCLTee.TeePoin3, Vcl.ExtCtrls, VCLTee.TeeProcs, VCLTee.Chart,
  VCLTee.DBChart, Data.DB, Data.Win.ADODB;

type
  TFormGraph = class(TForm)
    ADOQuery2: TADOQuery;
    DBChart1: TDBChart;
    Series1: TPoint3DSeries;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormGraph: TFormGraph;

implementation

{$R *.dfm}

end.
