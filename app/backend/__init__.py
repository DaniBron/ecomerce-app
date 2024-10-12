from flask import Flask
from .extensions import db, login_manager  # Import from extensions.py
from .models import User  # Ensure models are loaded after db initialization

def check_user_table_exists():
    inspector = db.inspect(db.engine)  # Use SQLAlchemy inspector
    if 'user' in inspector.get_table_names():
        print("User table exists.")
        return True
    else:
        print("User table does not exist.")
        return False

def create_app():
    app = Flask(__name__)
    app.config.from_object('config.Config')

    db.init_app(app)

    with app.app_context():
        if not check_user_table_exists():  
            db.create_all()  
        else:
            print("No need to create the table.")

    login_manager.init_app(app)
    login_manager.login_view = 'auth.login'

    # Import blueprints and the create_products_index function
    from .routes import main_bp, auth_bp, create_products_index
    app.register_blueprint(main_bp)
    app.register_blueprint(auth_bp)

    # Create Elasticsearch index for products
    with app.app_context():
        create_products_index()

    @login_manager.user_loader
    def load_user(user_id):
        return User.query.get(int(user_id))

    return app
