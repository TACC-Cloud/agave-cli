"""
    validation_helpers.py

Functions used to validate Agave API request data.
"""
from flask import jsonify


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
