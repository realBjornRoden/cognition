#
# run-requests.sh
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
VERBOSE=-v

REQ=${2:-request.json}
[[ -f "$REQ" ]] || { echo "***ENOREQ"; exit 1; }

OUTPUT=result$RANDOM.json

case $1 in
vision-ocr-hand)
	AUTH=$COGNITIVE_SERVICE_KEY
	URL="https://westus2.api.cognitive.microsoft.com/vision/v2.0/ocr?detectOrientation=true"
	OCTETSTREAM=binary
	file $REQ
	;;
vision-pdf) # first step to submit the specified PDF URL for OCR processing - Save the Operation-Location
	AUTH=$COGNITIVE_SERVICE_KEY
	URL="https://westus2.api.cognitive.microsoft.com/vision/v2.0/read/core/asyncBatchAnalyze"
	OCTETSTREAM=pdf1
	;;
vision-readop) # second step to get the OCR from the specified PDF URL - $3 ==>> Operation-Location such as "4db4671f-a382-447d-b43d-d6ff815cd4a6"
	[[ -z "$3" ]] && { echo "***ENOARG"; exit 1; }
	echo "***READOP Operation-Location: $3"
	AUTH=$COGNITIVE_SERVICE_KEY
	URL="https://westus2.api.cognitive.microsoft.com/vision/v2.0/read/operations/$3"
	OCTETSTREAM=pdf2
	;;
vision-ocr)
	AUTH=$COGNITIVE_SERVICE_KEY
	URL="https://westus2.api.cognitive.microsoft.com/vision/v2.0/ocr"
	OCTETSTREAM=binary
	file $REQ
	;;
vision-tag)
	AUTH=$COGNITIVE_SERVICE_KEY
	URL="https://westus2.api.cognitive.microsoft.com/vision/v2.0/tag"
	OCTETSTREAM=binary
	file $REQ
	;;
vision-objects)
	AUTH=$COGNITIVE_SERVICE_KEY
	URL="https://westus2.api.cognitive.microsoft.com/vision/v2.0/analyze?visualFeatures=Objects"
	;;
vision-landmark)
	AUTH=$COGNITIVE_SERVICE_KEY
	URL="https://westus2.api.cognitive.microsoft.com/vision/v2.0/analyze?details=Landmarks"
	;;
vision-face-analyze)
	AUTH=$COGNITIVE_SERVICE_KEY
	URL="https://westus2.api.cognitive.microsoft.com/vision/v2.0/analyze?visualFeatures=Faces"
	;;
face-similar)
	echo "***ENOTIMPLEMENTEDYET"; exit 0
	# Given query face's faceId, to search the similar-looking faces from a faceId array, a face list or a large face list. 
	# faceId array contains the faces created by Face-Detect, which will expire 24 hours after creation. 
	# A "faceListId" is created by FaceList-Create containing persistedFaceIds that will not expire. 
	# And a "largeFaceListId" is created by LargeFaceList-Create containing persistedFaceIds that will also not expire. 
	# Find similar has two working modes, "matchPerson" and "matchFace".
	# "matchPerson" is the default mode that it tries to find faces of the same person as possible by using internal same-person thresholds. 
	# "matchFace" mode ignores same-person thresholds and returns ranked similar faces anyway, even the similarity is low. 
	# https://docs.microsoft.com/en-us/azure/cognitive-services/face/face-api-how-to-topics/specify-detection-model
	;;
face-group)
	echo "***ENOTIMPLEMENTEDYET"; exit 0
	# Divide candidate faces into groups based on face similarity. 
	# https://{endpoint}/face/v1.0/group
	;;
face-verify)
	echo "***ENOTIMPLEMENTEDYET"; exit 0
	# 1-to-1 verify whether two faces belong to a same person or whether one face belongs to a person.
	# Verify whether two faces belong to a same person or whether one face belongs to a person. 
	# https://{endpoint}/face/v1.0/verify
	;;
face-identify)
	echo "***ENOTIMPLEMENTEDYET"; exit 0
	# 1-to-many identification to find the closest matches of the specific query person face from a person group or large person group. 
	# Create PersonGroup, after creation, use PersonGroup Person-Create to add persons into the group, and then call PersonGroup-Train to get this group ready for Face-Identify
	# https://{endpoint}/face/v1.0/persongroups/{personGroupId}
	# https://{endpoint}/face/v1.0/persongroups/{personGroupId}/train
	# https://{endpoint}/face/v1.0/persongroups/{personGroupId}/training
	# https://{endpoint}/face/v1.0/persongroups/{personGroupId}/training
	# https://westus2.api.cognitive.microsoft.com/face/v1.0/identify
	;;
face-detect)
	AUTH=$COGNITIVE_SERVICE_KEY
	URL="https://westus2.api.cognitive.microsoft.com/face/v1.0/detect"
	;;
face-detect-details)
	AUTH=$COGNITIVE_SERVICE_KEY
	URL="https://westus2.api.cognitive.microsoft.com/face/v1.0/detect?returnFaceId=true&returnFaceLandmarks=false&returnFaceAttributes=age,gender,headPose,smile,facialHair,glasses,emotion,hair,makeup,occlusion,accessories,blur,exposure,noise"
	;;
esac

[[ -z "$AUTH" ]] && { echo "***ENOAUTH"; exit 1; }

case $OCTETSTREAM in
binary)
	curl $VERBOSE -s -X POST \
	-H "Ocp-Apim-Subscription-Key: $AUTH" \
	-H "Content-Type: application/octet-stream" \
	--data-binary "@$REQ" \
	$URL > $OUTPUT
	;;
pdf2)
	curl $VERBOSE -s -X GET \
	-H "Ocp-Apim-Subscription-Key: $AUTH" \
	--data "@$REQ" \
	$URL > $OUTPUT
	;;
pdf1)
	curl $VERBOSE -s -X POST \
	-H "Ocp-Apim-Subscription-Key: $AUTH" \
	-H "Content-Type: application/json" \
	--data "@$REQ" \
	$URL 2>&1 >/dev/null  | awk '/Operation-Location/{print "***OCRBATCH ",$2,substr($3,index($3,"operations/")+11)}'
	unset OUTPUT
	;;
*)
	curl $VERBOSE -s -X POST \
	-H "Ocp-Apim-Subscription-Key: $AUTH" \
	-H "Content-Type: application/json" \
	--data "@$REQ" \
	$URL > $OUTPUT
	;;
esac

[[ $? -ne 0 ]] && { echo "***EFAILED"; exit 1; }
 
echo $OUTPUT
