#
# run-translate.sh
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

AUTH=$(gcloud auth application-default print-access-token 2>/dev/null)
[[ -z "$AUTH" ]] && { echo "***ENOAUTH"; exit 1; }

[[ -z "$2" ]] &&  { echo "***ENOFILE"; exit 1; }
INPUT=$2

[[ -z "$3" ]] && { echo "***ENOLANG"; exit 1; }
SLANG=${3%%-*}
[[ -z "$SLANG" ]] && { echo "***ENOSOURCELANG"; exit 1; }
TLANG=${3##*-}
[[ -z "$TLANG" ]] && { echo "***ENOTARGETLANG"; exit 1; }


OUTPUT=result$RANDOM.json
REQ=request.json

case $1 in
translate)
	URL=https://translation.googleapis.com/language/translate/v2
        [[ -f "$INPUT" ]] ||  { echo "***ENOINPUT"; exit 1; }

        BASE64=base64.tmp
        base64 -i $INPUT -o $BASE64
        [[ -f "$BASE64" ]] ||  { echo "***ENOBASE64"; exit 1; }
	
	cat <<-EOD > $REQ
		{ "q": "$(<$INPUT)", "source": "$SLANG", "target": "$TLANG", "format": "text" }
	EOD
	[[ -f "$REQ" ]] ||  { echo "***ENOREQ"; exit 1; }

	curl -s -X POST \
		-H "Authorization: Bearer "$(gcloud auth application-default print-access-token) \
		-H "Content-Type: application/json" \
		-d @$REQ \
		$URL > $OUTPUT
	[[ $? -eq 0 ]] || { echo "***ECURL"; exit 1; }
	echo $OUTPUT
;;

translate-bucket)
	URL=https://translation.googleapis.com/language/translate/v2
	GSBUCKET="gs://$(gcloud config get-value project)"
	GSFILE="$GSBUCKET/$INPUT"
	gsutil ls $GSFILE >/dev/null 2>&1
	[[ $? -eq 0 ]] || { echo "***EGSLSFILE"; exit 1; }
	
	cat <<-EOD > $REQ
		{ "q": "$TEXT", "source": "$LANG", "target": "$TLANG", "format": "text" }
	EOD
	[[ -f "$REQ" ]] ||  { echo "***ENOREQ"; exit 1; }

	curl -s -X POST \
		-H "Authorization: Bearer "$(gcloud auth application-default print-access-token) \
		-H "Content-Type: application/json" \
		-d @$REQ \
		$URL > $OUTPUT
	[[ $? -eq 0 ]] || { echo "***ECURL"; exit 1; }
	echo $OUTPUT
;;
esac
