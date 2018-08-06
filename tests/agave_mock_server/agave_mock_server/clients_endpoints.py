"""
    clients_endpoints.py

CLI integration tests for "clients-*" cli commands.
"""
import json
from flask import jsonify, request
from flask_restful import Resource


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
