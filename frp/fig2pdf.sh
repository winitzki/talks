#!/bin/sh 
###############################################################################
#                                                                             #
# Converts a .fig file into an .eps file suitable for including               #
# in a latex document via, say, the graphicx package.                         #
#                                                                             #
# This program typesets any latex commands (as "specially flagged" text)      #
# within foo.fig                                                              #
#                                                                             #
# The argument of this program is the name of                                 #
# a fig file "foo.fig", or simply "foo"                                       #
#                                                                             #
# The probgram looks for an optional file foo.preamble in the same            #
# directory as foo.fig, where additional                                      #
# latex preamble commands such as "\newcommand{\es}{\emptyset}" can be        #
# placed.                                                                     #
# This script relies on fig2dev, latex, dvips, ps2eps, and eps2pdf            #
# These are common in UNIX (LINUX, MAC OS X)                                  #
# It assumes your temp directory is /tmp, but it cleans up after itself.      #
#                                                                             #
# Error handling and help have not been implemented.                          #
#                                                                             #
# This was written by Luis Goddyn August 2004                                 #
# and updated November 2011.                                                  #
# It may be freely distributed or modified with comment                       #
# provided this header remains intact.                                        #
#                                                                             #
# It comes without any guarantee, warantee etc.                               #
#                                                                             #
###############################################################################

#echo "Starting shell script [$0]."

if [ $# -eq 0 ]
then
 echo "Syntax: $0 file.fig, or simply $0 file"
 exit 1
fi

#extract file base filename if .fig extension used
fileBase=`echo $1 | sed 's/\.fig$//'`
fileName=${fileBase}.fig
curDir=`pwd`

if [ ! -f $fileName ]
then
    echo "Input file [${fileName}] not found - Aborting"
    exit 1
fi

tempBase="/tmp/a_$$_fig2pdf"

echo "Temporary files start with ${tempBase}"

#if [ -f ${fileBase}.eps ]
if [ -f ${fileBase}.pdf ]
then
# echo "Output file [${fileBase}.eps] already exists."
  echo "Output file [${fileBase}.pdf] already exists."
  echo "Okay to overwrite? ( y/n ) : \c"
  read answer
# echo ""
  if [ "$answer" != "y" ] && [ "$answer" != "Y" ] && [ "$answer" != "yes" ] && [ "$answer" != "Yes" ]
  then
    echo "Aborting"
    exit 1
  fi
fi

unset noclobber;

echo "Generating base .ps from .fig"
fig2dev -L pstex ${fileBase}.fig > ${tempBase}.pstex_t

#generate .tex commands from .fig using "pens specification in the .ps file
echo "Generating .tex commands"
fig2dev -L pstex_t -p ${tempBase}.pstex_t ${fileBase}.fig > ${tempBase}.temptex

echo "Generating latex file"
printf '%s\n' '\documentclass{article}'                  >> ${tempBase}.tex
printf '%s\n' '\usepackage{graphicx,epsfig,color}'       >> ${tempBase}.tex
printf '%s\n' '\pagestyle{empty}'                        >> ${tempBase}.tex
if [ -f ${fileBase}.preamble ]
then
  echo "Including preamble commands in [${fileBase}.preamble]"
  printf '%s\n' "\input{${curDir}/${fileBase}.preamble}" >> ${tempBase}.tex
fi
printf '%s\n' '\begin{document}'                         >> ${tempBase}.tex
printf '%s\n' "\input{${tempBase}.temptex}"              >> ${tempBase}.tex
printf '%s\n' '\end{document}'                           >> ${tempBase}.tex

echo "Starting latex"
#(cd /tmp; latex    ${tempBase}.tex ; )
(cd /tmp; latex    ${tempBase}.tex > /dev/null ; )     #Makes things less verbose

echo "Starting dvips"
dvips  -E -q -o ${tempBase}.ps ${tempBase}.dvi 

echo "Starting ps2eps"
#ps2eps  ${tempBase}.ps
ps2eps  -B -l ${tempBase}.ps        #Slightly extends BoundingBox

##The following may be uncommented if you would like a .pdf file made (for pdflatex)
##You should also uncomment the /bin/rm below
##BoundingBox info may be corrupted: See
## http://phaseportrait.blogspot.com/2007/06/bounding-boxes-and-eps-to-pdf.html
##    if you have trouble.
#echo "Starting ps2pdf"
#ps2pdf -dEPSCrop ${tempBase}.eps ${tempBase}.pdf
echo "Starting epstopdf"
epstopdf -outfile=${tempBase}.pdf ${tempBase}.eps

echo "Writing to ${fileBase}.pdf"
#cp ${tempBase}.eps ${fileBase}.eps
#cp ${tempBase}.ps ${fileBase}.ps
cp ${tempBase}.pdf ${fileBase}.pdf

set noclobber;

echo "Cleaning up"
/bin/rm ${tempBase}.temptex ${tempBase}.tex ${tempBase}.pstex_t
/bin/rm ${tempBase}.dvi ${tempBase}.log  ${tempBase}.aux
/bin/rm ${tempBase}.ps
/bin/rm ${tempBase}.eps
/bin/rm ${tempBase}.pdf

