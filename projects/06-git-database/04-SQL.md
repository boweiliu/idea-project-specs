How to do the sql to git part?

Table: tasks

```
snapshot_id          ID 
  -- this is a append-only table, this is the primary key
stable_id            ID 
  -- allows us to update tasks by referring to their stable id
readable_id          str
  -- how humans refer to this task, e.g. "GT-001"
blob_hash            hex(128)
  -- stores the git blob sha. we can precompute this so it should just work.
external_id_type     str
external_id          str
  -- data to connect to another service, if this database entry is supposed to be managed elsewhere
title                utf8_str
  -- optional. should probably not contain fancy links.
body                 utf8_str
  -- can contain links to other tasks by snapshot_id
attachments          any
  -- TBD
```

I think... this is an append-only table, so this should be git-backed by a bunch of files, one per `stable_id`


