#
# requests.sh
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
detect-text)
	aws rekognition $1 --image "$(<$REQ)" --region us-east-2 > $OUTPUT
	;;
*)
	echo "***ENOOP"; exit -1;;
esac

[[ $? -ne 0 ]] && { echo "***EFAILED"; exit 1; }
 
echo $OUTPUT
