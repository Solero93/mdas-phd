#!/usr/bin/env bash
APP_NAME='votingapp'

build() {
    pushd './src/'$APP_NAME''
    ./deps.sh
    rm -rf ./deploy
    go build -o ./deploy/votingapp || return 1
    cp -r ui ./deploy
    popd
}

run() {
    pushd './src/'$APP_NAME''
    # [v]otingapp is a hack to exclude the grep itself from processes
    # https://unix.stackexchange.com/questions/74185/how-can-i-prevent-grep-from-showing-up-in-ps-results
    pid=$(ps aux | grep [v]otingapp | awk '{print $1}' | head -1)
    kill -9 $pid || echo "Nothing to kill"
    ./deploy/$APP_NAME &
    sleep 2
    popd
}

test() {
    http_client() {
        curl --url 'http://localhost:8080/vote'\
            --request $1\
            --data "$2"\
            --header 'Content-Type: application/json'
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

    if [ "$expectedWinner" = "$winner" ]; then
        return 0;
    else
        (>&2 echo "Expected Winner is $winner and should be $expectedWinner")
        return 1;
    fi

}

python_test() {
    pushd './test/'$APP_NAME''
    pip3 install -r ./requirements.txt --quiet
    if python3 ./votingapp.py; then
        return 0;
    else
        return 1;
    fi
    popd
}

if build > build.log 2> build.error; then
    echo "Build Completed"
    if run > run.log 2> run.error; then
        if test && python_test; then
            echo "Test Passed"
        else
            echo "Test Failed"
        fi
    else
        echo "Run Failed"
    fi
else
    echo "FAILED"
fi