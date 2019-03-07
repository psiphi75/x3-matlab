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

function    x3 = readx3xml(xfile)

%     x3 = readx3xml(xfile)
%     Read an xml file or string containing xml. 
%     This is a front-end for the xml2mat function 
%     in the XML4MATv2 toolbox by Jonas Almeida et al. This toolbox is
%     included in the X3 toolbox and is also available on the Mathworks 
%     user contributed website.
%     Make sure the XML4MATv2 toolbox is on your matlab path before
%     using this function.
%
%     This function: 
%     GNU General Public License, see README.txt
%     mark johnson, SOI / Univ. St. Andrews
%     mj26@st-andrews.ac.uk
%     November 2012
%     XML4MATv2:
%     Copyright 2003 J. Almeida. Licensed under GNU GPL.

x3 = struct ;
warning off MATLAB:REGEXP:deprecated

if xfile(1) == '<',
   y = xfile ;
else
   y = file2str(xfile) ;
   %y=strrep(y,'''','''''') ;
end

if isempty(y),
   return
end

% convert first to MbML compliant string and then onto an m-variable
y=xml2mat(mbmling(y,0));
y=consolidateall(y);
warning on MATLAB:REGEXP:deprecated

% loop through the structure looking for unneeded arrays
fn = fieldnames(y) ;
x3 = struct ;
n = length(y) ;
if n==1, x3=y; return, end

for k=1:length(fn),
   for kk=1:n,
      v{kk} = getfield(y,{kk},fn{k}) ;
      if ~isempty(v{kk}),
         kg = kk ;
      end
   end

   if kg==1,
      x3 = setfield(x3,fn{k},v{1}) ;
   else
      x3 = setfield(x3,fn{k},{v{1:kg}}) ;
   end
end
