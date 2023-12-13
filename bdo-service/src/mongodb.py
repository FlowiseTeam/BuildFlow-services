import os
from pymongo import MongoClient


connection_string = os.getenv('MONGODB_URL')


def get_database():
    client = MongoClient("mongodb+srv://flowise_admin:Drq9NeJCjuAkqCUy@buildflow.fic9xoa.mongodb.net/BuildFlowTest?retryWrites=true&w=majority")
    return client["BuildFlowTest"]
