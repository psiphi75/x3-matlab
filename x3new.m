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

function    fid = x3new(fname,fs)

%     fid = x3new(fname,fs)
%     Create an X3 archive file called fname and store the
%     initial metadata.
%     fname is a string containing the filename (including suffix
%      although '.x3a' is suggested). Files will be written to the
%      current working directory unless an absolute path is included
%      in fname.
%     fs is the sampling rate of the data that will be stored in
%      the file.
%
%     Returns:
%     fid is a file pointer for subsequent writes. 
%
%     This function is based on, and extends the X3 definition in
%     Johnson, Hurst and Partan, JASA 133(3):1387-1398, 2013.
%
%     GNU General Public License, see README.txt
%     mark johnson, SOI / Univ. St. Andrews
%     mj26@st-andrews.ac.uk
%     November 2012

fid = fopen(fname,'w') ;
if fid<=0,
   fprintf(' Unable to open file %s for writing\n',fname) ;
   return
end

% 64 bit file header
H = 'X3ARCHIV' ;
fwrite(fid,H,'uchar') ;

% The first frame must be a metadata frame describing the
% data types that will be in the file. Additional metadata
% frames (and data types) can be added later in the file 
% as needed.

% NOTE: the XML formatting here is deliberately loose. No
% classes are given for field contents and so it is up to the
% code that will decode the fields to decide how to use the
% metadata. This has the advantage of keeping the fields
% simple and easy to generate by an embedded processor.

% start by defining the file format type and the default
% data source i.e., the metadata source with id=0
MD{1} = '<X3ARCH PROG="x3new.m" VERSION="2.0" />' ;
MD{2} = '<CFG ID="0" FTYPE="XML" />' ;

% There can be up to 255 other source types in an X3 archive file.
% Each data source is associated with a different type of data
% and generates a unique output file. This allows multi-rate and
% heterogenous data collection, e.g., simultaneous high and low 
% audio bands, spectral averages, and CTD data.

% Add a CFG statement for each source ID - in this case there is
% only one data source - an X3-encoded WAV file:

% 1. select an ID number (1..255) and indicate the file type to produce
%    when data from this source is encountered.
md{1} = '<CFG ID="1" FTYPE="WAV">' ;

% 2. notify the sampling rate
md{2} = sprintf('<FS UNIT="Hz">%d</FS>',round(fs)) ;

% 3. suffix to give the output file (doesn't have to be 'wav' - this
%    enables multiple audio streams in the same archive.
md{3} = ['<SUFFIX>wav</SUFFIX>'] ;

% 4. notify the codec that is being used and give the parameters
md{4} = '<CODEC TYPE="X3" VERS="2">' ;      % name of the encoder

% 5. list the parameters used by the coder. Change the following 
%    if you use different parameters
md{5} = '<BLKLEN>20</BLKLEN>' ;
md{6} = '<CODES N="4">RICE0,RICE1,RICE3,BFP</CODES>' ;
md{7} = '<FILTER>DIFF</FILTER>' ;
md{8} = '<NBITS>16</NBITS>' ;
md{9} = '<T N="3">3,8,20</T>' ;

% 6. end the codec and cfg fields and append the metadata
md{10} = '</CODEC></CFG>' ;
MD{3} = horzcat(md{:}) ;

% pack the metadata frame and write it to the file
p = x3makemetaframe(horzcat(MD{:}),gettime) ;

% use the following instead of fwrite to avoid matlab endian woes
fwrite_short(fid,p(:)) ;
return
