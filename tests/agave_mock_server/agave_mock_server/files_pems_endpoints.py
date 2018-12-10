"""
    files_pems_endpoints.py

Test "files/v2/pems/system" endpoints.
"""
import json                                                                     
import ntpath                                                                   
from flask import jsonify, request                                              
from flask_restful import Resource                                              
from .response_templates import response_template_to_json                       
from .validation_helpers import (basic_access_token_checks,                     
    basic_file_path_checks, basic_system_id_checks)                             
                                                                                
                                                                                
# Sample responses. 
files_pems_list_response = response_template_to_json("files-pems-list.json")

class AgaveFilesPems(Resource):                                                
    """ Test /files/v2/pems enpoints                                           
                                                                                
    Tests:                                                                      
        - files-pems-list                                             
    """                                                                         
    def get(self, system_id, file_path):                                        
        """ Test files-pems-list                                          
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
                                                                                
        return files_pems_list_response
