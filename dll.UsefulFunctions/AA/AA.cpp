#include "stdafx.h"
#include "aaplus\AA+.h"

typedef CAAElliptical *EllipticalHandle;

// define a macro for the calling convention and export type
#define EXPORTCALL /*__declspec(dllexport)*/ __stdcall

struct ObjectElem
{
	double a;
	double e;
	double i;
	double w;
	double omega;
	double JDEquinox;
	double T;
};

struct ObjectDetails
{
	double CoordinateEquatorial[3];
	double CoordinateEcliptical[3];
	double elments[12];
	/*
		0	HeliocentricEclipticLongitude; 
		1	HeliocentricEclipticLatitude;
		2	TrueGeocentricRA;
		3	TrueGeocentricDeclination;
		4	TrueGeocentricDistance;	+
		5	TrueGeocentricLightTime;
		6	AstrometricGeocentricRA;
		7	AstrometricGeocentricDeclination;
		8	AstrometricGeocentricDistance;
		9	AstrometricGeocentricLightTime;
		10	Elongation;
		11	PhaseAngle;
	*/
};

extern "C"
{

	ObjectDetails EXPORTCALL EllipticalCalculate(EllipticalHandle handle,
		double JD, ObjectElem elements, bool bHighPrecision)
	{
		CAAEllipticalObjectElements CAAObjectElem;
		CAAObjectElem.a = elements.a;
		CAAObjectElem.e = elements.e;
		CAAObjectElem.i = elements.i;
		CAAObjectElem.w = elements.w;
		CAAObjectElem.omega = elements.omega;
		CAAObjectElem.JDEquinox = elements.JDEquinox;
		CAAObjectElem.T = elements.T;

		CAAEllipticalObjectDetails ResTemp;
		ResTemp = CAAElliptical::Calculate(JD, CAAObjectElem, bHighPrecision);

		ObjectDetails Res;
		Res.CoordinateEquatorial[0] = ResTemp.HeliocentricRectangularEquatorial.X;
		Res.CoordinateEquatorial[1] = ResTemp.HeliocentricRectangularEquatorial.Y;
		Res.CoordinateEquatorial[2] = ResTemp.HeliocentricRectangularEquatorial.Z;

		Res.CoordinateEcliptical[0] = ResTemp.HeliocentricRectangularEcliptical.X;
		Res.CoordinateEcliptical[1] = ResTemp.HeliocentricRectangularEcliptical.Y;
		Res.CoordinateEcliptical[2] = ResTemp.HeliocentricRectangularEcliptical.Z;

		Res.elments[4] = ResTemp.TrueGeocentricDistance;

		return Res;

	}

} // extern "C"

/*
	CAAEllipticalObjectElements elements;
	elements.a = 2.2091404;
	elements.e = 0.8502196;
	elements.i = 11.94524;
	elements.omega = 334.75006;
	elements.w = 186.23352;
	elements.T = 2448192.5 + 0.54502;
	elements.JDEquinox = 2451544.5;
	CAAEllipticalObjectDetails details = CAAElliptical::Calculate(2448170.5, elements, false);
*/