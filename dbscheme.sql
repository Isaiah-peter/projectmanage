-- 1. Create the database
CREATE DATABASE taskmanager;

-- 2. Connect to the database
\c taskmanager;

-- 3. Create the tasks table
CREATE TABLE tasks (
    id SERIAL PRIMARY KEY,
    description TEXT NOT NULL,
    due DATE NOT NULL,
    priority TEXT NOT NULL CHECK (priority IN ('high', 'medium', 'low')),
    status TEXT NOT NULL DEFAULT 'Pending' CHECK (status IN ('Pending', 'Done'))
);
