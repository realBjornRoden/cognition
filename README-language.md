# Cognitive Artificial Intelligence - Language

* [Amazon (AWS)](https://aws.amazon.com/machine-learning/)
* [Google (GCP)](https://cloud.google.com/products/ai/)
* [Microsoft (Azure)](https://azure.microsoft.com/services/cognitive-services/)

***

## Use Cases
1. Translation
1. Analysis

***

## GCP (Google Cloud Platform)
* [translate-docs](https://cloud.google.com/translate/docs/)
   * Prerequisites are to have a valid and activated GCP account and permissions to use API `translate.googleapis.com` or `automl.googleapis.com` cognitive services
* [natural-language](https://cloud.google.com/natural-language/docs/basics)

***

1. Create project; service account; download service account key file and enable API [before-you-begin](https://cloud.google.com/vision/docs/before-you-begin)

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
1. List supported languages
   ```
   $ curl -sH "Authorization: Bearer "$(gcloud auth application-default print-access-token) "https://translation.googleapis.com/language/translate/v2/languages"|jq -r '.data.languages[].language' | pr -4 -t
   af		  gd		    lb		      sl
   am		  gl		    lo		      sm
   ar		  gu		    lt		      sn
   az		  ha		    lv		      so
   be		  haw		    mg		      sq
   bg		  hi		    mi		      sr
   bn		  hmn		    mk		      st
   bs		  hr		    ml		      su
   ca		  ht		    mn		      sv
   ceb		  hu		    mr		      sw
   co		  hy		    ms		      ta
   cs		  id		    mt		      te
   cy		  ig		    my		      tg
   da		  is		    ne		      th
   de		  it		    nl		      tl
   el		  iw		    no		      tr
   en		  ja		    ny		      uk
   eo		  jw		    pa		      ur
   es		  ka		    pl		      uz
   et		  kk		    ps		      vi
   eu		  km		    pt		      xh
   fa		  kn		    ro		      yi
   fi		  ko		    ru		      yo
   fr		  ku		    sd		      zh
   fy		  ky		    si		      zh-TW
   ga		  la		    sk		      zu
   ```

### APIs
* [Enable API](https://cloud.google.com/endpoints/docs/openapi/enable-api)
* Check if available, enable APIs and check if enabled, required: `texttospeech.googleapis.com` and `speech.googleapis.com`
***
```
$ gcloud services list --available --filter translate.googleapis.com
NAME                      TITLE
automl.googleapis.com     Cloud AutoML API
translate.googleapis.com  Cloud Translation API

$ gcloud services enable translate.googleapis.com
Operation "operations/acf.6920dcef-ef0d-4c40-b22c-e559bef6c4f4" finished successfully.

$ gcloud services list --enabled --filter translate.googleapis.com
NAME                      TITLE
translate.googleapis.com  Cloud Translation API
```

***

### Translation
* [translating-text](https://cloud.google.com/translate/docs/translating-text)
* Create JSON formatted request file (request.json)
```
$ cat request.json 
{ "q": "Ù…Ø±Ø­Ø¨Ø§ Ø¨Ø§Ù„Ø¹Ø§Ù„Ù…", "source": "ar", "target": "en", "format": "text" }
```

* Run  `curl` to access the API
```
$ curl -s -X POST -H "Authorization: Bearer ya29.c.Kl6bB_jYUEsWxlO6Dw-XpAfZi5XGHia39RvgKYaVXWcbAClsGihy9OpLAa62bE-5SO4kTKu5a1-QZ3R3KM8yPVJa4frdsnk2MuZhRR6KtMQPjDEENgOvbCemGBOic7Mb" -H "Content-Type: application/json" -d @request.json https://translation.googleapis.com/language/translate/v2
```

* Review the results from the JSON output file
```
$ jq '.data.translations[].translatedText' result26288.json
"Hello World"

$ jq '.' result26288.json                                  
{
  "data": {
    "translations": [
      {
        "translatedText": "Hello World"
      }
    ]
  }
}
```

***

### Analysis


***

## AWS (Amazon Web Services)

* [Amazon Translate](https://docs.aws.amazon.com/translate/latest/dg/what-is.html)
   * [translate-limits](https://docs.aws.amazon.com/en_pv/translate/latest/dg/what-is-limits.html)
   * Prerequisites are to have a valid and activated AWS account and permissions to use "Translate" cognitive services
* [Amazon Comprehend](https://aws.amazon.com/comprehend/)
   * [comprehend](https://docs.aws.amazon.com/en_pv/comprehend/latest/dg/functionality.html)

***

1. Prepare to configure AWS CLI
   <br><i>NB. Do not use the AWS account root user access key. The access key for the AWS account root user gives full access to all resources for all AWS services, including billing information. The permissions cannot be reduce for the AWS account root user access key.</i>
   1. Create a GROUP in the Console, such as `cognitive`, and assign `TranslateFullAccess` as Policy [create-admin-group](https://docs.aws.amazon.com/IAM/latest/UserGuide/getting-started_create-admin-group.html)
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
* [Create S3 Bucket](https://docs.aws.amazon.com/cli/latest/reference/s3api/create-bucket.html)
   * In this case the bucket is named `blobbucket` and set to `private`, with LocationConstraint set to the specified region
   ```
   $ aws s3api create-bucket --bucket blobbucket --acl private --region us-east-2 --create-bucket-configuration LocationConstraint=us-east-2
   http://blobbucket.s3.amazonaws.com/
   ```
   * Upload files to the S3 Bucket (s3 and s3api commands)
   ```
   $ aws s3 cp --recursive ../data/ s3://blobbucket/
   
   $ aws s3api put-object --bucket blobbucket --key texttyped1.png --body ../data/texttyped1.png --acl private
   ```
   * List objects (files) in the S3 Bucket  (s3 and s3api commands)
   ```
   $ aws s3 ls s3://blobbucket

   $ aws s3api list-objects --bucket blobbucket --query 'Contents[].{Key: Key}' | jq -r '.[].Key'
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

### 

***

### Translation

* Shorter source text - Run `aws translate translate-text` directly
```
$ aws translate translate-text --region us-east-2 --source-language-code "en" --target-language-code "ar" --text "Hello World" > result-1.json

$ jq '.SourceLanguageCode,.TargetLanguageCode,.TranslatedText' result-1.json

$ aws translate translate-text --region us-east-2 --source-language-code "ar" --target-language-code "en" --text "$(jq -r '.TranslatedText' result-1.json)" | tee result-2.json
{
    "TranslatedText": "Hello World",
    "SourceLanguageCode": "ar",
    "TargetLanguageCode": "en"
}

$ jq -r '.TranslatedText' result-1.json | base64
2YXYsdit2KjYpyDZiNmI2LHZhNivCg==

$ jq -r '.TranslatedText' result-1.json | base64 --decode
Ù…Ø±Ø­Ø¨Ø§ ÙˆÙˆØ±Ù„Ø¯
```

* Longer source text - Create JSON formatted request file (request.json)
```

$ cat <<-EOD > request.json
	{ "SourceLanguageCode": "en", "TargetLanguageCode": "ar", "Text": "Hello World" }
EOD

$ cat request.json
{ "SourceLanguageCode": "en", "TargetLanguageCode": "ar", "Text": "Hello World" }
```

* Submit the job (input: JSON file "request.json"; output: JSON file "result$RANDOM.json)
```
$ aws translate translate-text --region us-east-2 --cli-input-json file://request.json | tee result$RANDOM.json | jq -r '.TranslatedText' |base64
2YXYsdit2KjYpyDZiNmI2LHZhNivCg==
```
***

### Analysis



<!--

## Azure (Microsoft Azure Cloud)

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

   $ az cognitiveservices account create --name face-api --kind Face --resource-group cognitive-services-resource-group --sku F0 --location westus2 --yes
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

   $ az cognitiveservices account keys list --name face-api --resource-group cognitive-services-resource-group
   ```
1. Set environment `COGNITIVE_SERVICE_KEY` variable with one of the keys for the resource
    ```
   $ export COGNITIVE_SERVICE_KEY=XXXXX
   ```
1. Cleanup (after temporary usage)
   ```
   $ az group delete --name cognitive-services-resource-group
   Are you sure you want to perform this operation? (y/n): y
   ```

***

### Translation
* [XXXX](XXXX)

-->
