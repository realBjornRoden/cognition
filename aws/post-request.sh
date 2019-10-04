#
# post-request.sh
#
# Copyright (c) 2019 B.Roden
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
# 

[[ -z "$1" ]] &&  { echo "***ENOARG"; exit 1; }
[[ -f "$2" ]] ||  { echo "***ENOFILE"; exit 1; }

case $1 in
detect-labels)            jq -r '.Labels[]| "\(.Name) \(.Confidence)"' $2 ;;
detect-faces)             jq -r '.FaceDetails[].Confidence' $2 ;;
detect-text)              jq -r '.TextDetections[].DetectedText' $2 | tr '\n' ' ' ; echo ;;
detect-document-text)     jq -r '.Blocks[]|select(.BlockType=="LINE")|.Text' $2 | tr '\n' ' '; echo;;
document-text-detection)  jq -r '.Blocks[]|select(.BlockType=="LINE")|.Text' $2 | tr '\n' ' '; echo;;
*)                        jq -r "." $2 ;;
esac
