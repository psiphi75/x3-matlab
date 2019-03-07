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

function		[x,last] = x3uncompress(p,nsamples,nchs,N,last)

%     [x,last] = x3uncompress(p,nsamples,nchs,N,last)
%     Uncompress an X3 compressed data frame to audio signal x.
%     p is a vector of packed binary.
%     nsamples is the number of samples per channel in p.
%     nchs is the number of channels of data in the frame.
%     N is the block length used in the coder. It must be between 4 and 32.
%      Default value is 20. Make sure this matches the setting used in the 
%      compressor.
%     last is the last sample for each channel, i.e., at the end of the
%      frame. If last is not specified, last=0 for each channel ;
%
%     returns:
%	   x is a vector or matrix of integers.
%     last is the final sample for each channel to pass to the next
%      call of this function for decoding sequential frames.
%
%     This routine follows the definition for X3 data frames in
%     Johnson, Hurst and Partan, JASA 133(3):1387-1398, 2013.
%
%     GNU General Public License, see README.txt
%     mark johnson, SOI / Univ. St. Andrews
%     mj26@st-andrews.ac.uk
%     November 2012

if nargin<4 || isempty(N),
   N = 20 ;                % X3 block size
end

if nargin<5,
   last = zeros(1,nchs) ;
end

% initialize unpacker and code
[w,p] = bunpackv(p,0,0) ;
codes = [0,1,3] ;          % rice code types to use
for k=1:length(codes),
   code(k) = makericecode(codes(k)) ;         
end

% make space for output vector
x = zeros(nsamples,nchs) ;

% decode the first sample for each channel - these are always 
% pass-through coded.
[xx,p] = bunpackv(p,nchs,16) ;
x(1,:) = fixsign(xx,16)' ;
ok = 1 ;          % output sample pointer
nsamples = nsamples-1 ;

% now unpack each block
while nsamples>0,
   nbl = min(N,nsamples) ;
   for k=1:nchs,
      [xx,p,nbl] = x3unpackblock(p,code,x(ok,k),nbl) ;
      if isempty(xx),
         if k>1,
            fprintf(' Unexpected block-length header\n') ;
            return
         end
         [xx,p,nbl] = x3unpackblock(p,code,x(ok,k),nbl) ;
      end
      x(ok+(1:nbl),k) = xx ;
   end
   ok = ok+nbl ;
   nsamples = nsamples - N ;
end

last = x(end,:) ;
return


function    [xx,pp,nbl] = x3unpackblock(pp,code,last,nbl)
%
%  unpack a single block 
%
BFP_XTRA_LEN = 4 ;          % additional bits in BFP header 
[hdr,pp] = bunpackv(pp,1,2) ;	    % get block type bits

if hdr>0,	                      % it is a rice block. hdr is the code number
	[xx,pp] = bunpackrice(pp,nbl,code(hdr)) ;

else	                            % block is a raw or bfp type
	[nb,pp] = bunpackv(pp,1,BFP_XTRA_LEN) ;   % get number of significant bits
	% unpack the block - fixed word length of nb+1
	[xx,pp] = bunpackv(pp,nbl,nb+1) ;
   xx = fixsign(xx,nb+1) ;
   if nb==15,
      return            % no deemphasis on a 16 bit frame
   end
end

% run deemphasis filter - a single integrator
xx = filter(1,[1 -1],xx,last) ;
return


function    x = fixsign(x,nbits)
%
%  sign extend negative numbers
%
kn = find(x>=2^(nbits-1)) ;
x(kn) = x(kn)-2^nbits ;
return
