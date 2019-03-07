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

function    p = bpackv(words,bits)

%      p = bpackv(words,nbits)
%      Pack integers from a variable bit-length stream to 16 bit
%      packed binary vector p. The last word in p is zero-filled
%      if necessary to left justify.
%      words is a vector of integers to be packed. These can be either
%        whole numbers between 0 and 2^nbits-1, or signed integers
%        between -2^(nbits-1) and 2^(nbits-1)-1.
%      nbits is a scalar or vector number of bits. If bits is a scalar,
%        all of the words are packed with the same number of bits. Otherwise,
%        each word is packed with the number of bits specified by the 
%        corresponding entry in bits. The magnitude of words must be less
%        than 2.^nbits. All nbits must be <=16.
%
%      Returns:
%      p is a vector of 16-bit packed data.
%
%      GNU General Public License, see README.txt
%      mark johnson, SOI / Univ. St. Andrews
%      mj26@st-andrews.ac.uk
%      November 2012

obits = 16 ;         % number of bits per word in packed stream
maxbits = 32 ;
MASK = 2^obits-1 ;

% allocate space for p
p = zeros(ceil(sum(bits,1)/obits),1) ;

% initialize states
op = 1 ;
ntogo = obits ;
pword = 0 ;

% check if there are variable bits per word
if length(bits)<length(words),
   % if not, all words have the same number of bits
   bits = repmat(bits(1),length(words),1) ;
end

bitsp2 = 2.^bits ;

% some error checking - note that this test will not catch
% signed words that are too large.
if any(abs(words)>=bitsp2),
   fprintf(' Input word size exceeds number of bits\n') ;
   return
end

% convert signed integers to 2's complement
kn = find(words<0) ;
words(kn) = bitsp2(kn) + words(kn) ;

for k=1:length(words),        % for each input word
   % append the next input word to the current packed word
   pword = bitor(pword*bitsp2(k),words(k)) ;
   ntogo = ntogo-bits(k) ;
   % if the current packed word has 16 or more bits
   if ntogo<=0,
      % add it to the output stream and start a new accumulator
      p(op) = bitand(bitshift(pword,ntogo,maxbits),MASK) ;
      pword = bitand(pword,MASK) ;
      ntogo = ntogo+obits ;
      op = op+1 ;
   end
end

% end of stream: flush the packed word and truncate the output vector
% if necessary
if ntogo==obits,
   p = p(1:op-1) ;
else
   % left justify the final partial word
   p(op) = bitand(bitshift(pword,ntogo,maxbits),MASK) ;
   p = p(1:op) ;
end
