import os
import requests


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


def get_company_details(access_token: str, company_name: str):
    url = f'{bdo_base_url}/api/WasteRegister/v1/Search/searchcompany'
    headers = {
        'accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': f'Bearer {access_token}'
    }

    response = requests.get(url, headers=headers, params={'query': company_name})
    response.raise_for_status()

    return response.json()


def get_eup_ids(access_token: str, company_id: str):
    url = f'{bdo_base_url}/api/WasteRegister/v1/Search/searcheupsbycompanyid'
    headers = {
        'accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': f'Bearer {access_token}'
    }

    response = requests.get(url, headers=headers, params={'companyId': company_id})

    response.raise_for_status()
    transformed_response = [{item['name']: item['eup_id']} for item in response.json()]

    return transformed_response

