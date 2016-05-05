/**
 * @file
 * @brief MATLAB interface for polygon triangulation using GPC library.
 * @author Joan Pau Beltran  <joanpau.beltran@socib.cat>
 *
 *  Copyright (C) 2013-2016
 *  ICTS SOCIB - Servei d'observacio i prediccio costaner de les Illes Balears.
 *  <http://www.socib.es>
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * This file implements an interface to allow polygon triangulation from MATLAB 
 * using the function GPC_POLYGON_TO_TRISTRIP provided by the GPC library.
 *
 * The General Polygon Clipper library is a C library for boolean operations on 
 * polygons written by Alan Murta at the University of Manchester. It also 
 * provides a triangulation function decomposing a polygon into triangle strips.
 * The official web site of the library is:
 *   <http://www.cs.man.ac.uk/~amurta/software/index.html#gpc>
 * 
 * On Debian based systems, the package ligpcl-dev in the non-free section of
 * the official repositories provides the development files for the GPC library.
 * The mex file may be built with the command:
 *   mex -lgpcl poly2tri.c
 *
 * Alternatively, it is possible to build the mex file using the GPC sources 
 * directly, extracting the GPC sources downloaded from the official web site 
 * to a directory called 'gpcl' in the same directory than the mex file source.
 * Please note that in this case mex file and library sources are compiled 
 * together. Hence, the resulting binary might be slightly bigger.
 * The mex file may be built with the command:
 *   mex poly2tri.c gpcl/gpc.c
 */


#include "mex.h"
#include "stddef.h"
#include "gpcl/gpc.h"


void poly2tri_gpc(double** xout, double** yout, size_t* nout,
                  const double* xin, const double* yin, size_t nin)
{
  int i, j, k;
  gpc_polygon p;
  gpc_tristrip t;

  /* Fill in the gpc contour. */
  p.num_contours = 1;
  p.hole = (int*) malloc(1 * sizeof(int));
  p.hole[0] = 0;
  p.contour = (gpc_vertex_list*) malloc(1 * sizeof(gpc_vertex_list));
  p.contour[0].num_vertices = nin;
  p.contour[0].vertex = (gpc_vertex*) malloc(nin * sizeof(gpc_vertex));
  for (i = 0; i < nin; i++)
  {
    p.contour[0].vertex[i].x = xin[i];
    p.contour[0].vertex[i].y = yin[i];
  }

  /* Convert the polygon to a list of triangle strips. */
  t.num_strips = 0;
  t.strip = NULL;
  gpc_polygon_to_tristrip(&p, &t);

  /* Take out the triangles from the triangle strips. */
  *nout = 0;
  for (i = 0; i < t.num_strips; i++)
    *nout += t.strip[i].num_vertices - 2;
  *xout = (double*) mxMalloc(*nout * 3 * sizeof(double));
  *yout = (double*) mxMalloc(*nout * 3 * sizeof(double));
  for (k = 0, i = 0; i < t.num_strips; i++)
    for (j = 2; j < t.strip[i].num_vertices; j++)
    {
      (*xout)[k]   = t.strip[i].vertex[j-2].x;
      (*yout)[k++] = t.strip[i].vertex[j-2].y;
      (*xout)[k]   = t.strip[i].vertex[j-1].x;
      (*yout)[k++] = t.strip[i].vertex[j-1].y;
      (*xout)[k]   = t.strip[i].vertex[j].x;
      (*yout)[k++] = t.strip[i].vertex[j].y;
    }


  /* Free the gpc polygon and triangle strip. */
  gpc_free_tristrip(&t);
  gpc_free_polygon(&p);
}


void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[] )
{
  double *xin, *yin, *xout, *yout;
  size_t nin, nout;

  /* Check for proper number of arguments. */
  if (nrhs!=2)
    mexErrMsgTxt("Two inputs required.");
  if (nlhs>2)
    mexErrMsgTxt("Too many output arguments.");

  /* Check for matching dimensions. */
  if ( mxGetM(prhs[0]) != mxGetM(prhs[1]) || 
       mxGetN(prhs[0]) != mxGetN(prhs[1]) )
    mexErrMsgTxt("Inputs must have the same dimensions.");

  /* Check for proper numeric class and dimensions. */
  if ( !mxIsDouble(prhs[0]) || mxIsComplex(prhs[0]) ||
       !mxIsDouble(prhs[0]) || mxIsComplex(prhs[0]) ||
       ( mxGetM(prhs[0]) != 1 && mxGetN(prhs[0]) != 1 ) )
    mexErrMsgTxt("Inputs must be double non complex vectors.");

  /* Assign pointers to corresponding inputs. */
  nin = mxGetNumberOfElements(prhs[0]);
  xin = mxGetPr(prhs[0]);
  yin = mxGetPr(prhs[1]);

  /* Call to triangulation function based on gpc. */
  xout = NULL;
  yout = NULL;
  nout = 0;
  poly2tri_gpc(&xout, &yout, &nout, xin, yin, nin);

  /* Assign pointers to corresponding outputs. */
  if (nlhs > 0)
  {
    plhs[0] = mxCreateNumericMatrix(0, 0, mxDOUBLE_CLASS, mxREAL);
    mxSetM(plhs[0], 3);
    mxSetN(plhs[0], nout);
    mxSetPr(plhs[0], xout);
  }
  if (nlhs > 1)
  {
    plhs[1] = mxCreateNumericMatrix(0, 0, mxDOUBLE_CLASS, mxREAL);
    mxSetM(plhs[1], 3);
    mxSetN(plhs[1], nout);
    mxSetPr(plhs[1], yout);
  }
}
