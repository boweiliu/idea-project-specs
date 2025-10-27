How to do the sql to git part?

Table: tasks

```
snapshot_id          TYPED_ID (pkey,tasks)
  -- this is a append-only table, this is the primary key. unrelated to anything
stable_id            TYPED_ID (tasks)
  -- allows us to update tasks by referring to their stable id
serializer_ver       str(enum)
  -- stores a reference to the implementation of HOW to serialize this sql model into the file
  -- consequently this also determines what the hash ends up as
blob_hash            hex(128)
  -- stores the git blob sha. we can precompute this so it should just work.

external_id_type     str(enum)(optional)
external_id          str(optional)
  -- data to connect to another service, if this database entry is supposed to be managed elsewhere

readable_id          str
  -- how humans refer to this task, e.g. "GT-001"
status               str(enum)
assignee_id          TYPED_ID (
title                utf8_str(optional)
  -- optional. should probably not contain fancy links.
body                 utf8_str
  -- can contain links to other tasks by snapshot_id or stable_id
  -- TBD how exactly
  -- can also contain links to files e.g. attachments
```

I think... this is an append-only table, so this should be git-backed by a bunch of files, one per `stable_id`


Table: docs

```
snapshot_id          ID 
  -- this is a append-only table, this is the primary key
stable_id            ID 
  -- allows us to update tasks by referring to their stable id
blob_hash            hex(128)
  -- stores the git blob sha. we can precompute this so it should just work.
