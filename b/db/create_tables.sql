create table auth.users (
  id       char(36) primary key,
  username varchar(20) not null,
  email    integer not null
);
