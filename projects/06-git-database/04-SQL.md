idea: have the sql layer, distinct from the tables that help out with persistence (i.e. transforming to git).

SQL layer:

  - concepts:
  - be crdt friendly (dag: plural parents, children, references etc. where possible)
  - be migration friendly (maintain multiple active schema versions at once)
  - avoid booleans in favor of links (evidence allows verify)
  - content-hash where possible; but note that you will have to recompute if so
  - explicit backlinks wherever possible (saves on reverse lookup; can always optimize out later)

All tables share
```
snapshot_id          TYPED_ID<this> PKEY
  -- this is a append-only table, this is the primary key. unrelated to anything
prior_snapshot_ids   list<TYPED_ID<this>>
  -- backlinks to form a dag in case of crdt merge
stable_id            TYPED_ID<this.stable>
  -- allows us to update this by referring to the stable id
schema_ver           str<enum>
  -- hehe. need to figure this out across git branched migrations. maybe: git hash of the code?
created_at           timestamp
created_trace        str<uuid>
  -- trace_id for debugging

created_from         list<TYPED_ID<this.stable>>
  -- if we deleted 2 record and they now refer here. can be empty.
deleted_into         list<TYPED_ID<this.stable>> OPTIONAL
  -- if we deleted this record and split it to other locations. can be empty if we just plain deleted.
  -- null if this is NOT deleted.
is_deleted           bool COMPUTED

externally_owned     bool COMPUTED
  -- could be a computed field here, but included for ease of algebraically typing
external_owner       str<enum> OPTIONAL
  -- data to connect to another service, if this database entry is supposed to be managed elsewhere
  -- this contains the name of the external service, and the entity type name(s) over there
external_id_type     str OPTIONAL
external_ids         list<str> OPTIONAL
  -- entity type name(s) over there and their ids. plural since our mapping may not be 1:1. 
  -- precise implementation of mapping is referred by:
external_schema_ver  str<enum> OPTIONAL
  -- schema_ver stores info about which code is used to translate this entry to the remote.
external_mirror_info str<enum> OPTIONAL
  -- metadata about the semantics of the translation/import. maybe sample values:
  -- exact: this record contains a full and exact mirror of all external data
  --   (in which case we should probably also save the timestamp of last sync)
  -- lazy: this record is incomplete and data should be fetched laizly from external source
  --   (which fields exactly are lazy???)

<other fields follow>

```

For instance:

table: hypers has all of the above, PLUS

```
parent_ids           list<TYPED_ID<this.stable>>
  -- can be empty list if no parent. this roughly corresponds to "location in file hierarchy"
format               str<enum>
  -- defaults to `utf8_str`, but can also be `binary` or `utf8_jsonl` or something.
contents_raw         bytes OPTIONAL
  -- holds the raw text/binary contents
  -- optional - can just leave this null
resolved_by          TYPED_ID<resolvers> OPTIONAL
  -- Does this doc contain resolvable hyperlinks to other docs? Or is it plain old text/binary?
  -- if the former -- then this field holds the ref to the hyperlink lookup field used for resolving.
  -- if the latter -- then this field is null
```

table: `hyper_lookups`
```
referrer_ids         list<TYPED_ID<hypers.stable>>
  -- list of places this resolver table is used.
entries              list<TYPED_ID<_resolver_pairs>>
  -- unordered list of key-value pairs.
  -- the keys in resolver_pairs can be duplicated.
```


table: `_resolver_pairs`
This is an internal table, plus its immutable, so it doesn't have any of the mutable/crdt/external bullshit

```
snapshot_id          TYPED_ID<this> PKEY
  -- only named as snapshot for consistency
readable_key         str
  -- the key used for lookup; if this is duplicated, dedupe via the snapshot_id
target_table         str OPTIONAL
  -- should be a table name, e.g. "tasks". Defaults to "hypers"
target_stable_id     str
target_snapshot_id   str OPTIONAL
  -- null: this is a ref to @latest
target_field         str OPTIONAL
```


table: docs
```
author_ids
hyper_ids







Serialization layer:

```
serializer_ver       str(enum)
  -- stores a reference to the implementation of HOW to serialize this sql model into the file
  -- consequently this also determines what the hash ends up as
blob_hash            bytes(128)
  -- stores the git blob sha. we can precompute this so it should just work.
  -- stored as raw binary but we (and everyone else) works with this as a hex string.

```

maybe use the git style: 
```
blob int[,int]*
```
e.g. `blob 38,1214,1399` for a 3-part file with 38 bytes followed by 1214 bytes followed by 1399 bytes.
e.g. `blob 123-4-123-4-123 for a 3-part file with 2 4-byte delimiters (maybe: "---\n"?)
Or maybe a variant based on the multipart file upload syntax (except removing the stupid \r\n--<boundary>\r\n wrapping)
e.g. `boundary12=|--DELIM--|\n` for a file that uses the 12-byte delim "|--DELIM--|\n"



--

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
  -- TODO: maybe we can merge this with body?

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
  -- needed for compatibility with git, we almost never care
  -- format is like 100644 file or 040000 dir or 120000 symlink

doc_type             str(enum)
  -- hyper, binary, record, symlink
  -- hyper - see below, has usually utf8 text and any number of links
  -- binary - just bytes, no links allowed. images and other binaries.
  -- symlink - the ordinary git symlink. as usual, relative to its cwd
  -- record - a generic sql record row, serialized as e.g. json. Schema should be linked too.
  -- eg  task - see above, has a bunch of task metadata, and then also contains hyper in the body
  -- maybe computed / file views are an example of records? otherwise it's a separate type
  -- TODO: should we have a special case for empty docs (eg dirs)?

TODO: what goes here? some sort of polymorphic contents_id?
```



iTable:
