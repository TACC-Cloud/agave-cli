from agave_mock_server import app as application

if __name__ == "__main__":
    application.run(host="0.0.0.0", ssl_context="adhoc")
