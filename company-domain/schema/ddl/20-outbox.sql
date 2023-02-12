CREATE TYPE outbox_state AS ENUM ('start', 'running', 'finished', 'error', 'unknowun');

CREATE TABLE outbox {
  query VARCHAR NOT NULL,
  time TIMESTAMP DEFAULT NOT,
  aync_state outbox_state DEFAULT,
}