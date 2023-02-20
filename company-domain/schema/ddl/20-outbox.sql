CREATE TYPE outbox_state AS ENUM ('unknowun', 'start', 'running', 'finished', 'error');

CREATE TABLE outboxes (
  id BIGSERIAL NOT NULL,
  query VARCHAR NOT NULL,
  time TIMESTAMP NOT NULL DEFAULT NOW(),
  aync_state outbox_state
);