#!/usr/bin/env bash

export APP_URL='http://myvotingapp:8080/vote'

test() {
    http_client() {
        # myvotingapp es resuelto por el DNS de Docker
        curl --url $APP_URL\
            --request $1\
            --data "$2"\
            --header 'Content-Type: application/json'\
            --silent
    }
    start_voting() {
        http_client POST '{"topics":'$1'}'
    }
    put_vote() {
        http_client PUT '{"topic":"'$1'"}'
    }
    finish_voting() {
        http_client DELETE
    }
    options='["Bash","Python","Go"]'
    expectedWinner='Bash'
    echo "Given voting topics $options, When vote for [Bash Bash Bash Python], Then winner is $expectedWinner"
    start_voting $options

    for option in Bash Bash Bash Python
    do
        put_vote $option
    done
    winner=$(finish_voting | jq -r '.winner')

    if [[ "$expectedWinner" = "$winner" ]]; then
        echo "Bash Test Completed!"
        return 0;
    else
        (>&2 echo "Expected Winner is $winner and should be $expectedWinner")
        return 1;
    fi

}

# TODO pass APP_PATH to Python
python_test() {
    pip3 install -r ./requirements.txt --quiet
    if python3 ./votingapp.py; then
        echo "Python Test Completed!"
        return 0;
    else
        (>&2 echo "Python Test Failed")
        return 1;
    fi
}
# TODO Añadir política de reintentos
test
python_test

# Reventar disco en Docker -> Preferences -> Disk -> Reveal in Finder si te ocupa mucho