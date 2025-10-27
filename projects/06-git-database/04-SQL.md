How to do the sql to git part?

Table: tasks

```
snapshot_id          TYPED_ID (pkey,tasks)
  -- this is a append-only table, this is the primary key. unrelated to anything
stable_id            TYPED_ID (tasks)
  -- allows us to update this by referring to the stable id
created_at           timestamp
created_trace        str (uuid)
  -- trace_id for debugging
is_deleted           bool
  -- tombstone. deleted entries CANNOT be undeleted, only copied

schema_ver           str(enum)
  -- hehe. need to figure out how to do this across git branched migrations. maybe refer to git?
serializer_ver       str(enum)
  -- stores a reference to the implementation of HOW to serialize this sql model into the file
  -- consequently this also determines what the hash ends up as
blob_hash            bytes(128)
  -- stores the git blob sha. we can precompute this so it should just work.
  -- stored as raw binary but we (and everyone else) works with this as a hex string.

externally_owned     bool
external_id_type     str(enum)(optional)
external_id          str(optional)
  -- data to connect to another service, if this database entry is supposed to be managed elsewhere

readable_id          str
  -- how humans refer to this task, e.g. "GT-001". may be non-unique in case of merge conflict
status               str(enum)
sorting_key          sortable
  -- TBD. used to store order relative to other tasks when breaking ties
properties           jsonb
  -- other misc non-referntial properties, like size_estimate, priority_level, upvote_count
assignee_id          TYPED_ID (agents)
creator_id           TYPED_ID (agents)
title                utf8_str(optional)
  -- optional. should probably not contain fancy links.
body                 utf8_str(optional)
  -- can contain links to other tasks by snapshot_id or stable_id
  -- TBD how exactly
  -- can also contain links to files e.g. attachments
relations            list[TYPED_ID<relations>]
  -- TBD but this is where to store info about how exactly this entity links to other entities.
  -- for instance - this <is tagged with> -> [tag_id]
  -- for instance - this <is part of project> -> [task_id]
  -- for instance - this <has_comment_data> -> [comment_tree_id]
  -- for instance - this <duplicates> <> [task_id]
  -- for instance - this <is completed by> -> [doc_id]
```

I think... this is an append-only table, so this should be git-backed by a bunch of files, one per `stable_id`


Table: docs

NOTE: hmm, there's some notion of doc lifetime... some docs are tied to a task, some are permanently relevant.
NOTE: tags are docs. tasks are docs. file attachments are docs. Comments are docs.

```
snapshot_id          TYPED_ID (pkey,docs)
  -- this is a append-only table, this is the primary key. unrelated to anything
stable_id            TYPED_ID (docs)
  -- allows us to update this by referring to the stable id
created_at           timestamp
created_trace        str (uuid)
  -- trace_id for debugging
is_deleted           bool
  -- tombstone. deleted entries CANNOT be undeleted, only copied

schema_ver           str(enum)
  -- hehe. need to figure out how to do this across git branched migrations. maybe refer to git?
serializer_ver       str(enum)
  -- stores a reference to the implementation of HOW to serialize this sql model into the file
  -- consequently this also determines what the hash ends up as
blob_hash            hex(128)
  -- stores the git blob sha. we can precompute this so it should just work.

externally_owned     bool
external_id_type     str(enum)(optional)
external_id          str(optional)
  -- data to connect to another service, if this database entry is supposed to be managed elsewhere

is_directory         bool
name                 utf8_str
  -- file or directory name
parent_directory     TYPED_ID (docs) (optional)
  -- can be null only if this is the root. must refer to a docs entry with is_directory=true
permissions          str
  -- needed for compatibility with git, format is like 100644 file or 040000 dir. we almost never care

doc_type             str(enum)
  -- task, text, or raw
  -- task - see above, has a bunch of task metadata, and then also contains text
  -- text - see below, has links
  -- raw - just bytes

```




