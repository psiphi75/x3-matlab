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

function    [hdr,data] = getnextframe(fid)

%    [hdr,data] = getnextframe(fid)
%
%

data = [] ;
% read in the 20 byte header and convert to 16-bit
h = fread(fid,20,'uchar') ;
if length(h)<20,  % must be at the end of the file
   hdr = [] ;
   return
end

hdr = h(1:2:end)*256+h(2:2:end) ;

% check the header CRC
if crc16(hdr(1:8))~=hdr(9),
   fprintf(' CRC failure on frame header\n') ;
   % We could try to search for the next valid frame header
   % to recover from the error. Here we just crash out.
   return
end

% read in the data payload
nby = hdr(4) ;
d = fread(fid,nby,'uchar') ;
data = d(1:2:end)*256+d(2:2:end) ;

% check the data CRC
if crc16(data(1:nby/2))~=hdr(10),
   fprintf(' CRC failure on data\n') ;
   return
end
return
