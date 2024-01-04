import os
import time
import requests

BDO_BASE_URL = os.getenv('BDO_BASE_URL')
CLIENT_ID = os.getenv('CLIENT_ID')
CLIENT_SECRET = os.getenv('CLIENT_SECRET')
EUP_ID = os.getenv('EUP_ID')


def fetch_token() -> str:
    token_expires_at = 0
    access_token = ""

    if access_token and time.time() < token_expires_at:
        return access_token

    url = f"{BDO_BASE_URL}/api/WasteRegister/v1/Auth/generateEupAccessToken"
    headers = {
        'accept': 'application/json',
        'Content-Type': 'application/json'
    }
    data = {
        'ClientId': CLIENT_ID,
        'ClientSecret': CLIENT_SECRET,
        'EupId': EUP_ID
    }
    response = requests.post(url, headers=headers, json=data)
    response.raise_for_status()

    token_data = response.json()
    access_token = token_data["AccessToken"]
    # Subtract a buffer (e.g., 60 seconds) to refresh the token before it actually expires
    token_expires_at = time.time() + token_data["ExpiresIn"] - 60

    return access_token
