from flask import Flask
from flask_restful import Api
from .clients_endpoints import AgaveClients

app = Flask(__name__)
app.config["JSONIFY_PRETTYPRINT_REGULAR"] = True
api = Api(app)


api.add_resource(AgaveClients, "/clients/v2/")

if __name__ == "__main__":
    app.run(host="0.0.0.0", ssl_context="adhoc")
