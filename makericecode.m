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

function    code = makericecode(level)

%     code = makericecode(level)
%     Create a structure of information about a variable length Rice code
%     for encoding or decoding audio data. 'Level' specifies the code type 
%     as per the table below.
%
%     See:  Table 1 in Johnson et al., JASA 133(3):1387-1398, 2013
%           www.cs.tut.fi/~albert/Dev/pucrunch/packing.html
%           www.firstpr.com.au/audiocomp/lossless/#rice
%
%     Code allocations are:
%        value           level=0    level=1    level=2   level=3
%          0             1            10         100       1000 
%         -1             01           11         101       1001 
%	        1             001          010        110       1010
%         -2             0001         011        111       1011
%          2             00001        0010       0100      1100
%         -3             000001       0011       0101      1101
%          3             0000001      00010      0110      1110
%         etc
%
%     This function generates a structure with the following fields:
%      code.nsubs = 0,1,2 is the level of the code (i.e., number of
%        suffix bits following the '1' flag bit.
%      code.offset is the position in the lookup tables corresponding
%        to a value of 0.
%      code.code is a vector containing mappings from integers
%        to codewords, i.e., the codeword for integer w is
%        code.code(w+code.offset).
%      code.nbits is a vector containing the corresponding word length
%        in bits.
%      code.inv is an inverse table containing mappings from codeword
%        to integer. Codewords are extracted from a packed source by
%        first counting the number of shifts needed to reach the leading
%        '1' bit and then by extracting the following code.nsubs suffix
%        bits. The general formula for inverting a codeword is then:
%           w = code.inv((2^code.nsubs)*(nshifts-1)+suffix+1) ;
%
%      GNU General Public License, see README.txt
%      mark johnson, SOI / Univ. St. Andrews
%      mj26@st-andrews.ac.uk
%      November 2012

switch level
   case 0
      code.nsubs = 0 ;     % number of subcode (suffix) bits
      code.offset = 7 ;    % table offset for 0
      code.code = ones(1,14) ;
		code.nbits = [12,10,8,6,4,2,1,3,5,7,9,11,13,15] ;

   case 1
      code.nsubs = 1 ;
      code.offset = 12 ;
      code.code = [repmat(3,1,11),repmat(2,1,11)] ;
		code.nbits = [12,11,10,9,8,7,6,5,4,3,2,2,3,4,5,6,7,8,9,10,11,12] ;

   case 2
      code.nsubs = 2 ;
      code.offset = 21 ;
      code.code = [repmat([7,5],1,10),repmat([4,6],1,10)] ;
      code.nbits = [12,12,11,11,10,10,9,9,8,8,7,7,6,6,5,5,4,4,3,3,...
                     3,3,4,4,5,5,6,6,7,7,8,8,9,9,10,10,11,11,12,12] ;

   case 3
      code.nsubs = 3 ;
      code.offset = 29 ;
      code.code = [repmat([15,13,11,9],1,7),repmat([8,10,12,14],1,7)] ;
      code.nbits = [10,10,10,10,9,9,9,9,8,8,8,8,7,7,7,7,6,6,6,6,5,5,...
                     5,5,4,4,4,4,4,4,4,4,5,5,5,5,6,6,6,6,7,7,7,7,...
                     8,8,8,8,9,9,9,9,10,10,10,10] ;

   otherwise
      fprintf(' Unknown code type\n') ;
      code = [] ;
end

% inverse table is the same for all Rice code
invt = [0:code.offset;-1*(1:code.offset+1)] ;
code.inv = invt(:) ;
return

