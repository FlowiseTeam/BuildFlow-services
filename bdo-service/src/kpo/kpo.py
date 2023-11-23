import requests

from schemas import CardCreate


bdo_base_url = 'https://bdo.mos.gov.pl'




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


def create_planned_card(access_token: str, data: CardCreate) -> dict:
    url = f"{bdo_base_url}/api/WasteRegister/WasteTransferCard/v1/Kpo/create/plannedcard"
    headers = {
        'accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': f'Bearer {access_token}'
    }
    response = requests.post(url, headers=headers, json=data)
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
    response = requests.delete(url, headers=headers, json=data)
    response.raise_for_status()
    return response.json()
