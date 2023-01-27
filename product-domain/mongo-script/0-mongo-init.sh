mongo -- "$MONGO_INITDB_DATABASE" <<EOF
    var user = '$MONGO_APP_DB_USERNAME';
    var passwd = '$(cat "$MONGO_APP_DB_PASSWORD")';
    db.createUser({user: user, pwd: passwd, roles: ["readWrite"]});
EOF