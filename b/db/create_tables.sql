create table auth.users (
  id       char(36) primary key,
  user_name varchar(20) not null,
  email    integer not null,
  password: varchar(150) not null
);
