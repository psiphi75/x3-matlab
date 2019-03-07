	           X3 Matlab Toolbox v1.0
	   Copyright (C) 2012,2013 Mark Johnson

These files are an implementation of X3, a low-complexity lossless
audio compressor for underwater sound.

The X3 Matlab toolbox is free software: you can redistribute it 
and/or modify it under the terms of the GNU General Public License 
as published by the Free Software Foundation, either version 3 of 
the License, or any later version.

This software is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this file. If not, see <http://www.gnu.org/licenses/>.

Getting started:
Make sure the x3toolbox and its subdirectories are on your matlab path.
There are two entry points to the tools: 
1. To evaluate just the compression algorithm, use x3compress and x3uncompress, e.g.:
  x = wavread('GI16_15s.wav',[1 5000]) ;  % read in some audio from a wav file
  x = round(32768*x) ;   % convert to integers
  p = x3compress(x) ;    % compress using default values
  xu = x3uncompress(p,size(x,1),size(x,2)) ;  % uncompress
  max(abs(xu-x))         % should be 0
  cf = size(x,1)*size(x,2)/length(p)	% compression factor

2. To evaluate the archive file format, metadata capabilities or to compress
an entire wav file, use wav_to_x3 and x3_to_wav, e.g.:
 wav_to_x3('GI16_15s.wav')   % generates a compressed archive file GI16_15s.x3a
 x3_to_wav('GI16_15s.x3a')   % uncompresses the archive to make a wav file
 % called GI16_15su.wav and an xml metadata file GI16_15s.xml.
You should be able to double click on the xml file to inspect it in your web
browser if you don't have an xml reader.


Note: audio data compression and uncompression in Matlab is slow.
These functions are provided to demonstrate the method and facilitate
evaluation but are not really suited for compression of large audio
files. A faster C-code implementation is available for this.

Finally, no-one is perfect. Please report any problems with these 
functions to markjohnson@st-andrews.ac.uk.
