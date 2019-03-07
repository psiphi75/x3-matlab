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

function    [fin,xid,wav] = x3open(fname)

%     [fin,xid,wav] = x3open(fname)
%     Open an X3 archive file called fname and extract the
%     initial metadata.
%     fname is a string containing the filename including suffix.
%     An XML file with the same name and an .xml suffix will be 
%     generated in the same directory. A WAV file for each audio
%     source declared in the archive will also be created. The file
%     name will be the same as the X3 archive but with a trailing 'u'
%     to avoid over-writting the original WAV files used to create the
%     archive. The suffix of the wav file will be .wav unless a different
%     suffix was listed in the configuration.
%
%     Returns:
%     fin is a file handle for the x3 archive file (open for read). 
%     xid is a handle for an xml file which will contain the extracted metadata.
%     wav is a cell array of wav file structures, one for each audio
%      configuration with FTYPE='wav' in the archive.
%
%     GNU General Public License, see README.txt
%     mark johnson, SOI / Univ. St. Andrews
%     mj26@st-andrews.ac.uk
%     November 2012

xid = [] ; wav = {} ;
fin = fopen(fname,'r') ;
if fin<=0,
   fprintf(' Unable to open file %s for reading\n',fname) ;
   return
end

% check the 64 bit file header
H = 'X3ARCHIV' ;
h = fread(fin,8,'uchar') ;
if strcmp(h,H),
   fprintf(' Bad file header: not a valid X3A archive file\n') ;
   fclose(fin) ;
   return
end

% The first frame must be a metadata frame describing the
% data types that will be in the file. Read in the first frame
% and try to parse the XML.

[hdr,data] = getnextframe(fin) ;
[s,id,T] = x3decodeframe(hdr,data) ;
if id~=0,
   fprintf(' Error: first frame is not a metadata frame\n') ;
   return
end

% add an encapsulating field to the metadata
s = ['<X3A>' s] ;

% terminate the xml message to make it complete and then parse it
x = readx3xml([s '</X3A>']) ;          % convert xml to a structure of strings
[xid,wav] = parsemetadata(x,fname) ;   % extract information from the structure

% save the metadata to the open xml file
fprintf(xid,s) ;
return
