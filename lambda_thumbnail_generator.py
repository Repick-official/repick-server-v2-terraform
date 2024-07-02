import boto3
import os
from urllib.parse import unquote_plus
from PIL import Image
import io

s3_client = boto3.client('s3')

def lambda_handler(event, context):

    bucket_name = event['Records'][0]['s3']['bucket']['name']
    key = unquote_plus(event['Records'][0]['s3']['object']['key'])

    file_extension = key.lower().split('.')[-1]

    if file_extension in ['jpg', 'jpeg', 'png']:
        response = s3_client.get_object(Bucket=bucket_name, Key=key)
        image = Image.open(response['Body'])

        image.thumbnail((512, 512))

        buffer = io.BytesIO()
        image_format = 'JPEG' if file_extension in ['jpg', 'jpeg'] else 'PNG'
        image.save(buffer, format=image_format)
        buffer.seek(0)

        thumbnail_key = key.replace("thumbnail", "thumbnail_generated")
        s3_client.put_object(Bucket=bucket_name, Key=thumbnail_key, Body=buffer, ContentType=f'image/{image_format.lower()}')
        print(f"Thumbnail created and uploaded to {bucket_name}/{thumbnail_key}")
    else:
        print(f"File format not supported: {file_extension}")