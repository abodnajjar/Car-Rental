import mysql.connector
from mysql.connector import Error

def get_connection():
    return mysql.connector.connect(
        host="127.0.0.1",
        port=3306,
        user="root",
        password="root1234",
        database="car_rental",
    )
