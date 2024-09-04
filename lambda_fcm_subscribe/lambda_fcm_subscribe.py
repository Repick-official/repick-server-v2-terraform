import os
import json
from firebase_admin import credentials, initialize_app, messaging

cred = credentials.Certificate('./service_account.json')
default_app = initialize_app(cred)

def lambda_handler(event, context):
    print(event)
    # DynamoDB 스트림의 이벤트 레코드에서 fcmToken을 추출
    for record in event['Records']:
        old_image = record['dynamodb'].get('OldImage', None)
        new_image = record['dynamodb'].get('NewImage', None)

        if record['eventName'] == 'REMOVE' and old_image:  # 항목 삭제에만 반응
            fcm_token = old_image['fcmToken']['S']
            topic = 'all'

            # FCM 토큰에 대한 주제 구독 취소
            try:
                response = messaging.unsubscribe_from_topic([fcm_token], topic)
                print('Unsubscribe from topic response:', response)
            except Exception as e:
                print(e)
                return {
                    'statusCode': 500,
                    'body': json.dumps('Error unsubscribing from topic')
                }

        elif record['eventName'] == 'INSERT' and new_image:  # 새 항목 삽입에만 반응
            fcm_token = new_image['fcmToken']['S']
            topic = 'all'

            # FCM 토큰을 주제에 구독시키기
            try:
                response = messaging.subscribe_to_topic([fcm_token], topic)
                print('Subscribe to topic response:', response)
            except Exception as e:
                print(e)
                return {
                    'statusCode': 500,
                    'body': json.dumps('Error subscribing to topic')
                }

        elif record['eventName'] == 'MODIFY' and old_image and new_image:  # 항목 수정에 반응
            old_fcm_token = old_image['fcmToken']['S']
            new_fcm_token = new_image['fcmToken']['S']
            topic = 'all'

            # 기존 FCM 토큰에 대한 주제 구독 취소
            try:
                response = messaging.unsubscribe_from_topic([old_fcm_token], topic)
                print('Unsubscribe from topic response:', response)
            except Exception as e:
                print(e)

            # 새 FCM 토큰을 주제에 구독시키기
            try:
                response = messaging.subscribe_to_topic([new_fcm_token], topic)
                print('Subscribe to topic response:', response)
            except Exception as e:
                print(e)
                return {
                    'statusCode': 500,
                    'body': json.dumps('Error subscribing to new topic')
                }

    return {
        'statusCode': 200,
        'body': json.dumps('Successfully processed DynamoDB Stream event')
    }
