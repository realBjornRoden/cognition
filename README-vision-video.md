# Cognitive Artificial Intelligence - Vision Video

## Use Cases
1. Detect Labels
1. Detect People
1. Detect Faces

***

## AWS (Amazon Web Services)

* [Amazon Rekognition](https://docs.aws.amazon.com/en_pv/rekognition/latest/dg/what-is.html)
   * Prerequisites are to have a valid and activated AWS account and permissions to use "Rekognition" cognitive services
   * <i>Amazon Rekognition operations can analyze videos in MPEG-4 and MOV formats encoded using H.264 codec, that are stored in Amazon S3 buckets</i>
   * "<i>The maximum file size for a stored video is 8GB</i> (2019)"
   * [recommendations-camera-stored-streaming-video](https://docs.aws.amazon.com/en_pv/rekognition/latest/dg/recommendations-camera-stored-streaming-video.html)
   
* Basic Setup
<br><img src="https://docs.aws.amazon.com/en_pv/rekognition/latest/dg/images/VideoRekognition.png" /><br>
   * "<i>You start detecting labels in a video by calling start-label-detection. When Amazon Rekognition finishes analyzing the video, the completion status is sent to the <strong>Amazon SNS topic</strong> that's specified in the --notification-channel parameter of start-label-detection. You can get the completion status by subscribing an <strong>Amazon Simple Queue Service (Amazon SQS) queue</strong> to the Amazon SNS topic. You then poll receive-message to get the completion status from the Amazon SQS queue.</i>"
***
1. Prepare to configure AWS CLI
   <br><i>NB. Do not use the AWS account root user access key. The access key for the AWS account root user gives full access to all resources for all AWS services, including billing information. The permissions cannot be reduce for the AWS account root user access key.</i>
   1. Create a GROUP in the Console, such as `cognitive`, and assign `AmazonRekognitionFullAccess` and `AmazonS3FullAccess` as Policy [create-admin-group](https://docs.aws.amazon.com/IAM/latest/UserGuide/getting-started_create-admin-group.html)
      * NB. Here also using `AmazonSNSFullAccess` for SNS  and `AmazonSQSFullAccess` for SQS and `IAMFullAccess` for IAM
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
1. Create an S3 Bucket and copy files to it
   * [Create an S3 Bucket](https://docs.aws.amazon.com/cli/latest/reference/s3/mb.html) using `aws s3` naming the bucket `blobbucket`
   ```
   $ aws s3 mb s3://blobbucket --region us-east-2 
   make_bucket: blobbucket
   ```
   * [Create an S3 Bucket](https://docs.aws.amazon.com/cli/latest/reference/s3api/create-bucket.html) using `aws s3api` naming the bucket `blobbucket` set to `private`, with `LocationConstraint` set to the specified region
   ```
   $ aws s3api create-bucket --bucket blobbucket --acl private --region us-east-2 --create-bucket-configuration LocationConstraint=us-east-2
   http://blobbucket.s3.amazonaws.com/
   ```
   * Upload files to the S3 Bucket (s3 and s3api commands; single file or recursive on directory)
   ```
   $ aws s3 cp data/15fps-surveillance-video.mp4 s3://blobbucket/
   upload: data/15fps-surveillance-video.mp4 to s3://blobbucket/15fps-surveillance-video.mp4
   
   $ aws s3api put-object --bucket blobbucket --key t15fps-surveillance-video.mp4 --body ./data/15fps-surveillance-video.mp4 --acl private

   $ aws s3 cp --recursive ./data/ s3://blobbucket/
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
***

## Setup for Rekognition video processing
* [video-cli-commands](https://docs.aws.amazon.com/en_pv/rekognition/latest/dg/video-cli-commands.html)
* Evaluate video [recommendations-video](https://docs.aws.amazon.com/en_pv/rekognition/latest/dg/recommendations-camera-stored-streaming-video.html)
   * Codec (h.264 encoded)
   * Frame rate (recommended frame rate is 30 fps, and not less than 5 fps)
   * Encoder bitrate (recommended encoder bitrate is 3 Mbps, and not less than 1.5 Mbps)
   * Frame Rate vs. Frame Resolution (such as for better face search results, favoring a higher frame resolution over a higher frame rate)

***
### Setup Process
* Setup Process Overview
1. Create an SNS topic to receive notifications from Rekognition
   * SNS > Topics
1. Create a Standard SQS queue to recieve messages from Amazon SNS
   * SQS > Create Queue
1. Subscribe the SQS queue to the Amazon SNS topic
   * SQS > Queue Actions > Subscribe Queue to SNS Topic > Choose a Topic
1. Grant permission to the SNS topic to send messages to the SQS queue
   * SQS > Select the queue > Add Permissions > 
      Effect: Allow
      Principal: Everybody (*)
      Actions drop-down: SendMessage
      Add Conditions 
         Condition: ArnEquals
         Key: aws:SourceArn
         Value: the SNS Topic ARN
1. Create the IAM Policy to allow Rekognition to publish the completion status on SNS
   * IAM > Policies > Create Policy > Add JSON { "Version": "2012-10-17", "Statement": [ { "Effect": "Allow", "Action": [ "sns:Publish" ], "Resource": "arn:aws:sns:us-east-2:deadbeeef7898:Textract" } ] }
1. Create the IAM Role
   * IAM > Roles > Choose the service > Rekognition > AmazonRekognitionServiceRole

* Testing sending message to SNS topic for SQS subscriber

1. Send test message
   * SNS > Topics > select topic > Publish message > type and publish message

1. Receive the test message
   ```
   $ aws sqs receive-message --queue-url https://us-east-2.queue.amazonaws.com/deadbeeef7898/Textract --region us-east-2
   ```

1. Parse the test message JSON
   ```
   $ jq -r .Messages[].Body out.test|jq -r .
   {
     "Type": "Notification",
     "MessageId": "2a533413-c11c-5f89-b694-620c9ef8f4bb",
     "TopicArn": "arn:aws:sns:us-east-2:deadbeeef7898:Textract",
     "Message": "bunga bunga",
     "Timestamp": "2019-10-15T05:48:20.205Z",
     "SignatureVersion": "1",
     "Signature": "Ph2ma8EQcgv0MBAwkdF5frdNay9Ymz8pT+/z3dWnozvMNtWwbTDLPP/03iDJuExyNEAOaIAOtGe4ehmmQfA/+6ZNnhfnkG+3R+ux9VIJiKUc9XJsibBH4zrLt7w3dVwOl38nDKf94vbNLPgH17s27SgaXlPBuvELminvwZY1q8/VLnR/gVooxrNwi2CRl1HyDNFZaPWfsw25RMX8ra47SwF173WDi/D7Zfm4IHutIjfPV4eRAWgL6JG0/xKGUJvMY0fD1chqrsw+j119LFWSGAxuQGu5FuGA1ZcauTc69r9muOy8euHxeNWkBBAyp5gUWJuxXY6CXAeuMCPUhG01zA==",
     "SigningCertURL": "https://sns.us-east-2.amazonaws.com/SimpleNotificationService-6aad65c2f9911b05cd53efda11f913f9.pem",
     "UnsubscribeURL": "https://sns.us-east-2.amazonaws.com/?Action=Unsubscribe&SubscriptionArn=arn:aws:sns:us-east-2:deadbeeef7898:Textract:74ab3934-7e9d-450d-98e9-6803f245ab12"
   }
   ```


### Setup Configuration Overview

* Amazon SNS > Topics
   ```
   Name: RekognitionVideo
   ARN: arn:aws:sns:us-east-1:deadbeeef7898:RekognitionVideo
   ```

* Amazon SQS > Create Queue
   ```
   Name: RekognitionVideo
   Queue Type: Standard
   URL: https://sqs.us-east-1.amazonaws.com/deadbeeef7898/RekognitionVideo	
   ARN: arn:aws:sqs:us-east-1:deadbeeef7898:RekognitionVideo	
   Subscribe SNS Topic: RekognitionVideo
   Subscribe SNS ARN: arn:aws:sns:us-east-1:deadbeeef7898:RekognitionVideo
   Permission subscribing on SNS:
      Effect	Principals	Actions	         Conditions
      Allow	Everybody (*)   SQS:SendMessage  ArnEquals - aws:SourceArn: "arn:aws:sns:us-east-1:deadbeeef7898:RekognitionVideo"
   Permission subscribing on SNS JSON:
      { "Version": "2012-10-17", "Id": "arn:aws:sqs:us-east-1:deadbeeef7898:RekognitionVideo/SQSDefaultPolicy", "Statement": [ { "Sid": "Sid1571039537626", "Effect": "Allow", "Principal": { "AWS": "*" }, "Action": "SQS:SendMessage", "Resource": "arn:aws:sqs:us-east-1:deadbeeef7898:RekognitionVideo", "Condition": { "ArnEquals": { "aws:SourceArn": "arn:aws:sns:us-east-1:deadbeeef7898:RekognitionVideo" } } } ] }
   ```

* IAM > Roles > Rekognition > AmazonRekognitionServiceRole
   ```
   Name: RekognitionVideo
   AWS service: rekognition.amazonaws.com
   ARN: arn:aws:iam::deadbeeef7898:role/RekognitionVideo
   ```

* IAM > Policy
   ```
   Name: RekognitionVideo
   ARN: arn:aws:iam::deadbeeef7898:policy/RekognitionVideo
   Permission to publish on SNS:
   JSON: { "Version": "2012-10-17", "Statement": [ { "Effect": "Allow", "Action": [ "sns:Publish" ], "Resource": "arn:aws:sns:us-east-1:deadbeeef7898:RekognitionVideo" } ] }
   ```


### Setup Configuration Review
* SQS Queue
   ```
   $ aws sqs list-queues --region us-east-1
   {
       "QueueUrls": [
           "https://queue.amazonaws.com/deadbeeef7898/RekognitionVideo"
       ]
   }
   ```
* SNS Topic
   ```
   $ aws sns list-topics --region us-east-1
   {
       "Topics": [
           {
               "TopicArn": "arn:aws:sns:us-east-1:deadbeeef7898:RekognitionVideo"
           }
       ]
   }
   ```
* SNS Subscription
   ```
   $ aws sns list-subscriptions --region us-east-1 
   {
       "Subscriptions": [
           {
               "SubscriptionArn": "arn:aws:sns:us-east-1:deadbeeef7898:RekognitionVideo:af2afca1-b93b-44d2-b69b-79983ba1fa5b",
               "Owner": "deadbeeef7898",
               "Protocol": "sqs",
               "Endpoint": "arn:aws:sqs:us-east-1:deadbeeef7898:RekognitionVideo",
               "TopicArn": "arn:aws:sns:us-east-1:deadbeeef7898:RekognitionVideo"
           }
       ]
   }
   ```
* IAM Role
   ```
   $ aws iam list-roles | jq '.Roles[]|select(.RoleName=="RekognitionVideo")'
   {
     "Path": "/",
     "RoleName": "RekognitionVideo",
     "RoleId": "AROAYWZGLN25MDYHHZ7WE",
     "Arn": "arn:aws:iam::deadbeeef7898:role/RekognitionVideo",
     "CreateDate": "2019-10-14T07:10:15Z",
     "AssumeRolePolicyDocument": {
       "Version": "2012-10-17",
       "Statement": [
         {
           "Effect": "Allow",
           "Principal": {
             "Service": "rekognition.amazonaws.com"
           },
           "Action": "sts:AssumeRole",
           "Condition": {}
         }
       ]
     },
     "Description": "Allows Rekognition to call AWS services on your behalf.",
     "MaxSessionDuration": 3600
   }
   ```
* IAM Policy
   ```
   $ aws iam list-policies| jq '.Policies[]|select(.PolicyName=="RekognitionVideo")'           
   {
     "PolicyName": "RekognitionVideo",
     "PolicyId": "ANPAYWZGLN25IY67HU6CW",
     "Arn": "arn:aws:iam::deadbeef7898:policy/RekognitionVideo",
     "Path": "/",
     "DefaultVersionId": "v1",
     "AttachmentCount": 0,
     "PermissionsBoundaryUsageCount": 0,
     "IsAttachable": true,
     "CreateDate": "2019-10-14T07:20:44Z",
     "UpdateDate": "2019-10-14T07:20:44Z"
   }
   ```

### Detect Labels

1. Upload the video to be analyzed to S3 Bucket, create the bucket if needed
   ```
   $ aws s3 mb s3://blobbucket-us-east-1/ --region us-east-1
   make_bucket: blobbucket-us-east-1

   $ aws s3 cp data/15fps-surveillance-video.mp4  s3://blobbucket-us-east-1                         
   upload: data/15fps-surveillance-video.mp4 to s3://blobbucket-us-east-1/15fps-surveillance-video.mp4
   ```

1. Start the video analysis request with `aws rekognition start-label-detection`
   ```
   $ aws rekognition start-label-detection --video '{"S3Object":{"Bucket":"blobbucket-us-east-1","Name":"15fps-surveillance-video.mp4"}}' --notification-channel '{"SNSTopicArn":"arn:aws:sns:us-east-1:deadbeeef7898:RekognitionVideo","RoleArn":"arn:aws:iam::deadbeeef7898:role/RekognitionVideo"}' --region us-east-1
   {
       "JobId": "7964e89e7bcf6c13205552ebb6564b06deadbeeefaa811beda0fc3a6ce2b336fa"
   }
   ```

1. Get the completion status from the Amazon SQS queue with `aws sqs receive-message`
   ```
   $ aws sqs receive-message --queue-url https://sqs.us-east-1.amazonaws.com/deadbeeef7898/RekognitionVideo --region us-east-1 | tee result-status.json
   {
       "Messages": [
           {
               "MessageId": "ec3211dc-3f7b-4885-a49e-4c383d94a3cd",
               "ReceiptHandle": "AQEBE/S2Onn/rQrrycJhS9oanKiDf5SQHrsk0HcA5RiHS4IsucBGOQoINYusmLRNUpZL51WMo7BmYbD92AvXPZ/B4QAVt2+pYGxWvRiwsUnbVvPvTlTnnQ0VxDGQD5+P/1xRnEp0ghBdGSE83rzDT8bTK2Nhi220o20wZjrU3ORXA69JUty9othNLJIJ3g/piE4Ebf1tYQNO+A9naPoIYYedbnRVtXEK5KqJFjcMtvh2U5N7cTDNOXcYtzJ9QuXFugTo4lwSQsH5xFCbaER5Sb5WQgt8eLqs629ohJpru5NiF45TVa9SXvoNIcEdvfxyAENra8SYyn+9Xxwx4NIKs8ZAhK3YwQT82p2ER84ncH1VT9Kpkrn80v/ZZr/aGZfw0KwmusOye/5pgv6SB7maPQ+BbQ==",
               "MD5OfBody": "3442806b4e240da211091700a48216ef",
               "Body": "{\n  \"Type\" : \"Notification\",\n  \"MessageId\" : \"de3dc304-57e4-546c-a947-951a6456ab86\",\n  \"TopicArn\" : \"arn:aws:sns:us-east-1:deadbeeef7898:RekognitionVideo\",\n  \"Message\" : \"{\\\"JobId\\\":\\\"7964e89e7bcf6c13205552ebb6564b06deadbeeefaa811beda0fc3a6ce2b336fa\\\",\\\"Status\\\":\\\"SUCCEEDED\\\",\\\"API\\\":\\\"StartLabelDetection\\\",\\\"Timestamp\\\":1571041650362,\\\"Video\\\":{\\\"S3ObjectName\\\":\\\"15fps-surveillance-video.mp4\\\",\\\"S3Bucket\\\":\\\"blobbucket-us-east-1\\\"}}\",\n  \"Timestamp\" : \"2019-10-14T08:27:30.458Z\",\n  \"SignatureVersion\" : \"1\",\n  \"Signature\" : \"nApZMv3+NZjoO0ld79BMsmR+YV44VK69Kg39KZj2JxUYXWN+rlyZnlMiwiz/o6Gge2bNgFL6Ome0/qRvGZonKW9MfxScYkl6ZW50AElxoXoZP5cR++yJ340MucFRK+fdjNlqoXemmfUt3S5Q5n9p3JUViPt4k/rZmyFSwE751FJeQp/b1xK/fsd4hAoraQ5pwSvoagUBLihMqAkCyRVDhwbNY1FwjOgjK3SxpH5PF4KLhMO3XcniqOI0RxYYBrXPmWOy9G2gObepl/vqt1xVYEPWUud6aqM3ERmNTqn7q6LYioIjx6koWbXWdpIgjK6oI3cwoZkiNU1jx3DVKUC32w==\",\n  \"SigningCertURL\" : \"https://sns.us-east-1.amazonaws.com/SimpleNotificationService-6aad65c2f9911b05cd53efda11f913f9.pem\",\n  \"UnsubscribeURL\" : \"https://sns.us-east-1.amazonaws.com/?Action=Unsubscribe&SubscriptionArn=arn:aws:sns:us-east-1:deadbeeef7898:RekognitionVideo:af2afca1-b93b-44d2-b69b-79983ba1fa5b\"\n}"
           }
       ]
   }

   $ jq -r '.Messages[].Body' result-status.json
   {
     "Type": "Notification",
     "MessageId": "de3dc304-57e4-546c-a947-951a6456ab86",
     "TopicArn": "arn:aws:sns:us-east-1:deadbeeef7898:RekognitionVideo",
     "Message": "{\"JobId\":\"7964e89e7bcf6c13205552ebb6564b06deadbeeefaa811beda0fc3a6ce2b336fa\",\"Status\":\"SUCCEEDED\",\"API\":\"StartLabelDetection\",\"Timestamp\":1571041650362,\"Video\":{\"S3ObjectName\":\"15fps-surveillance-video.mp4\",\"S3Bucket\":\"blobbucket-us-east-1\"}}",
     "Timestamp": "2019-10-14T08:27:30.458Z",
     "SignatureVersion": "1",
     "Signature": "nApZMv3+NZjoO0ld79BMsmR+YV44VK69Kg39KZj2JxUYXWN+rlyZnlMiwiz/o6Gge2bNgFL6Ome0/qRvGZonKW9MfxScYkl6ZW50AElxoXoZP5cR++yJ340MucFRK+fdjNlqoXemmfUt3S5Q5n9p3JUViPt4k/rZmyFSwE751FJeQp/b1xK/fsd4hAoraQ5pwSvoagUBLihMqAkCyRVDhwbNY1FwjOgjK3SxpH5PF4KLhMO3XcniqOI0RxYYBrXPmWOy9G2gObepl/vqt1xVYEPWUud6aqM3ERmNTqn7q6LYioIjx6koWbXWdpIgjK6oI3cwoZkiNU1jx3DVKUC32w==",
     "SigningCertURL": "https://sns.us-east-1.amazonaws.com/SimpleNotificationService-6aad65c2f9911b05cd53efda11f913f9.pem",
     "UnsubscribeURL": "https://sns.us-east-1.amazonaws.com/?Action=Unsubscribe&SubscriptionArn=arn:aws:sns:us-east-1:deadbeeef7898:RekognitionVideo:af2afca1-b93b-44d2-b69b-79983ba1fa5b"
   }

   $ jq -r '.Messages[0].Body' result-status.json|jq -r '.Message'|jq '.'
   {
     "JobId": "7964e89e7bcf6c13205552ebb6564b06deadbeeefaa811beda0fc3a6ce2b336fa",
     "Status": "SUCCEEDED",
     "API": "StartLabelDetection",
     "Timestamp": 1571041650362,
     "Video": {
       "S3ObjectName": "15fps-surveillance-video.mp4",
       "S3Bucket": "blobbucket-us-east-1"
     }
   }
   ```

1. Get the video analysis results with `aws rekognition get-label-detection`
   ```
   $ aws rekognition get-label-detection --job-id "7964e89e7bcf6c13205552ebb6564b06deadbeeefaa811beda0fc3a6ce2b336fa" --region us-east-1 >result-detection.json

   $ jq -r '.JobStatus,.VideoMetadata' result-detection.json
   SUCCEEDED
   {
     "Codec": "h264",
     "DurationMillis": 21656,
     "Format": "QuickTime / MOV",
     "FrameRate": 29.9689998626709,
     "FrameHeight": 240,
     "FrameWidth": 320
   }

   $ jq -r '.Labels[]|select(.Label.Name=="Person")|"\(.Timestamp) \(.Label.Confidence|tonumber) \(.Label.Instances)"' out2.json|awk '{printf "Frame: %s Confidence: %.2f Box: %s\n", $1, $2,$3}'  
   Frame: 967 Confidence: 58.26 Box: [{"BoundingBox":{"Width":0.041670799255371094,"Height":0.1896933913230896,"Left":0.952782928943634,"Top":0.3357686996459961},"Confidence":63.67138671875}]
   Frame: 1468 Confidence: 92.70 Box: [{"BoundingBox":{"Width":0.08079147338867188,"Height":0.23073521256446838,"Left":0.9086510539054871,"Top":0.3004027009010315},"Confidence":99.84532928466797}]
   Frame: 1968 Confidence: 99.73 Box: [{"BoundingBox":{"Width":0.06082210689783096,"Height":0.2385426163673401,"Left":0.871123194694519,"Top":0.28691354393959045},"Confidence":99.72191619873047}]
   Frame: 2469 Confidence: 99.64 Box: [{"BoundingBox":{"Width":0.07394981384277344,"Height":0.24707704782485962,"Left":0.8161672353744507,"Top":0.2709895074367523},"Confidence":99.63427734375}]
   Frame: 2969 Confidence: 99.62 Box: [{"BoundingBox":{"Width":0.09204711765050888,"Height":0.2337835133075714,"Left":0.7435498237609863,"Top":0.2602587640285492},"Confidence":99.5849838256836}]
   Frame: 3470 Confidence: 99.63 Box: [{"BoundingBox":{"Width":0.06473159790039062,"Height":0.24745871126651764,"Left":0.7012126445770264,"Top":0.24149833619594574},"Confidence":99.72181701660156}]
   Frame: 3970 Confidence: 98.73 Box: [{"BoundingBox":{"Width":0.05377340316772461,"Height":0.23113708198070526,"Left":0.6442241668701172,"Top":0.23210640251636505},"Confidence":99.38427734375}]
   Frame: 4471 Confidence: 96.91 Box: [{"BoundingBox":{"Width":0.0795888900756836,"Height":0.23333440721035004,"Left":0.5717700719833374,"Top":0.2333349585533142},"Confidence":95.74153900146484}]
   Frame: 4971 Confidence: 97.90 Box: [{"BoundingBox":{"Width":0.093767449259758,"Height":0.22934886813163757,"Left":0.5023199915885925,"Top":0.23211219906806946},"Confidence":98.04926300048828}]
   Frame: 5472 Confidence: 99.27 Box: [{"BoundingBox":{"Width":0.07382984459400177,"Height":0.21751612424850464,"Left":0.4604105055332184,"Top":0.22720497846603394},"Confidence":99.57424926757812}]
   Frame: 5972 Confidence: 99.37 Box: [{"BoundingBox":{"Width":0.06527690589427948,"Height":0.2122858613729477,"Left":0.45242947340011597,"Top":0.22600330412387848},"Confidence":99.54767608642578}]
   Frame: 6473 Confidence: 98.90 Box: [{"BoundingBox":{"Width":0.060443781316280365,"Height":0.22271715104579926,"Left":0.45079106092453003,"Top":0.22034291923046112},"Confidence":98.5984115600586}]
   Frame: 6973 Confidence: 99.07 Box: [{"BoundingBox":{"Width":0.057089708745479584,"Height":0.22315064072608948,"Left":0.4529975950717926,"Top":0.2216542810201645},"Confidence":99.1624526977539}]
   Frame: 7474 Confidence: 99.18 Box: [{"BoundingBox":{"Width":0.06469936668872833,"Height":0.2262258529663086,"Left":0.4495598375797272,"Top":0.22182568907737732},"Confidence":99.23768615722656}]
   Frame: 7974 Confidence: 99.16 Box: [{"BoundingBox":{"Width":0.06654186546802521,"Height":0.22303110361099243,"Left":0.45049452781677246,"Top":0.22402258217334747},"Confidence":99.04534912109375}]
   Frame: 8475 Confidence: 99.35 Box: [{"BoundingBox":{"Width":0.058776091784238815,"Height":0.2221209853887558,"Left":0.4544622302055359,"Top":0.2249108999967575},"Confidence":99.43775939941406}]
   Frame: 8975 Confidence: 99.18 Box: [{"BoundingBox":{"Width":0.06203870847821236,"Height":0.22727209329605103,"Left":0.4643033444881439,"Top":0.22616854310035706},"Confidence":99.36737060546875}]
   Frame: 9476 Confidence: 96.13 Box: [{"BoundingBox":{"Width":0.059099484235048294,"Height":0.22834141552448273,"Left":0.4874933660030365,"Top":0.21885770559310913},"Confidence":98.3703842163086}]
   Frame: 9976 Confidence: 90.30 Box: [{"BoundingBox":{"Width":0.06722088158130646,"Height":0.21765105426311493,"Left":0.5355201959609985,"Top":0.22908101975917816},"Confidence":86.02194213867188}]
   Frame: 10477 Confidence: 94.11 Box: [{"BoundingBox":{"Width":0.11091585457324982,"Height":0.2167797088623047,"Left":0.570489227771759,"Top":0.2526220977306366},"Confidence":95.37702941894531}]
   Frame: 10978 Confidence: 97.76 Box: [{"BoundingBox":{"Width":0.11687908321619034,"Height":0.21114571392536163,"Left":0.6746412515640259,"Top":0.274556428194046},"Confidence":98.29331970214844}]
   Frame: 11478 Confidence: 79.05 Box: [{"BoundingBox":{"Width":0.07418155670166016,"Height":0.22305838763713837,"Left":0.8415846824645996,"Top":0.29771655797958374},"Confidence":98.47969055175781}]
   ```

