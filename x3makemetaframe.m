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

function    p = x3makemetaframe(s,nsamples,T)

%     p = x3makemetaframe(s,nsamplesT)
%     Make a metadata frame for inclusion in an X3-format data file.
%     s is an ASCII string containing metadata text. No parsing is performed
%      on the text so any 8-bit data format is acceptable. XML-encoded text
%      is recommended.
%     nsamples is the number of samples per channel.
%     T is an optional time code (4x16 bit words).
%
%     Returns:
%     p is a vector of packed 16-bit words that contains the frame header
%     followed by the packed text.
%
%     This routine follows the definition for X3 data frames in
%     Johnson, Hurst and Partan, JASA 133(3):1387-1398, 2013.
%     The 20-byte frame header format is as follows:
%        Field:   Function:                           Size:
%        KEY      key word (30771 or 'x3' in ASCII)   16 bits
%        ID       source identifier (0 for metadata)  8 bits
%        NCH      number of channels (0)              8 bits
%        NSAMP    samples per channel (0)             16 bits
%        NBYTE    number of bytes in the data payload 16 bits
%        T        time code                           64 bits
%        CH       CRC on the above header             16 bits
%        CD       CRC on the data payload             16 bits
%
%     GNU General Public License, see README.txt
%     mark johnson, SOI / Univ. St. Andrews
%     mj26@st-andrews.ac.uk
%     November 2012

KEY = 30771 ;        % 'x3' in ASCII
p = [] ;

if nargin<3 || isempty(T),
   T = zeros(4,1) ;
end

% pack the ASCII string into 16-bit words
s = abs(s(:)) ;
if rem(length(s),2)==1,
   s = [s;0] ;
end
p = s(1:2:end)*256 + s(2:2:end) ;

% Check compressed data is not too large for a frame. Frames shouldn't 
% have more than a few thousand samples because the CRC-16 won't protect 
% more than this. The absolute limit on frame size is 65536 bytes.
if length(p) >= 32768-32,
   fprintf(' X3 frame size exceeded\n') ;
   return
end

hdr = [KEY;0;nsamples;length(p)*2;T] ;
hdr(9) = crc16(hdr) ;
hdr(10) = crc16(p) ;
p = [hdr;p] ;
