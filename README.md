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

* Enable the specific API with `gcloud services enable <API>`
   * NB. <i>Error message if the specific API service is not enabled when requesting</i>
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
* Check the currently active project
```
$ gcloud config get-value project 
bungabunga-123456
```
* Set the current project
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

### Detect text in a local image
* [Detect text in a local image](https://cloud.google.com/vision/docs/ocr)
* Provide image data to the Vision API by specifying the URI path to the image, or by sending the image data as [base64-encoded text](https://cloud.google.com/vision/docs/base64).

* Enable the specific API
```
$ gcloud services enable vision.googleapis.com
Operation "operations/acf.7710a593-9a73-488d-81e4-1b6130afdab9" finished successfully.
```
* Prepare (input: PNG file "image1.png"; output: JSON file "request.json")
```
$ ./pre-request.sh ../images/image1.png

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
* Perform (input: JSON file "request.json"; output: JSON file "result$RANDOM.json)
```
$ ./run-request.sh request.json
result31008.json
```
* Review
```
$ ./post-request.sh result31008.json --output printf
"Google is using deepfakes to fight deepfakes. With the 2020 US presidential
election approaching, the race is on to figure out how to prevent widespread
deepfake disinformation. On Tuesday, Google offered the latest contribution: an
open-source database containing 3,000 original manipulated videos. The goal
is to help train and test automated detection tools. The company compiled the
data by working with 28 actors to record videos of them speaking, making
common expressions, and doing mundane tasks. It then used publicly available
deepfake algorithms to alter their faces.
Google isn't the first to take this approach. As we covered in The Algorithm
earlier this month, Facebook announced that it would be releasing a similar
database near the end of the year. In January, an academic team led by a
researcher from the Technical University of Munich also created another called
FaceForensics++. The trouble is technical solutions like these can only go so
far because synthetic media could soon become indistinguishable from reality
Read more here.
```

### 

## AWS (Amazon Web Services)

## Azure (Microsoft Azure Cloud)
