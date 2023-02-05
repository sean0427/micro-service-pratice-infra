const root = _getEnv('MONGO_INITDB_ROOT_USERNAME');
const pwd = cat(_getEnv('MONGO_INITDB_ROOT_PASSWORD_FILE'));
const adminDb = db.getSiblingDB('admin');

adminDb.auth(root, pwd);
print('Successfully authenticated admin user');

var db_name = _getEnv('MONGO_INITDB_DATABASE');

const test_db = db.getSiblingDB(db_name);
test_db.createUser(
    {
        user: _getEnv('MONGO_APP_DB_USERNAME'),
        pwd: _getEnv('MONGO_APP_DB_PASSWORD'),
        roles: [{ role: 'readWrite', db: db_name }] 
    }
);
