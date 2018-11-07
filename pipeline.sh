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
    popd
}

if build > build.log 2> build.error; then
    echo "Build Completed"
    if run > run.log 2> run.error; then
        echo "Run Completed"
    else
        echo "Run Failed"
    fi
else
    echo "Build Failed"
fi