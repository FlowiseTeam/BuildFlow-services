import os
import requests


bdo_base_url = os.getenv('BDO_BASE_URL')


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

