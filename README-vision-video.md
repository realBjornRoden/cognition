# Cognitive Artificial Intelligence - Vision Video


* [Amazon (AWS)](https://aws.amazon.com/machine-learning/)
* [Google (GCP)](https://cloud.google.com/products/ai/)
* [Microsoft (Azure)](https://azure.microsoft.com/services/cognitive-services/)

***

## Use Cases
1. Detect Faces
1. Detect People
1. Detect Labels

***

## AWS (Amazon Web Services)

* [Amazon Rekognition](https://docs.aws.amazon.com/en_pv/rekognition/latest/dg/what-is.html)
   * Prerequisites are to have a valid and activated AWS account and permissions to use "Rekognition" cognitive services
   * <i>Amazon Rekognition operations can analyze videos in MPEG-4 and MOV formats encoded using H.264 codec, that are stored in Amazon S3 buckets</i>
   * "<i>The maximum file size for a stored video is 8GB</i> (2019)"
* Process
<br><img src="https://docs.aws.amazon.com/en_pv/rekognition/latest/dg/images/VideoRekognition.png" /><br>
   * <i>You start detecting labels in a video by calling start-label-detection. When Amazon Rekognition finishes analyzing the video, the completion status is sent to the <strong>Amazon SNS topic</strong> that's specified in the --notification-channel parameter of start-label-detection. You can get the completion status by subscribing an <strong>Amazon Simple Queue Service (Amazon SQS) queue</strong> to the Amazon SNS topic. You then poll receive-message to get the completion status from the Amazon SQS queue.</i>

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

### XXXXX
* [video-cli-commands](https://docs.aws.amazon.com/en_pv/rekognition/latest/dg/video-cli-commands.html)
***

