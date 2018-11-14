import unittest
import requests
import os

from requests.adapters import PoolManager
from urllib3 import Retry

APP_URL = os.environ["VOTING_URL"]


class TestVotingApp(unittest.TestCase):
    def test_votingapp(self):
        retries = Retry(total=5, backoff_factor=1)
        http = PoolManager(retries=retries)

        def start_voting(options):
            return http.request('POST', APP_URL, json={'topics': options})

        def put_vote(option):
            return http.request('PUT', APP_URL, json={'topic': option})

        def finish_voting():
            return http.request('DELETE', APP_URL)

        options = ['Bash', 'Python', 'Go']

        start_voting(options)

        for i in range(3):
            put_vote(options[0])
        put_vote(options[1])

        expected_winner = options[0]

        winner = (finish_voting().json())['winner']

        self.assertEqual(winner, expected_winner,
                            msg=f"Expected Winner is {winner} and should be {expected_winner}")


if __name__ == '__main__':
    unittest.main()
