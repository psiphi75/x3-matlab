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

function    n = fwrite_short(fid,p)

%    n = fwrite_short(fid,p)
%    Trick to avoid endian issues when writing 16-bit numbers
%    to a binary file in Matlab
%

p = [floor(p'/256);rem(p',256)] ;
fwrite(fid,p(:),'uchar') ;
return
