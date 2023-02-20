CREATE OR REPLACE FUNCTION push_to_api()
RETURNS TRIGGER AS $$
DECLARE
    http_req text;
    http_resp text;
BEGIN
    http_req := 'curl -X POST -H "Content-Type: application/json" -d ''' || 
                row_to_json(NEW) || ''' $OUTOBX_PATH';
    http_resp := shell_exec(http_req);

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER push_to_api_trigger
AFTER INSERT ON outboxes
FOR EACH ROW EXECUTE FUNCTION push_to_api();  