CREATE TYPE outbox_state AS ENUM ('unknown', 'start', 'running', 'finished', 'error');

CREATE TABLE outboxes (
  id BIGSERIAL NOT NULL,
  topic VARCHAR(100) NOT NULL, 
  entity_id BIGINT NOT NULL,
  query JSONB NOT NULL,
  time TIMESTAMP NOT NULL DEFAULT NOW(),
  async_state outbox_state
);