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
[[ -z "$2" ]] && { echo "***ENOFILE"; exit 1; }
INPUT=$2
[[ -z "$3" ]] && { echo "***ENOLANG"; exit 1; }
SLANG=${3%%-*}
[[ -z "$SLANG" ]] && { echo "***ENOSOURCELANG"; exit 1; }
TLANG=${3##*-}
[[ -z "$TLANG" ]] && { echo "***ENOTARGETLANG"; exit 1; }

REQ=request.json
OUTPUT=result$RANDOM.json

case $1 in

translate-long)
	cat <<-EOD > request.json
		{ "SourceLanguageCode": "$SLANG", "TargetLanguageCode": "$TLANG", "Text": "$(<$INPUT)" }
	EOD
	[[ -f "$REQ" ]] ||  { echo "***ENOREQ"; exit 1; }

	aws translate translate-text --region us-east-2 --cli-input-json file://request.json | tee $OUTPUT
	[[ $? -ne 0 ]] && { echo "***EFAILED"; exit 1; }
;;

translate-short)
	aws translate translate-text --region us-east-2 --source-language-code "$SLANG" --target-language-code "$TLANG" --text "$(<$INPUT)" | tee $OUTPUT
	[[ $? -ne 0 ]] && { echo "***EFAILED"; exit 1; }
;;

*)
	echo "***ENOOP"; exit -1 ;;
esac
echo $OUTPUT
