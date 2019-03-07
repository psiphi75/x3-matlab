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

function    F = makeccitt16tab
%
%     F = makeccitt16tab
%     Make the lookup table for the 16 bit CCITT cyclic redundancy code
%     Based on Eric Johnson, NMSU report
%     Tested against web CRC calculators
%
%     To make a table to include in a C program use:
%     FF=reshape(makeccitt16tab,8,[]);
%     for(k=1:size(FF,2)),fprintf('0x%04x,',FF(:,k)) ;fprintf('\n');end
%
%     GNU General Public License, see README.txt
%     mark johnson, SOI / Univ. St. Andrews
%     mj26@st-andrews.ac.uk
%     November 2012

% compute the basis polynomials
G(1) = hex2dec('1021') ;
for k=2:8,
   G(k) = bitshift(G(k-1),1,16) ;
   if bitget(G(k-1),16)
      G(k) = bitand(bitxor(G(k),G(1)),65535) ;
   end
end

% compute the table entries
F = zeros(256,1) ;
for k=1:256,
   f = 0 ;
   T = k-1 ;
   for kk=1:8,
      if bitget(T,kk) 
         f = bitxor(f,G(kk)) ;
      end
   end
   F(k) = f ;
end
