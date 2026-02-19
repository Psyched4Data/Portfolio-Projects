# Creating an RESTful API using Python
## Project Overview
This project demonstrates the development of a RESTful API using Flask, Flask-RESTful, and SQLAlchemy.
The API supports full CRUD functionality for a User resource and connects to a SQLite database for persistent storage.
The application includes:
- Database modeling
- REST endpoint design
- JSON request parsing
- Response marshalling
- HTTP status codes
- Error handling

The project consists of two Python files:
- api.py → Main API application
- create-db.py → Database initialization script

## Step 1: Database Initialization (create-db.py)
```python
from api import app, db

with app.app_context():
    db.create_all()
```
### What I Did
- Created a separate script to initialize the database.
- Generated all database tables using SQLAlchemy.

### How I Did It
- Imported the Flask app and database instance.
- Used app.app_context() to provide the necessary application context.
- Called db.create_all() to create tables defined in the models.

### Why I Did It
- Flask requires an application context to interact with the database.
- Separating database creation into its own file keeps the main API file clean and production-ready.

## Step 2: Application & Database Configuration
```python
app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///database.db'
db = SQLAlchemy(app)
api = Api(app)
```
### What I Did
- Created a Flask application.
- Configured a SQLite database.
- Initialized Flask-RESTful.

### How I Did It
- Set the database URI to a local SQLite file.
- Passed the Flask app into SQLAlchemy and Api objects.

## Step 3: Defining the Database Model
```python
class UserModel(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(80), unique=True, nullable=False)
    email = db.Column(db.String(80), unique=True, nullable=False)
```
### What I Did
- Created a relational database model for users.
- Enforced uniqueness and required fields.

### How I Did It
- Used SQLAlchemy ORM to define columns and constraints.
- Set primary_key=True for the ID field.
- Applied unique=True and nullable=False to prevent duplicate or empty entries.

## Step 4: Requesting Parsing & Response Marshalling
```python
user_args = reqparse.RequestParser()
user_args.add_argument('name', type=str, required=True)
user_args.add_argument('email', type=str, required=True)
userFields = {
    'id': fields.Integer,
    'name': fields.String,
    'email': fields.String,
}
```
### What I Did
- Validated incoming JSON request data.
- Structured outgoing JSON responses.

### How I Did It
- Used reqparse to enforce required fields.
- Used marshal_with to control API response formatting.

### Why I Did It
- This prevents malformed input and ensures consistent API output structure — both critical in production APIs.

## Step 5: Implementing REST Endpoints
```python
class Users(Resource):
```
### Supported Methods
GET /api/users/
-Returns all users.

POST /api/users/
- Creates a new user
  - Parses JSON input
  - Inserts into database
  - Commits transaction
  - Returns updated list with 201 Created

### Individual User Resource
```python
class User(Resource):
```
### Supported Methods
GET /api/users/<id>
- Retrieves a specific user
- Returns 404 if not found

PATCH /api/users/<id>
- Updates name and email
- Commits changes
- Returns updated record

DELETE /api/users/<id>
- Deletes the user
- Returns 204 No Content

## Step 6: Error Handling
```python
if not user:
    abort(404, "User not found")
```
### What I Did
- Implemented defensive error handling for missing resources.

### How I Did It
- Checked query results.
- Used abort() to return appropriate HTTP status codes.

This ensures REST-compliant responses.

## Step 7: Root Health Check Endpoint
```python
@app.route("/")
def home():
    return "It works!"
```
### What I Did
- Created a simple root endpoint for testing server status.

### How I Did It
- Defined a standard Flask route separate from API resources.

This is useful for verifying server deployment.

## Project Outcome
By the end of this project, I developed a fully functional RESTful API capable of:
- Creating users
- Retrieving all users
- Retrieving individual users
- Updating users
- Deleting users
- Persisting data in a relational database
