APP_NAME='votingapp'

VOTING_APP_PATH='./src/'$APP_NAME''

build() {
    pushd $VOTING_APP_PATH
    ./deps.sh
    rm -rf ./deploy
    go build -o ./deploy/votingapp || return 1
    cp -r ui ./deploy
    popd
}

run() {
    pushd $VOTING_APP_PATH
    pid=$(ps | grep $APP_NAME | awk '{print $1}' | head -1)
    kill -9 $pid || true
    ./deploy/$APP_NAME &
    popd
}

test() {
    http_client() {
        curl \
            --url 'http://localhost:8080/vote' \
            --request $1 \
            --data "$2" \
            --header 'Content-Type: application/json' \
            --silent
    }
    options='["Bash", "Python", "Go"]'
    topics='{"topics":'$options'}'
    expectedWinner='Bash'

    echo "Given voting topics $topics, When vote for $options, Then winner is $expectedWinner"
    http_client POST $topics

    for option in Bash Bash Bash Python
    do
        http_client PUT '{"topic":"'$option'"}'
    done

    winner=$(http_client DELETE | jq -r '.winner')

    if [ "$expectedWinner" = "$winner" ]; then
        return 0;
    else
        return 1;
    fi

}

if build > log 2> error; then
    echo "Build Completed"
    run
    if test; then
        echo "Test Passed"
    else
        echo "Test Failed"
    fi
else
    echo "FAILED"
fi