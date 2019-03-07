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

function		[p,last,ntypes] = x3compress(x,N,T,last)

%     [p,last,ntypes] = x3compress(x,N,T,last)
%     Compress single- or multi-channel audio data in x to an X3 
%     compressed data frame.
%     x is a vector or matrix of integers with values between -32768 and 32767.
%     N is the block length to use. N must be between 4 and 32. Default is 20.
%     T=[T1,T2,T3] are the magnitude thresholds used to select codes. Default
%        values are: 3,8,20.
%     last is the last sample for each channel, i.e., at the end of the
%       frame. If last is not specified, last=0 for each channel.
%
%     Returns:
%	   p is a vector of packed 16-bit binary data.
%     last is the final sample for each channel to pass to the next
%      call of this function for encoding sequential frames.
%     ntypes is a record of what block types have been used. Columns are:
%      ntypes = [rice0,rice1,rice3,bfp,passthrough]
%
%     This routine follows the definition for X3 data frames in
%     Johnson, Hurst and Partan, JASA 133(3):1387-1398, 2013.
%
%     GNU General Public License, see README.txt
%     mark johnson, SOI / Univ. St. Andrews
%     mj26@st-andrews.ac.uk
%     November 2012

% check the input arguments
p = [] ;
if nargin<2 || isempty(N),
   N = 20 ;          % default block size
end

if nargin<3 || isempty(T),
   T = [3,8,20] ;    % default thresholds
end

[nsamples,nchs] = size(x) ;
if nargin<4 || isempty(last),
   last = zeros(1,nchs) ;
end

if size(last,2)~=nchs,
   fprintf(' LAST must have same number of channels as X\n') ;
   return
end

% setup the codes
codes = [0,1,3] ;          % rice code types to use
for k=1:length(codes),
   code(k) = makericecode(codes(k)) ;         
   if T(k)>code(k).offset,
      fprintf(' Threshold %d must be less than or equal to %d\n',k,code{k}.offset) ;
      return
   end
end

x = round(x) ;             % just in case non-integers have been passed

% apply pre-emphasis filter
xf = diff([last;x]) ;

% make space for the coded result vector xc. xc has a row for each sample
% and block header, and has two columns: an integer value and a number of bits.
nblks = ceil((nsamples-1)/N) ;       % number of block headers
xc = zeros(nchs*(nsamples+nblks),2) ;

% keep a record of what block types have been used. Columns of ntypes are:
%     ntypes = [rice0,rice1,rice3,bfp,passthrough]
ntypes = [zeros(1,4) 1] ;

% pack first sample for each channel
xc(1:nchs,1) = twoscomp(x(1,:)',16) ;
xc(1:nchs,2) = 16 ;
kx = 2 ;                % input sample pointer
nsamples = nsamples-1 ;
ok = nchs ;

% Now compress blocks of N samples. The last block may have fewer than N samples.
% Data from multiple channels are interleaved on a block-by-block basis.
while nsamples>0,

   N = min(N,nsamples) ;      % check block size
   for kk=1:nchs,             % pack the data block for each channel
      [cb,nt] = x3block(x(kx+(0:N-1),kk),xf(kx+(0:N-1),kk),T,code) ;
      xc(ok+(1:length(cb)),:) = cb ;
      ntypes(nt) = ntypes(nt)+N ;
      ok = ok+length(cb) ;
   end
   kx = kx+N ;
   nsamples = nsamples-N ;
end

p = bpackv(xc(:,1),xc(:,2)) ;     % pack the result

last = x(end,:) ;
return 


function    [xc,ftype] = x3block(x,xf,T,code)
%
%    [xc,ftype] = x3block(x,xf,T,code)
%
BFP_HDR_LEN = 6 ;

mabsd = max(abs(xf));         % maximum size of sample in the filtered block
n = size(x,1);                % requested block length
xc = zeros(n+1,2);            % allocate some space for the result

if mabsd<=T(3),               % Rice encoding
  kc = sum(mabsd>T)+1;          % find which code to use
  xc(1,:) = [kc,2];              % 2 bit rice block header
  xf+code(kc).offset;
	xc(1+(1:n),1) = code(kc).code(xf+code(kc).offset)' ; % apply code
	xc(1+(1:n),2) = code(kc).nbits(xf+code(kc).offset)' ;
	ftype = kc;                   % record the code selection

elseif mabsd>T(3),			   % BFP encoding

  % number of bits needed to represent right-justified samples
	nb = min(ceil(log2(mabsd+0.5))+1,16) ;       % number of bits
  xc(1,:) = [nb-1 BFP_HDR_LEN] ;	    % bfp bit count
  if nb==16,                           % Pass-through encoding - no filtering
    xc(1+(1:n),1) = twoscomp(x,16) ;
    xc(1+(1:n),2) = 16 ;
    ftype = 5 ;
  else
    xc(1+(1:n),1) = twoscomp(xf,nb) ;
    xc(1+(1:n),2) = nb ;
    ftype = 4 ;
  end
end
return


function    x = twoscomp(x,nb)
%
%  sign extend negative numbers
%
kn = find(x<0) ;
x(kn) = x(kn)+2^nb ;
return

