"""
    clients_endpoints.py

CLI integration tests for "clients-*" cli commands.
"""
import json
from flask import jsonify, request
from flask_restful import Resource
from .response_templates import response_template_to_json

# Sample response for "clients-create -N rm -D 'remove this client'" cli
# command.
# curl -sku "user:XXXXX" -X POST -d clientName=rm -d "tier=Unlimited" \
#        -d "description=remove this client" -d "callbackUrl=" \
#        'https://api.tenant.org/clients/v2/?pretty=true'
clients_create_response = response_template_to_json("clients-create.json") 

# Sample response for "clients-delete <client>" cli command.
# curl -sku "usr:xxxx" -X DELETE 'https://api.tenant.org/clients/v2/rm?pretty=true'
clients_delete_response = response_template_to_json("clients-delete.json")

# Sample response for "clients-list" cli command.
# curl -sku "usr:xxxx" 'https://api.tenant.org/clients/v2/?pretty=true'
clients_list_response = response_template_to_json("clients-list.json")


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
        auth = request.authorization
        url_root = request.url_root

        # Test basic HTTP authentication.
        if auth == None or auth.username == "" or auth.password == "":
            resp = jsonify({
                "error": "User authentication error",
                "status_code": 400
            })
            resp.status_code = 400
            return resp

        response = json.dumps(clients_list_response)
        response = response.replace("{USER}", auth.username)
        response = response.replace("{URL_ROOT}", url_root)
        return jsonify(json.loads(response))

    def post(self):
        """ Test clients-create command

        curl -ku "user:XXXXX" -X POST -d clientName=rm -d "tier=Unlimited" \
        -d "description=remove this client" -d "callbackUrl=" \
        'https://localhost:5000/clients/v2/?pretty=true'
        """
        # Test basic HTTP authentication.
        auth = request.authorization
        if auth == None or auth.username == "" or auth.password == "":
            resp = jsonify({
                "error": "User authentication error",
                "status_code": 400
            })
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

    def delete(self, client_name):
        """ Test clients-delete command
        
        curl -ku "usr:xxxx" -X DELETE https://localhost:5000/clients/v2/rm?pretty=true
        """
        # Test a valid client name.
        if client_name is None or client_name == "":
            resp = jsonify({"error": "Invalid client name", "status_code": 400})
            resp.status_code = 400
            return resp

        # Test basic HTTP authentication.
        auth = request.authorization
        if auth == None or auth.username == "" or auth.password == "":
            resp = jsonify({
                "error": "User authentication error",
                "status_code": 400
            })
            resp.status_code = 400
            return resp

        response = json.dumps(clients_delete_response)
        return jsonify(json.loads(response))
