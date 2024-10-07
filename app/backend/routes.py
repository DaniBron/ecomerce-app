from flask import Blueprint, render_template, redirect, request, url_for, flash, render_template
from flask_login import current_user, login_user, logout_user, login_required
from .models import Order, Product, User, db
from .forms import RegistrationForm, LoginForm
from werkzeug.security import generate_password_hash, check_password_hash  # Ensure this line is included
import boto3
import json
from flask import current_app
from elasticsearch import Elasticsearch

main_bp = Blueprint('main', __name__)

@main_bp.route('/')
@login_required
def home():
    return render_template('index.html')

auth_bp = Blueprint('auth', __name__)

@auth_bp.route('/register', methods=['GET', 'POST'])
def register():
    form = RegistrationForm()
    if form.validate_on_submit():
        hashed_password = generate_password_hash(form.password.data, method='pbkdf2:sha256')
        new_user = User(username=form.username.data, email=form.email.data, password=hashed_password)
        db.session.add(new_user)
        db.session.commit()
        return redirect(url_for('auth.login'))
    return render_template('register.html', form=form)

@auth_bp.route('/login', methods=['GET', 'POST'])
def login():
    form = LoginForm()
    if form.validate_on_submit():
        user = User.query.filter_by(email=form.email.data).first()
        if user and check_password_hash(user.password, form.password.data):
            login_user(user)
            return redirect(url_for('main.home'))  # Redirect to home on successful login
        flash('Invalid credentials')
    return render_template('login.html', form=form)

@auth_bp.route('/logout')
@login_required
def logout():
    logout_user()
    return redirect(url_for('auth.login'))



@main_bp.route('/products')
def list_products():
    products = Product.query.all()
    return render_template('products.html', products=products)

@main_bp.route('/products/new', methods=['POST'])
@login_required
def add_product():
    product = Product(
        name=request.form['name'],
        description=request.form['description'],
        price=float(request.form['price']),
        stock=int(request.form['stock'])
    )

    db.session.add(product)
    db.session.commit()

    # Index the product in Elasticsearch
    add_product_to_index('products', product)

    flash('Product added successfully!')
    return redirect(url_for('main.list_products'))

@main_bp.route('/products/new', methods=['GET'])
@login_required
def new_product_form():
    return render_template('add_product.html')



def send_order_to_kinesis(order_data):
    kinesis_client = boto3.client(
        'kinesis',
        aws_access_key_id=current_app.config['AWS_ACCESS_KEY_ID'],
        aws_secret_access_key=current_app.config['AWS_SECRET_ACCESS_KEY'],
        region_name=current_app.config['AWS_REGION_NAME']
    )

    response = kinesis_client.put_record(
        StreamName=current_app.config['KINESIS_STREAM_NAME'],
        Data=json.dumps(order_data),
        PartitionKey=str(order_data['user_id'])
    )
    # Add logging to confirm the record was sent
    print(f"Order sent to Kinesis: {order_data}")
    print(f"Kinesis response: {response}")


@main_bp.route('/order', methods=['POST'])
@login_required
def place_order():
    user_id = current_user.id
    product_id = request.form['product_id']
    quantity = int(request.form['quantity'])

    product = Product.query.get(product_id)
    if not product or product.stock < quantity:
        flash('Product is out of stock or invalid quantity')
        return redirect(url_for('main.list_products'))

    total_price = product.price * quantity
    new_order = Order(user_id=user_id, product_id=product_id, quantity=quantity, total_price=total_price)

    # Update product stock
    product.stock -= quantity

    # Add the order to the database
    db.session.add(new_order)
    db.session.commit()

    # Send order data to Kinesis
    order_data = {
        'user_id': user_id,
        'product_id': product_id,
        'quantity': quantity,
        'total_price': total_price,
        'timestamp': str(new_order.timestamp)
    }
    send_order_to_kinesis(order_data)

    flash('Order placed successfully!')
    return redirect(url_for('main.list_products'))


@main_bp.route('/orders')
@login_required
def view_orders():
    # Fetch orders placed by the current logged-in user
    orders = Order.query.filter_by(user_id=current_user.id).all()
    return render_template('orders.html', orders=orders)


@main_bp.route('/order/update_status/<int:order_id>', methods=['POST'])
@login_required
def update_order_status(order_id):
    order = Order.query.get_or_404(order_id)
    if request.form.get('status'):
        order.status = request.form['status']
        db.session.commit()
        flash('Order status updated!')
    return redirect(url_for('main.view_orders'))


# In elastic_search.py
def add_product_to_index(index, product):
    # Add the product to Elasticsearch index
    # Ensure that you convert the product object to a suitable format (like a dictionary) if needed
    es = Elasticsearch(current_app.config['ELASTICSEARCH_URL'])
    
    doc = {
        'name': product.name,
        'description': product.description,
        'price': product.price,
        'stock': product.stock
    }
    es.index(index=index, body=doc, id=product.id)


def update_product_in_index(product):
    es = Elasticsearch(current_app.config['ELASTICSEARCH_URL'])

    # Define the updated document
    doc = {
        'name': product.name,
        'description': product.description,
        'price': product.price,
        'stock': product.stock
    }

    # Update the product in the index
    es.update(index='products', id=product.id, body={"doc": doc})

def remove_product_from_index(product_id):
    es = Elasticsearch(current_app.config['ELASTICSEARCH_URL'])
    
    # Delete the product from the index
    es.delete(index='products', id=product_id)

# @main_bp.route('/products/new', methods=['POST'])
# @login_required
# def add_product():
#     product = Product(
#         name=request.form['name'],
#         description=request.form['description'],
#         price=float(request.form['price']),
#         stock=int(request.form['stock'])
#     )

#     db.session.add(product)
#     db.session.commit()

#     # Index the product in Elasticsearch
#     add_product_to_index(product)

#     flash('Product added successfully!')
#     return redirect(url_for('main.list_products'))

@main_bp.route('/search', methods=['GET'])
def search():
    query = request.args.get('q', '')
    es = Elasticsearch(current_app.config['ELASTICSEARCH_URL'])

    # Perform a search query in Elasticsearch
    body = {
        "query": {
            "multi_match": {
                "query": query,
                "fields": ["name", "description"]
            }
        }
    }

    res = es.search(index='products', body=body)
    results = res['hits']['hits']

    # Extract product details from search results
    products = [{
        'name': hit['_source']['name'],
        'description': hit['_source']['description'],
        'price': hit['_source']['price'],
        'stock': hit['_source']['stock']
    } for hit in results]

    return render_template('search_results.html', products=products, query=query)


def create_products_index():
    es = Elasticsearch(current_app.config['ELASTICSEARCH_URL'])
    
    # Check if the index already exists
    if not es.indices.exists(index="products"):
        # Define the index settings and mappings
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
        # Create the index
        es.indices.create(index="products", body=body)