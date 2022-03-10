from keboola.http_client import HttpClient

BASE_URL = "https://api.hightouch.io/api/v2/rest/run/"


class hightouchClient(HttpClient):
    """

    Main class for the Hightouch Client.
    """

    
    def __init__(self, access_token):
        auth_header = {'Authorization': f'Bearer {access_token}'}
        super().__init__(BASE_URL, auth_header=auth_header)


    def run_sync(self, sync_id):
        """
        Run a sync
        """
        self.post(endpoint_path=sync_id)
