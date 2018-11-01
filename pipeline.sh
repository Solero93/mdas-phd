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

python_test() {
    pushd './test/'$APP_NAME''
    pip install -r ./requirements.txt
    if [ $(python3.6 ./votingapp.py) ]; then
        return 1;
    else
        return 0;
    fi
    popd
}


if build > log 2> error; then
    echo "Build Completed"
    run
    if test && python_test; then
        echo "Test Passed"
    else
        echo "Test Failed"
    fi
else
    echo "FAILED"
fi