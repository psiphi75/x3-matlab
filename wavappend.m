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

function    wh = wavappend(wh,x)

%     wavappend(wh,x)
%     Add audio data x to an open wav file. Use wavopen.m to create
%     the file and obtain the wav handle wh.
%     x is a multichannel audio matrix with values between -1 and 1.
%     The number of columns in x must be equal to the number of channels
%     declared in the call to wavopen. There can be any number of samples
%     in x.
%
%     Returns:
%     wh is the wav handle including the updated sample count.
%
%     This function only supports 16 bit data.
%
%     GNU General Public License, see README.txt
%     mark johnson, SOI / Univ. St. Andrews
%     mj26@st-andrews.ac.uk
%     November 2012

if size(x,2)~=wh.nch,
   fprintf(' Data must have %d channels\n',wh.nch) ;
   return
end

ns = size(x,1) ;
fwrite(wh.fid,round(32768*reshape(x',ns*wh.nch,1)),'short') ;
wh.ns = wh.ns+ns ;
