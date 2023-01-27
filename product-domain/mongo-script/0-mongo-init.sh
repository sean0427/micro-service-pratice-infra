mongo -- "$MONGO_INITDB_DATABASE" <<EOF
    var user = '$MONGO_INITDB_USERNAME';
    var passwd = '$(cat "$MONGO_INITDB_PASSWORD")';
    db.createUser({user: user, pwd: passwd, roles: ["readWrite"]});
EOF