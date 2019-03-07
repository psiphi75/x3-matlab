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

function    [w,pp] = bunpackrice(p,n,code)
%
%      [w,pp] = bunpackrice(p,n,code)
%      Unpack n Rice-encoded integers from the 16-bit packed 
%      stream in p. Can be called recursively to unpack a stream
%      of data packed from a variable bit-length source such as X3.
%      p can be either a vector of 16-bit packed data or a structure.
%        If p is a vector, bunpackrice initializes internal states. If p
%        is a structure returned from a previous call to bunpackv or 
%        bunpackrice, the states in the structure are used.
%      n is the number of integers to extract
%      code is a structure containing information about the coding.
%        Use makericecode to generate this structure.
%
%      returns:
%      w is a vector of n integers.
%      pp is a structure containing the packed stream and some state 
%      variables which are used in subsequent calls to bunpackv or 
%      bunpackrice.
%
%      GNU General Public License, see README.txt
%      mark johnson, SOI / Univ. St. Andrews
%      mj26@st-andrews.ac.uk
%      November 2012

ibits = 16 ;
maxbits = 32 ;

% initialize states
if isstruct(p),
   pword = p.stream(1) ;
   ntotake = p.ntotake ;
   p = p.stream(2:end) ;
else
   pword = 0 ;
   ntotake = 0 ;
end

% make inverse Rice table
IRT = code.inv ;
ns = code.nsubs ;
submask = 2^ns - 1 ;

% allocate space for cdw
cdw = zeros(n,2) ;
ip = 1 ;                % pointer to next packed word in the input stream

for k=1:n,
   done = 0 ;
   nshifts = 0 ;
   while ~done,         % find the first '1' in the next codeword
      if ntotake<=ns,     % make sure there are always enough bits in pword
         if ip>length(p),
            fprintf(' No bits left in packed stream\n') ;
            break ;
         end
         pword = bitor(bitshift(pword,ibits,maxbits),p(ip)) ;
         ntotake = ntotake+ibits ;
         ip = ip+1 ;
      end
      done = bitget(pword,ntotake)==1 ;
      ntotake = ntotake-1 ;
      nshifts = nshifts+1 ;
   end

   cdw(k,1) = nshifts ;
   if ns>0,             % retrieve the codeword suffix if there is one
      cdw(k,2) = bitand(bitshift(pword,ns-ntotake),submask) ;
      ntotake = ntotake-ns ;
      pword = bitand(pword,2^ntotake-1) ;
   end
end

% decode the shifts and subs
w = IRT(2^ns*(cdw(:,1)-1)+cdw(:,2)+1) ;

% update the state of the bit packer
pp.stream = [pword;p(ip:end)] ;
pp.ntotake = ntotake ;
return
