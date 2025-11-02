

Parts of the project:

 1 links over vanilla git
 2 improved filesystem over vanilla git (stable ids, symlinks in the .so style, multiple files with the same name that shadow)
 3 improved diffs over vanilla git (capture: edit, split, erge, insert-before vs insert-after)
 4 improved branching semantics over vanilla git (bowei/feature has a implicit write lock; why not put file-level write locks on main too)
 5 link metadata (e.g. inline, inline quoted, block quoted, expandacollapsible, inline-editable, quoted-recursively-with-depth-2)
 6 semantics for viewing a content file and 1 or more comment files that refer to it
 7 blames & diffs as commentable/referrable pseudofiles
 8 shared reflog for a head of a branch, in the shape of a dag obviously
 9 finitely editable commit messages that point to diffs
 10 bidirectional arbitrary sql over git, with dag-versioned schemas and backcompatibility and serializers, and each sql client having its own git repo clone
 11 overlayfs at the git level -- allows us to layer 2 git repos on top of each other if they do not contain the same file names (and sometimes even if they do). this helps with putting tasks right next to the relevant code files while being separate repos. gitdir to decollide the .git folder itself if needed. color distinguishing files somehow.

