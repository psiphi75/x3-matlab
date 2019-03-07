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

function    wav_to_x3(fname)

%     wav_to_x3(fname)
%     Compress a wav format audio file using the X3 lossless
%     compression algorithm. A compressed binary file with suffix
%     .x3a is generated.
%     fname is the name of the wav file to compress including the
%     .wav suffix. If it is not in the current working directory,
%     include a relative or absolute path. The compressed file will
%     be written to the same directory and will have the same name
%     but with a .x3a suffix.
%
%     Warning: compression in Matlab is not fast! Large wav files
%     will take many minutes to compress. Use the C-code functions
%     for better performance.
%
%     GNU General Public License, see README.txt
%     mark johnson, SOI / Univ. St. Andrews
%     mj26@st-andrews.ac.uk
%     November 2012

FSIZE = 10000 ;       % maximum number of samples in a frame
[s, fs] = audioread(fname, 'native') ; % where s = data, fs = sample frequency
if sizeof(s(1)) ~= 2,
   fprintf(' Wav file must have 16-bit data\n') ;
   return
end


% make an output filename
ofname = [strtok(fname,'.') '.x3a'] ;
fid = x3new(ofname,fs) ;

% set up to work through the wav file
ns = size(s)(1) ;
nch = size(s)(2) ;
FSIZE = floor(FSIZE/nch) ;
scnt = 0 ;
wsent = 0 ;
ntypes = zeros(1,5) ;



% process frames of samples from the wav file
while scnt<ns,
   fprintf(' %d%% complete\n',round(scnt/ns*100)) ;
   n = min(ns-scnt,FSIZE) ;         % pick a frame size
   x = audioread(fname,scnt+[1 n]) ;  % read in the next frame of data
   x = round(32768*x) ;          % convert to integers
   [p,nt] = x3makeframe(x) ;     % encode
   fwrite_short(fid,p) ;         % write to the output file
   scnt = scnt+n ;               % increment the sample counter
   ntypes = ntypes+nt ;          % keep track of what codes are used
   wsent = wsent+length(p) ;
end

% at anytime you can add metadata frames as follows. Note: there are currently
% no rules for metadata fields other than that they are valid xml.
meta{1} = '<LOCATION UNITS="decimal degrees">32.3456,128.9012</LOCATION>' ;
meta{2} = '<SPECIES>Physeter humongous</SPECIES>' ;
data = horzcat(meta{:});
p = x3makemetaframe(data, length(data)) ;     % pack the metadata frame
fwrite_short(fid,p) ;                    % write it to the output file

fclose(fid) ;

% report compression performance
ntypes = ntypes/sum(ntypes)*100 ;
fprintf('\nBlock allocation:\t%3.4f%% Rice-0, %3.4f%% Rice-1, %3.4f%% Rice-3, %3.4f%% BFP, %3.4f%% PASS\n', ntypes) ;
fprintf('Compression factor:\t%3.2f\n\n', scnt*nch/wsent) ;
