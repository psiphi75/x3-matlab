%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                      %
% Matlab implementation of the X3 lossless audio compression protocol. %
%                                                                      %
% Copyright (C) 2012,2013 Mark Johnson                                 %
%                                                                      %
% This program is free software; you can redistribute it and/or modify %
% it under the terms of the GNU General Public License as published by %
% the Free Software Foundation, either version 3 of the License, or    %
% (at your option) any later version.                                  %
%                                                                      %
% This program is distributed in the hope that it will be useful,      %
% but WITHOUT ANY WARRANTY; without even the implied warranty of       %
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the        %
% GNU General Public License for more details.                         %
%                                                                      %
% You should have received a copy of the GNU General Public License    %
% along with this program.  If not, see <http://www.gnu.org/licenses/>.%
%                                                                      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function    wh = wavopen(fname,fs,nch)

%     wh = wavopen(fname,fs,nch)
%     Generate a new wav format file called fname.
%     fs is the sampling rate for the file.
%
%     Returns:
%     wh is a structure containing the file handle
%     and a cumulative sample count which will be used
%     to close the file.
%
%     This is a quick hack relying on the Matlab wavwrite
%     to create the base file. Only 16-bit wav files are
%     supported.
%
%     GNU General Public License, see README.txt
%     mark johnson, SOI / Univ. St. Andrews
%     mj26@st-andrews.ac.uk
%     November 2012

% create a wav file by writing some dummy data
wavwrite(zeros(10,nch),fs,16,fname) ;
wh.fid = fopen(fname,'r+','l') ;

% move file cursor back to the start of the data chunk
fseek(wh.fid,-10*2*nch,'eof') ;

wh.nch = nch ;
wh.ns = 0 ;
