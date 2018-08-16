"""
    files_media_endpoints.py

Test the "/files/v2/media" endpoints.
"""
from flask import jsonify, request
from flask_restful import Resource

class AgaveFilesMedia(Resource):
    """ Test /files/v2/media enpoints

    Tests:
        - files-get
    """
    def get(self, system_id, file_path):
        """ Test files-get cli command
        
        curl -k -H "Authorization: Bearer xxx"  \
            -O 'https://localhost:5000/files/v2/media/system/system_id/path'
        """
        # Test api access token.
        token = request.headers.get("Authorization")
        if (token is None or token == "" or token[:7] != "Bearer " or 
                len(token[7:]) < 30):
            resp = jsonify({"error": "Bad authorization header"})
            resp.status_code = 400
            return resp

        # Test system ID.
        if system_id is None or system_id == "":
            resp = jsonify({"error": "No system ID specified"})
            resp.status_code = 400
            return resp

        # Test file/dir path.
        if file_path is None or file_path == "":
            resp = jsonify({"error": "No path to file/dir specified"})
            resp.status_code = 400
            return resp

        return "{0}/{1}".format(system_id, file_path)
