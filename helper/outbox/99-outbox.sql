CREATE TYPE outbox_state AS ENUM ('unknown', 'start', 'running', 'finished', 'error');
CREATE TYPE outbox_action AS ENUM ('create/update', 'update', 'delete', 'sync')

CREATE TABLE outboxes (
  id BIGSERIAL NOT NULL,
  topic VARCHAR(100) NOT NULL, 
  entity_id BIGINT NOT NULL,
  action outbox_action,
  query JSONB NOT NULL,
  time TIMESTAMP NOT NULL DEFAULT NOW(),
  async_state outbox_state
);