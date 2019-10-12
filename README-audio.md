# Cognitive Artificial Intelligence - Audio

* [Amazon (AWS)](https://aws.amazon.com/machine-learning/)
* [Google (GCP)](https://cloud.google.com/products/ai/)
* [Microsoft (Azure)](https://azure.microsoft.com/services/cognitive-services/)
* [pypi.org](https://pypi.org/project/SpeechRecognition/)
* [archive.org](https://archive.org/details/audio)

***

## Use Cases
1. Transcription
1. Diarization
1. Language Detection
1. Translate

***

## GCP (Google Cloud Platform)

* https://cloud.google.com/speech-to-text/
* https://cloud.google.com/speech-to-text/docs/encoding

|Model	|Description|
|---|---|
|command_and_search	|Best for short queries such as voice commands or voice search.|
|phone_call	|Best for audio that originated from a phone call (typically recorded at an 8khz sampling rate).|
|video	|Best for audio that originated from from video or includes multiple speakers. Ideally the audio is recorded at a 16khz or greater sampling rate. This is a premium model that costs more than the standard rate.|
|default	|Best for audio that is not one of the specific audio models. For example, long-form audio. Ideally the audio is high-fidelity, recorded at a 16khz or greater sampling rate.|


* Create project; service account; download service account key file and enable API [before-you-begin](https://cloud.google.com/vision/docs/before-you-begin)

* Authenticate CLI session with `gcloud auth login`

* Set the environment variable GOOGLE_APPLICATION_CREDENTIALS to point to the location of the service account key file
```
export GOOGLE_APPLICATION_CREDENTIALS=$PWD/cognitive-aab254879251.json
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

### APIs
* [Enable API](https://cloud.google.com/endpoints/docs/openapi/enable-api)
* Check if available, enable APIs and check if enabled, required: `texttospeech.googleapis.com` and `speech.googleapis.com`
```
$ gcloud services list --available --filter "texttospeech.googleapis.com OR speech.googleapis.com"
NAME                         TITLE
speech.googleapis.com        Cloud Speech-to-Text API
texttospeech.googleapis.com  Cloud Text-to-Speech API

$ gcloud services enable texttospeech.googleapis.com speech.googleapis.com
Operation "operations/acf.fa58e2e5-1830-41f2-aafe-991d716fe61f" finished successfully.

$ gcloud services list --enabled --filter "texttospeech.googleapis.com OR speech.googleapis.com"  
NAME                         TITLE
speech.googleapis.com        Cloud Speech-to-Text API
texttospeech.googleapis.com  Cloud Text-to-Speech API
```

***

### Transcription (short/sync)
* [Transcribing short audio files (less than a minute)](https://cloud.google.com/speech-to-text/docs/sync-recognize)
* "<i>An asynchronous Speech-to-Text API request to the LongRunningRecognize method is identical in form to a synchronous Speech-to-Text API request.</i>"
* The payload size limit: 10485760 bytes.

1. Get a sample audio file
```
$ wget https://ia803009.us.archive.org/29/items/hpr2798/hpr2798.wav
--2019-10-10 18:19:50--  https://ia803009.us.archive.org/29/items/hpr2798/hpr2798.wav
Resolving ia803009.us.archive.org (ia803009.us.archive.org)... 207.241.233.29
Connecting to ia803009.us.archive.org (ia803009.us.archive.org)|207.241.233.29|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 75388322 (72M) [audio/x-wav]
Saving to: 'hpr2798.wav'

hpr2798.wav                                   100%[==============================================================================================>]  71.90M  2.56MB/s    in 1m 52s  

2019-10-10 18:21:43 (659 KB/s) - 'hpr2798.wav' saved [75388322/75388322]
```
1. Check the audio file, such as for sampling rate
   * "<i>Sample rates between 8000 Hz and 48000 Hz are supported within Cloud Speech-to-Text.</i>"
   * In below, using `audio_metadata`
```
(env-audio) $ python lsaudio.py ../data/hpr2798.wav
Duration sec:	 854.7273015873016
Sample rate:	 44100
```
1. Cut the file to size from a specific starting point, and convert to WAV format with one audio channel excluding any video (if there was any)
   * Audio options:
      -aframes number     set the number of audio frames to output
      -aq quality         set audio quality (codec-specific)
      -ar rate            set audio sampling rate (in Hz)
      -ac channels        set number of audio channels
      -an                 disable audio
      -acodec codec       force audio codec ('copy' to copy stream)
      -vol volume         change audio volume (256=normal)
      -af filter_graph    set audio filters
```
$ ffmpeg -hide_banner -i ../data/hpr2798.wav -ss 00:01:14 -t 59 -ac 1 -vn audio2.wav
Guessed Channel Layout for Input Stream #0.0 : mono
Input #0, wav, from 'hpr2798.wav':
  Metadata:
    album           : Hacker Public Radio
    artist          : knightwise
    comment         : http://hackerpublicradio.org Explicit; Knightwise waxes nostalgically on the early days of podcasting and wonders if we all sold out?
    genre           : Podcast
    title           : Should Podcasters be Pirates ?
    track           : 2798
    date            : 2019
  Duration: 00:14:14.73, bitrate: 705 kb/s
    Stream #0:0: Audio: pcm_s16le ([1][0][0][0] / 0x0001), 44100 Hz, mono, s16, 705 kb/s
Stream mapping:
  Stream #0:0 -> #0:0 (pcm_s16le (native) -> pcm_s16le (native))
Output #0, wav, to 'audio2.wav':
  Metadata:
    IPRD            : Hacker Public Radio
    IART            : knightwise
    ICMT            : http://hackerpublicradio.org Explicit; Knightwise waxes nostalgically on the early days of podcasting and wonders if we all sold out?
    IGNR            : Podcast
    INAM            : Should Podcasters be Pirates ?
    IPRT            : 2798
    ICRD            : 2019
    ISFT            : Lavf58.33.100
    Stream #0:0: Audio: pcm_s16le ([1][0][0][0] / 0x0001), 44100 Hz, mono, s16, 705 kb/s
    Metadata:
      encoder         : Lavc58.59.102 pcm_s16le
size=    5082kB time=00:00:59.00 bitrate= 705.6kbits/s speed=1.4e+03x    
video:0kB audio:5082kB subtitle:0kB other streams:0kB global headers:0kB muxing overhead: 0.006764%
```
1. Check the converted audio file, such as for sampling rate
```
$ hexdump -Cn 48 audio2.wav 
00000000  52 49 46 46 b0 68 4f 00  57 41 56 45 66 6d 74 20  |RIFF.hO.WAVEfmt |
00000010  10 00 00 00 01 00 01 00  44 ac 00 00 88 58 01 00  |........D....X..|
00000020  02 00 10 00 4c 49 53 54  2c 01 00 00 49 4e 46 4f  |....LIST,...INFO|

(env-audio) $ python lsaudio.py ../data/audio2.wav
Duration sec:	 59.0
Sample rate:	 44100
```
1. Run `gcloud ml speech recognize`; in this case US English, in other cases select the corresponding English (a dozen variants to select from)
```
$ gcloud ml speech recognize audio2.wav --language-code='en-US' | tee result$RANDOM.json
{
  "results": [
    {
      "alternatives": [
        {
          "confidence": 0.96187854,
          "transcript": "checking in with another show for HPR in the car on my way to a client's going to be a short show I'm think I'm going to be there in 10 minutes but I want to do you know shoot something up the flagpole you wanted to talk about the state of podcasting these days these days I sound old because in podcasting terms I am I've been around since 2004 mm started producing show since 2005 and have been listening to podcast daily since 2004 I came across my archives from shows that I used to download back then and listen to which I had burned to a CD and put them on my nose and I've started streaming them while at work the last couple of weeks and I've had a ball listening to old podcast episodes"
        }
      ]
    }
  ]
}
```
1. Review the results from the JSON output file
```
$ jq -r '.results[].alternatives[]|.confidence,.transcript' result26358.json
0.96501887
checking in with another show for HPR in the car on my way to a client's going to be a short show I'm think I'm going to be there in 10 minutes but I want to do you know shoot something up the flagpole you're wanted to talk about the state of podcasting these days these days I sound old because in podcasting terms I am I've been around since 2004 mm started producing show since 2005 and have been listening to podcast daily since 2004 I came across my archives from shows that I used to download back then and listen to which I had burned to a CD and put them on my nose and I've started streaming them while at work the last couple of weeks and I've had a ball listening to old podcast episodes
```
<!--
$ ./run-audio.sh audio-transcription ../data/audio2.wav
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 6777k  100  1557  100 6776k      6  28523  0:04:19  0:04:03  0:00:16   331
result6083.json
-->
### Transcription (long/async)
* [Transcribing longer audio files (more than a minute)](https://cloud.google.com/speech-to-text/docs/async-recognize)
1. Transfer the audio file to GCP bucket
```
$ gsutil cp data/audio2.wav gs://$(gcloud config get-value project) 
Copying file://data/audio2.wav [Content-Type=audio/x-wav]...
| [1 files][  5.0 MiB/  5.0 MiB]  383.4 KiB/s                                   
Operation completed over 1 objects/5.0 MiB.                                      
```
1. Run `gcloud ml speech recognize-long-running`
```
$ gcloud ml speech recognize-long-running gs://$(gcloud config get-value project)/audio2.wav --async --language-code='en-US'
Check operation [operations/5263634183516942311] for status.
{
  "name": "5263634183516942311"
}
```
1. Check when ready with `gcloud ml speech operations wait`
```
$ gcloud ml speech operations wait "5263634183516942311" | tee result$RANDOM.json
Waiting for operation [operations/5263634183516942311] to complete...done.                                                                                                          
{
  "@type": "type.googleapis.com/google.cloud.speech.v1.LongRunningRecognizeResponse",
  "results": [
    {
      "alternatives": [
        {
          "confidence": 0.961879,
          "transcript": "checking in with another show for HPR in the car on my way to a client's going to be a short show I'm think I'm going to be there in 10 minutes but I want to do you know shoot something up the flagpole you wanted to talk about the state of podcasting these days these days I sound old because in podcasting terms I am I've been around since 2004 mm started producing show since 2005 and have been listening to podcast daily since 2004 I came across my archives from shows that I used to download back then and listen to which I had burned to a CD and put them on my nose and I've started streaming them while at work the last couple of weeks and I've had a ball listening to old podcast episodes"
        }
      ]
    }
  ]
}
```
1. Check the outcome with `gcloud ml speech operations describe`
```
$ gcloud ml speech operations describe "5263634183516942311" | tee result$RANDOM.json
{
  "done": true,
  "metadata": {
    "@type": "type.googleapis.com/google.cloud.speech.v1.LongRunningRecognizeMetadata",
    "lastUpdateTime": "2019-10-10T15:42:16.492003Z",
    "progressPercent": 100,
    "startTime": "2019-10-10T15:41:57.151427Z"
  },
  "name": "5263634183516942311",
  "response": {
    "@type": "type.googleapis.com/google.cloud.speech.v1.LongRunningRecognizeResponse",
    "results": [
      {
        "alternatives": [
          {
            "confidence": 0.961879,
            "transcript": "checking in with another show for HPR in the car on my way to a client's going to be a short show I'm think I'm going to be there in 10 minutes but I want to do you know shoot something up the flagpole you wanted to talk about the state of podcasting these days these days I sound old because in podcasting terms I am I've been around since 2004 mm started producing show since 2005 and have been listening to podcast daily since 2004 I came across my archives from shows that I used to download back then and listen to which I had burned to a CD and put them on my nose and I've started streaming them while at work the last couple of weeks and I've had a ball listening to old podcast episodes"
          }
        ]
      }
    ]
  }
}
```
1. Review the results from the JSON output file
```
$ jq -r '.response.results[].alternatives[]|.confidence,.transcript' result25359.json
0.961879
checking in with another show for HPR in the car on my way to a client's going to be a short show I'm think I'm going to be there in 10 minutes but I want to do you know shoot something up the flagpole you wanted to talk about the state of podcasting these days these days I sound old because in podcasting terms I am I've been around since 2004 mm started producing show since 2005 and have been listening to podcast daily since 2004 I came across my archives from shows that I used to download back then and listen to which I had burned to a CD and put them on my nose and I've started streaming them while at work the last couple of weeks and I've had a ball listening to old podcast episodes
```

### Language Detection
* [multiple-languages](https://cloud.google.com/speech-to-text/docs/multiple-languages)
* [v1p1beta1/RecognitionConfig](https://cloud.google.com/speech-to-text/docs/reference/rest/v1p1beta1/RecognitionConfig)
   * "<i>Optional A list of up to 3 additional BCP-47 language tags, listing possible alternative languages of the supplied audio</i>"
1. Transfer the audio file to GCP bucket
```
$ gsutil cp ../data/audio[12].wav gs://$(gcloud config get-value project)  
Copying file://../data/audio1.wav [Content-Type=audio/x-wav]...
Copying file://../data/audio2.wav [Content-Type=audio/x-wav]...                 
\ [2 files][ 10.3 MiB/ 10.3 MiB]                                                
Operation completed over 2 objects/10.3 MiB.                                     
```
1. Create JSON formatted request file (request.json)
```
{ "config": { "encoding":"LINEAR16", "languageCode": "en-US", "alternativeLanguageCodes": [ "en-AU", "en-GB", "en-IE" ], "model": "command_and_search" }, "audio": { "uri":"$(gcloud config get-value project)/audio2.wav" } }
```
1. Run  `curl` to access the API
```
$ curl -s -H "Content-Type: application/json" -H "Authorization: Bearer $(gcloud auth application-default print-access-token)" -d @request.json https://speech.googleapis.com/v1p1beta1/speech:recognize | tee result$RANDOM.json
{
  "results": [
    {
      "alternatives": [
        { "transcript": "checking in with another show for HP are in the car on my way to a clients can be a short show on think I'm going to be there in 10 minutes but I want to do you know should something up the flagpole here to talk about the state of podcast in these days these days I sound old because in podcasting terms I am I've been around since 2004 to 2000 started producing shows since 2005 and have been listening to podcast daily since 2004 I came across my own archive from show that I used to download back then and listen to which I had burnt to a CD and I put them on mine and I started screaming them while at work the last couple of weeks and listening to Old Podcast episode",
          "confidence": 0.94958663
        }
      ],
      "languageCode": "en-gb"
    }
  ]
}

```
1. Review the results from the JSON output file
```
$ jq -r '.results[]|.languageCode,.alternatives[].confidence,.alternatives[].transcript' result31483.json 
en-gb
0.94958663
checking in with another show for HP are in the car on my way to a clients can be a short show on think I'm going to be there in 10 minutes but I want to do you know should something up the flagpole here to talk about the state of podcast in these days these days I sound old because in podcasting terms I am I've been around since 2004 to 2000 started producing shows since 2005 and have been listening to podcast daily since 2004 I came across my own archive from show that I used to download back then and listen to which I had burnt to a CD and I put them on mine and I started screaming them while at work the last couple of weeks and listening to Old Podcast episode
```


### Diarization 
* [multiple-voices](https://cloud.google.com/speech-to-text/docs/multiple-voices)
* [supported-features-languages](https://cloud.google.com/speech-to-text/docs/supported-features-languages)
* "<i>Cloud Speech-to-Text only supports speaker diarization for transcribing phone calls</i>"

1. Transfer the audio file to GCP bucket
```
$ gsutil cp data/audio2.wav gs://$(gcloud config get-value project) 
Copying file://data/audio2.wav [Content-Type=audio/x-wav]...
| [1 files][  5.0 MiB/  5.0 MiB]  383.4 KiB/s                                   
Operation completed over 1 objects/5.0 MiB.                                      
```
1. Create JSON formatted request file (request.json)
   * <i>diarizationSpeakerCount (optional) If set, specifies the estimated number of speakers in the conversation. If not set, defaults to '2'.</i>
```
{ "config": { "encoding":"LINEAR16", "languageCode": "en-US", "diarizationConfig": { "enableSpeakerDiarization": true }, "model": "phone_call" }, "audio": { "uri":"$(gcloud config get-value project)/audio2.wav" } }
```
1. Run  `curl` to access the API
```
$ curl -s -H "Content-Type: application/json" -H "Authorization: Bearer $(gcloud auth application-default print-access-token)" -d @request.json https://speech.googleapis.com/v1p1beta1/speech:recognize > result$RANDOM.json

$ ls -ltr|tail -1
-rw-r--r--    1 bjro  staff   43322 Oct 11 14:58 result28054.json
```
1. Review the results from the JSON output file
```
$ jq -r '.results[].alternatives[].words[]|select(.speakerTag==1)|.word' result28054.json |tr '\n' ' '; echo
checking in with another show for HP are in the car on my way to a client's going to be a short show I'm think I'm going to be there in 10 minutes but I wanted to you know shoot something up the flag pole here wanted to talk about the state of these days I found old because in podcasting terms I am I've been around since 2004 2000 started producing show since 2005 and a big listing to podcast and 2004 and I came across my own archive from shows that I used to download back then listening to old podcast episodes of 

$ jq -r '.results[].alternatives[].words[]|select(.speakerTag==2)|.word' result28054.json |tr '\n' ' '; echo
podcasting days day 80 since and listen to which I had burn to a CD and I put them on my nose and I've started screaming them while at work the last couple of weeks and I've had up Paul 
```

1. Translate
* [xxx](xxx)
1. Transfer the audio file to GCP bucket
```
$ gsutil cp ../data/audio[12].wav gs://$(gcloud config get-value project)
Copying file://../data/audio1.wav [Content-Type=audio/x-wav]...
Copying file://../data/audio2.wav [Content-Type=audio/x-wav]...
\ [2 files][ 10.3 MiB/ 10.3 MiB]
Operation completed over 2 objects/10.3 MiB.
```
1. Create JSON formatted request file (request.json)
1. Run  `curl` to access the API
1. Review the results from the JSON output file





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

### Transcription
* [XXXX](XXXX)

### Diarization
* [XXXX](XXXX)

### Language Detection
* [XXXX](XXXX)

### Translate
* [XXXX](XXXX)

-->

## AWS (Amazon Web Services)

* [Amazon Transcribe](https://docs.aws.amazon.com/transcribe/index.html)
* Prerequisites are to have a valid and activated AWS account and permissions to use "Transcribe" cognitive services

1. Prepare to configure AWS CLI
   <br><i>NB. Do not use the AWS account root user access key. The access key for the AWS account root user gives full access to all resources for all AWS services, including billing information. The permissions cannot be reduce for the AWS account root user access key.</i>
   1. Create a GROUP in the Console, such as `cognitive`, and assign `AmazonTranscribeFullAccess` and `AmazonS3FullAccess` as Policy [create-admin-group](https://docs.aws.amazon.com/IAM/latest/UserGuide/getting-started_create-admin-group.html)
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

### Transcription
* [transcribe](https://docs.aws.amazon.com/en_pv/transcribe/latest/dg/what-is-transcribe.html)
* [transcribe-input](https://docs.aws.amazon.com/en_pv/transcribe/latest/dg/input.html)
   * <i>FLAC, MP3, MP4, or WAV file format</i>
* [API_StartTranscriptionJob](https://docs.aws.amazon.com/transcribe/latest/dg/API_StartTranscriptionJob.html)

* Verify (that the file is in the S3 Bucket, if not copy it there; create JSON request content file)
```
$ aws s3 ls s3://blobbucket/audio2.wav || aws s3 cp ../data/audio2.wav s3://blobbucket/audio2.wav
upload: ../data/audio2.wav to s3://blobbucket/audio2.wav         

$ JOBNO=$RANDOM

$ cat <<-EOD > request.json
	{ "TranscriptionJobName": "job$JOBNO", "LanguageCode": "en-US", "MediaFormat": "wav", "Media": { "MediaFileUri": "s3://blobbucket/audio2.wav" } }
EOD

$ cat request.json
{ "TranscriptionJobName": "job26816", "LanguageCode": "en-US", "MediaFormat": "wav", "Media": { "MediaFileUri": "s3://blobbucket/audio2.wav" } }
```

* Submit the translation job (input: JSON file "request.json"; output: JSON file "result$JOBNO.json)
```
$ aws transcribe start-transcription-job --region us-east-2 --cli-input-json file://request.json | tee result-start-$JOBNO.json
{
    "TranscriptionJob": {
        "TranscriptionJobName": "job26816",
        "TranscriptionJobStatus": "IN_PROGRESS",
        "LanguageCode": "en-US",
        "MediaFormat": "wav",
        "Media": {
            "MediaFileUri": "s3://blobbucket/audio2.wav"
        },
        "CreationTime": 1570858854.632
    }
}
```

* Check progress of the Job
```
$ aws transcribe list-transcription-jobs --region us-east-2 --status IN_PROGRESS | tee result-list-$JOBNO.json
{
    "Status": "IN_PROGRESS",
    "TranscriptionJobSummaries": [
        {
            "TranscriptionJobName": "job26816",
            "CreationTime": 1570871217.434,
            "LanguageCode": "en-US",
            "TranscriptionJobStatus": "IN_PROGRESS",
            "OutputLocationType": "SERVICE_BUCKET"
        }
    ]
}

$ aws transcribe list-transcription-jobs --region us-east-2 --status IN_PROGRESS | tee result-list-$JOBNO.json
{
    "Status": "IN_PROGRESS",
    "TranscriptionJobSummaries": []
}
```

* Get details about the Job
```
$ aws transcribe get-transcription-job --region us-east-2 --transcription-job-name "job26816" | tee result-get-$JOBNO.json
{
    "TranscriptionJob": {
        "TranscriptionJobName": "job26816",
        "TranscriptionJobStatus": "COMPLETED",
        "LanguageCode": "en-US",
        "MediaSampleRateHertz": 44100,
        "MediaFormat": "wav",
        "Media": {
            "MediaFileUri": "s3://blobbucket/audio2.wav"
        },
        "Transcript": {
            "TranscriptFileUri": "https://s3.us-east-2.amazonaws.com/aws-transcribe-us-east-2-prod/598691507898/job26816/92e124ae-d054-480f-a850-72d68a61bbc0/asrOutput.json?X-Amz-Security-Token=AgoJb3JpZ2luX2VjEPz%2F%2F%2F%2F%2F%2F%2F%2F%2F%2FwEaCXVzLWVhc3QtMiJHMEUCIQC%2FU4Y2jp7gWkaTY8JQztfwfXxeSNIcQdQOMFxl4IVFhgIgdfv%2FtLHAXXgOYGjwZdVsAngpjlpRWGIV0sfEbwbfVq4q4wMI5v%2F%2F%2F%2F%2F%2F%2F%2F%2F%2FARABGgwyNDYzNjEzMjI3NTIiDPMx2qiU32KAOSeN%2Byq3A8o1hjejbXr%2B0odnwNNLleH2ve9oqLvb3k8HBQIDr0Oh2X9h277vD%2BoXI6ZgfL2NF2rPw3NtFaj25OYBbWdcRYfHNel6uJD8wq49a8oGGPh8GblmvfgpW9kqzP82L1NJaTxOoKOYpHi9aIo16G7ygMjwqqeQgNk3JOuIm4J6YMzNs3Gyp7aLOd180JGGTjgzkJ%2BWFD%2BCj5EG%2BZjjDO%2BWz7G7jqdk7Md498bWa%2BVjkEo3a2Kytc9v5W3X2tpJT%2ByqS3o%2FuoFUJj2f%2FbVhOV%2BoPvch7UWwz9spi0kO1pqp%2FivmZ%2B2e3VxYrTTUwMIfssW7r%2FZe755sRlUcjcMNDZk0UTJHA7VIv63VGLpI7VtCt0nXLylq8Hre1Y479Y83mz4ZF3PvQ%2B4ms3HSm62XNlDxjqfXnqhXxU69YZlMHf%2FysaAqQZWAUrecIDaGgsDUm0g5yLOKTsEDIMpmCp9e4fsiWTI44gQo2fKoxgyaSRW9nTx%2B%2FcMCQiN2Iutpl7A%2BRXjFu5qJVxg1wr%2Bh5aOSaIq%2FLsFUBFLtTpWnggmLerbP3Hdv%2BnFTJkAYTkxbU79FbIkkCL91FTQn5fwwgauF7QU6tAGjF8Oe7uXrvHiac3gSGKNbpB2GKa%2FzGdbXMmIbCnkENx0aoRSaB2kqq3oVGeNF70XJoa1xvLzLrml2YYmLpUKFyeEH6segX%2F0hkhF0d2Haegw27do4rLyoLFRnub58M0zQCWLc5aYoDo2R9fYoxwR%2BOFdmJJk7%2BoI6R44vURaLnhoR%2FD1C3wkq0kfqnMIZ7i3TQVl%2BlaSPX6XTqJxHNqgYuypw6tPXiP9MQvTGNhbIuVFh1zo%3D&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20191012T055032Z&X-Amz-SignedHeaders=host&X-Amz-Expires=899&X-Amz-Credential=ASIATSXCHOUAOYARCSPL%2F20191012%2Fus-east-2%2Fs3%2Faws4_request&X-Amz-Signature=0ffe7b88113dacb547f1861105c21fcebbf3022f70dc831f6a1193c544a4d732"
        },
        "CreationTime": 1570858854.632,
        "CompletionTime": 1570858902.423,
        "Settings": {
            "ChannelIdentification": false
        }
    }
}
```

* Retrieve the JSON output file from the Job
```
$ wget $(jq -r '.TranscriptionJob.Transcript.TranscriptFileUri' results-get-job26816.json)  --output-document=results-output-job26816.json
```

* Review the translation result from the Job
```
$ jq -r '.jobName,.status,.results.transcripts[0].transcript' results-output-job26816.json
job26816
COMPLETED
checking in with another show for H p. R. Um, In the car on my way to a client's gonna be a short show. I'm think I'm gonna be there in 10 minutes, but I want to do, you know, shoot something up the flagpole here, uh, wanted to talk about the state of podcasting these days. These days, I I sound old because in podcasting terms, I am. I've been around since 4 4000 Started producing shows since 2005. Have been listening to podcasts and daily since 2004. I came across, um, my own archives from shows that I used to download back then and listen to which I had burned to a CD, and I've put them on my nads. And I've started streaming them while at work the last couple of weeks and I've had a ball listening to old podcast episodes of
```

### Diarization

* [diarization](https://docs.aws.amazon.com/en_pv/transcribe/latest/dg/how-diarization)
* [API_StartTranscriptionJob](https://docs.aws.amazon.com/transcribe/latest/dg/API_StartTranscriptionJob.html)
* <i>To turn on speaker identification, set the `MaxSpeakerLabels` and `ShowSpeakerLabels` field of the Settings field when you make a call to the StartTranscriptionJob operation.</i>

* Verify (that the file is in the S3 Bucket, if not copy it there; create JSON request content file)
```
$ aws s3 ls s3://blobbucket/audio2.wav || aws s3 cp ../data/audio2.wav s3://blobbucket/audio2.wav
upload: ../data/audio2.wav to s3://blobbucket/audio2.wav         

$ JOBNO=28912

$ cat <<-EOD > request.json
{ "TranscriptionJobName": "job28912", "LanguageCode": "en-US", "Settings": { "MaxSpeakerLabels": 2, "ShowSpeakerLabels": true }, "MediaFormat": "wav", "Media": { "MediaFileUri": "s3://blobbucket/audio2.wav" } }
EOD

```

* Submit the translation job (input: JSON file "request.json"; output: JSON file "result$JOBNO.json)
```
$ aws transcribe start-transcription-job --region us-east-2 --cli-input-json file://request.json | tee result-start-$JOBNO.json
{
    "TranscriptionJob": {
        "TranscriptionJobName": "job28912",
        "TranscriptionJobStatus": "IN_PROGRESS",
        "LanguageCode": "en-US",
        "MediaFormat": "wav",
        "Media": {
            "MediaFileUri": "s3://blobbucket/audio2.wav"
        },
        "CreationTime": 1570871217.434,
        "Settings": {
            "ShowSpeakerLabels": true,
            "MaxSpeakerLabels": 2
        }
    }
}
```

* Check progress of the Job
```
$ aws transcribe list-transcription-jobs --region us-east-2 --status IN_PROGRESS | tee result-list-$JOBNO.json
{
    "Status": "IN_PROGRESS",
    "TranscriptionJobSummaries": [
        {
            "TranscriptionJobName": "job28912",
            "CreationTime": 1570871217.434,
            "LanguageCode": "en-US",
            "TranscriptionJobStatus": "IN_PROGRESS",
            "OutputLocationType": "SERVICE_BUCKET"
        }
    ]
}

$ aws transcribe list-transcription-jobs --region us-east-2 --status IN_PROGRESS | tee result-list-$JOBNO.json
{
    "Status": "IN_PROGRESS",
    "TranscriptionJobSummaries": []
}
```

* Get details about the Job
```
$ aws transcribe get-transcription-job --region us-east-2 --transcription-job-name "job28912" | tee result-get-$JOBNO.json
{
    "TranscriptionJob": {
        "TranscriptionJobName": "job28912",
        "TranscriptionJobStatus": "COMPLETED",
        "LanguageCode": "en-US",
        "MediaSampleRateHertz": 44100,
        "MediaFormat": "wav",
        "Media": {
            "MediaFileUri": "s3://blobbucket/audio2.wav"
        },
        "Transcript": {
            "TranscriptFileUri": "https://s3.us-east-2.amazonaws.com/aws-transcribe-us-east-2-prod/598691507898/job28912/d18357e9-b7f8-419e-b6c8-c37516a66f8f/asrOutput.json?X-Amz-Security-Token=AgoJb3JpZ2luX2VjEAEaCXVzLWVhc3QtMiJGMEQCIFc8TsgswisbjUbQEAkddBvqUCfu%2BjBl%2B9o30RWxKZwhAiAqYZWg9g%2BxAMXw2yzI2JLABe4h%2BlS4Xc%2B%2B4jQvSFZvRyrjAwjq%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F8BEAEaDDI0NjM2MTMyMjc1MiIM7gm%2FH9KjxBU60vG2KrcDJFfi1ztE13grWZYWJStMu%2BotR%2FSk%2FlD%2Fqi0%2BCxyjnIx9oYKG2LCARSPZKprNpXZloFI0A7i6%2FBXrnGf6P%2F9zbTNzeWZE3rxr3GTUjq067HMpNOoZnx3kLDnjRk1NE90CN7XS3VcHKha8eFiBdhtTiMvBmN7rpS%2BdiWpQH6cD3UGAyXkr17jswn3hsV8yc9DkrEZ5sRzVqDEaWHuRp8JczkHV07wGIPKlbFF%2F%2Blw%2Fs401PWKJKncqtVhYuwG97rzhloifNAdVEgs7u5Lip4SfBpFV1Lr%2B3%2FKTT2azj%2FJDKSEfVJLnzGwmDcL34Z88efajRyTobFTbrSufkA7v0fPLBxSURD87YgN7bQh%2B3WB3pxWl4rkKcw8r6QJgKHgBskSMWC2uHWjfUVji5RcRsAuSeedJLcrUdQ1NSsEI13Vkzr7oR8WYsiHz3rPmVsKCLfMgfifPMmU0MNqAcPBZhi3UlCJ0bh5nM7Bb2m9nMiTHk7kRdg1mbra8eckKFXUcHwFtdIcQwxTPdiuxkiM5eMc%2BsWCyaDLUZ7VZE2w%2BfOv6PyMXYj%2BVQKax9c%2F4V9Jirlv7MtfbiB41czC8oYbtBTq1ARgc5qb%2ByLnlbtOCr7yYRsUorkH0iz5WHepFpB73AHDcttA%2BtN2Irkz2FPWfV%2BBUrKMU7G012niqsDu8qXBZeIxQ2ZA7z0sCdaZBaJqODywo4o5CeH173FKhmy00YFvfXXTtSZHOy3XYxuf%2BEDFix1q6bfiRe18eNA5mCR%2BPwLoFSEUdB5eLiJFvFpM6MXAUrWpEal3%2FAvIzXcEqqb0RPAb6YZid1%2BDV%2FzjBO%2B7W9JzVUrgKKdI%3D&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20191012T092107Z&X-Amz-SignedHeaders=host&X-Amz-Expires=900&X-Amz-Credential=ASIATSXCHOUAPLLBLSNZ%2F20191012%2Fus-east-2%2Fs3%2Faws4_request&X-Amz-Signature=ee56417aac64d5428616d74a93bd82bd6c7ec48bb77eec4a2611637203daaf48"
        },
        "CreationTime": 1570871217.434,
        "CompletionTime": 1570871343.764,
        "Settings": {
            "ShowSpeakerLabels": true,
            "MaxSpeakerLabels": 2,
            "ChannelIdentification": false
        }
    }
}
```

* Retrieve the JSON output file from the Job
```
$ wget $(jq -r '.TranscriptionJob.Transcript.TranscriptFileUri' results-get-job28912.json) --output-document=results-output-job28912.json
--2019-10-12 13:22:20--  https://s3.us-east-2.amazonaws.com/aws-transcribe-us-east-2-prod/598691507898/job28912/d18357e9-b7f8-419e-b6c8-c37516a66f8f/asrOutput.json?X-Amz-Security-Token=AgoJb3JpZ2luX2VjEAEaCXVzLWVhc3QtMiJGMEQCIFc8TsgswisbjUbQEAkddBvqUCfu%2BjBl%2B9o30RWxKZwhAiAqYZWg9g%2BxAMXw2yzI2JLABe4h%2BlS4Xc%2B%2B4jQvSFZvRyrjAwjq%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F8BEAEaDDI0NjM2MTMyMjc1MiIM7gm%2FH9KjxBU60vG2KrcDJFfi1ztE13grWZYWJStMu%2BotR%2FSk%2FlD%2Fqi0%2BCxyjnIx9oYKG2LCARSPZKprNpXZloFI0A7i6%2FBXrnGf6P%2F9zbTNzeWZE3rxr3GTUjq067HMpNOoZnx3kLDnjRk1NE90CN7XS3VcHKha8eFiBdhtTiMvBmN7rpS%2BdiWpQH6cD3UGAyXkr17jswn3hsV8yc9DkrEZ5sRzVqDEaWHuRp8JczkHV07wGIPKlbFF%2F%2Blw%2Fs401PWKJKncqtVhYuwG97rzhloifNAdVEgs7u5Lip4SfBpFV1Lr%2B3%2FKTT2azj%2FJDKSEfVJLnzGwmDcL34Z88efajRyTobFTbrSufkA7v0fPLBxSURD87YgN7bQh%2B3WB3pxWl4rkKcw8r6QJgKHgBskSMWC2uHWjfUVji5RcRsAuSeedJLcrUdQ1NSsEI13Vkzr7oR8WYsiHz3rPmVsKCLfMgfifPMmU0MNqAcPBZhi3UlCJ0bh5nM7Bb2m9nMiTHk7kRdg1mbra8eckKFXUcHwFtdIcQwxTPdiuxkiM5eMc%2BsWCyaDLUZ7VZE2w%2BfOv6PyMXYj%2BVQKax9c%2F4V9Jirlv7MtfbiB41czC8oYbtBTq1ARgc5qb%2ByLnlbtOCr7yYRsUorkH0iz5WHepFpB73AHDcttA%2BtN2Irkz2FPWfV%2BBUrKMU7G012niqsDu8qXBZeIxQ2ZA7z0sCdaZBaJqODywo4o5CeH173FKhmy00YFvfXXTtSZHOy3XYxuf%2BEDFix1q6bfiRe18eNA5mCR%2BPwLoFSEUdB5eLiJFvFpM6MXAUrWpEal3%2FAvIzXcEqqb0RPAb6YZid1%2BDV%2FzjBO%2B7W9JzVUrgKKdI%3D&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20191012T092107Z&X-Amz-SignedHeaders=host&X-Amz-Expires=900&X-Amz-Credential=ASIATSXCHOUAPLLBLSNZ%2F20191012%2Fus-east-2%2Fs3%2Faws4_request&X-Amz-Signature=ee56417aac64d5428616d74a93bd82bd6c7ec48bb77eec4a2611637203daaf48
Resolving s3.us-east-2.amazonaws.com (s3.us-east-2.amazonaws.com)... 52.219.104.114
Connecting to s3.us-east-2.amazonaws.com (s3.us-east-2.amazonaws.com)|52.219.104.114|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 30007 (29K) [application/octet-stream]
Saving to: 'results-output-job28912.json'

results-output-job28912.json                  100%[==============================================================================================>]  29.30K   143KB/s    in 0.2s    

2019-10-12 13:22:22 (143 KB/s) - 'results-output-job28912.json' saved [30007/30007]
```

* Review the translation result from the Job
```
$ jq -r '.jobName,.status,.results.speaker_labels.speakers,.results.transcripts[0].transcript' results-output-job28912.json
job28912
COMPLETED
1
checking in with another show for H p. R. Um, In the car on my way to a client's gonna be a short show. I'm think I'm gonna be there in 10 minutes, but I want to do, you know, shoot something up the flagpole here, uh, wanted to talk about the state of podcasting these days. These days, I I sound old because in podcasting terms, I am. I've been around since 4 4000 Started producing shows since 2005. Have been listening to podcasts and daily since 2004. I came across, um, my own archives from shows that I used to download back then and listen to which I had burned to a CD, and I've put them on my nads. And I've started streaming them while at work the last couple of weeks and I've had a ball listening to old podcast episodes of
```

### Language Detection
N/A


<!--



### Language Detection
* [XXXX](XXXX)


### Translate
* [translate](https://docs.aws.amazon.com/translate/latest/dg/what-is.html)


* Verify (that the file is in the S3 Bucket; create JSON request content file)
```
$ ./pre-audio.sh transcribe audio2.mp3
```
* Perform (input: JSON file "request.json"; output: JSON file "result$RANDOM.json)
```
./run-audio.sh detect-labels request.json
```
* Review (text from output JSON) - for expanded view use `jq . <output JSON filename>`
```
$ jq -r . resultXXXX.json
```

-->

