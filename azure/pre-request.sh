#
# pre-request.sh
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

REQ=request.json

[[ -z "$2" ]] && { echo "***ENOFILE"; exit 1; }
INPUT=$2

case $1 in
vision-pdf)
	cat <<-EOD > $REQ
		{ "url" : "$INPUT" }
	EOD
	#[[ -f "$INPUT" ]] || { echo "***ENOFILE"; exit 1; }
	#file $INPUT
	#exit 0
        ;;
vision-ocr*)
	[[ -f "$INPUT" ]] || { echo "***ENOFILE"; exit 1; }
	file $INPUT
	exit 0
        ;;
vision-tag)
	[[ -f "$INPUT" ]] || { echo "***ENOFILE"; exit 1; }
	file $INPUT
	exit 0
        ;;
vision-objects)
	cat <<-EOD > $REQ
		{ "url" : "$INPUT" }
	EOD
        ;;
vision-landmark)
	cat <<-EOD > $REQ
		{ "url" : "$INPUT" }
	EOD
        ;;
face-identify)
	cat <<-EOD > $REQ
		{ "url" : "$INPUT" }
	EOD
        ;;
face-detect)
	# model _02 Does not return face attributes or face landmarks but has improved accuracy on small, side-view, and blurry faces
	# https://docs.microsoft.com/en-us/azure/cognitive-services/face/face-api-how-to-topics/specify-detection-model
	cat <<-EOD > $REQ
		{ "url" : "$INPUT", "recognitionModel" : "recognition_02", "detectionModel" : "detection_02" }
	EOD
        ;;
face-detect-details)
	cat <<-EOD > $REQ
		{ "url" : "$INPUT" }
	EOD
        ;;
base64*)
	B64=base64.tmp
	base64 -i $INPUT -o $B64
	[[ -f "$B64" ]] ||  { echo "***ENOBASE64"; exit 1; }

	case $1 in
	face)
		cat <<-EOD > $REQ
			{ "url" : "https://cloud.google.com/vision/docs/images/faces.png" }
		EOD
		;;
	esac
	rm -f $B64
	;;
*)	exit 1;;
esac
[[ -f "$REQ" ]] ||  { echo "***ENOREQ"; exit 1; }
echo $REQ
