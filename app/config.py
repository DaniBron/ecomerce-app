import os
from dotenv import load_dotenv

# Load environment variables from the .env file
basedir = os.path.abspath(os.path.dirname(__file__))
load_dotenv(os.path.join(basedir, '.env'))

class Config:
    SECRET_KEY = os.environ.get('SECRET_KEY') or 'you-will-never-guess'
    SQLALCHEMY_DATABASE_URI = os.environ.get('SQLALCHEMY_DATABASE_URI')
    SQLALCHEMY_TRACK_MODIFICATIONS = False

    # AWS Kinesis configuration
    AWS_ACCESS_KEY_ID = os.environ.get('AWS_ACCESS_KEY_ID')
    AWS_SECRET_ACCESS_KEY = os.environ.get('AWS_SECRET_ACCESS_KEY')
    KINESIS_STREAM_NAME = os.environ.get('KINESIS_STREAM_NAME')
    AWS_REGION_NAME = os.environ.get('AWS_REGION_NAME')

    # OpenSearch configuration
    ELASTICSEARCH_URL = os.environ.get('ELASTICSEARCH_URL')
    ELASTICSEARCH_USERNAME = os.environ.get('ELASTICSEARCH_USERNAME')
    ELASTICSEARCH_PASSWORD = os.environ.get('ELASTICSEARCH_PASSWORD')
