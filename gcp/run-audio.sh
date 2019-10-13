#
# run-audio.sh
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

## "alternativeLanguageCodes": [ "en-AU", "en-CA", "en-GH", "en-GB", "en-IN", "en-IE", "en-KE", "en-NZ", "en-NG", "en-PH", "en-SG", "en-ZA", "en-TZ" ],

AUTH=$(gcloud auth application-default print-access-token 2>/dev/null)
[[ -z "$AUTH" ]] && { echo "***ENOAUTH"; exit 1; }

[[ -z "$2" ]] &&  { echo "***ENOFILE"; exit 1; }
INPUT=$2

OUTPUT=result$RANDOM.json
REQ=request.json

case $1 in
audio-detection)
	URL=https://speech.googleapis.com/v1p1beta1/speech:recognize

	GSBUCKET="gs://$(gcloud config get-value project)"
	GSFILE="$GSBUCKET/$INPUT"
	gsutil ls $GSFILE >/dev/null 2>&1
	[[ $? -eq 0 ]] || { echo "***EGSLSFILE"; exit 1; }
	
	cat <<-EOD > $REQ
		{ "config": { "encoding":"LINEAR16", "languageCode": "en-US", "alternativeLanguageCodes": [ "en-AU", "en-GB", "en-IE" ], "model": "command_and_search" }, "audio": { "uri":"$GSFILE" } }
	EOD
	[[ -f "$REQ" ]] ||  { echo "***ENOREQ"; exit 1; }

	curl -s -H "Content-Type: application/json" \
		-H "Authorization: Bearer $(gcloud auth application-default print-access-token)" \
		-d @$REQ \
		$URL > $OUTPUT
	[[ $? -eq 0 ]] || { echo "***ECURL"; exit 1; }
	echo $OUTPUT
;;

audio-diarization)
	URL=https://speech.googleapis.com/v1p1beta1/speech:recognize
	GSBUCKET="gs://$(gcloud config get-value project)"
	GSFILE="$GSBUCKET/$INPUT"
	gsutil ls $GSFILE >/dev/null 2>&1
	[[ $? -eq 0 ]] || { echo "***EGSLSFILE"; exit 1; }
	
	cat <<-EOD > $REQ
		{ "config": { "encoding":"LINEAR16", "languageCode": "en-US", "diarizationConfig": { "enableSpeakerDiarization": true }, "diarizationSpeakerCount": 2, "model": "phone_call" }, "audio": { "uri":"$GSFILE" } }
	EOD
	[[ -f "$REQ" ]] ||  { echo "***ENOREQ"; exit 1; }

	curl -s -H "Content-Type: application/json" \
		-H "Authorization: Bearer $(gcloud auth application-default print-access-token)" \
		-d @$REQ \
		$URL > $OUTPUT
	[[ $? -eq 0 ]] || { echo "***ECURL"; exit 1; }
	echo $OUTPUT
;;

audio-transcription)
	URL=https://speech.googleapis.com/v1/speech:recognize
        [[ -f "$INPUT" ]] ||  { echo "***ENOINPUT"; exit 1; }

        BASE64=base64.tmp
        base64 -i $INPUT -o $BASE64
        [[ -f "$BASE64" ]] ||  { echo "***ENOBASE64"; exit 1; }
	
	cat <<-EOD > $REQ
		{ "config": { "language_code": "en-US" }, "encoding": "LINEAR16", "sampleRateHertz": 16000, "enableWordTimeOffsets": false, "audio": { "content": "$(<$BASE64)" } }
	EOD
	[[ -f "$REQ" ]] ||  { echo "***ENOREQ"; exit 1; }

	curl -X POST \
		-H "Authorization: Bearer "$(gcloud auth application-default print-access-token) \
		-H "Content-Type: application/json" \
		-d @$REQ \
		$URL > $OUTPUT
	[[ $? -eq 0 ]] || { echo "***ECURL"; exit 1; }
	echo $OUTPUT
;;

audio-transcription2)
	URL=https://speech.googleapis.com/v1/speech:longrunningrecognize
	GSBUCKET="gs://$(gcloud config get-value project)"
	GSFILE="$GSBUCKET/$INPUT"
	gsutil ls $GSFILE >/dev/null 2>&1
	[[ $? -eq 0 ]] || { echo "***EGSLSFILE"; exit 1; }
	
	cat <<-EOD > $REQ
		{ "config": { "language_code": "en-US" }, "audio": { "uri":"$GSFILE" } }
	EOD
	[[ -f "$REQ" ]] ||  { echo "***ENOREQ"; exit 1; }

	curl -X POST \
		-H "Authorization: Bearer "$(gcloud auth application-default print-access-token) \
		-H "Content-Type: application/json" \
		-d @$REQ \
		$URL > $OUTPUT
	[[ $? -eq 0 ]] || { echo "***ECURL"; exit 1; }
	echo $OUTPUT
;;
esac
