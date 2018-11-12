import unittest
import requests
import os

from requests.adapters import HTTPAdapter
from urllib3 import Retry

APP_URL = os.environ["APP_URL"]


class TestVotingApp(unittest.TestCase):
    def test_votingapp(self):
        with requests.Session() as session:
            retries = Retry(total=5, backoff_factor=1, status_forcelist=[502, 503, 504])
            session.mount('http://', HTTPAdapter(max_retries=retries))

            def start_voting(options):
                return session.post(APP_URL, json={'topics': options})

            def put_vote(option):
                return session.put(APP_URL, json={'topic': option})

            def finish_voting():
                return session.delete(APP_URL)

            options = ['Bash', 'Python', 'Go']

            start_voting(options)

            for i in range(3):
                put_vote(options[0])
            put_vote(options[1])

            expected_winner = options[0]

            winner = (finish_voting().json())['winner']

            self.assertEqual(winner, expected_winner)


if __name__ == '__main__':
    unittest.main()
