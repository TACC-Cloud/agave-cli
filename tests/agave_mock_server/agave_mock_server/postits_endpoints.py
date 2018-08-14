"""
    postits_endpoints.py

CLI integration tests for "postits-*" cli commands.
"""
import json
from flask import jsonify, request
from flask_restful import Resource


# Sample response for "postits-list" cli command.
response = "/agave-cli/tests/agave_mock_server/agave_mock_server/responses/postits-list.response"
with open(response, 'r') as infile:
    postits_list_response = json.load(infile)



class AgavePostits(Resource):
    """ Test postits-* cli commands
    """

    def get(self):
        """ Test postits-list utility

        This test emulates the Agave API endpoint "/postits/v2/" for GET
        requests. To test it:

        curl -sk -H "Authorization: Bearer xxx" 'https://localhost:5000/postits/v2/?pretty=true'
        """
        pretty_print = request.args.get("pretty", "")
        return jsonify(postits_list_response)
