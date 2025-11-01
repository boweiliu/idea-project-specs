

Parts of the project:

 * links over vanilla git
 * improved filesystem over vanilla git (stable ids)
 * improved diffs over vanilla git (capture: edit, split, erge, insert-before vs insert-after)
 * improved branching semantics over vanilla git (bowei/feature has a implicit write lock; why not put file-level write locks on main too)
 * link metadata (e.g. inline, inline quoted, block quoted, expandacollapsible, inline-editable, quoted-recursively-with-depth-2)
 * semantics for viewing a content file and 1 or more comment files that refer to it
 * blames & diffs as commentable/referrable pseudofiles
 * shared reflog for a head of a branch, in the shape of a dag obviously
 * finitely editable commit messages that point to diffs
 * bidirectional sql over git, with dag-versioned schemas and backcompatibility and serializers

