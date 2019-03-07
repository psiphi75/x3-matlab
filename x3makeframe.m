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

function    [p,ntypes] = x3makeframe(x,id,T)

%     [p,ntypes] = x3makeframe(x,id,T)
%     Compress multi-channel audio data in x into an X3-format
%     packed data frame.
%     x is a vector or matrix of integers with values between -32768 and 32767.
%     id is an optional source identifier (8 bits). Any value between 1 and
%      255 can be used. id=0 is reserved for metadata.
%     T is an optional time code (4x16 bit words).
%
%     Returns:
%     p is a vector of packed 16-bit words that contains the frame header
%      followed by blocks of x3-encoded data.
%     ntypes is a vector of code usage as defined in x3compress.m
%
%     This routine follows the definition for X3 data frames in
%     Johnson, Hurst and Partan, JASA 133(3):1387-1398, 2013.
%     The 20-byte frame header format is as follows:
%        Field:   Function:                           Size:
%        KEY      key word (30771 or 'x3' in ASCII)   16 bits
%        ID       source identifier                   8 bits
%        NCH      number of channels                  8 bits
%        NSAMP    samples per channel                 16 bits
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

if nargin<2 || isempty(id),
   id = 1 ;
end

if nargin<3 || isempty(T),
   T = zeros(4,1) ;
end

[nsamples,nch] = size(x) ;
id = min(max(id,0),255) ;
idnch = id*256 + nch ;
[p,last,ntypes] = x3compress(x) ;

% Check compressed data is not too large for a frame. Frames shouldn't 
% have more than a few thousand samples because the CRC-16 won't protect 
% more than this. The absolute limit on frame size is 65536 bytes.
if length(p) >= 32768-32,
   fprintf(' X3 frame size exceeded\n') ;
   return
end

% FIXME: should be "hdr = [KEY;idnch;length(p)*2;nsamples;T] ;"
hdr = [KEY;idnch;nsamples;length(p)*2;T] ;
hdr(9) = crc16(hdr) ;
hdr(10) = crc16(p) ;
p = [hdr;p] ;

% report compression performance
%fprintf('\nBlock allocation:\t%d Rice-0, %d Rice-1, %d Rice-3, %d BFP, %d PASS\n', ntypes) ;
%fprintf('Compression factor:\t%3.2f\n\n', nsamples*nch/length(p)) ;
