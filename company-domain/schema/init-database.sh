#!/bin/sh

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
  CREATE EXTENSION plpython3u;
EOSQL

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
#!/bin/sh

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
  CREATE EXTENSION plpython3u;
EOSQL

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
CREATE OR REPLACE FUNCTION push_to_api()
RETURNS TRIGGER AS \$\$
import urllib.request
import os
import json

def push_to_api(new_record):
    url = os.getenv("OUTBOX_PATH")
    data = json.dumps(new_record).encode("utf-8")
    request = urllib.request.Request(f'http://{url}', data=data, method="POST") 
    request.add_header("Content-Type", "application/json") 
    with urllib.request.urlopen(request) as response:
        html = response.read()
        print(html)
    return new_record

return push_to_api(TD['new'])

\$\$ LANGUAGE plpython3u;

CREATE TRIGGER push_to_api_trigger
AFTER INSERT ON outboxes
FOR EACH ROW EXECUTE FUNCTION push_to_api();
EOSQLCREATE OR REPLACE FUNCTION push_to_api()
RETURNS TRIGGER AS \$\$
import urllib.request
import os
import json

def push_to_api(new_record):
    url = os.getenv("OUTBOX_PATH")
    data = json.dumps(new_record).encode("utf-8")
    request = urllib.request.Request(f'http://{url}', data=data, method="POST") 
    request.add_header("Content-Type", "application/json") 
    with urllib.request.urlopen(request) as response:
      html = response.read()
      print(html)
    return new_record

\$\$ LANGUAGE plpython3u;

CREATE TRIGGER push_to_api_trigger
AFTER INSERT ON outboxes
FOR EACH ROW EXECUTE FUNCTION push_to_api(NEW);
EOSQL