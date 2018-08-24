"""
    tenants_endpoints.py

CLI integration tests for "tenants-*" cli commands.
"""
from flask import jsonify, request
from flask_restful import Resource
from .response_templates import response_template_to_json


# Sample response for "apps-list" cli command.
tenants_list_response = response_template_to_json("tenants-list.json")


class AgaveTenants(Resource):
    """ Test tenants-* cli commands
    """

    def get(self):
        """ Test tenants-list utility

        This test emulates the Agave API endpoint "/tenants/" for GET
        requests. To test it:

        curl -sk 'https://localhost:5000/tenants?pretty=True'
        """
        pretty_print = request.args.get("pretty", "")
        return jsonify(tenants_list_response)
