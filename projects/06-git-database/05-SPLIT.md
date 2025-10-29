What if: we split the project up into 3 more simple project

1. Just enhance git text repos with rich hyper link semantics.
   make it easy to write markdown or code files that refer to hashes of
   blobs, commits, or trees. (or... histories of trees?)
2. Enhance git text repos with schema'd record semantics. For instance
   git commits already consists of kv-metadata + a text blob;
   git trees are csv-like, containing an array of kv metadata
   Already here we should have the notion of a sql database <> git repo
   where each is reconstructable from the other.
3. Layer a UI on top to help with task management specifically, and all
   doc types that are associated, e.g. context docs, commit chain of code commits
   as output, plus a MR description of the changes. a left/right comparison doc type.
   And a system for managing this across repos and across clients (remember the git model
   each client needs to have their own copy of the repo)
