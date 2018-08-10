"""
    clients_endpoints.py

CLI integration tests for "clients-*" cli commands.
"""
import json
from flask import jsonify, request
from flask_restful import Resource


# Sample response for "cients-create -N rm -D 'remove this client'" cli
# command.
# curl -sku "user:XXXXX" -X POST -d clientName=rm -d "tier=Unlimited" \
#        -d "description=remove this client" -d "callbackUrl=" \
#        'https://api.tenant.org/clients/v2/?pretty=true'
clients_create_response = {
  "status": "success",
  "message": "Client created successfully.",
  "version": "2.0.0-SNAPSHOT-rc3fad",
  "result": {
    "description": "{DESCRIPTION}",
    "name": "{NAME}",
    "consumerKey": "xxxxxxxxxxxxxxxxxxxxxxxxxx",
    "_links": {
      "subscriber": {
        "href": "{URL_ROOT}profiles/v2/{USER}"
      },
      "self": {
        "href": "{URL_ROOT}clients/v2/{NAME}"
      },
      "subscriptions": {
        "href": "{URL_ROOT}clients/v2/{NAME}/subscriptions/"
      }
    },
    "tier": "{TIER}",
    "consumerSecret": "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
    "callbackUrl": "{CALLBACK_URL}"
  }
}


# Sample response for "clients-list" cli command.
clients_list_response = {
    "status":
    "success",
    "message":
    "Clients retrieved successfully.",
    "version":
    "2.0.0-SNAPSHOT-rc3fad",
    "result": [{
        "description": "Sample description for Oauth client",
        "name": "agave-cli",
        "consumerKey": "xxxxxxxxxxxxxxxxxxxxxxxx",
        "_links": {
            "subscriber": {
                "href": "{URL_ROOT}profiles/v2/{USER}"
            },
            "self": {
                "href": "{URL_ROOT}clients/v2/agave-cli"
            },
            "subscriptions": {
                "href":
                "{URL_ROOT}clients/v2/agave-cli/subscriptions/"
            }
        },
        "tier": "Unlimited",
        "callbackUrl": ""
    }, {
        "description": "test container",
        "name": "container",
        "consumerKey": "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
        "_links": {
            "subscriber": {
                "href": "{URL_ROOT}profiles/v2/{USER}"
            },
            "self": {
                "href": "{URL_ROOT}clients/v2/container"
            },
            "subscriptions": {
                "href":
                "{URL_ROOT}clients/v2/container/subscriptions/"
            }
        },
        "tier": "Unlimited",
        "callbackUrl": ""
    }, {
        "description": "testing agavecli",
        "name": "testclient",
        "consumerKey": "xxxxxxxxxxxxxxxxxxxxxxxxxx",
        "_links": {
            "subscriber": {
                "href": "{URL_ROOT}profiles/v2/{USER}"
            },
            "self": {
                "href": "{URL_ROOT}clients/v2/testclient"
            },
            "subscriptions": {
                "href":
                "{URL_ROOT}clients/v2/testclient/subscriptions/"
            }
        },
        "tier": "Unlimited",
        "callbackUrl": ""
    }]
}


class AgaveClients(Resource):
    """ Test clients-* cli commands
    """

    def get(self):
        """ Test clients-list utility

        This test emulates the Agave API endpoint "/clients/v2/" for GET 
        requests. To test it:

        curl -sku "username:xxxx" 'https://localhost:5000/clients/v2/?pretty=true'
        """
        pretty_print = request.args.get("pretty", "")
        auth         = request.authorization
        url_root     = request.url_root
    
        if auth == None or auth.username == "" or auth.password == "":
            resp = jsonify({"error": "User authentication error", "status_code": 400})
            resp.status_code = 400
            return resp

        response = json.dumps(clients_list_response)
        response = response.replace("{USER}", auth.username)
        response = response.replace("{URL_ROOT}", url_root)
        return jsonify(json.loads(response))

    def post(self):
        """ Test clients-create command

        curl -sku "user:XXXXX" -X POST -d clientName=rm -d "tier=Unlimited" \
        -d "description=remove this client" -d "callbackUrl=" \
        'https://localhost:5000/clients/v2/?pretty=true'
        """
        # test basic HTTP authentication.
        auth = request.authorization
        if auth == None or auth.username == "" or auth.password == "":
            resp = jsonify({"error": "User authentication error", "status_code": 400})
            resp.status_code = 400
            return resp

        # Test form data.
        client_name = request.form.get("clientName", None)
        client_description = request.form.get("description", None)
        client_tier = request.form.get("tier", None)
        client_callbackurl = request.form.get("callbackUrl", None)
        if (client_name is None or client_description is None or 
                client_tier is None or client_callbackurl is None):
            resp = jsonify({"error": "Error on form data", "status_code": 400})
            resp.status_code = 400
            return resp

        response = json.dumps(clients_create_response)
        response = response.replace("{USER}", auth.username)
        response = response.replace("{URL_ROOT}", request.url_root)
        response = response.replace("{NAME}", client_name)
        response = response.replace("{DESCRIPTION}", client_description)
        response = response.replace("{TIER}", client_tier)
        response = response.replace("{CALLBACK_URL}", client_callbackurl)
        return jsonify(json.loads(response))
