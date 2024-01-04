import os
import requests

from src.kpo.schemas import BdoCardCreate


bdo_base_url = os.getenv('BDO_BASE_URL')


def get_planned_card(access_token:str, card_id: str):
    url = f"{bdo_base_url}/api/WasteRegister/WasteTransferCard/v1/Kpo/planned/card"
    headers = {
        'accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': f'Bearer {access_token}'
    }
    response = requests.get(url, headers=headers, params=card_id)
    response.raise_for_status()
    return response.json()


def create_planned_card(access_token: str, data: BdoCardCreate) -> dict:
    url = f"{bdo_base_url}/api/WasteRegister/WasteTransferCard/v1/Kpo/create/plannedcard"
    headers = {
        'accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': f'Bearer {access_token}'
    }

    response = requests.post(url, headers=headers, json=data.model_dump())
    response.raise_for_status()

    return response.json()


def delete_planned_card(access_token: str, kpo_id: str):
    url = f"{bdo_base_url}/api/WasteRegister/WasteTransferCard/v1/Kpo/delete"
    headers = {
        'accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': f'Bearer {access_token}'
    }
    data = {
        'KpoId': kpo_id
    }
    requests.delete(url, headers=headers, json=data)

