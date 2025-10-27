How to do the sql to git part?

Table: tasks

```
snapshot_id          ID 
  -- this is a append-only table, this is the primary key
stable_id            ID 
  -- allows us to update tasks by referring to their stable id
readable_id          str
  -- how humans refer to this task. linear
external_id_type     str
external_id          str
  -- data to connect to another service, if this database entry is supposed to be managed elsewhere
title                utf8_str
body                 utf8_str

```



