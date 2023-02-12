CREATE TABLE companies (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL,
    address VALUES(255) NOT NULL,
    contact VALUES(255) NOT NULL,

    created TIMESTAMP NOT NULL DEFAULT NOW(),
    createby CHAR(24) NOT NULL,

    updated TIMESTAMP NOT NULL DEFAULT NOW(),
    updateBy CHAR(24) NOT NULL
);
