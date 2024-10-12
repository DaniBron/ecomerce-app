from opensearchpy import OpenSearch, RequestsHttpConnection, AWSV4SignerAuth
import boto3
from flask import current_app

def get_opensearch_client():
    host = current_app.config['ELASTICSEARCH_URL']
    region = current_app.config['AWS_REGION_NAME']
    
    # Use the admin username and password from config
    admin_username = current_app.config['ELASTICSEARCH_USERNAME']
    admin_password = current_app.config['ELASTICSEARCH_PASSWORD']

    try:
        # Use opensearch-py client with basic authentication
        es = OpenSearch(
            hosts=[{'host': host, 'port': 443}],
            http_auth=(admin_username, admin_password),  # Use admin credentials for basic auth
            use_ssl=True,
            verify_certs=True,
            ssl_assert_hostname=False,
            ssl_show_warn=False,
            connection_class=RequestsHttpConnection,
        )

        # Test connection
        es.ping()
        print("Successfully connected to OpenSearch")

    except Exception as e:
        print(f"Error connecting to OpenSearch: {e}")
        return None

    return es



def add_product_to_index(index, product):
    client = get_opensearch_client()

    doc = {
        'name': product.name,
        'description': product.description,
        'price': product.price,
        'stock': product.stock
    }
    client.index(index=index, body=doc, id=product.id)

def update_product_in_index(product):
    client = get_opensearch_client()

    doc = {
        'name': product.name,
        'description': product.description,
        'price': product.price,
        'stock': product.stock
    }
    client.update(index='products', id=product.id, body={"doc": doc})

def remove_product_from_index(product_id):
    client = get_opensearch_client()
    client.delete(index='products', id=product_id)

def create_products_index():
    client = get_opensearch_client()

    if not client.indices.exists(index="products"):
        body = {
            "mappings": {
                "properties": {
                    "name": {"type": "text"},
                    "description": {"type": "text"},
                    "price": {"type": "float"},
                    "stock": {"type": "integer"}
                }
            }
        }
        client.indices.create(index="products", body=body)
