CREATE TABLE companies (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL,
    address VARCHAR(255) NOT NULL,
    contact VARCHAR(255) NOT NULL,

    created TIMESTAMP NOT NULL DEFAULT NOW(),
    created_by CHAR(24) NOT NULL,

    updated TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_by CHAR(24) NOT NULL
);
