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

asyncBatchAnnotate)   jq -r '.responses[].fullTextAnnotation["text"]' $2 ;;
annotate|annotate2)   jq -r ".responses[].textAnnotations[0].description" $2 ;;
annotate3)            jq '.responses[].faceAnnotations[].detectionConfidence' $2 ;;
annotate4)            jq -r '.responses[].localizedObjectAnnotations[] | "\(.name) \(.score)"' $2 ;;
annotate5)            jq -r '.responses[].webDetection.fullMatchingImages[] |.url' $2 ;;
annotate6)            jq -r '.responses[].landmarkAnnotations[] | "\(.description) \(.score) \(.locations[].latLng)"' $2 ;;
*)                    jq . $2 ;;
esac

#          "locations": [
#            {
#              "latLng": {
#                "latitude": 55.752912,
#                "longitude": 37.622315883636475
#              }
#            }
#          ]
# curl https://maps.googleapis.com/maps/api/geocode/json?latlng=55.752912,37.622315883636475 #&key=YOUR_API_KEY
#{
#   "error_message" : "You must use an API key to authenticate each request to Google Maps Platform APIs. For additional information, please refer to http://g.co/dev/maps-no-account",
#   "results" : [],
#   "status" : "REQUEST_DENIED"
#}
