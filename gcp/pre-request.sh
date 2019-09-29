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

[[ -z "$2" ]] &&  { echo "***ENOFILE"; exit 1; }
INPUT=$2

case $1 in
asyncBatchAnnotate)
	GSBUCKET="gs://$(gcloud config get-value project)"
	GSFILE="$GSBUCKET/$INPUT"
	[[ $? ]] || { echo "***EGSUTIL1"; exit 1; }
	gsutil ls $GSFILE >/dev/null 2>&1
	[[ $? ]] || { echo "***EGSUTIL2"; exit 1; }

	cat <<-EOD > $REQ
	{ "requests":[
    		{ "inputConfig": { "gcsSource": { "uri": "$GSFILE" }, "mimeType": "application/pdf" },
      		"features": [ { "type": "DOCUMENT_TEXT_DETECTION" } ],
      		"outputConfig": { "gcsDestination": { "uri": "$GSBUCKET/" }, "batchSize": 1 } }
  		]
	}
	EOD
	[[ -f "$REQ" ]] ||  { echo "***ENOREQ"; exit 1; }
	echo $REQ
;;
annotate*)
	B64=base64.tmp
	base64 -i $INPUT -o $B64
	[[ -f "$B64" ]] ||  { echo "***ENOBASE64"; exit 1; }

	MAX=0	# 0==unlimited

	case $1 in
	
	annotate1)
		cat <<-EOD > $REQ
			{ "requests": [ { "image": { "content": "$(<$B64)" }, "features": [ { "type": "TEXT_DETECTION" } ] } ] }
		EOD
	;;
	annotate2)
		cat <<-EOD > $REQ
			{ "requests": [ { "image": { "content": "$(<$B64)" }, "features": [ { "type": "DOCUMENT_TEXT_DETECTION" } ] } ] }
		EOD
	;;
	annotate3)
		cat <<-EOD > $REQ
			{ "requests": [ { "image": { "content": "$(<$B64)" }, "features": [ { "maxResults": $MAX, "type": "FACE_DETECTION" } ] } ] }
		EOD
	;;
	annotate4)
		cat <<-EOD > $REQ
			{ "requests": [ { "image": { "content": "$(<$B64)" }, "features": [ { "maxResults": $MAX, "type": "OBJECT_LOCALIZATION" } ] } ] }
		EOD
	;;
	annotate5)
		cat <<-EOD > $REQ
			{ "requests": [ { "image": { "content": "$(<$B64)" }, "features": [ { "maxResults": $MAX, "type": "WEB_DETECTION" } ] } ] }
		EOD
	;;
	annotate4)
		cat <<-EOD > $REQ
			{ "requests": [ { "image": { "content": "$(<$B64)" }, "features": [ { "maxResults": $MAX, "type": "OBJECT_LOCALIZATION" } ] } ] }
		EOD
	;;
	esac

	[[ -f "$REQ" ]] ||  { echo "***ENOREQ"; exit 1; }
	rm -f $B64
	echo $REQ
;;
esac
