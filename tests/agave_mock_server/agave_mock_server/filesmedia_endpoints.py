"""
    files_media_endpoints.py

Test the "/files/v2/media" endpoints.
"""
import json
from flask import jsonify, request
from flask_restful import Resource
from .response_templates import response_template_to_json
from .validation_helpers import (basic_access_token_checks,                     
    basic_file_path_checks, basic_system_id_checks)


# Sample response for "files-delete --V -S systemid file".
# curl -sk -H "Authorization: Bearer xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" \
#   -X DELETE 'https://api.tenant.org/files/v2/media/system/systemid/file?pretty=true'
files_delete_response = response_template_to_json("files-delete.json")

# Sample response for "files-mkdir -V -S system -N name /path".
# curl -sk -H "Authorization: Bearer xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" \
#   -X PUT -d "action=mkdir&path=name" \
#   'https://api.tenant.org/files/v2/media/system/system//path?pretty=true'
files_mkdir_response = response_template_to_json("files-mkdir.json")


# Sample response for "files-upload -V -S system -F file.ext /path" cli
# command.
# curl -# -k -H "Authorization: Bearer xxxxxxxxxxxxxxxxxxxxxxxxxxxxx" \
#   -X POST -F "fileToUpload=@file.ext" \
#   'https://api.tenant.org/files/v2/media/system/system/path?pretty=true'
files_upload_response = response_template_to_json("files-upload.json")


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

    def put(self, system_id, file_path):
        """ Test files-mkdir command

        curl -k -H "Authorization: Bearer xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" \
            -X PUT -d "action=mkdir&path=name" \
            'https://localhost:5000/files/v2/media/system/system//path?pretty=true'
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

        # Test form data fields "action" and "path".
        action = request.form.get("action")
        if action != "mkdir":
            resp = jsonify({"error": "Bad authorization header"})
            resp.status_code = 400
            return resp

        new_dirname = request.form.get("path")
        if new_dirname is None or new_dirname == "":
            resp = jsonify({"error": "Bad file system path"})
            resp.status_code = 400
            return resp

        response = json.dumps(files_mkdir_response)                            
        response = response.replace("{URL_ROOT}", request.url_root)
        response = response.replace("{REMOTEPATH}", file_path)
        response = response.replace("{SYSTEMID}", system_id)
        response = response.replace("{DIRNAME}", new_dirname)
        return jsonify(json.loads(response))

    def delete(self, system_id, file_path):
        """ Test files=delete command

        curl -k -H "Authorization: Bearer xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" \
            -X DELETE 'https://localhost:5000/files/v2/media/system/system_id/file_path?pretty=true'
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

        return jsonify(files_delete_response)

