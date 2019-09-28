# Cognitive Artificial Intelligence


* [Amazon](https://aws.amazon.com/machine-learning/)
* [Google](https://cloud.google.com/products/ai/)
* [Microsoft](https://azure.microsoft.com/services/cognitive-services/)

***

## GCP (Google Cloud Platform)
* FIRST [before-you-begin](https://cloud.google.com/vision/docs/before-you-begin)
* SECOND [enable-api-for-project]()
### APIs
* List API services
```
$ gcloud services list --available
NAME                                                  TITLE
...
```
* Cognitive APIs
|NAME                                                  |TITLE|
|---|---|
|automl.googleapis.com                                 |Cloud AutoML API|
|cloudsearch.googleapis.com                            |Cloud Search API|
|dlp.googleapis.com                                    |Cloud Data Loss Prevention (DLP) API|
|jobs.googleapis.com                                   |Cloud Talent Solution API|
|language.googleapis.com                               |Cloud Natural Language API|
|ml.googleapis.com                                     |Cloud Machine Learning Engine|
|speech.googleapis.com                                 |Cloud Speech-to-Text API|
|texttospeech.googleapis.com                           |Cloud Text-to-Speech API|
|translate.googleapis.com                              |Cloud Translation API|
|videointelligence.googleapis.com                      |Cloud Video Intelligence API|
|vision.googleapis.com                                 |Cloud Vision API|

* Specific API service is not enabled error message
```
{
  "error": {
    "code": 403,
    "message": "Cloud Vision API has not been used in project 711533833686 before or it is disabled. Enable it by visiting https://console.cloud.google.com/apis/api/vision.googleapis.com/overview?project=711533833686 then retry. If you enabled this API recently, wait a few minutes for the action to propagate to our systems and retry.",
    "status": "PERMISSION_DENIED",
    "details": [
      {
        "@type": "type.googleapis.com/google.rpc.Help",
        "links": [
          {
            "description": "Google Cloud Console API activation",
            "url": "https://console.cloud.google.com/apis/api/vision.googleapis.com/overview?project=711533833686"
          }
        ]
      }
    ]
  }
}
```

### Detect text in a local image
Pprovide image data to the Vision API by specifying the URI path to the image, or by sending the image data as [base64-encoded text](https://cloud.google.com/vision/docs/base64).

* Check which is the current project
```
$ gcloud config get-value project 
bungabunga-123456
```
* Set the project
```
$ gcloud projects list
PROJECT_ID          NAME                PROJECT_NUMBER
cognitive-254305    cognitive           711533833686
bungabunga-123456   bungabunga          400688388535

$ gcloud config set project cognitive-254305
Updated property [core/project].

$ gcloud config get-value project 
cognitive-254305
```
* Enable the specific API
```
$ gcloud services enable vision.googleapis.com
Operation "operations/acf.7710a593-9a73-488d-81e4-1b6130afdab9" finished successfully.
```
* Prepare (input: PNG file "image1.png"; output: JSON file "request.json")
```
$ ./preprequest.sh  image1.png

$ grep content request.json|cut -f2 -d:|wc -c
  248720

$ grep -v content request.json|wc -c
     145

$ cat request.json
{
  "requests": [
    {
      "image": {
      "content": "<...removed...>"
      },
      "features": [
        {
          "type": "TEXT_DETECTION"
        }
      ]
    }
  ]
}
```
* Perform (input: JSON file "request.json")
```
$ ./runrequest.sh

$ grep -v ^# runrequest.sh
AUTH=$(gcloud auth application-default print-access-token 2>/dev/null)
REQ=request.json

[[ -z "$AUTH" ]] && { echo "***ENOAUTH"; exit 1; }
[[ -f "$REQ" ]]  || { echo "***ENOREQ"; exit 1; }

OUTPUT=result$RANDOM.json

URL=https://vision.googleapis.com/v1/images:annotate

curl -s -X POST \
-H "Authorization: Bearer "$AUTH \
-H "Content-Type: application/json; charset=utf-8" \
-d @$REQ \
$URL > $OUTPUT
[[ $? ]] || { echo "***EPOST"; exit 1; }
echo $OUTPUT
```
* Review
```
$ jq ".responses[].textAnnotations[0].description" result5236.json 
"Google is using deepfakes to fight deepfakes. With the 2020 US presidential\nelection approaching, the race is on to figure out how to prevent widespread\ndeepfake disinformation. On Tuesday, Google offered the latest contribution: an\nopen-source database containing 3,000 original manipulated videos. The goal\nis to help train and test automated detection tools. The company compiled the\ndata by working with 28 actors to record videos of them speaking, making\ncommon expressions, and doing mundane tasks. It then used publicly available\ndeepfake algorithms to alter their faces.\nGoogle isn't the first to take this approach. As we covered in The Algorithm\nearlier this month, Facebook announced that it would be releasing a similar\ndatabase near the end of the year. In January, an academic team led by a\nresearcher from the Technical University of Munich also created another called\nFaceForensics++. The trouble is technical solutions like these can only go so\nfar because synthetic media could soon become indistinguishable from reality\nRead more here.\n"

```

## AWS (Amazon Web Services)

## Azure (Microsoft Azure Cloud)
