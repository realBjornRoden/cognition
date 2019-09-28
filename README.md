# Cognitive Artificial Intelligence


* [Amazon](https://aws.amazon.com/machine-learning/)
* [Google](https://cloud.google.com/products/ai/)
* [Microsoft](https://azure.microsoft.com/services/cognitive-services/)

***

### Use cases
1. Detect text in a local image
1. Detect handwriting in a local image
1. Detect text in files


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
   * <i>NB.  Error message if the specific API service is not enabled when requesting</i>
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

***

### Detect text in a local image
* [Detect text in a local image](https://cloud.google.com/vision/docs/ocr)
* Provide image data to the Vision API by specifying the URI path to the image, or by sending the image data as [base64-encoded text](https://cloud.google.com/vision/docs/base64).

* Check if the required API is enabled, if not enable it
```
$ gcloud services list |grep vision.googleapis.com
vision.googleapis.com             Cloud Vision API

$ gcloud services enable vision.googleapis.com
Operation "operations/acf.7710a593-9a73-488d-81e4-1b6130afdab9" finished successfully.
```
* Prepare (input: PNG file "image1.png"; output: JSON file "request.json")
```
$ ./pre-request.sh annotate ../data/image1.png
request.json

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
$ ./run-request.sh annotate request.json
result31008.json
```
* Review (text from output JSON)
```
$ printf $(jq ".responses[].textAnnotations[0].description" result31008.json)

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

***

### Detect handwriting in a local image
* [Detect handwriting in a local image](https://cloud.google.com/vision/docs/handwriting)
* Provide image data to the Vision API by specifying the URI path to the image, or by sending the image data as [base64-encoded text](https://cloud.google.com/vision/docs/base64).

* Check if the required API is enabled, if not enable it
```
$ gcloud services list |grep vision.googleapis.com
vision.googleapis.com             Cloud Vision API

$ gcloud services enable vision.googleapis.com
Operation "operations/acf.7710a593-9a73-488d-81e4-1b6130afdab9" finished successfully.
```
* Prepare (input: PNG file "image1.png"; output: JSON file "request.json")
```
$ ./pre-request.sh annotate2 ../data/detect_handwriting_OCR-detect-handwriting_SMALL.png
request.json

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
          "type": "DOCUMENT_TEXT_DETECTION"
        }
      ]
    }
  ]
}
```
* Perform (input: JSON file "request.json"; output: JSON file "result$RANDOM.json)
```
$ ./run-request.sh annotate2 request.json
result11184.json
```
* Review (text from output JSON)
```
$ printf "$(jq '.responses[].textAnnotations[0].description' result11184.json)"

"Cloud
Google
Platform
```

***

### Detect text in files (PDF)
* [Detect text in files](https://cloud.google.com/vision/docs/pdf)
* Check if the required API is enabled, if not enable it
```
$ gcloud services list |grep vision.googleapis.com
vision.googleapis.com             Cloud Vision API

$ gcloud services enable vision.googleapis.com
Operation "operations/acf.7710a593-9a73-488d-81e4-1b6130afdab9" finished successfully.
```
* Create Google Cloud Storage Bucket
```
$ gcloud config get-value project 
cognitive-254305

$ gsutil mb gs://cognitive-254305
Creating gs://cognitive-254305/...

```
* Copy data to the Google Cloud Storage Bucket
```
$ gsutil cp data/letter1.pdf gs://$(gcloud config get-value project)
Copying file://data/letter1.pdf [Content-Type=application/pdf]...
- [1 files][ 21.1 KiB/ 21.1 KiB]                                                
Operation completed over 1 objects/21.1 KiB.                                     

$ gsutil ls -l gs://$(gcloud config get-value project)
     21578  2019-09-28T10:15:36Z  gs://cognitive-254305/letter1.pdf
TOTAL: 1 objects, 21578 bytes (21.07 KiB)

$ ls -l data/letter1.pdf 
-rw-r--r--@ 1 bjro  staff  21578 Sep 28 14:06 data/letter1.pdf
```
* Prepare (input: PNG file "image1.png"; output: JSON file "request.json")
```
$ gsutil cp data/letter1.pdf gs://$(gcloud config get-value project)

$ ./pre-request.sh asyncBatchAnnotate letter1.pdf
request.json

$ cat request.json
{
  "requests":[
    {
      "inputConfig": {
        "gcsSource": {
          "uri": "gs://cognitive-254305/letter1.pdf"
        },
        "mimeType": "application/pdf"
      },
      "features": [
        {
          "type": "DOCUMENT_TEXT_DETECTION"
        }
      ],
      "outputConfig": {
        "gcsDestination": {
          "uri": "gs://cognitive-254305/"
        },
        "batchSize": 1
      }
    }
  ]
}
```
* Perform (input: JSON file "request.json"; output: JSON file "result$RANDOM.json)
```
$ ./run-request.sh asyncBatchAnnotate
result10350.json
"projects/cognitive-254305/operations/5c7fc871d25e65b8"
```
* Review (check job; copy output JSON to local storage; extract text from output JSON)
```
$ jq '.name' result6909.json
"projects/cognitive-254305/operations/5c7fc871d25e65b8"

$ gsutil ls gs://$(gcloud config get-value project)/
gs://cognitive-254305/letter1.pdf
gs://cognitive-254305/output-1-to-1.json

$ gsutil cp gs://$(gcloud config get-value project)/output-1-to-1.json .
Copying gs://cognitive-254305/output-1-to-1.json...
- [1 files][179.5 KiB/179.5 KiB]                                                
Operation completed over 1 objects/179.5 KiB.        

$ STRING=$(jq '.responses[].fullTextAnnotation["text"]' output-1-to-1.json)

$ printf "$STRING"

"Urna Semper
1234 Main Street
Anytown, State ZIP
123-456-7890
no_reply@example.com
September 28, 2019
Trenz Pruca
4321 First Street
Anytown, State ZIP
Dear Trenz,
Lorem ipsum dolor sit amet, ligula suspendisse nulla pretium, rhoncus tempor
fermentum, enim integer ad vestibulum volutpat. Nisl rhoncus turpis est, vel elit,
congue wisi enim nunc ultricies sit, magna tincidunt. Maecenas aliquam maecenas
ligula nostra, accumsan taciti. Sociis mauris in integer, a dolor netus non dui aliquet,
sagittis felis sodales, dolor sociis mauris, vel eu libero cras. Faucibus at. Arcu habitasse
elementum est, ipsum purus pede porttitor class.
Ac dolor ac adipiscing amet bibendum nullam, lacus molestie ut libero nec, diam et,
pharetra sodales, feugiat ullamcorper id tempor id vitae. Mauris pretium aliquet,
lectus tincidunt. Porttitor mollis imperdiet libero senectus pulvinar. Etiam molestie
mauris ligula laoreet, vehicula eleifend. Repellat orci erat et, sem cum, ultricies
sollicitudin amet eleifend dolor.
Consectetuer arcu ipsum ornare pellentesque vehicula, in vehicula diam, ornare
magna erat felis wisi a risus. Justo fermentum id. Malesuada eleifend, tortor molestie,
a a vel et. Mauris at suspendisse, neque aliquam faucibus adipiscing, vivamus in. Wisi
mattis leo suscipit nec amet, nisl fermentum tempor ac a, augue in eleifend in
venenatis, cras sit id in vestibulum felis in, sed ligula.
Sincerely yours,
Urna Semper
```




## AWS (Amazon Web Services)

## Azure (Microsoft Azure Cloud)
