/**
 * @file
 * @brief MATLAB interface to get POSIX time using standard C time functions.
 * @author Joan Pau Beltran
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
  if (nlhs > 0)
    plhs[0] = mxCreateDoubleScalar((double) t);
}

