import os
import requests

from src.keo.schemas import CreateRecord


bdo_base_url = os.getenv('BDO_BASE_URL')


def fetch_token(client_id: str, client_secret: str, eup_id: str) -> tuple:
    url = f"{bdo_base_url}/api/WasteRegister/v1/Auth/generateEupAccessToken"
    headers = {
        'accept': 'application/json',
        'Content-Type': 'application/json'
    }
    data = {
        'ClientId': client_id,
        'ClientSecret': client_secret,
        'EupId': eup_id
    }
    response = requests.post(url, headers=headers, json=data)
    response.raise_for_status()

    token_data = response.json()
    return token_data["AccessToken"], token_data["ExpiresIn"]


def get_keo_card_info(access_token: str, keo_id: str) -> dict:
    url = f"{bdo_base_url}/api/WasteRegister/WasteRecordCard/v1/Keo/card"
    headers = {
        'accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': f'Bearer {access_token}'
    }

    response = requests.get(url, headers=headers, params=keo_id)
    response.raise_for_status()
    return response.json()


def create_generated_record(access_token: str, data: CreateRecord) -> dict:
    url = f"{bdo_base_url}/api/WasteRegister/WasteRecordCard/v1/Keo/KeoGenerated/create"
    headers = {
        'accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': f'Bearer {access_token}'
    }

    response = requests.post(url, headers=headers, json=data.model_dump())
    response.raise_for_status()
    return response.json()


def delete_generated_record(access_token: str, keo_generated_id: str):
    url = f"{bdo_base_url}/api/WasteRegister/WasteRecordCard/v1/Keo/KeoGenerated/delete"
    headers = {
        'accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': f'Bearer {access_token}'
    }
    data = {
        'KeoGeneratedId': keo_generated_id
    }
    response = requests.delete(url, headers=headers, json=data)
    response.raise_for_status()
    return response.json()
