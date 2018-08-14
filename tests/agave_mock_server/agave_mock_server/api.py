from flask import Flask
from flask_restful import Api
from .apps_endpoints import AgaveApps
from .clients_endpoints import AgaveClients
from .postits_endpoints import AgavePostits

app = Flask(__name__)
app.config["JSONIFY_PRETTYPRINT_REGULAR"] = True
api = Api(app)

api.add_resource(AgaveApps, "/apps/v2")
api.add_resource(AgaveClients, "/clients/v2/",
                 "/clients/v2/<string:client_name>")
api.add_resource(AgavePostits, "/postits/v2/")

if __name__ == "__main__":
    app.run(host="0.0.0.0", ssl_context="adhoc")
