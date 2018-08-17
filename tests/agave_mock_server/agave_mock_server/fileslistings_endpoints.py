"""
    fileslistings_endpoints.py

Mock Agave "/files/v2/listings/system/" endpoint.
"""
import json                                                                     
from flask import jsonify, request                                              
from flask_restful import Resource                                              
from .response_templates import response_template_to_json
from .validation_helpers import (basic_access_token_checks, 
    basic_file_path_checks, basic_system_id_checks)

# Sample response for "files-list -V -S system-id /path".
# curl -sk -H "Authorization: Bearer xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" \
#   'https://api.tenant.org/files/v2/listings/system/system-id//path?pretty=true'
files_list_response = response_template_to_json("files-list.json")


class AgaveFilesListings(Resource):
    """ Mock Agave API /files/v2/listings/system/ endpoint

    Mocks endpoint for cli commands:
        - files-list
    """

    def get(self, system_id, file_path):
        """
        curl -sk -H "Authorization: Bearer xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" \
            'https://localhost:5000/files/v2/listings/system/system//path?pretty=true'
        """
        # Test api access token.                                                
        token = request.headers.get("Authorization")                            
        resp = basic_access_token_checks(token)                                 
        if resp:                                                                
            return resp                                                         
                                                                                
        # Test system ID.                                                       
        resp = basic_system_id_checks(system_id)                                
        if resp:                                                                
            return resp

        # Test file/dir path.
        resp = basic_file_path_checks(file_path)
        if resp:
            return resp

        response = json.dumps(files_list_response)
        response = response.replace("{URL_ROOT}", request.url_root)
        response = response.replace("{REMOTEPATH}", file_path)
        response = response.replace("{SYSTEMID}", system_id)
        return jsonify(json.loads(response))
