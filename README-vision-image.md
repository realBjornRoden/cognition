# Cognitive Artificial Intelligence - Vision Image


* [Amazon (AWS)](https://aws.amazon.com/machine-learning/)
* [Google (GCP)](https://cloud.google.com/products/ai/)
* [Microsoft (Azure)](https://azure.microsoft.com/services/cognitive-services/)

***

## Use Cases
1. Detect text in images
1. Detect handwriting in images
1. Detect text in files
1. Detect faces in images
1. Detect multiple objects in images
1. Detect web references to an image
1. Detect landmarks in images

***

## GCP (Google Cloud Platform)

*  Create project, service account, download service account key file and enable API [before-you-begin](https://cloud.google.com/vision/docs/before-you-begin)

***

1. Authenticate CLI session with `gcloud auth login`

1. Set the environment variable GOOGLE_APPLICATION_CREDENTIALS to point to the location of the service account key file
   ```
   export GOOGLE_APPLICATION_CREDENTIALS=$PWD/cognitive-aab254879251.json
   ```
1. Check the currently active project
   ```
   $ gcloud config get-value project 
   bungabunga-123456
   ```
1. Set the current project
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

* [Enable API](https://cloud.google.com/endpoints/docs/openapi/enable-api)
```
$ gcloud services list | grep vision.googleapis.com
vision.googleapis.com             Cloud Vision API

$ gcloud services enable vision.googleapis.com
Operation "operations/acf.7710a593-9a73-488d-81e4-1b6130afdab9" finished successfully.
```
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

***

### Detect text in images
* [Detect text in a local image](https://cloud.google.com/vision/docs/ocr)
* Provide image data to the Vision API by specifying the URI path to the image, or by sending the image data as [base64-encoded text](https://cloud.google.com/vision/docs/base64).
***

* Check project, credentials environment variable and if the required API is enabled
```
$ gcloud config get-value project 
cognitive-254305

$ export GOOGLE_APPLICATION_CREDENTIALS=$PWD/cognitive-aab254879251.json

$ gcloud services list | grep vision.googleapis.com
vision.googleapis.com             Cloud Vision API
```
* Prepare (input: PNG file "texttyped1.png"; output: JSON file "request.json")
```
$ ./pre-request.sh annotate1 ../data/texttyped1.png
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
$ jq -r ".responses[].textAnnotations[0].description" result31008.json
Google is using deepfakes to fight deepfakes. With the 2020 US presidential
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

### Detect handwriting in images
* [Detect handwriting in a local image](https://cloud.google.com/vision/docs/handwriting)
* Provide image data to the Vision API by specifying the URI path to the image, or by sending the image data as [base64-encoded text](https://cloud.google.com/vision/docs/base64).
***

* Check project, credentials environment variable and if the required API is enabled
```
$ gcloud config get-value project 
cognitive-254305

$ export GOOGLE_APPLICATION_CREDENTIALS=$PWD/cognitive-aab254879251.json

$ gcloud services list | grep vision.googleapis.com
vision.googleapis.com             Cloud Vision API
```
* Prepare (input: PNG file "texthandwriting1.png"; output: JSON file "request.json")
```
$ ./pre-request.sh annotate2 ../data/texthandwriting1.png
request.json

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
$ jq -r '.responses[].textAnnotations[0].description' result11184.json
Cloud
Google
Platform
```

***

### Detect text in files
* [Detect text in files](https://cloud.google.com/vision/docs/pdf)
***

* Check project, credentials environment variable and if the required API is enabled
```
$ gcloud config get-value project 
cognitive-254305

$ export GOOGLE_APPLICATION_CREDENTIALS=$PWD/cognitive-aab254879251.json

$ gcloud services list | grep vision.googleapis.com
vision.googleapis.com             Cloud Vision API
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
* Prepare (input: PNG file "letter1.pdf"; output: JSON file "request.json")
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

$ jq -r '.responses[].fullTextAnnotation["text"]' output-1-to-1.json
Urna Semper
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

### Detect Faces in images
* [Detect Faces in a local image](https://cloud.google.com/vision/docs/detecting-faces)
* Provide image data to the Vision API by specifying the URI path to the image, or by sending the image data as [base64-encoded text](https://cloud.google.com/vision/docs/base64).
<br><img src="https://www.nih.gov/sites/default/files/news-events/research-matters/2014/20140428-attention.jpg" width="50%" /><br>
***

* Check project, credentials environment variable and if the required API is enabled
```
$ gcloud config get-value project 
cognitive-254305

$ export GOOGLE_APPLICATION_CREDENTIALS=$PWD/cognitive-aab254879251.json

$ gcloud services list | grep vision.googleapis.com
vision.googleapis.com             Cloud Vision API
```
* Prepare (input: PNG file "faces1.jpg"; output: JSON file "request.json")
```
$ ./pre-request.sh annotate3 ../data/faces1.jpg
request.json

$ cat request.json
{
  "requests": [
    {
      "image": {
      "content": "<...removed...>"
      },
      "features": [
        {
          "maxResults": 10,
          "type": "FACE_DETECTION"
        }
      ]
    }
  ]
}
```
* Perform (input: JSON file "request.json"; output: JSON file "result$RANDOM.json)
```
$ ./run-request.sh annotate3 request.json
result12945.json
```
* Review (text from output JSON) - for expanded view use `jq . <output JSON filename>`
```
$ jq '.responses[].faceAnnotations[].detectionConfidence' result12945.json
0.7988144
0.99993396
0.85146695
0.8147049
0.7686665
0.6784521
```

### Detect multiple objects in images
* [Detect multiple objects in images](https://cloud.google.com/vision/docs/object-localizer)
* Provide image data to the Vision API by specifying the URI path to the image, or by sending the image data as [base64-encoded text](https://cloud.google.com/vision/docs/base64).
***

* Check project, credentials environment variable and if the required API is enabled
```
$ gcloud config get-value project 
cognitive-254305

$ export GOOGLE_APPLICATION_CREDENTIALS=$PWD/cognitive-aab254879251.json

$ gcloud services list | grep vision.googleapis.com
vision.googleapis.com             Cloud Vision API
```
* Prepare (input: PNG file "multiple1.jpeg"; output: JSON file "request.json")
```
$ ./pre-request.sh annotate4 ../data/multiple1.jpeg
request.json

$ cat request.json
{
  "requests": [
    {
      "image": {
      "content": "<...removed...>"
      },
      "features": [
        {
          "maxResults": 10,
          "type": "OBJECT_LOCALIZATION"
        }
      ]
    }
  ]
}
```
* Perform (input: JSON file "request.json"; output: JSON file "result$RANDOM.json)
```
$ ./run-request.sh annotate4 request.json
result31276.json
```
* Review (text from output JSON)
```
$ jq -r '.responses[].localizedObjectAnnotations[] | "\(.name) \(.score)"' result31276.json
Bicycle wheel 0.93440825
Bicycle wheel 0.9333072
Bicycle 0.9044979
Picture frame 0.6551748
```

### Detect web references to an image
* [Detect Web entities and pages](https://cloud.google.com/vision/docs/detecting-web)
* Provide image data to the Vision API by specifying the URI path to the image, or by sending the image data as [base64-encoded text](https://cloud.google.com/vision/docs/base64).
***

* Check project, credentials environment variable and if the required API is enabled
```
$ gcloud config get-value project 
cognitive-254305

$ export GOOGLE_APPLICATION_CREDENTIALS=$PWD/cognitive-aab254879251.json

$ gcloud services list | grep vision.googleapis.com
vision.googleapis.com             Cloud Vision API
```
* Prepare (input: PNG file "multiple1.jpeg"; output: JSON file "request.json")
```
$ ./pre-request.sh annotate5 ../data/multiple1.jpeg
request.json

$ cat request.json
{
  "requests": [
    {
      "image": {
      "content": "<...removed...>"
      },
      "features": [
        {
          "maxResults": 10,
          "type": "WEB_DETECTION"
        }
      ]
    }
  ]
}
```
* Perform (input: JSON file "request.json"; output: JSON file "result$RANDOM.json)
```
$ ./run-request.sh annotate5 request.json
result23353.json
```
* Review (text from output JSON)
```
$ jq -r '.responses[].webDetection.fullMatchingImages[] |.url' result23353.json
https://mosaicovero.co.za/wp-content/uploads/2018/03/MVG-550-Copenhagen-copy-2.jpg
https://static1.squarespace.com/static/59d0a313be42d658b89bd39b/5b718b39c2241b31de2fd1bf/5c791b42652deaaa562e8b3d/1554359551823/bogdan-dada-279935-unsplash.jpg?format=2500w
https://kapost.com/b/wp-content/uploads/sites/4/2018/02/street-cred-compressor.jpg
http://www.dukefotografia.com/blog/wp-content/uploads/2018/03/photo-1496864137062-a12b5defe6be.jpg
https://i0.wp.com/www.aviasales.ru/blog/wp-content/uploads/2018/01/photo-1496864137062-a12b5defe6be.jpeg?ssl=1
https://cdn.shopify.com/s/files/1/0247/0717/0403/files/bogdan-dada-279935-unsplash_1400x.progressive.jpg?v=1555789235
https://www.dom-comfort.kz/wp-content/uploads/2017/11/photo-1496864137062-a12b5defe6be.jpg
https://868077240903148220.weebly.com/uploads/1/1/7/9/117963265/architecture-2562316-1920_2_orig.jpg
http://elheraldoslp.com.mx/wp-content/uploads/2019/02/S3.jpg
https://travelandleisure.mx/wp-content/uploads/2019/01/bogdan-dada-279935-unsplash.jpg
```
* Download each image to inspect further
```
$ mkdir tmp
$ cd tmp
$ jq -r '.responses[].webDetection.fullMatchingImages[] |.url' ../result23353.json > image.list
$ wget --quiet --continue --timestamping --tries=1 --input-file=image.list
```

***

### Detect landmarks in images
* [Detect landmarks](https://cloud.google.com/vision/docs/detecting-landmarks)
* [Reverse geocoding for Google Map API](https://developers.google.com/maps/documentation/geocoding/intro#ReverseGeocoding)
* Provide image data to the Vision API by specifying the URI path to the image, or by sending the image data as [base64-encoded text](https://cloud.google.com/vision/docs/base64).
***

* Check project, credentials environment variable and if the required API is enabled
```
$ gcloud config get-value project 
cognitive-254305

$ export GOOGLE_APPLICATION_CREDENTIALS=$PWD/cognitive-aab254879251.json

$ gcloud services list | grep vision.googleapis.com
vision.googleapis.com             Cloud Vision API
```
* Prepare (input: PNG file "landmark1.jpeg"; output: JSON file "request.json")
```
$ ./pre-request.sh annotate6 ../data/landmark1.jpeg
request.json

$ cat request.json
{
  "requests": [
    {
      "image": {
      "content": "<...removed...>"
      },
      "features": [
        {
          "maxResults": 10,
          "type": "LANDMARK_DETECTION"
        }
      ]
    }
  ]
}
```
* Perform (input: JSON file "request.json"; output: JSON file "result$RANDOM.json)
```
$ ./run-request.sh annotate6 request.json
result12922.json
```
* Review (text from output JSON)
```
$ jq -r '.responses[].landmarkAnnotations[] | "\(.description) \(.score) \(.locations[].latLng)"' result12922.json
St. Basil's Cathedral 0.90775275 {"latitude":55.752522899999995,"longitude":37.623086799999996}
Saint Basil's Cathedral 0.89397573 {"latitude":55.752912,"longitude":37.622315883636475}
```

### Detect landmarks in and web references of an image (combined)
***
* Add the types within the "features" brackets `[...]`
```
{ "requests": [ { "image": { "content": "$(<$B64)" }, "features": [ { "type": "LANDMARK_DETECTION" },{ "type": "WEB_DETECTION" } ] } ] }
```
* Review (text from output JSON) 
```
$ jq -r '.responses[].landmarkAnnotations[] | "\(.description) \(.score) \(.locations[].latLng)"' google-output.json
$ jq -r '.responses[].webDetection.fullMatchingImages[] |.url' google-output.json
```





## Azure (Microsoft Azure Cloud)
* [Azure Cognitive Services](https://docs.microsoft.com/en-us/azure/cognitive-services/welcome)
* [Azure Computer Vision Service](https://docs.microsoft.com/en-us/azure/cognitive-services/computer-vision/home)
* [Create a Cognitive Services resource using the Azure CLI](https://docs.microsoft.com/en-us/azure/cognitive-services/cognitive-services-apis-create-account-cli?tabs=windows)
* [az cognitiveservices](https://docs.microsoft.com/en-us/cli/azure/cognitiveservices?view=azure-cli-latest#az_cognitiveservices_list)
* [Azure Cognitive Services Authentication](https://docs.microsoft.com/en-us/azure/cognitive-services/authentication)

***

* Prerequisites are to have a valid and activated Azure account and an Azure Cognitive Services subscription within a Azure Resource Group

1. Sign in to Azure
   ```
   $ az login
   Note, we have launched a browser for you to login. For old experience with device code, use "az login --use-device-code"
   You have logged in. Now let us find all the subscriptions to which you have access...
   [
     {
       "cloudName": "AzureCloud",
       "id": "deadbeef-e904-4c8e-a3d8-5503f0e310e7",
       "isDefault": true,
       "name": "Free Trial",
       "state": "Enabled",
       "tenantId": "deadbeef-3411-4054-a56e-18809a214004",
       "user": {
         "name": "USER@FQDN",
         "type": "user"
       }
     }
   ]
   ```
1. Choose resource group location

   |INSTANCE    |TRANSACTIONS PER SECOND (TPS)    |FEATURES    |
   |---                 |---                                                             |---                  |
   |Free    |2 TPS    |Upload, training, and prediction transactions
   |||Up to 2 projects
   |||Up to 1 hour training per month|
   |||5,000 training images free per project
   |||10,000 predictions per month|
   
   ```
   $ az account list-locations --query "[].{Region:name}" --out table|grep euro
   northeurope
   westeurope

   $ az account list-locations --query "[].{Region:name}" --out table|grep -E "us\$|us[0-9]\$"
   centralus
   eastus
   eastus2
   westus
   northcentralus
   southcentralus
   westcentralus
   westus2
   ```
1. Create a Azure Cognitive Services resource group
   ```
   $ az group create --name cognitive-services-resource-group --location westus2
   {
      "id": "/subscriptions/deadbeef-e904-4c8e-a3d8-5503f0e310e7/resourceGroups/cognitive-services-resource-group",
      "location": "westus2",
      "managedBy": null,
      "name": "cognitive-services-resource-group",
      "properties": {
        "provisioningState": "Succeeded"
      },
      "tags": null,
      "type": null
    }

    $ az group create --name cognitive-services-resource-group --location westus
     {
     "id": "/subscriptions/deadbeef-e904-4c8e-a3d8-5503f0e310e7/resourceGroups/cognitive-services-resource-group",
     "location": "westus",
     "managedBy": null,
     "name": "cognitive-services-resource-group",
     "properties": {
     "provisioningState": "Succeeded"
     },
     "tags": null,
     "type": null
   }
   ```
1. Determine available Cognitive Service resources
   ```
   $ az cognitiveservices account list-kinds --output table --subscription deadbeef-e904-4c8e-a3d8-5503f0e310e7
   Result
   -----------------------
   AnomalyDetector
   Bing.Autosuggest.v7
   Bing.CustomSearch
   Bing.EntitySearch
   Bing.Search.v7
   Bing.SpellCheck.v7
   CognitiveServices
   ComputerVision
   ContentModerator
   CustomVision.Prediction
   CustomVision.Training
   Face
   ImmersiveReader
   InkRecognizer
   Internal.AllInOne
   LUIS
   LUIS.Authoring
   Personalizer
   QnAMaker
   SpeakerRecognition
   SpeechServices
   TextAnalytics
   TextTranslation
   ```
1. Add a Cognitive Service resource to the resource group (F0 free)
   ```
   $ az cognitiveservices account create --name computer-vision --kind ComputerVision --resource-group cognitive-services-resource-group --sku F0 --location westus2 --yes
   {
     "customSubDomainName": null,
     "endpoint": "https://westus2.api.cognitive.microsoft.com/",
     "etag": "\"0b0026c1-0000-0800-0000-5d92d59d0000\"",
     "id": "/subscriptions/deadbeef-e904-4c8e-a3d8-5503f0e310e7/resourceGroups/cognitive-services-resource-group/providers/Microsoft.CognitiveServices/accounts/computer-vision",
      "internalId": "deadbeef5739424698825e2192e2ed00",
     "kind": "ComputerVision",
     "location": "westus2",
     "name": "computer-vision",
     "networkAcls": null,
     "provisioningState": "Succeeded",
     "resourceGroup": "cognitive-services-resource-group",
    "sku": {
       "name": "F0",
       "tier": null
     },
     "tags": null,
     "type": "Microsoft.CognitiveServices/accounts"
    }

   $ az cognitiveservices account create --name face-api --kind Face --resource-group cognitive-services-resource-group --sku F0 --location westus2 --yes
   {
     "customSubDomainName": null,
     "endpoint": "https://westus2.api.cognitive.microsoft.com/face/v1.0",
     "etag": "\"0b00c5d1-0000-0800-0000-5d9306f80000\"",
     "id": "/subscriptions/deadbeef-e904-4c8e-a3d8-5503f0e310e7/resourceGroups/cognitive-services-resource-group/providers/Microsoft.CognitiveServices/accounts/face-api",
     "internalId": "deadbeef5239498da16b3d615bfbf430",
     "kind": "Face",
     "location": "westus2",
     "name": "face-api",
     "networkAcls": null,
     "provisioningState": "Succeeded",
     "resourceGroup": "cognitive-services-resource-group",
     "sku": {
        "name": "F0",
        "tier": null
     },
     "tags": null,
     "type": "Microsoft.CognitiveServices/accounts"
   }
   ```
   * If the required service is not added, a similar error message will be returned when requesting use of the service
      ```
      {
        "error": {
          "code": "401",
          "message": "The Face - Detect Operation under Face API - V1.0 API is not supported with the current subscription key and pricing tier ComputerVision.F0."
        }
      }
      ```
1. Get the keys for the Cognitive Service resource.
   ```
   $ az cognitiveservices account keys list --name computer-vision --resource-group cognitive-services-resource-group
   {
     "key1": "deadbeef3e5f4bd5a22501aff861d411",
     "key2": "deadbeef7084476a9b898d6cbe4fab54"
   }

   $ az cognitiveservices account keys list --name face-api --resource-group cognitive-services-resource-group
   {
     "key1": "deadbeef0acc1441e95017bb2a43a96a7",
     "key2": "deadbeef198d4e6590d1b70ec47b0145"
   }
   ```
1. Set environment `COGNITIVE_SERVICE_KEY` variable with one of the keys for the resource
    ```
   $ export COGNITIVE_SERVICE_KEY=deadbeef3e5f4bd5a22501aff861d411
   ```
1. Cleanup (after temporary usage)
   ```
   $ az group delete --name cognitive-services-resource-group
   Are you sure you want to perform this operation? (y/n): y
   ```

***

### Detect text in images
***
* Verify the file content type of the input file (that it is an image)
```
$ file ../data/texttyped1.png 
../data/texttyped1.png: PNG image data, 1290 x 856, 8-bit/color RGBA, non-interlaced
```
* Perform (input: "texttyped1.png"; output: JSON file "result$RANDOM.json)
```
$ ./run-request.sh vision-ocr ../data/texttyped1.png
result28340.json
```
* Review (text from output JSON)
```
$ jq -r '.regions[].lines[].words[].text' result28340.json |tr '\n' ' ' ;echo
Google is using deepfakes to fight deepfakes. With the 2020 US presidential election approaching, the race is on to figure out how to prevent widespread deepfake disinformation. On Tuesday, Google offered the latest contribution: an open-source database containing 3,000 original manipulated videos. The goal is to help train and test automated detection tools. The company compiled the data by working with 28 actors to record videos of them speaking, making common expressions, and doing mundane tasks. It then used publicly available deepfake algorithms to alter their faces. Google isn't the first to take this approach. As we covered in The Algorithm earlier this month, Facebook announced that it would be releasing a similar database near the end of the year. In January, an academic team led by a researcher from the Technical University of Munich also created another called FaceForensics++. The trouble is technical solutions like these can only go so far because synthetic media could soon become indistinguishable from reality. Read more here.
```

***

### Detect handwriting in images
***

* Verify the file content type of the input file (that it is an image)
```
$ ./pre-request.sh vision-ink ../data/texthandwriting1.png
../data/texthandwriting1.png: PNG image data, 500 x 323, 8-bit/color RGB, non-interlaced
```
* Perform (input: "texthandwriting1.png"; output: JSON file "result$RANDOM.json)
```
$ ./run-request.sh vision-ocr-hand ../data/texthandwriting1.png
result22465.json
```
* Review (text from output JSON)
```
$ jq . result22465.json
{
  "language": "en",
  "textAngle": 0,
  "orientation": "NotDetected",
  "regions": []
}
```

***

### Detect text in files
***
* Two step process:
   1. Batch Read File operation to submit the OCR operation, return "Operation-Location" with the URL for the next step 
   1. Get Read Operation Result operation to access OCR results

* Verify the file content type of the input file (that it is an image)
```
$ ./pre-request.sh vision-pdf http://www.africau.edu/images/default/sample.pdf
request.json

$ jq . request.json 
{
  "url": "http://www.africau.edu/images/default/sample.pdf"
}
```
* Perform (input: JSON file "request.json"; 1st output: "Operation-Location"; 2nd output: JSON file "result$RANDOM.json)
```
$ ./run-request.sh vision-pdf request.json
***OCRBATCH  Operation-Location: deadbeef-37ee-419f-8709-007bf64a0c8a

$ ./run-request.sh vision-readop request.json deadbeef-37ee-419f-8709-007bf64a0c8a
***READOP Operation-Location: deadbeef-37ee-419f-8709-007bf64a0c8a
result16131.json
```
* Review (text from output JSON)
```
$ ./post-request.sh vision-pdf result16131.json
A Simple PDF File This is a small demonstration .pdf file - just for use in the Virtual Mechanics tutorials. More text. And more text. And more text. And more text. And more text. And more text. And more text. And more text. And more text. And more text. And more text. Boring, zzzzz. And more text. And more text. And more text. And more text. And more text. And more text. And more text. And more text. And more text. And more text. And more text. And more text. And more text. And more text. And more text. And more text. Even more. Continued on page 2 ... Simple PDF File 2 ...continued from page 1. Yet more text. And more text. And more text. And more text. And more text. And more text. And more text. And more text. Oh, how boring typing this stuff. But not as boring as watching paint dry. And more text. And more text. And more text. And more text. Boring. More, a little more text. The end, and just as well. 
```

***

### Detect Faces in images (Vision with visualFeatures for Faces API)
***

<br><img src="https://cloud.google.com/vision/docs/images/faces.png" width="50%" /><br>

* Prepare (input: PNG file "URL/faces.png"; output: JSON file "request.json")
```
$ ./pre-request.sh vision-face-identify https://cloud.google.com/vision/docs/images/faces.png
request.json

$ jq . request.json 
{
  "url": "https://cloud.google.com/vision/docs/images/faces.png"
}
```
* Perform (input: JSON file "request.json"; output: JSON file "result$RANDOM.json)
```
$ ./run-request.sh vision-face-identify request.json
result21321.json
```
* Review (text from output JSON) - for expanded view use `jq . <output JSON filename>`
```
$ jq '.faces[],.metadata' result21321.json 
{
  "age": 10,
  "gender": "Female",
  "faceRectangle": {
    "left": 208,
    "top": 98,
    "width": 128,
    "height": 128
  }
}
{
  "age": 7,
  "gender": "Female",
  "faceRectangle": {
    "left": 666,
    "top": 96,
    "width": 127,
    "height": 127
  }
}
{
  "age": 1,
  "gender": "Male",
  "faceRectangle": {
    "left": 41,
    "top": 269,
    "width": 81,
    "height": 66
  }
}
{
  "width": 910,
  "height": 336,
  "format": "Png"
}
```

***

### Detect Faces in images (Face API)
* The stored face features will expire and be deleted 24 hours after the original detection call.
* [Get face detection data](https://docs.microsoft.com/en-us/azure/cognitive-services/face/face-api-how-to-topics/howtodetectfacesinimage)
<br><img src="https://www.nih.gov/sites/default/files/news-events/research-matters/2014/20140428-attention.jpg" width="50%" /><br>
***

* Prepare (input: PNG file "URL/faces.png"; output: JSON file "request.json")
```
$ ./pre-request.sh face-detect https://cloud.google.com/vision/docs/images/faces.png
request.json

$ jq . request.json 
{
  { "url" : "https://cloud.google.com/vision/docs/images/faces.png", recognitionModel: "recognition_02", detectionModel: "detection_02" }
}
```
* Perform (input: JSON file "request.json"; output: JSON file "result$RANDOM.json)
```
$ ./run-request.sh face-detect request.json
result2306.json
```
* Review (text from output JSON) - for compact view use `cat <output JSON filename>`
```
jq . result2306.json # cat result2306.json
[
  {
    "faceId": "c44eb1c9-5f0a-4507-8f7e-8984a10899e3",
    "faceRectangle": {
      "top": 98,
      "left": 208,
      "width": 128,
      "height": 128
    }
  },
  {
    "faceId": "b5540f79-5fe2-4419-9e08-35817839a2b3",
    "faceRectangle": {
      "top": 96,
      "left": 666,
      "width": 127,
      "height": 127
    }
  },
  {
    "faceId": "4fd1bac1-b056-457a-a97f-d00184734b70",
    "faceRectangle": {
      "top": 269,
      "left": 41,
      "width": 81,
      "height": 66
    }
  }
]
```

***

### Detect Faces in images (Face API)
* The stored face features will expire and be deleted 24 hours after the original detection call.
<br><img src="https://www.nih.gov/sites/default/files/news-events/research-matters/2014/20140428-attention.jpg" width="50%" /><br>
***

* Prepare (input: PNG file "URL/faces.png"; output: JSON file "request.json")
```
$ ./pre-request.sh face-detect https://www.nih.gov/sites/default/files/news-events/research-matters/2014/20140428-attention.jpg
request.json

$ jq . request.json 
{
  "url": "https://www.nih.gov/sites/default/files/news-events/research-matters/2014/20140428-attention.jpg",
  "recognitionModel": "recognition_02",
  "detectionModel": "detection_02"
}
```
* Perform (input: JSON file "request.json"; output: JSON file "result$RANDOM.json)
```
$ ./run-request.sh face-detect request.json
result5214.json
```
* Review (text from output JSON) - for expanded view use `jq . <output JSON filename>`
```
$ cat result5214.json # jq . result5214.json
[{"faceId":"d60422dd-13ff-4fe8-9220-4062635e7cd1","faceRectangle":{"top":992,"left":838,"width":298,"height":298}},{"faceId":"15952a36-6ac0-404e-9aaf-b877c7e694ab","faceRectangle":{"top":546,"left":327,"width":236,"height":236}},{"faceId":"1b4a6421-e8a1-455d-a87c-d03c4898adf2","faceRectangle":{"top":489,"left":1742,"width":221,"height":221}},{"faceId":"5774433f-0538-46ac-8d8f-94f45074aa84","faceRectangle":{"top":244,"left":467,"width":209,"height":209}},{"faceId":"3bf3ca92-fdbe-46e3-92e5-48c3b01be8b9","faceRectangle":{"top":326,"left":790,"width":207,"height":207}},{"faceId":"f81dd662-a7fa-47bb-affb-7e03d2d24e9d","faceRectangle":{"top":172,"left":234,"width":155,"height":155}},{"faceId":"40ae3733-28e8-497c-9c27-37d6fd80a22d","faceRectangle":{"top":165,"left":1337,"width":152,"height":152}},{"faceId":"7c0905a2-f679-4571-b921-44f6fd85c9a4","faceRectangle":{"top":3,"left":363,"width":137,"height":137}}]/Users/bjro/code/cloudactions/cognition/azure: 
```

***

### Detect Faces in images and details (Face API)
* The stored face features will expire and be deleted 24 hours after the original detection call.
* Optional parameters include faceId, landmarks, and attributes. Besides face rectangles and landmarks, the face detection API can analyze several conceptual attributes of a face. Attributes include age, gender, headPose, smile, facialHair, glasses, emotion, hair, makeup, occlusion, accessories, blur, exposure and noise. Some of the results returned for specific attributes may not be highly accurate.
* [Face detection and attributes](https://docs.microsoft.com/en-us/azure/cognitive-services/face/concepts/face-detection#attributes)
* [Face landmarks](https://docs.microsoft.com/en-us/azure/cognitive-services/face/images/landmarks.1.jpg)
<br><img src="https://docs.microsoft.com/en-us/azure/cognitive-services/face/images/landmarks.1.jpg" alt="Face Landmarks" width="50%"/><br>
* [Head pose](https://docs.microsoft.com/en-us/azure/cognitive-services/face/images/headpose.1.jpg)
<br><img src="https://docs.microsoft.com/en-us/azure/cognitive-services/face/images/headpose.1.jpg" alt="Head Pose" width="50%"/><br>
***

* Prepare (input: PNG file "URL/faces.png"; output: JSON file "request.json")
```
$ ./pre-request.sh face-detect-details https://cloud.google.com/vision/docs/images/faces.png
request.json

$ jq . request.json 
{
  "url": "https://cloud.google.com/vision/docs/images/faces.png"
}
```
* Perform (input: JSON file "request.json"; output: JSON file "result$RANDOM.json)
```
$ ./run-request.sh face-detect-details request.json
result1651.json
```
* Review (text from output JSON) - for expanded view use `jq . <output JSON filename>`
```
$ cat result1651.json # jq . result1651.json
[{"faceId":"22e3f84a-f030-4fbc-a9de-951be08cee3d","faceRectangle":{"top":98,"left":208,"width":128,"height":128},"faceAttributes":{"smile":0.998,"headPose":{"pitch":-5.4,"roll":0.1,"yaw":-15.7},"gender":"female","age":6.0,"facialHair":{"moustache":0.0,"beard":0.0,"sideburns":0.0},"glasses":"NoGlasses","emotion":{"anger":0.0,"contempt":0.0,"disgust":0.0,"fear":0.0,"happiness":0.998,"neutral":0.0,"sadness":0.0,"surprise":0.002},"blur":{"blurLevel":"low","value":0.11},"exposure":{"exposureLevel":"goodExposure","value":0.55},"noise":{"noiseLevel":"low","value":0.0},"makeup":{"eyeMakeup":false,"lipMakeup":false},"accessories":[],"occlusion":{"foreheadOccluded":false,"eyeOccluded":false,"mouthOccluded":false},"hair":{"bald":0.22,"invisible":false,"hairColor":[{"color":"brown","confidence":0.95},{"color":"red","confidence":0.86},{"color":"other","confidence":0.36},{"color":"blond","confidence":0.31},{"color":"black","confidence":0.28},{"color":"gray","confidence":0.08}]}}},
{"faceId":"c862af46-ec5e-4c20-92b8-e380791c1a49","faceRectangle":{"top":96,"left":666,"width":127,"height":127},"faceAttributes":{"smile":0.978,"headPose":{"pitch":0.0,"roll":0.1,"yaw":-15.0},"gender":"female","age":6.0,"facialHair":{"moustache":0.0,"beard":0.0,"sideburns":0.0},"glasses":"NoGlasses","emotion":{"anger":0.0,"contempt":0.001,"disgust":0.0,"fear":0.0,"happiness":0.978,"neutral":0.02,"sadness":0.0,"surprise":0.001},"blur":{"blurLevel":"low","value":0.0},"exposure":{"exposureLevel":"goodExposure","value":0.55},"noise":{"noiseLevel":"low","value":0.0},"makeup":{"eyeMakeup":false,"lipMakeup":false},"accessories":[],"occlusion":{"foreheadOccluded":false,"eyeOccluded":false,"mouthOccluded":false},"hair":{"bald":0.34,"invisible":false,"hairColor":[{"color":"brown","confidence":0.96},{"color":"black","confidence":0.67},{"color":"red","confidence":0.42},{"color":"blond","confidence":0.37},{"color":"other","confidence":0.23},{"color":"gray","confidence":0.16}]}}},
{"faceId":"dc844c91-b4d1-4606-8acc-7f34ea2646a1","faceRectangle":{"top":269,"left":41,"width":81,"height":66},"faceAttributes":{"smile":0.002,"headPose":{"pitch":-10.2,"roll":-13.4,"yaw":-14.5},"gender":"male","age":2.0,"facialHair":{"moustache":0.0,"beard":0.0,"sideburns":0.0},"glasses":"NoGlasses","emotion":{"anger":0.0,"contempt":0.001,"disgust":0.0,"fear":0.0,"happiness":0.002,"neutral":0.973,"sadness":0.024,"surprise":0.0},"blur":{"blurLevel":"high","value":1.0},"exposure":{"exposureLevel":"goodExposure","value":0.71},"noise":{"noiseLevel":"high","value":0.79},"makeup":{"eyeMakeup":false,"lipMakeup":false},"accessories":[],"occlusion":{"foreheadOccluded":false,"eyeOccluded":false,"mouthOccluded":false},"hair":{"bald":0.05,"invisible":false,"hairColor":[{"color":"brown","confidence":0.99},{"color":"blond","confidence":0.52},{"color":"black","confidence":0.51},{"color":"red","confidence":0.32},{"color":"gray","confidence":0.16},{"color":"other","confidence":0.1}]}}}] 
```

***

### Detect multiple objects in images
***

* Prepare (input: PNG file "URL/Italian-Sign-Bogdan-Dada-Unsplash.jpg"; output: JSON file "request.json")
```
$ ./pre-request.sh vision-objects https://educationaltravelforlife.com/wp-content/uploads/2018/12/Italian-Sign-Bogdan-Dada-Unsplash.jpg
request.json

$ jq . request.json 
{
  "url": "https://educationaltravelforlife.com/wp-content/uploads/2018/12/Italian-Sign-Bogdan-Dada-Unsplash.jpg"
}
```
* Perform (input: JSON file "request.json"; output: JSON file "result$RANDOM.json)
```
$ ./run-request.sh vision-objects request.json
result12311.json
```
* Review (text from output JSON)
```
$ jq -r '.objects[] | "\(.object) \(.confidence)"' result12311.json|sort -k2rn
bicycle 0.88
Wheel 0.674
Wheel 0.533
```

***
### Detect web references to an image
N/A

***

### Detect landmarks in images
***

* Prepare (input: PNG file "URL/moscow_small.jpeg"; output: JSON file "request.json")
```
$ ./pre-request.sh vision-landmark https://cloud.google.com/vision/docs/images/moscow_small.jpeg
request.json

$ jq . request.json 
{
  "url": "https://cloud.google.com/vision/docs/images/moscow_small.jpeg"
}
```
* Perform (input: JSON file "request.json"; output: JSON file "result$RANDOM.json)
```
$ ./run-request.sh vision-landmark request.json
result12922.json
```
* Review (text from output JSON)
```
$ jq -r '.categories[]|select(.name == "building_") | .detail.landmarks[] | "\(.name) \(.confidence)"' result29245.json
Saint Basil's Cathedral 0.9864403605461121

$ jq -r '.categories[].detail.landmarks[] | "\(.name) \(.confidence)"' result29245.json
Saint Basil's Cathedral 0.9864403605461121
Saint Basil's Cathedral 0.9864403605461121

$ jq -r '.categories[].detail.landmarks[] | "\(.name) \(.confidence)"' result29245.json|sort -u
Saint Basil's Cathedral 0.9864403605461121

$ jq . result29245.json
{
  "categories": [
    {
      "name": "building_",
      "score": 0.4453125,
      "detail": {
        "landmarks": [
          {
            "name": "Saint Basil's Cathedral",
            "confidence": 0.9864403605461121
          }
        ]
      }
    },
    {
      "name": "outdoor_",
      "score": 0.00390625,
      "detail": {
        "landmarks": [
          {
            "name": "Saint Basil's Cathedral",
            "confidence": 0.9864403605461121
          }
        ]
      }
    }
  ],
  "requestId": "f3672098-b016-4c16-b9f4-b939f10a654b",
  "metadata": {
    "width": 503,
    "height": 650,
    "format": "Jpeg"
  }
}
```

***

### Detect and label objects in images
* Generates a list of words, or tags based on objects, living beings, scenery or actions found in images
***

* Verify the file content type of the input file (that it is an image)
```
$ ./pre-request.sh vision-tag ../data/multiple1.jpeg 
../data/multiple1.jpeg: JPEG image data, JFIF standard 1.01, resolution (DPI), density 72x72, segment length 16, baseline, precision 8, 650x433, frames 3
```
* Perform (input: "multiple1.jpeg"; output: JSON file "result$RANDOM.json)
```
$ ./run-request.sh vision-tag ../data/multiple1.jpeg 
result13960.json
```
* Review (text from output JSON)
```
$ jq -r '.tags[] | "\(.name) \(.confidence)"' result13960.json
bicycle 0.9988218545913696
building 0.9979211091995239
outdoor 0.9960430264472961
bicycle wheel 0.9315172433853149
bike 0.7868402004241943
wheel 0.7255246043205261
street 0.6894863247871399
land vehicle 0.645155668258667
vehicle 0.6149222254753113
```


## AWS (Amazon Web Services)

* [Amazon Rekognition](https://docs.aws.amazon.com/en_pv/rekognition/latest/dg/what-is.html)
* Prerequisites are to have a valid and activated AWS account and permissions to use "Rekognition" cognitive services

***

1. Prepare to configure AWS CLI
   <br><i>NB. Do not use the AWS account root user access key. The access key for the AWS account root user gives full access to all resources for all AWS services, including billing information. The permissions cannot be reduce for the AWS account root user access key.</i>
   1. Create a GROUP in the Console, such as `cognitive`, and assign `AmazonRekognitionFullAccess` and `AmazonS3FullAccess` as Policy [create-admin-group](https://docs.aws.amazon.com/IAM/latest/UserGuide/getting-started_create-admin-group.html)
   <br>Select one or more policies to attach. Each group can have up to 10 policies attached.
   1. Create a USER in the Console, such as `aiuser`, assign it to the GROUP, and save the `credentials.csv` file (store and keep it secret) [create-admin-user](https://docs.aws.amazon.com/IAM/latest/UserGuide/getting-started_create-admin-group.html)
   1. Set a PASSWORD for the user [aws-password](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_passwords_admin-change-user.html)
1. Run the `aws configure` command to configure the AWS CLI using the keys for the USER (`aiuser`)
   <br><i>NB. The command prompts for: access key, secret access key, AWS Region, and output format; stores this in a profile ("default"), this is used when running  an AWS CLI command without explicitly specify another profile.</i>
   ```
   $ aws configure list
         Name                    Value             Type    Location
         ----                    -----             ----    --------
      profile                <not set>             None    None
   access_key     ****************MYVZ shared-credentials-file    
   secret_key     ****************nEac shared-credentials-file    
       region                <not set>             None    None
   ```
1. [Create S3 Bucket](https://docs.aws.amazon.com/cli/latest/reference/s3api/create-bucket.html)
   * In this case the bucket is named `blobbucket` and set to `private`, with LocationConstraint set to the specified region
   ```
   $ aws s3api create-bucket --bucket blobbucket --acl private --region us-east-2 --create-bucket-configuration LocationConstraint=us-east-2
   http://blobbucket.s3.amazonaws.com/
   ```
   * Upload files to the S3 Bucket (s3 and s3api commands)
   ```
   $ aws s3 cp --recursive ../data/ s3://blobbucket/
   upload: ../data/letter1.pdf to s3://blobbucket/letter1.pdf        
   upload: ../data/faces1.jpeg to s3://blobbucket/faces1.jpeg        
   upload: ../data/texthandwriting1.png to s3://blobbucket/texthandwriting1.png
   upload: ../data/landmark1.jpeg to s3://blobbucket/landmark1.jpeg    
   upload: ../data/multiple1.jpeg to s3://blobbucket/multiple1.jpeg    
   upload: ../data/texttyped1.png to s3://blobbucket/texttyped1.png    
   upload: ../data/faces2.png to s3://blobbucket/faces2.png
   
   $ aws s3api put-object --bucket blobbucket --key texttyped1.png --body ../data/texttyped1.png --acl private
   {
       "ETag": "\"c9ad5d3165a38a49281c693f0a4bc694\""
   }
   ```
   * List objects (files) in the S3 Bucket  (s3 and s3api commands)
   ```
   $ aws s3 ls s3://blobbucket
   2019-10-02 02:43:13      26107 faces1.jpeg
   2019-10-02 02:43:21     458795 faces2.png
   2019-10-02 02:43:35     181092 landmark1.jpeg
   2019-10-02 02:43:44      21578 letter1.pdf
   2019-10-02 02:43:50      96078 multiple1.jpeg
   2019-10-02 02:43:59      61840 texthandwriting1.png
   2019-10-02 10:49:46      26107 texttyped1.png

   $ aws s3api list-objects --bucket blobbucket --query 'Contents[].{Key: Key}' | jq -r '.[].Key'
   faces1.jpeg
   faces2.png
   landmark1.jpeg
   letter1.pdf
   multiple1.jpeg
   texthandwriting1.png
   texttyped1.png
   ```
   * Trying to access this bucket over HTTP without authenticating is denied
   ```
   <Error>
         <Code>AccessDenied</Code>
         <Message>Access Denied</Message>
         <RequestId>090832BE4B92F4DC</RequestId>
      <HostId>
         27Ec+Sx6rPwGJFpWIQ4ktZrdlG5m710m+yUKjXJ9IfWE3GWXde6e2OdaY0OdKnV6Y3NEUSOI4iw=
      </HostId>
   </Error>
   ```
   

### Detect text in images (Recognition DetectText)
* [detect-text](https://docs.aws.amazon.com/cli/latest/reference/rekognition/detect-text.html)
* [DetectText can detect <i>up to 50 words</i> in an image](https://docs.aws.amazon.com/en_pv/rekognition/latest/dg/limits.html)
* <i>A word is one or more <b>ISO basic latin script characters</b> that are not separated by spaces.</i>
***

* Verify that the file is in the S3 Bucket; create JSON request content file
```
$ ./pre-request.sh detect-text texttyped1.png
2019-10-02 11:06:19     186536 texttyped1.png
request.json
```
* Perform (input: JSON file "request.json"; output: JSON file "result$RANDOM.json)
```
$ ./run-request.sh detect-text request.json 
result12541.json
```
* Review (text from output JSON) <i>NB. It is capped at 100 words</i>
```
$ jq -r '.TextDetections[].DetectedText' result12541.json | tr '\n' ' ' ; echo 

Google is using deepfakes to fight deepfakes. With the 2020 US presidential election approaching, the race is on to figure how to prevent widespread out deepfake disinformation. On Tuesday, Google offered the latest contribution: an open-source database containing 3,000 original manipulated videos. The goal is to help train and test Google is using deepfakes to fight deepfakes. With the 2020 US presidential election approaching, the race is on to figure out how to prevent widespread deepfake disinformation. On Tuesday, Google offered the latest contribution: an open-source database containing 3,000 original manipulated videos. The goal is to help train and test 
```

### Detect text in images (Textract DetectDocumentText)
* [Detecting and Analyzing Text in Single-Page Documents](https://docs.aws.amazon.com/en_pv/textract/latest/dg/sync.html)
* NB. This require Security Policy `AmazonTextractFullAccess`, not `AmazonRekognitionFullAccess`
***

* Verify that the file is in the S3 Bucket; create JSON request content file
```
$ ./pre-request.sh detect-document-text texttyped1.png
2019-10-02 11:06:19     186536 texttyped1.png
request.json
```
* Perform (input: JSON file "request.json"; output: JSON file "result$RANDOM.json)
```
$ ./run-request.sh detect-document-text request.json 
result22224.json
```
* Review (text from output JSON) <i>NB. Missed "l" in "presidential"</i>
```
$ jq -r '.Blocks[]|select(.BlockType=="LINE")|.Text'  result22224.json| tr '\n' ' '; echo

Google is using deepfakes to fight deepfakes. With the 2020 US presidentia election approaching, the race is on to figure out how to prevent widespread deepfake disinformation. On Tuesday, Google offered the latest contribution: an open-source database containing 3,000 original manipulated videos. The goal is to help train and test automated detection tools. The company compiled the data by working with 28 actors to record videos of them speaking, making common expressions, and doing mundane tasks. It then used publicly available deepfake algorithms to alter their faces. Google isn't the first to take this approach. As we covered in The Algorithm earlier this month, Facebook announced that it would be releasing a similar database near the end of the year. In January, an academic team led by a researcher from the Technical University of Munich also created another called FaceForensics++. The trouble is technical solutions like these can only go so far because synthetic media could soon become indistinguishable from reality. Read more here. 
```

***

### Detect handwriting in images
* [detect-text](https://docs.aws.amazon.com/cli/latest/reference/rekognition/detect-text.html)
* [DetectText can detect <i>up to 50 words</i> in an image](https://docs.aws.amazon.com/en_pv/rekognition/latest/dg/limits.html)
***

* Verify that the file is in the S3 Bucket; create JSON request content file
```
$ ./pre-request.sh detect-text texthandwriting1.png 
2019-10-02 11:06:18      61840 texthandwriting1.png
request.json
```
* Perform (input: JSON file "request.json"; output: JSON file "result$RANDOM.json)
```
$ ./run-request.sh detect-text request.json 
result3587.json
```
* Review (text from output JSON)
```
$ jq -r '.TextDetections[].DetectedText' result3587.json | tr '\n' ' ' ; echo
oople CLoud 0 gle P fatform oople gle CLoud 0 P fatform 
```

***

### Detect text in files (Textract DocumentTextDetection)
* [Detecting and Analyzing Text in Multipage Documents](https://docs.aws.amazon.com/en_pv/textract/latest/dg/async.html)
* [Calling Amazon Textract Asynchronous Operations](https://docs.aws.amazon.com/en_pv/textract/latest/dg/api-async.html)
<br><img src="https://docs.aws.amazon.com/en_pv/textract/latest/dg/images/asynchronous.png" alt="DocumentTextDetection" width="50%"/><br>
***

* NB. Here using  `AmazonTextractFullAccess` Policy, not `AmazonRekognitionFullAccess`
* NB. Here using `AmazonSNSFullAccess` for SNS  and `AmazonSQSFullAccess` for SQS and `IAMFullAccess` for IAM

* Multi-step process:
   1. Setup SQS to receive SNS status notification [aws-sqs](https://docs.aws.amazon.com/cli/latest/reference/sqs/index.html)
      * Add Operaiton Permissions for Principal to the Queue, such as for "Everybody (*)"
   1. Setup SNS Topic and Subscription to recieve notification from StartDocumentTextDetection [aws-sns](https://docs.aws.amazon.com/cli/latest/reference/sns/index.html)
   1. Create IAM Role to allow Textract to publish to SNS, with the `AmazonTextractServiceRole` Policy
   1. StartDocumentTextDetection operation to submit the OCR operation, returns a job identifier (JobId) for the next step [aws-textract](https://docs.aws.amazon.com/cli/latest/reference/textract/start-document-text-detection.html)
   1. Check completion status queued in SQS from SNS
   1. GetDocumentTextDetection with job identifier (JobId) to access the OCR results in JSON output format [aws-textract](https://docs.aws.amazon.com/cli/latest/reference/textract/get-document-text-detection.html)

* Example

|SERVICE                                                  |ARN|
|---|---|
|SQS ARN                   |`arn:aws:sqs:us-east-2:deadbeef7898:SNStopic123`|
|SQS URL                   |`https://sqs.us-east-2.amazonaws.com/deadbeef7898/SNStopic123`|
|SQS Principal Operation Permissions |`SQS:AddPermission`, `SQS:DeleteMessage` and `SQS:ReceiveMessage`|
|SNS Topic ARN             |`arn:aws:sns:us-east-2:deadbeef7898:topic123`|
|SNS Subscription ARN      |`arn:aws:sns:us-east-2:deadbeef7898:topic123:deadbeef-9863-41e8-b283-78290f63d316`|
|SNS Subscription Endpoint |`arn:aws:sqs:us-east-2:deadbeef7898:SNStopic123`|
|Textract ARN Role         |`arn:aws:sqs:us-east-2:deadbeef7898:SNStopic123`|

```
$ aws sqs list-queues --region us-east-2
{
    "QueueUrls": [
        "https://us-east-2.queue.amazonaws.com/deadbeef7898/SNStopic123"
    ]
}

$ aws sns list-topics --region us-east-2
{
    "Topics": [
        {
            "TopicArn": "arn:aws:sns:us-east-2:deadbeef7898:topic123"
        }
    ]
}

$ aws sns list-subscriptions --region us-east-2
{
    "Subscriptions": [
        {
            "SubscriptionArn": "arn:aws:sns:us-east-2:deadbeef7898:topic123:b39a91fc-9863-41e8-b283-78290f63d316",
            "Owner": "deadbeef7898",
            "Protocol": "sqs",
            "Endpoint": "arn:aws:sqs:us-east-2:deadbeef7898:SNStopic123",
            "TopicArn": "arn:aws:sns:us-east-2:deadbeef7898:topic123"
        }
    ]
}

$ aws iam list-roles | jq '.Roles[]|select(.RoleName=="Textract2SNS")'
{
  "Path": "/",
  "RoleName": "Textract2SNS",
  "RoleId": "AROAYWZGLN25L6XSDYTI4",
  "Arn": "arn:aws:iam::deadbeef7898:role/Textract2SNS",
  "CreateDate": "2019-10-03T06:37:23Z",
  "AssumeRolePolicyDocument": {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "",
        "Effect": "Allow",
        "Principal": {
          "Service": "textract.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  },
  "Description": "Allows AWS Textract to call other AWS services on your behalf.",
  "MaxSessionDuration": 3600
}

$ aws textract start-document-text-detection --document '{"S3Object":{"Bucket":"blobbucket","Name":"sample.pdf"}}' --notification-channel '{"SNSTopicArn":"arn:aws:sns:us-east-2:deadbeef7898:topic123","RoleArn":"arn:aws:iam::deadbeef7898:role/Textract2SNS"}' --region us-east-2
{
    "JobId": "6014e9101702c9da1c505a4acdbd2e5675d630155dfa8da9205f77c34981b9b8"
}

$ aws sqs receive-message --queue-url https://us-east-2.queue.amazonaws.com/deadbeef7898/SNStopic123 --region us-east-2

$ aws textract get-document-text-detection --job-id "6014e9101702c9da1c505a4acdbd2e5675d630155dfa8da9205f77c34981b9b8" --region us-east-2 > textract-output-sample.json

$ jq -r '.Blocks[]|select(.BlockType=="LINE")|.Text' textract-output-sample.json | tr '\n' ' '; echo
A Simple PDF File This is a small demonstration .pdf file -- just for use in the Virtual Mechanics tutorials. More text. And more text. And more text. And more text. And more text. And more text. And more text. And more text. And more text. And more text. And more text. Boring, ZZZZZ. And more text. And more text. And more text. And more text. And more text. And more text. And more text. And more text. And more text. And more text. And more text. And more text. And more text. And more text. And more text. And more text. Even more. Continued on page 2 Simple PDF File 2 .continued from page 1. Yet more text And more text. And more text. And more text. And more text. And more text. And more text. And more text. Oh, how boring typing this stuff. But not as boring as watching paint dry. And more text And more text. And more text. And more text. Boring. More, a little more text. The end, and just as well. 
```

***

### Detect Faces in images
* [Detecting Faces in an Image](https://docs.aws.amazon.com/en_pv/rekognition/latest/dg/faces-detect-images.html)
* [detect-faces](https://docs.aws.amazon.com/cli/latest/reference/rekognition/detect-faces.html)
<br><img src="https://docs.aws.amazon.com/rekognition/latest/dg/images/landmarkface.png" alt="Face Landmarks" width="50%" /><br>
***

* Verify that the file is in the S3 Bucket; create JSON request content file
```
$ ./pre-request.sh detect-faces faces1.jpeg
2019-10-02 11:06:19      26107 faces1.jpeg
request.json
```
* Perform (input: JSON file "request.json"; output: JSON file "result$RANDOM.json)
```
$ ./run-request.sh detect-faces request.json 
result10579.json
```
* Review (text from output JSON) - for expanded view use `jq . <output JSON filename>`
```
$ jq -r '.FaceDetails[].Confidence' result10579.json
99.9998550415039
99.85765075683594
99.99970245361328
99.99711608886719
99.99925231933594
99.98178100585938
99.9980697631836
99.70393371582031
99.99464416503906
99.99987030029297
99.99915313720703
99.99749755859375
99.99079895019531
99.99903106689453
91.42262268066406
99.89049530029297
91.33202362060547
65.57625579833984
99.625244140625
81.71480560302734
```

***

### Detect multiple objects in images
* [Detecting Labels in an Image](https://docs.aws.amazon.com/en_pv/rekognition/latest/dg/labels-detect-labels-image.html)
***

* Verify that the file is in the S3 Bucket; create JSON request content file
```
$ ./pre-request.sh detect-labels multiple1.jpeg
2019-10-02 11:06:18      96078 multiple1.jpeg
request.json
```
* Perform (input: JSON file "request.json"; output: JSON file "result$RANDOM.json)
```
./run-request.sh detect-labels request.json 
result24519.json
```
* Review (text from output JSON) - for expanded view use `jq . <output JSON filename>`
```
$ jq -r '.Labels[]| "\(.Name) \(.Confidence)"' result24519.json
Bicycle 99.98738098144531
Transportation 99.98738098144531
Vehicle 99.98738098144531
Bike 99.98738098144531
Machine 99.97575378417969
Wheel 99.97575378417969
Handrail 85.58196258544922
Banister 85.58196258544922
Door 71.61861419677734
Staircase 66.0941390991211
Indoors 63.238643646240234
Interior Design 63.238643646240234
Walkway 62.390384674072266
Path 62.390384674072266
Wall 61.80942916870117
Building 55.82354736328125
Housing 55.82354736328125
```

***

### Detect web references to an image
N/A

***

### Detect landmarks in images
***
 
* Verify that the file is in the S3 Bucket; create JSON request content file
```
$ ./pre-request.sh detect-labels landmark1.jpeg
2019-10-02 11:06:19     181092 landmark1.jpeg
request.json
```
* Perform (input: JSON file "request.json"; output: JSON file "result$RANDOM.json)
```
./run-request.sh detect-labels request.json 
result27651.json
```
* Review (text from output JSON) - for expanded view use `jq . <output JSON filename>`
```
$ jq -r '.Labels[]| "\(.Name) \(.Confidence)"' result27651.json
Architecture 99.82380676269531
Dome 99.82380676269531
Building 99.82380676269531
Spire 99.72821044921875
Tower 99.72821044921875
Steeple 99.72821044921875
City 88.84866333007812
Town 88.84866333007812
Urban 88.84866333007812
Downtown 88.47482299804688
Metropolis 82.51697540283203
Person 73.4709701538086
Human 73.4709701538086
Church 59.03559494018555
Cathedral 59.03559494018555
Monument 55.30182647705078
```

***

### Recognition of Face in images
* [compare-faces](https://docs.aws.amazon.com/cli/latest/reference/rekognition/compare-faces.html)
* Target image
<br><img src="https://www.nih.gov/sites/default/files/news-events/research-matters/2014/20140428-attention.jpg" width="50%" /><br>
* Source image (to find in the target image (show as downsampled to 2kb from original 4kb)
<br><img src="https://github.com/realBjornRoden/cognition/blob/master/data/face2match2kb.jpg" /><br>
***

* Verify that the files are in the S3 Bucket
```
$ aws s3 ls s3://blobbucket/faces1.jpeg
2019-10-02 11:06:19      26107 faces1.jpeg

$ aws s3 ls s3://blobbucket/face2match4kb.jpeg
2019-10-04 11:08:08       3859 face2match4kb.jpeg

$ aws s3 ls s3://blobbucket/face2match2kb.jpg
2019-10-04 11:52:34       1829 face2match2kb.jpg
```
* Perform output: JSON file "facematch.json
```
$ aws rekognition compare-faces --target-image '{"S3Object":{"Bucket":"blobbucket","Name":"faces1.jpeg"}}' --source-image '{"S3Object":{"Bucket":"blobbucket","Name":"face2match4kb.jpeg"}}' > facematch4kb.out

$ aws rekognition compare-faces --target-image '{"S3Object":{"Bucket":"blobbucket","Name":"faces1.jpeg"}}' --source-image '{"S3Object":{"Bucket":"blobbucket","Name":"face2match2kb.jpg"}}' > facematch2kb.out
```
* Review (text from output JSON) - for expanded view use `jq . <file>` or `cat <file>`
```
$ jq -r '.FaceMatches[]| "Similarity: \(.Similarity) Face.Confidence: \(.Face.Confidence)"' facematch4kb.out
Similarity: 99.99290466308594 Face.Confidence: 99.98178100585938

$ jq -r '.FaceMatches[]| "Similarity: \(.Similarity) Face.Confidence: \(.Face.Confidence)"' facematch2kb.out
Similarity: 99.61591339111328 Face.Confidence: 99.98178100585938
```
