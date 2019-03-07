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

function    [w,pp] = bunpackv(p,n,bits)

%      [w,p] = bunpackv(p,n,nbits)
%      Unpack n integers with nbits each from the 16-bit packed 
%      stream in p. Can be called recursively to unpack a stream
%      packed from a variable bit-length source such as the X3
%      compressor.
%      p can be either a vector of 16-bit packed data or a structure.
%        If p is a vector, bunpackv converts it to a bit stream structure
%        and initializes the states. If p is a structure returned from a 
%        previous call to bunpackv, the states in the structure are used.
%      n is the number of integers to extract
%      nbits is the bit length of each integer. Must be <=16.
%
%      Returns:
%      w is a vector of n non-negative integers.
%      p is a structure containing the updated packed stream and 
%        some state variables which are used in subsequent calls to
%        bunpackv. p has two structure elements:
%           .stream   a vector containing the words to be unpacked.
%           .ntotake  the number of bits yet to be unpacked in the first
%                     word in the stream
%
%      GNU General Public License, see README.txt
%      mark johnson, SOI / Univ. St. Andrews
%      mj26@st-andrews.ac.uk
%      November 2012

ibits = 16 ;         % packed data stream word length
maxbits = 32 ;
MASK = 2^bits-1 ;

% allocate space for the output data vector
w = zeros(n,1) ;

% initialize bit stream states
if isstruct(p),
   ntotake = p.ntotake ;      % get the number of bits available in this word
   p = p.stream ;             % get the vector of packed words
else
   ntotake = ibits ;
end

pword = p(1) ;
bitsp2 = 2.^bits ;
ip = 2 ;

for k=1:n,              % for each output word
   if ntotake<bits,        % check if there are enough bits remaining
                           % in the current word in the bit stream
      if ip>length(p),     % if not, get the next word, if there is one
         fprintf(' No bits left in packed stream\n') ;
         break ;
      end

      % get the next word and append it to what was left of the current
      % word
      pword = bitor(bitshift(pword,ibits,maxbits),p(ip)) ;
      % update the available bit count
      ntotake = ntotake+ibits ;
      ip = ip+1 ;       % update the pointer to the next input word
   end
   % extract an nbit word from the input stream
   w(k) = bitand(bitshift(pword,bits-ntotake),MASK) ;
   % and adjust the state variables of the bit stream
   ntotake = ntotake-bits ;
   pword = bitand(pword,2^ntotake-1) ;
end

% store updated bit stream states
if ntotake==0,
   pp.stream = p(ip:end) ;
   pp.ntotake = ibits ;
else
   pp.stream = [pword;p(ip:end)] ;
   pp.ntotake = ntotake ;
end
