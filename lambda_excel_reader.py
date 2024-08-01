import boto3
import pandas as pd
import json
import io
import re
import urllib.request
import urllib.parse
import urllib.error
import mimetypes
import uuid
import os


def get_size_info(row, category):
    size_parts = row['size'].split('-')

    # Initialize size information with default values
    size_info = {
        "shoulder": 0,
        "chest": 0,
        "totalLength": 0,
        "arm": 0,
        "waist": 0,
        "hip": 0,
        "thigh": 0,
        "rise": 0
    }

    # Map the size parts based on category
    if category in ["CAR", "BLA", "WIN", "COA", "PAD", "FLE", "JIP", "MIL", "NON", "HAL", "LON", "MAN", "HOO", "NEA",
                    "SHI", "VES", "BLO"]:
        size_info["shoulder"] = size_parts[0]
        size_info["chest"] = size_parts[1]
        size_info["totalLength"] = size_parts[2]
        size_info["arm"] = size_parts[3]
    elif category in ["HAP", "LOP", "SLA", "DEN", "LEG", "JUM"]:
        size_info["totalLength"] = size_parts[0]
        size_info["waist"] = size_parts[1]
        size_info["hip"] = size_parts[2]
        size_info["thigh"] = size_parts[3]
        size_info["rise"] = size_parts[4]
    elif category in ["MNS", "MDS", "LOS"]:
        size_info["totalLength"] = size_parts[0]
        size_info["waist"] = size_parts[1]
        size_info["hip"] = size_parts[2]
    elif category in ["MNO", "LNO"]:
        size_info["shoulder"] = size_parts[0]
        size_info["chest"] = size_parts[1]
        size_info["totalLength"] = size_parts[2]
        size_info["arm"] = size_parts[3]
        size_info["waist"] = size_parts[4]
    else:
        # Default case: no size information
        pass

    return size_info


def lambda_handler(event, context):
    print(event)

    # Extract bucket name and object key from the event
    bucket_name = event['Records'][0]['s3']['bucket']['name']
    file_key = event['Records'][0]['s3']['object']['key']

    # S3 client
    s3 = boto3.client('s3')

    # Get the file from S3
    response = s3.get_object(Bucket=bucket_name, Key=file_key)

    # Read the Excel file content
    file_content = response['Body'].read()
    excel_data = pd.read_excel(io.BytesIO(file_content))

    # Iterate through each row in the Excel file
    for index, row in excel_data.iterrows():
        try:
            # Generate productCode
            product_code = f"{row['user_id']}-{row['clothing_sales_count']}-{row['product_number']}"

            # Define the S3 prefix for the images
            s3_prefix = f"images/{row['user_id']}/"

            # List objects in the specified S3 directory
            s3_objects = s3.list_objects_v2(Bucket='repick-admin-bucket', Prefix=s3_prefix)
            if 'Contents' not in s3_objects:
                print(f"No images found for user {row['user_id']} in {s3_prefix}")
                continue

            # Filter the image files based on the expected naming pattern
            image_pattern = re.compile(
                f"{row['user_id']}-{row['clothing_sales_count']}-{row['product_number']}-(\d+)\.\w+")
            image_keys = [obj['Key'] for obj in s3_objects['Contents'] if re.search(image_pattern, obj['Key'])]

            # Prepare the files payload for images
            boundary = str(uuid.uuid4())
            body = []

            for image_key in image_keys:
                # get the image file
                image_file = s3.get_object(Bucket='repick-admin-bucket', Key=image_key)
                image_data = image_file['Body'].read()

                # add image data to the body
                body.append('--' + boundary)
                body.append(f'Content-Disposition: form-data; name="images"; filename="{image_key}"')
                body.append('Content-Type: ' + mimetypes.guess_type(image_key)[0])
                body.append('')
                body.append(image_data)  # append bytes directly

            if pd.notnull(row['is_rejected']):
                # Process rejected products
                post_product = {
                    "userId": row['user_id'],
                    "clothingSalesCount": row['clothing_sales_count'],
                    "productCode": product_code,
                    "productName": row['product_name'],
                    "brandName": row['brand_name'],
                    "isRejected": "true"
                }

            else:
                # Process non-rejected products
                # Define the product data
                size_info = get_size_info(row, row['category'])

                post_product = {
                    "categories": [row['category']],
                    "styles": [row['style']],
                    "userId": row['user_id'],
                    "clothingSalesCount": row['clothing_sales_count'],
                    "productCode": product_code,
                    "isRejected": "false",
                    "productName": row['product_name'],
                    "suggestedPrice": row['suggested_price'],
                    "predictPrice": row['predict_price'],
                    "discountRate": 0,
                    "brandName": row['brand_name'],
                    "description": row['description'],
                    "sizeInfo": size_info,
                    "qualityRate": row['quality_rate'],
                    "gender": row['gender'],
                    "materials": row['materials'].split(',')
                }

            post_product_json = json.dumps(post_product, ensure_ascii=False)

            body.append('--' + boundary)
            body.append('Content-Disposition: form-data; name="postProduct"')
            body.append('Content-Type: application/json')
            body.append('')
            body.append(post_product_json)
            body.append('--' + boundary + '--')
            body.append('')

            # Ensure body parts are correctly formatted as bytes
            body_bytes = b'\r\n'.join([b if isinstance(b, bytes) else b.encode('utf-8') for b in body])

            headers = {
                'accept': '*/*',
                'Authorization': os.environ['TOKEN'],
                'Content-Type': f'multipart/form-data; boundary={boundary}'
            }

            req = urllib.request.Request('https://www.repick-server.shop/api/product', data=body_bytes, headers=headers)

            try:
                with urllib.request.urlopen(req) as response:
                    response_data = response.read().decode('utf-8')
                    print(f"Successfully registered product: {product_code}, Response: {response_data}")
            except urllib.error.HTTPError as e:
                print(f"Failed to register product: {product_code}, Response: {e.read().decode('utf-8')}")

        except Exception as e:
            print(f"Error processing row {index}: {str(e)}")

    return {
        'statusCode': 200,
        'body': json.dumps('Process completed.')
    }