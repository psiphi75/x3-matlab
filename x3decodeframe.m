function    [x,id,T] = x3decodeframe(hdr,data)

%     [x,id,T] = x3decodeframe(hdr,data)
%     Decode a packed X3-format data frame. The frame can contain ASCII 
%     metdata or multi-channel audio data compressed using X3.
%     hdr is the 10-word frame header or the entire packed data vector.
%     data is a variable length vector of packed 16-bit data (not needed
%      if the entire frame is passed in the first argument).
%
%     Returns:
%     x is a string or a vector or matrix of audio data.
%     id is the source identifier (0 for metadata).
%     T is the time code for the frame.
%
%     This routine follows the definition for X3 data frames in
%     Johnson, Hurst and Partan, JASA 133(3):1387-1398, 2013.
%     The 20-byte frame header format is as follows:
%        Field:   Function:                           Size:
%        KEY      key word (30771 or 'x3' in ASCII)   16 bits
%        ID       source identifier                   8 bits
%        NCH      number of channels                  8 bits
%        NSAMP    samples per channel                 16 bits
%        NBYTE    number of bytes in the data payload 16 bits
%        T        time code                           64 bits
%        CH       CRC on the above header             16 bits
%        CD       CRC on the data payload             16 bits
%
%     GNU General Public License, see README.txt
%     mark johnson, SOI / Univ. St. Andrews
%     mj26@st-andrews.ac.uk
%     November 2012

if nargin==1,
   data = hdr(11:end) ;
end

% decode the header
id = floor(hdr(2)/256) ;
nch = rem(hdr(2),256) ;
nsamples = hdr(3) ;
nby = hdr(4) ;
T = hdr(5:8) ;
x = [] ;

if length(data)<nby/2,
   fprintf(' Too little data in frame: expected %d words\n',nby/2) ;
   return
end

data = data(:) ;
if id>0,
   x = x3uncompress(data,nsamples,nch) ;
else
   x = [floor(data'/256);rem(data',256)] ;
   x = char(x(:)') ;
   if x(end)==0,          % get rid of the filler character at the end if there is one
      x = x(1:end-1) ;
   end
end
