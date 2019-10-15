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
1. Create an SNS topic to receive notifications from Rekognition
   * SNS > Topics
1. Create a Standard SQS queue to recieve messages from Amazon SNS
   * SQS > Create Queue
1. Subscribe the SQS queue to the Amazon SNS topic
   * SQS > Queue Actions > Subscribe Queue to SNS Topic > Choose a Topic
1. Grant permission to the SNS topic to send messages to the SQS queue
   * SQS > Select the queue > Add Permissions > 
      ```
      Effect: Allow
      Principal: Everybody (*)
      Actions drop-down: SendMessage
      Add Conditions 
         Condition: ArnEquals
         Key: aws:SourceArn
         Value: the SNS Topic ARN
      ```
1. Create the IAM Policy to allow Rekognition to publish the completion status on SNS
   * IAM > Policies > Create Policy > Add JSON
      ```
      {
        "Version": "2012-10-17",
        "Statement": [
           {
             "Effect": "Allow",
             "Action": [ "sns:Publish" ],
             "Resource": "arn:aws:sns:us-east-1:deadbeeef7898:RekognitionVideo"
           }
        ]
      }
      ```
1. Create the IAM Role
   * IAM > Roles > Choose the service > Rekognition > AmazonRekognitionServiceRole

1. Test the SNS to SQS connection by sending a message to the SNS topic for the SQS subscriber
   1. Send test message
      * SNS > Topics > select topic > Publish message > type and publish message
   1. Receive the test message
      ```
      $ aws sqs receive-message --queue-url https://sqs.us-east-1.amazonaws.com/deadbeef7898/RekognitionVideo --region us-east-1 | tee test-message.json
      {
          "Messages": [
              {
                  "MessageId": "88ab70a8-63cf-425e-a276-8d1bc2f09d97",
                  "ReceiptHandle": "AQEBFEcyFAXJiTVdLDVtiQMtwc5TuHtwHyHjEpmZ0ux434rtrp6lrc77HzggfSzk4Eq34W45Nxuvjz478Q7zNCNMSzkjmelSDuIMcPqcV85L+f5Gh6Ty3B3ga6QYNFocBjAAECVHhjgAl1U+HHhNHuPnE94h2jurKcXc86m5dgyUvdVncl3O/oJCQ4mp8okmqJKRjbmX5+r4pE6JVwRHpdEo6zti1SeEw8WplgA+e7YM7ojQEC+4rVAyKAla/Fy/k68Wxc3r7jx2kokWaajubWBOam2QYB0Zqr2m7aNt4KVp5uz2zEqWW/MCBDmeirXseZ7TOuD8KmjPzabudhlIOV1hoowFMa4TIpNCpCLUPvJKvJzOExBYaHZNIZyMdtCTb0SJt95p/7NTuBs5teh6yCz+lQ==",
                  "MD5OfBody": "da44c816125c2d5583b649719858556a",
                  "Body": "{\n  \"Type\" : \"Notification\",\n  \"MessageId\" : \"33807e86-7880-55c1-b183-289900bcd25b\",\n  \"TopicArn\" : \"arn:aws:sns:us-east-1:deadbeef7898:RekognitionVideo\",\n  \"Message\" : \"bunga bunga\",\n  \"Timestamp\" : \"2019-10-15T07:32:12.475Z\",\n  \"SignatureVersion\" : \"1\",\n  \"Signature\" : \"riP4YsOb9PT8AgtCIOXBiseaP4WeTzO6DSAk2JwP9+nDNnOoWXBGFREuYy6H2yKOTELIj6wissenm9nb9O/QRuBmQwyfRkEQUK1lhQipRmoYIbmeZjYMiynBUq9Kq5DOoH8TMmbLogUJwswDaigq33DG28Y6H4Bqt/j2V9KgxQr2gjS5Q8z1xVw/QCeam3Q1Lzii1wAm+fX8TXPl8ZrnBNMiEbNdyZzSgFHlAwj/BLbLK+WmPwxp/3Jtlxfg1Qy5paZKqzTSoeegBryJMWUWrhNPyQsz96uMSH0ZIrEY7sGiaVfeUZPmBGOKh0Vd5AH8z2V/TXRvKWier43uqa4G4A==\",\n  \"SigningCertURL\" : \"https://sns.us-east-1.amazonaws.com/SimpleNotificationService-6aad65c2f9911b05cd53efda11f913f9.pem\",\n  \"UnsubscribeURL\" : \"https://sns.us-east-1.amazonaws.com/?Action=Unsubscribe&SubscriptionArn=arn:aws:sns:us-east-1:deadbeef7898:RekognitionVideo:af2afca1-b93b-44d2-b69b-79983ba1fa5b\"\n}"
              }
          ]
      }
      ```
   1. Parse the test message JSON
      ```
      $ jq -r '.Messages[].Body' test-message.json|jq -r '"\(.MessageId) \(.Timestamp) MESSAGE:\"\(.Message)\""'  
      33807e86-7880-55c1-b183-289900bcd25b 2019-10-15T07:32:12.475Z MESSAGE:"bunga bunga"
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
* SQS Queue Policy
   ```
   $ aws sqs get-queue-attributes --region us-east-1 --queue-url https://sqs.us-east-1.amazonaws.com/deadbeef7898/RekognitionVideo --attribute-names Policy|jq -r '.Attributes.Policy'|jq .  
   {
     "Version": "2012-10-17",
     "Id": "arn:aws:sqs:us-east-1:deadbeef7898:RekognitionVideo/SQSDefaultPolicy",
     "Statement": [
       {
         "Sid": "Sid1571039537626",
         "Effect": "Allow",
         "Principal": {
           "AWS": "*"
         },
         "Action": "SQS:SendMessage",
         "Resource": "arn:aws:sqs:us-east-1:deadbeef7898:RekognitionVideo",
         "Condition": {
           "ArnEquals": {
             "aws:SourceArn": "arn:aws:sns:us-east-1:deadbeef7898:RekognitionVideo"
           }
         }
       }
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
* [detecting-labels](https://docs.aws.amazon.com/en_pv/rekognition/latest/dg/labels-detecting-labels-video.html)
***

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
   $ aws rekognition get-label-detection --job-id "7964e89e7bcf6c13205552ebb6564b06deadbeeefaa811beda0fc3a6ce2b336fa" --region us-east-1 >result-label-detection.json
   ```
   * Review the analsysis metadata information about the video file
      ```
      $ jq -r '.JobStatus,.VideoMetadata' result-label-detection.json
      SUCCEEDED
      {
        "Codec": "h264",
        "DurationMillis": 21656,
        "Format": "QuickTime / MOV",
        "FrameRate": 29.9689998626709,
        "FrameHeight": 240,
        "FrameWidth": 320
      }
      ```
   * Review the analsysis information about the video file, in this case label names tagged as "Person"
      ```
      $ jq -r '.Labels[]|select(.Label.Name=="Person")|"\(.Timestamp) \(.Label.Confidence|tonumber) \(.Label.Instances)"' result-label-detection.json|awk '{printf "Frame: %s Confidence: %.2f Box: %s\n", $1, $2,$3}'  
      Frame: 967 Confidence: 58.26 Box: [{"BoundingBox":{"Width":0.041670799255371094,"Height":0.1896933913230896,"Left":0.952782928943634,"Top":0.3357686996459961},"Confidence":63.67138671875}]
      Frame: 1468 Confidence: 92.70 Box: [{"BoundingBox":{"Width":0.08079147338867188,"Height":0.23073521256446838,"Left":0.9086510539054871,"Top":0.3004027009010315},"Confidence":99.84532928466797}]
      Frame: 1968 Confidence: 99.73 Box: [{"BoundingBox":{"Width":0.06082210689783096,"Height":0.2385426163673401,"Left":0.871123194694519,"Top":0.28691354393959045},"Confidence":99.72191619873047}]
      Frame: 2469 Confidence: 99.64 Box: [{"BoundingBox":{"Width":0.07394981384277344,"Height":0.24707704782485962,"Left":0.8161672353744507,"Top":0.2709895074367523},"Confidence":99.63427734375}]
      Frame: 2969 Confidence: 99.62 Box: [{"BoundingBox":{"Width":0.09204711765050888,"Height":0.2337835133075714,"Left":0.7435498237609863,"Top":0.2602587640285492},"Confidence":99.5849838256836}]
      <...removed...>
      Frame: 9476 Confidence: 96.13 Box: [{"BoundingBox":{"Width":0.059099484235048294,"Height":0.22834141552448273,"Left":0.4874933660030365,"Top":0.21885770559310913},"Confidence":98.3703842163086}]
      Frame: 9976 Confidence: 90.30 Box: [{"BoundingBox":{"Width":0.06722088158130646,"Height":0.21765105426311493,"Left":0.5355201959609985,"Top":0.22908101975917816},"Confidence":86.02194213867188}]
      Frame: 10477 Confidence: 94.11 Box: [{"BoundingBox":{"Width":0.11091585457324982,"Height":0.2167797088623047,"Left":0.570489227771759,"Top":0.2526220977306366},"Confidence":95.37702941894531}]
      Frame: 10978 Confidence: 97.76 Box: [{"BoundingBox":{"Width":0.11687908321619034,"Height":0.21114571392536163,"Left":0.6746412515640259,"Top":0.274556428194046},"Confidence":98.29331970214844}]
      Frame: 11478 Confidence: 79.05 Box: [{"BoundingBox":{"Width":0.07418155670166016,"Height":0.22305838763713837,"Left":0.8415846824645996,"Top":0.29771655797958374},"Confidence":98.47969055175781}]
      ```

### Detect Faces
* [detecting-faces](https://docs.aws.amazon.com/en_pv/rekognition/latest/dg/faces-sqs-video.html)
***

1. Start the video analysis request with `aws rekognition start-face-detection`
   ```
   $ aws rekognition start-face-detection --video '{"S3Object":{"Bucket":"blobbucket-us-east-1","Name":"15fps-surveillance-video.mp4"}}' --attributes "ALL" --notification-channel '{"SNSTopicArn":"arn:aws:sns:us-east-1:deadbeef7898:RekognitionVideo","RoleArn":"arn:aws:iam::deadbeef7898:role/RekognitionVideo"}' --region us-east-1
   {
       "JobId": "7ff36fb709f061b4b580eb483ac6d17c9c882cf9df240b70ca312be2d2bdc7e5"
   }
   ```

1. Check number of available message in the SQS queue
   ```
   $ aws sqs get-queue-attributes --region us-east-1 --queue-url https://sqs.us-east-1.amazonaws.com/deadbeef7898/RekognitionVideo --attribute-names ApproximateNumberOfMessages             
   {
       "Attributes": {
           "ApproximateNumberOfMessages": "1"
       }
   }
   ```

1. Retrieve the result from the analysis, in this case no faces were detected
   ```
   $ aws rekognition get-face-detection --job-id "7ff36fb709f061b4b580eb483ac6d17c9c882cf9df240b70ca312be2d2bdc7e5" --region us-east-1 >result-face-detection.json

   $ cat result-face-detection.json
   {
       "JobStatus": "SUCCEEDED",
       "VideoMetadata": {
           "Codec": "h264",
           "DurationMillis": 21656,
           "Format": "QuickTime / MOV",
           "FrameRate": 29.9689998626709,
           "FrameHeight": 240,
           "FrameWidth": 320
       },
       "Faces": []
   }
   ```

1. Delete the SQS message
   ```
   $ aws sqs receive-message --queue-url https://sqs.us-east-1.amazonaws.com/deadbeef7898/RekognitionVideo --region us-east-1 | jq '.Messages[].ReceiptHandle'
"AQEBxmrUWIWdu60Bp00l3tiaoGb2/eRZou1/wmI6WQjyl1BglyfNRz+4sxZE2RC+FnWo/hlnLU9r7qwysA34Y1d2K+mF1PYFMmx88wsXBszaOXQpetz9knSIh4Vts/yrYYlbhcdU7EyB4nf5VYNCuMk7StW7g7DLwUxDrF5KJbIMYhPR/JdyZ70EIG52vHjr+UPgXxpIuxuTiz0Q+vEIsgxYBAPgiVBdgmRJgcw3I8e297PO8NNDHm6eVSrWntMFFsl59dTIb+8LII4Mdp2OOjKcsLKNtHiUf/8i3bG76X7051yOe2PjXtRZ2m7aRfET/HmP6oWUV9fjz4T25WJH/idPNa1DgwQlkcsbnw24r+ucMsnCa0W6gTjH/zsmo0yLP2g7IMhXnskgBu0F/HGHie10WA=="

   $ aws sqs delete-message --queue-url https://sqs.us-east-1.amazonaws.com/deadbeef7898/RekognitionVideo --region us-east-1 --receipt-handle "AQEBxmrUWIWdu60Bp00l3tiaoGb2/eRZou1/wmI6WQjyl1BglyfNRz+4sxZE2RC+FnWo/hlnLU9r7qwysA34Y1d2K+mF1PYFMmx88wsXBszaOXQpetz9knSIh4Vts/yrYYlbhcdU7EyB4nf5VYNCuMk7StW7g7DLwUxDrF5KJbIMYhPR/JdyZ70EIG52vHjr+UPgXxpIuxuTiz0Q+vEIsgxYBAPgiVBdgmRJgcw3I8e297PO8NNDHm6eVSrWntMFFsl59dTIb+8LII4Mdp2OOjKcsLKNtHiUf/8i3bG76X7051yOe2PjXtRZ2m7aRfET/HmP6oWUV9fjz4T25WJH/idPNa1DgwQlkcsbnw24r+ucMsnCa0W6gTjH/zsmo0yLP2g7IMhXnskgBu0F/HGHie10WA=="

   $ aws sqs get-queue-attributes --region us-east-1 --queue-url https://sqs.us-east-1.amazonaws.com/deadbeef7898/RekognitionVideo --attribute-names ApproximateNumberOfMessages
   {
       "Attributes": {
           "ApproximateNumberOfMessages": "0"
       }
   }
   ```

### Track Person
* [person-tracking](https://docs.aws.amazon.com/cli/latest/reference/rekognition/start-person-tracking.html)
***

1. Upload the video to be analyzed to S3 Bucket, create the bucket if needed
   ```
   $ aws s3 mb s3://blobbucket-us-east-1/ --region us-east-1
   make_bucket: blobbucket-us-east-1

   $ aws s3 cp data/15fps-surveillance-video.mp4  s3://blobbucket-us-east-1                         
   upload: data/15fps-surveillance-video.mp4 to s3://blobbucket-us-east-1/15fps-surveillance-video.mp4
   ```

1. Start the video analysis request with `aws rekognition start-person-tracking`
   ```
   $ aws rekognition start-person-tracking --video '{"S3Object":{"Bucket":"blobbucket-us-east-1","Name":"15fps-surveillance-video.mp4"}}' --notification-channel '{"SNSTopicArn":"arn:aws:sns:us-east-1:deadbeef7898:RekognitionVideo","RoleArn":"arn:aws:iam::deadbeef7898:role/RekognitionVideo"}' --region us-east-1
   {
       "JobId": "43157b6bc2b0c73243e35eebf325a8322d06fa94b4940021fdf8f4b966a91ba4"
   }
   ```

1. Get the completion status from the Amazon SQS queue with `aws sqs receive-message`
   ```
   $ aws sqs receive-message --queue-url https://sqs.us-east-1.amazonaws.com/deadbeef7898/RekognitionVideo --region us-east-1 | tee result-status.json
   {
       "Messages": [
           {
               "MessageId": "1b2b36f1-5ccf-4e4c-8867-6c92cbd15405",
               "ReceiptHandle": "AQEBw8jfD1z9mD5G1tJQ7mvOUTJ/zsqB/YsbdyiIWMfYtK3LX6cFzWEfwFaMjKHmU7ep5VegcJRle1JNJ/BF5rhHqd7VO3+GtF4v9uvBU2kMPu0/CQBKECk22TdR7fHD1s4GA2NbPn3gAXdhMXKT8zLKRvpy0bl3aGeJBtNAT1hVqe2gs8g97A0PWhFrJXT7Qd3kuN/SNOIMfNgE1ZgQ64bg/a2sgSgQhMt1LScwepoEiZX18otbPkEFPE/68Q3rxYKrl5TJrirg+8kWwuonb2Dn3E+Bv0MONpSMj3mPlMsDpVnNUhnVNxv0gt+/S6zuNdDVGvwiIqVsb3tNEzAkAkxjtaiZcDzvzXQbQy3agHFgTxXqBlt1jXii2vevh05b0dXlKPntdWYp0cQs/0O0bDQs2A==",
               "MD5OfBody": "e568776a38f4cb1c7040e5e013d655e6",
               "Body": "{\n  \"Type\" : \"Notification\",\n  \"MessageId\" : \"d7a7edf6-3d28-57e0-ae98-bbe99a8d37da\",\n  \"TopicArn\" : \"arn:aws:sns:us-east-1:deadbeef7898:RekognitionVideo\",\n  \"Message\" : \"{\\\"JobId\\\":\\\"43157b6bc2b0c73243e35eebf325a8322d06fa94b4940021fdf8f4b966a91ba4\\\",\\\"Status\\\":\\\"SUCCEEDED\\\",\\\"API\\\":\\\"StartPersonTracking\\\",\\\"Timestamp\\\":1571136869013,\\\"Video\\\":{\\\"S3ObjectName\\\":\\\"15fps-surveillance-video.mp4\\\",\\\"S3Bucket\\\":\\\"blobbucket-us-east-1\\\"}}\",\n  \"Timestamp\" : \"2019-10-15T10:54:29.129Z\",\n  \"SignatureVersion\" : \"1\",\n  \"Signature\" : \"MaqlmOR7UqZIsaox2BFOLX9XM0YN1nStp+srQP4DB9iSJmOyHJQkwKVFopEVV4NkI55hTmthPnfA0xW3jSXL8lPIzcxGLBIJTI5YM+/Kx7/pusGFRTb0Gv08U02V4gQ0AvW+g/LQaDpRw87a0txv5zwvyp/GDygwXF5u6kQa8GchGiozHJo7+wEwjbbXzlVnuXB7lgJQKG8nnW1VSRiO032K5OdLz9eGicP+YyrFfuHJemK9AJqI5HV7CJz5c8GG0kkv0nKHYa0InPZqWx2UsKyPLA8QRm5de8RDq6APw055Z0VyHyWwpU6SsL1boZHsiBXjs6Zu0S1XbmGIYXEbTQ==\",\n  \"SigningCertURL\" : \"https://sns.us-east-1.amazonaws.com/SimpleNotificationService-6aad65c2f9911b05cd53efda11f913f9.pem\",\n  \"UnsubscribeURL\" : \"https://sns.us-east-1.amazonaws.com/?Action=Unsubscribe&SubscriptionArn=arn:aws:sns:us-east-1:deadbeef7898:RekognitionVideo:af2afca1-b93b-44d2-b69b-79983ba1fa5b\"\n}"
           }
       ]
   }

   $ jq -r '.Messages[].Body' result-status.json
   {
     "Type" : "Notification",
     "MessageId" : "d7a7edf6-3d28-57e0-ae98-bbe99a8d37da",
     "TopicArn" : "arn:aws:sns:us-east-1:deadbeef7898:RekognitionVideo",
     "Message" : "{\"JobId\":\"43157b6bc2b0c73243e35eebf325a8322d06fa94b4940021fdf8f4b966a91ba4\",\"Status\":\"SUCCEEDED\",\"API\":\"StartPersonTracking\",\"Timestamp\":1571136869013,\"Video\":{\"S3ObjectName\":\"15fps-surveillance-video.mp4\",\"S3Bucket\":\"blobbucket-us-east-1\"}}",
     "Timestamp" : "2019-10-15T10:54:29.129Z",
     "SignatureVersion" : "1",
     "Signature" : "MaqlmOR7UqZIsaox2BFOLX9XM0YN1nStp+srQP4DB9iSJmOyHJQkwKVFopEVV4NkI55hTmthPnfA0xW3jSXL8lPIzcxGLBIJTI5YM+/Kx7/pusGFRTb0Gv08U02V4gQ0AvW+g/LQaDpRw87a0txv5zwvyp/GDygwXF5u6kQa8GchGiozHJo7+wEwjbbXzlVnuXB7lgJQKG8nnW1VSRiO032K5OdLz9eGicP+YyrFfuHJemK9AJqI5HV7CJz5c8GG0kkv0nKHYa0InPZqWx2UsKyPLA8QRm5de8RDq6APw055Z0VyHyWwpU6SsL1boZHsiBXjs6Zu0S1XbmGIYXEbTQ==",
     "SigningCertURL" : "https://sns.us-east-1.amazonaws.com/SimpleNotificationService-6aad65c2f9911b05cd53efda11f913f9.pem",
     "UnsubscribeURL" : "https://sns.us-east-1.amazonaws.com/?Action=Unsubscribe&SubscriptionArn=arn:aws:sns:us-east-1:deadbeef7898:RekognitionVideo:af2afca1-b93b-44d2-b69b-79983ba1fa5b"
   }

   $ jq -r '.Messages[0].Body' result-status.json|jq -r '.Message'|jq '.'
   {
     "JobId": "43157b6bc2b0c73243e35eebf325a8322d06fa94b4940021fdf8f4b966a91ba4",
     "Status": "SUCCEEDED",
     "API": "StartPersonTracking",
     "Timestamp": 1571136869013,
     "Video": {
       "S3ObjectName": "15fps-surveillance-video.mp4",
       "S3Bucket": "blobbucket-us-east-1"
     }
   }
   ```

1. Get the video analysis results with `aws rekognition get-label-detection`
   ```
   $ aws rekognition get-person-tracking --job-id "43157b6bc2b0c73243e35eebf325a8322d06fa94b4940021fdf8f4b966a91ba4" --region us-east-1 >result-person-tracking.json
   ```
   * Review the analsysis metadata information about the video file
      ```
      $ jq -r '.JobStatus,.VideoMetadata' result-person-tracking.json
      SUCCEEDED
      {
        "Codec": "h264",
        "DurationMillis": 21656,
        "Format": "QuickTime / MOV",
        "FrameRate": 29.9689998626709,
        "FrameHeight": 240,
        "FrameWidth": 320
      }
      ```
   * Review the analsysis information about the video file
      ```
      $ jq -r '.Persons[]|"\(.Timestamp) \(.Person)"' result-person-tracking.json                                                                    
      1301 {"Index":0,"BoundingBox":{"Width":0.078125,"Height":0.22499999403953552,"Left":0.9125000238418579,"Top":0.30000001192092896}}
      1368 {"Index":0,"BoundingBox":{"Width":0.078125,"Height":0.22083333134651184,"Left":0.9125000238418579,"Top":0.30416667461395264}}
      1434 {"Index":0,"BoundingBox":{"Width":0.078125,"Height":0.22083333134651184,"Left":0.9125000238418579,"Top":0.30416667461395264}}
      1501 {"Index":0,"BoundingBox":{"Width":0.078125,"Height":0.22083333134651184,"Left":0.9125000238418579,"Top":0.30416667461395264}}
      <...removed...>
      11511 {"Index":0,"BoundingBox":{"Width":0.08124999701976776,"Height":0.22499999403953552,"Left":0.831250011920929,"Top":0.2916666567325592}}
      11578 {"Index":0,"BoundingBox":{"Width":0.09687499701976776,"Height":0.23333333432674408,"Left":0.887499988079071,"Top":0.30416667461395264}}
      11645 {"Index":0,"BoundingBox":{"Width":0.09687499701976776,"Height":0.23333333432674408,"Left":0.887499988079071,"Top":0.30416667461395264}}
      11712 {"Index":0,"BoundingBox":{"Width":0.09687499701976776,"Height":0.23333333432674408,"Left":0.887499988079071,"Top":0.30416667461395264}}
      11778 {"Index":0,"BoundingBox":{"Width":0.09687499701976776,"Height":0.2291666716337204,"Left":0.887499988079071,"Top":0.3083333373069763}}
      ```

