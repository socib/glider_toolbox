/**
 * @file
 * @brief MATLAB interface to get POSIX time using standard C time functions.
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
 * This file implements a method to get the current system POSIX time in MATLAB,
 * assuming a POSIX compilant version of the standard C libraries.
 * 
 * The corresponding mex file may be built with the command:
 *   mex posixtime.c
 */


#include "mex.h"
#include "time.h"


void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[] )
{
  time_t t;

  /* Check for proper number of arguments. */
  if (nrhs!=0)
    mexErrMsgTxt("Zero inputs required.");
  if (nlhs>1)
    mexErrMsgTxt("Too many output arguments.");

  /* Get current POSIX time. */
  time(&t);

  /* Assign pointers to corresponding outputs. */
  plhs[0] = mxCreateDoubleScalar((double) t);
}

