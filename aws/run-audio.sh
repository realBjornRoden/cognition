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
BUCKET=blobbucket

REQ=request.json

[[ -z "$2" ]] && { echo "***ENOFILE"; exit 1; }
INPUT=$2

aws s3 ls s3://$BUCKET/$INPUT
[[ $? -ne 0 ]] && { echo "***ENOFILE"; exit 1; }
# aws s3 cp $INPUT s3://$BUCKET/

case $1 in

audio-transcribe)
	cat <<-EOD > $REQ
		{ "TranscriptionJobName": "request ID", "LanguageCode": "en-US", "MediaFormat": "${INPUT##*.}", "Media": { "MediaFileUri": "$BUCKET/$INPUT" } }
	EOD
	[[ -f "$REQ" ]] ||  { echo "***ENOREQ"; exit 1; }

	aws transcribe start-transcription-job --region us-east-2 --cli-input-json file://request.json 
	[[ $? -ne 0 ]] && { echo "***EFAILED"; exit 1; }
;;

audio-diarization)
#To turn on speaker identification, set the MaxSpeakerLabels and ShowSpeakerLabels field of the Settings field when you make a call to the StartTranscriptionJob operation. You must set both fields or else Amazon Transcribe will return an exception.
	JOBID=job$RANDOM
	cat <<-EOD > $REQ
		{ "TranscriptionJobName": "$JOBID", "LanguageCode": "en-US", "Settings": { "MaxSpeakerLabels": 2, "ShowSpeakerLabels": true }, "MediaFormat": "${INPUT##*.}", "Media": { "MediaFileUri": "s3://$BUCKET/$INPUT" } }
	EOD
cat $REQ

	[[ -f "$REQ" ]] ||  { echo "***ENOREQ"; exit 1; }

	aws transcribe start-transcription-job --region us-east-2 --cli-input-json file://request.json 
	[[ $? -ne 0 ]] && { echo "***EFAILED"; exit 1; }

	aws transcribe list-transcription-jobs --region us-east-2 --status IN_PROGRESS
;;

*)
	echo "***ENOOP"; exit -1 ;;
esac
echo $JOBID $REQ
