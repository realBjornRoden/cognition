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

* API is not enabled error message
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
Pprovide image data to the Vision API by specifying the URI path to the image, or by sending the image data as base64-encoded text.
* [Base64 Encoding](https://cloud.google.com/vision/docs/base64)

* Check current project
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
* Enable API

gcloud services enable vision.googleapis.com


## AWS (Amazon Web Services)

## Azure (Microsoft Azure Cloud)
