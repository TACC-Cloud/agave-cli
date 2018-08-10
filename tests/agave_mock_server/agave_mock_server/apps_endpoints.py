"""
    apps_endpoints.py

CLI integration tests for "apps-*" cli commands.
"""
import json
import os
from flask import jsonify, request
from flask_restful import Resource


# Sample response for "apps-list" cli command.
response = "/agave-cli/tests/agave_mock_server/agave_mock_server/responses/apps-list.response"
with open(response, 'r') as infile:
    apps_list_response = json.load(infile)


class AgaveApps(Resource):
    """ Test apps-* cli commands
    """

    def get(self):
        """ Test apps-list utility

        This test emulates the Agave API endpoint "/apps/v2/" for GET
        requests. To test it:

        curl -sk -H "Authorization: Bearer xxx" 'https://localhost:5000/apps/v2/?pretty=True'
        """
        pretty_print = request.args.get("pretty", "")
        return jsonify(apps_list_response)
