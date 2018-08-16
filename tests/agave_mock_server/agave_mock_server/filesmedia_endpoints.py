"""
    files_media_endpoints.py

Test the "/files/v2/media" endpoints.
"""
import json
from flask import jsonify, request
from flask_restful import Resource
from .response_templates import response_template_to_json


# Sample response for "files-upload -S -S system -F file.ext /path" cli
# command.
# curl -# -k -H "Authorization: Bearer xxxxxxxxxxxxxxxxxxxxxxxxxxx" \
#   -X POST -F "fileToUpload=@file.ext" \
#   'https://api.tenant.org/files/v2/media/system/system/path?pretty=true'
files_upload_response = response_template_to_json("files-upload.json")


def basic_access_token_checks(access_token=None):
    """ Test validity of access token

    Check whether the Authorization header from the request meets basic format
    requirements.

    INPUT
    -----
    access_token : string (default: None)
    """
    if (access_token is None or access_token == "" or 
            access_token[:7] != "Bearer " or len(access_token[7:]) < 30):
        resp = jsonify({"error": "Bad authorization header"})
        resp.status_code = 400
        return resp
    else:
        None


def basic_system_id_checks(system_id=None):
    """ Test validity of system ID

    Check whether the system ID meets basic format requirements.

    INPUT
    -----
    system_id : string (default: None)
    """
    if system_id is None or system_id == "":
        resp = jsonify({"error": "No system ID specified"})
        resp.status_code = 400
        return resp
    else:
        return None


def basic_file_path_checks(file_path=None):
    """ Test validity of file path
    
    Check whether the system ID meets basic format requirements.
    
    INPUT
    -----
    system_id : string (default: None)
    """
    if file_path is None or file_path == "":
        resp = jsonify({"error": "No path to file/dir specified"})
        resp.status_code = 400
        return resp
    else:
        return None



class AgaveFilesMedia(Resource):
    """ Test /files/v2/media enpoints

    Tests:
        - files-get -S system /path
        - files-upload -S system -F file /path
    """
    def get(self, system_id, file_path):
        """ Test files-get cli command

        curl -k -H "Authorization: Bearer xxxxxxxxxxxxxxxxxxxxxxxxxxxxx"  \
            -O 'https://localhost:5000/files/v2/media/system/system_id/path'
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

        return "{0}/{1}".format(system_id, file_path)


    def post(self, system_id, file_path):
        """ Test files-upload cli command

        curl -# -k -H "Authorization: Bearer xxxxxxxxxxxxxxxxxxxxxxxxxxxx" \
            -X POST -F "fileToUpload=@file.ext" \
            'https://localhost:5000/files/v2/media/system/system/path?pretty=true'
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

        file_to_upload = request.files.get("fileToUpload")
        file_to_upload = file_to_upload.filename
        if file_to_upload is None or file_to_upload == "":
            resp = jsonify({"error": "No file to upload was specified"})
            resp.status_code = 400
            return resp

        response = json.dumps(files_upload_response)                          
        response = response.replace("{URL_ROOT}", request.url_root)
        response = response.replace("{FILENAME}", file_to_upload)
        response = response.replace("{REMOTEPATH}", file_path)
        response = response.replace("{SYSTEMID}", system_id)
        return jsonify(json.loads(response)) 