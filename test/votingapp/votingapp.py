import unittest

import requests

APP_URL = 'http://localhost:8080/vote'


def start_voting(options):
    return requests.post(APP_URL, data={'topics': options})


def put_vote(option):
    return requests.put(APP_URL, data={'topic': option})


def finish_voting():
    return requests.delete(APP_URL)


class TestVotingApp(unittest.TestCase):
    def test_votingapp(self):
        options = ["Bash", "Python", "Go"]

        start_voting(options)

        for i in range(3):
            put_vote(options[0])
        put_vote(options[1])

        expected_winner = options[0]

        winner = (finish_voting().json())['winner']

        self.assertEqual(winner, expected_winner)


if __name__ == '__main__':
    unittest.main()
