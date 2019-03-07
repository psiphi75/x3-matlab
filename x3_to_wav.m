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

function    x3_to_wav(fname)

%     x3_to_wav(fname)
%     Uncompress an x3a format audio archive. A WAV format audio 
%     file and an XML metadata file are generated.
%     fname is the name of the x3a file to uncompress including the
%     suffix. If it is not in the current working directory,
%     include a relative or absolute path. The uncompressed files will
%     be written to the same directory and will have the same name
%     but with an .xml and a .wav suffix (unless a different suffix is
%     specified in the configuration - see x3new.m.
%
%     Warning: uncompression in Matlab is not fast! Large archives
%     will take many minutes to uncompress. Use the C-code functions
%     for better performance.
%
%     GNU General Public License, see README.txt
%     mark johnson, SOI / Univ. St. Andrews
%     mj26@st-andrews.ac.uk
%     November 2012

% open the archive, read the configuration frame, and setup output files
[fin,xid,wav] = x3open(fname) ;

% get the size of the input file so that we can report progress
pp = ftell(fin) ;
fseek(fin,0,'eof') ;
N = ftell(fin) ;
fseek(fin,pp,'bof') ;
bcnt = 0 ;

% read the rest of the archive frame-by-frame
while 1,
   fprintf(' %d%% complete\n',round(bcnt/N*100)) ;
   [hdr,data] = getnextframe(fin) ;       % read in the next frame
   if isempty(hdr),                       % check if we are at the end of the file
      break
   end

   [x,id,T] = x3decodeframe(hdr,data) ;   % decode the frame

   if id==0,   % if this is metadata, add it to the xml file
      % ought to parse the metadata as well in case new configurations are
      % declared. For simplicity, we just store it.
      fprintf(xid,[x '\n']) ;
   else
      % otherwise, append the decoded audio data to the wav file.
      % The id indicates which wav structure to use.
      wav{id} = wavappend(wav{id},x/32768) ;
   end

   bcnt = bcnt+length(data)*2+20 ;
end

% close the wav files
for k=1:length(wav),
   if ~isempty(wav{k}),
      wavclose(wav{k}) ;
   end
end

% close the metadata file
fprintf(xid,'</X3A>\n') ;
fclose(xid) ;

% close the input file
fclose(fin) ;

