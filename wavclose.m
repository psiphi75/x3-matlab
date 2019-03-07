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

function       wavclose(wh)

%     wavclose(wh)
%     Close out a wav file that was opened using wavopen.m
%
%     GNU General Public License, see README.txt
%     mark johnson, SOI / Univ. St. Andrews
%     mj26@st-andrews.ac.uk
%     November 2012

f = wh.fid ;

% adjust header of output wavfile
databytes = wh.ns*wh.nch*2 ;
riff_size = 36+databytes ;

% Fix RIFF chunk size:
fseek(f,4,'bof') ;                % skip RIFF chunk header
fwrite(f,riff_size,'ulong');      % RIFF chunk size: 4 bytes 

% skip WAVE chunk (4 bytes)
% skip fmt chunk (8+16 bytes)
% skip data chunk header (4 bytes)

% Fix data chunk size
fseek(f,32,'cof') ;
fwrite(f,databytes,'ulong');      % data chunk size: 4 bytes 

% Close file:
fclose(f);
