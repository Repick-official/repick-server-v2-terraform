import os
import json
import requests
import google.auth.transport.requests

from google.oauth2 import service_account


server_key = os.environ['FCM_SERVER_KEY']
PROJECT_ID = os.environ['PROJECT_ID']
SCOPES = ['https://www.googleapis.com/auth/firebase.messaging']
FCM_URL = 'https://fcm.googleapis.com/v1/projects/' + PROJECT_ID +  '/messages:send'


def _get_access_token():
    """Retrieve a valid access token that can be used to authorize requests.

    :return: Access token.
    """
    credentials = service_account.Credentials.from_service_account_file(
        'repick-bb0d5-firebase-adminsdk-fdkh5-3050fe780b.json', scopes=SCOPES)
    request = google.auth.transport.requests.Request()
    credentials.refresh(request)
    return credentials.token


headers = {
    'Authorization': 'Bearer ' + _get_access_token(),
    'Content-Type': 'application/json; UTF-8',
}


def lambda_handler(event, context):
    fcm_token = event['fcmToken']
    title = event['title']
    body = event['body']

    payload = json.dumps(
        {
            "message": {
                "token": fcm_token,
                'notification': {
                    'title': title,
                    'body': body
                }
            }
        })

    resp = requests.post(FCM_URL, data=payload, headers=headers)

    if resp.status_code == 200:
        print('Message sent to Firebase for delivery, response:')
        print(resp.text)
    else:
        print('Unable to send message to Firebase')
        print(resp.text)