#!/usr/bin/bash

    set -feuo pipefail

    length="$(jq '. | length' $WORKSPACE/externalRemotes.config.json)"
    echo "There is $length remote repositories to clone"
    
    for (( i=0; i<$length; i++ ))
    
    do
    REPO=$(jq -r ".[$i].repo_url" externalRemotes.config.json | sed 's|https://github.com/sede-x/||')
    PATH=$WORKSPACE/host-app/out/$REPO
    TAG=$(jq -r ".[$i].version" externalRemotes.config.json)
    TOKEN=$(jq -r ".[$i].repo_url" externalRemotes.config.json | sed 's|https://github.com/sede-x/beacon-frontend-||'|tr '[:lower:]' '[:upper:]'_TOKEN)
    Dupa=$TOKEN
    
    echo "Cloning $REPO to directory $PATH"
    git clone --branch $TAG https://"$TOKEN"@github.com/sede-x/"$REPO" $PATH
    
    echo "Building and testing app"
    npm ci --prefix $PATH
    npm run build --prefix $PATH
    npm test --prefix $PATH
    
    echo "Making directory $WORKSPACE/host-app/out/$REPO"
    mkdir -p $WORKSPACE/host-app/out/$REPO
    
    echo "Copying build artifacts from $PATH/build/ to $WORKSPACE/host-app/out/$REPO
    cp -R $PATH/build/* $WORKSPACE/host-app/out/$REPO
    
    done
