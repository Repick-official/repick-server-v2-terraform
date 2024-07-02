import json
import boto3
import os

s3_client = boto3.client('s3')

def lambda_handler(event, context):
    bucket_name = os.environ['BUCKET_NAME']
    object_name = event['queryStringParameters']['object_name']
    operation = event['queryStringParameters']['operation']
    expiration = 3600

    try:
        if operation == 'upload':
            response = s3_client.generate_presigned_url('put_object',
                                                        Params={'Bucket': bucket_name, 'Key': object_name},
                                                        ExpiresIn=expiration)
        elif operation == 'download':
            response = s3_client.generate_presigned_url('get_object',
                                                        Params={'Bucket': bucket_name, 'Key': object_name},
                                                        ExpiresIn=expiration)
        else:
            return {
                'statusCode': 400,
                'body': json.dumps('Invalid operation. Use "upload" or "download".')
            }

        return {
            'statusCode': 200,
            'body': json.dumps({'presigned_url': response})
        }

    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps(str(e))
        }