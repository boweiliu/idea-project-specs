TODO(bowei):

1. Make it so that the links we are dealing with are a strict subset of markdwon inline links (link, tgt, title) and of markdown ref links (full, shortcut, or collapsed). They have some annoying edge cases with parsing brackets etc -- would like to make ours compatible and a subset. For instance maybe our link targets always look like `[link](</@#> (repo@file@hash@line@@extra))

--

Starting from the top again:

## What is the project?

Let's spec out a very small syntax on top of plaintext and git that allows semantic linking inclduing cross-commit.

After that let's build a few simmilarly tiny applications that make working with such plaintext links smoother.

## Background on git

Conceptually, git has at least 5 types of things:
1. objects in .git/objects, which are referred to by their hash:
  a. commits, containing data in a specific plaintext format
  b. trees, aka filesystem states, containing a csv-like plaintext structure
  c. blobs, aka raw file contents
2. refs, e.g. HEAD and refs/heads/`branch_name`, which are named pointers to commits or other refs
3. Filename strings, which are used in trees to keep track of files and subtrees inside.

## Link examples

Markdown
```md
blah blah i love citing sources like [this][target_1] or inline like [this](</docs/file name.md@HEAD> "title")
                                           [target_1]: /docs/file.md
```

or, code

```python
def fun_function():
    pass # see [target_2]
    #          [target_2]: /src/repo/file.py

class Foo:
    pass # see [target_3]((/src/repo/file.py)). hopefully no actual languages use [..]((...)) normally
```

This mirrors the standard md [reference](https://spec.commonmark.org/0.30/#link-label)
which supports remote refs like
```md
juilus was [here][target]

[target]: http://example.com/
```

## Link syntax spec

### Links

TODO(bowei): fill in as above. Basically just reuse the markdown syntax.
Look into some common languages to make sure syntax doesn't collide.
Also add an escape hatch if it does.

TODO(bowei): link resolutions can be reused (which direction when disambiguating??)


### Link resolution

Here's a list of things you are allowed to refer to, and what they mean

Format
```
[<repo_spec>@]<object_id>[@<version_id>][@<local_specifier>][@@[<ignored_text>]]
```

`repo_spec` is always optional and is of the form:

TODO(bowei)

`object_id` can be:

1. the hash of a commit
2. the hash of a blob/tree
3. a relative filename
4. an absolute filename, relative to the root of the repo

`version_id` is only relevant for relative or absolute filenames, and is disallowed otherwise. It can be:

1. the hash of a commit
2. a branch name, specified as `refs/heads/<branch_name>`
3. the literal string `HEAD`

Defaults to (3).

`local_specifier` can be:

1. a line number, 1-indexed
2. a line and col number, 1-indexed
3. a line range, 1-indexed and inclusive
4. a line and col range to another line and col, 1-indexed and inclusive
5. a string representing plaintext to search for, of the form 
TODO(bowei)
6. a mark aka anchor, like `#anc`

`ignored_text` is comment space and can be used for whatever systems are built on top of this.

### Link anchors

Syntax (TODO(bowei): change this???)

```md
option 1 Ordinary markdown sections are interpreted per gh md spec, eg #section-header links to this one
### Section header 


option 2: full line
<!--- {##section-anc ##alias}{blah}{blah blah} -->

option 3: explicit html tag (this becomes invisible in html) with id #anc-me
text is here <a id="anc-me"></a> yay
```

```py
x = funcall_me() # option 1 inline: []{#anc ##combined-with-fullline-alias}{meta <data>} any text can go here as usual

# options 2 fulline: []{##anc ##alias-anc}{meta <data>} blah blah
```

### Redirects

If there is an entire file whos only contents are
```
[_r]: <other_target>
```

Or, if there is a mark which says

```
{#anc1 #anc2}{_r=<other_target>}{blah}
```

then it's interpreted as a redirect.



---

4 Questions

1. Are ranges allowed as targets? Ans: yes, they help a lot with locating relevant info. 
  - allowed: line ranges, line/col ranges, or mark ranges
2. Are ranges + context allowed? Like "this line +/- 3 lines"? Ans: no, redundant and out of scope / can be managed by another layer. Rendering is not our concern -- we just want to denote "semantically this other thing is related..."
3. Are custom marks allowed as link targets? Ans: yes and in fact encouraged. Explicit is better than implcit. Hoping for line numbers/col nums/exact string lookups to remain consistent is silly.
4. How do we treat backlinks as a concept? Ans: second class. index O(1) backlinks - no. 

actually, that's 8 questions

5. Cross-repo references? Yes. Will need to know what the other repo resolves to using the gitconfig -- unfortunately git repos today are not yet IPFS'd with global uuids.
6. Referencing "computed" properties like git blame, diffs? No. Just compute them and save them if needed.
7. Tombstones/redirects/deprecation? Yes, but only at the file level... ok fine maybe at the mark level too.
8. Reuse of link tables? Yes, but only within a document, and even then discouraged. Explicit is better - you don't want your link targets changing on you. No "importing" link target defs from a common defs file -- that's how you get into recursive import hell. Just link there if you need to remember to keep it in sync.
9. 3-way or higher links? No - just use extra links, or link out to a tag doc which manually stores backlinks.

Things to build on top of this

1. A cli tool to look up the current repo for backlinks to a given [file/line], using the technology inside git blame.
2. Editor extensions for vim, IDEs, github/gitlab browser to enable following links.
   a. And, add sensible features like viewing browse history (in the natural tree structure), and persisting that browse history to a linkable flat file.
3. A format for storing a couple of links together with their relative screen positions, and a corresponding tmux + vim or IDE integration to save/load them.
4. A precommit git hook to remind to update places that are linked to/from
5. A format for adding review comments to files and/or diffs, and a tool for viewing said comments. Intended for decentralized code review.
6. A vim or IDE workflow that lets a user default to writing stuff in one big file then shunting it out to other files post-hoc.
7. Claude hook and file use / MCP extensions to let LLMs more easily follow links.
8. Text renderer extensions that add metadata on top of the links to allow configuring inline-ness (quote-style) and editable-ness. See: "tooltip the tooltips"

WHY we are doing something so trivially simple:
1. Simple is better. It means other people can add bloat on top easily. Compare that to a complex idea where removing bloat is hard.
2. Relatedly -- it's ripe to growing in other ways as well. Perhaps this could be extended to non-plaintext formats, like image or video. Perhaps we can bring about the return of HyperText.
3. Enables connecting code to docs more directly - maybe you dont like inlining because you want your docs to be verbose, or maybe you want to inline code into your docs instead. Similarly for tests to docs/code.
4. Easier to work across git versions -- especially since all the data is already there!! Switching branches can be clunky and there's frequently no need
5. Git is the best CRDT of 50 years -- amazing offline support and supports multiplayer version control up to any number of collaborators. Local first. Building docs on top of it makes a lot of sense.
6. Linking code <-> code is also useful if your code doesn't have an explicit dependency in the language but has an outo-of-band human dependency.
7. All these are mainly for humans, but LLMs can also benefit quite heavily as well from having a good way to encode context.
8. LLMs also love repeating information, which is tedious for humans, so compressing that into links is good for tokens and for sanity.
9. Working with LLMs requires good specs. Specs which reference each other permit better information organization.

--

Trying part I again:

Vanilla git has 5 things

1. commits (hashed)
2. trees (hashed)
3. blobs (hashed)
4. file names, in the tree content
5. refs
  a. special refs, like HEAD
  b. branch names, like refs/heads/main
  c. tags, like refs/tags/1.0
  d. other crap, like refs/remotes/ and refs/stash

  -- 
  Semantically, there are 5 types of branches, and maybe 5 types of collaboration models
  1. the current default branch, or main
  2. Long-lived forks with no intention of being merged back in
  3. Long-lived branches which are continually cross-merging
  4. Short-lived feature branches, usually owned by 1 person, intended to be merged into a specific 
     target branch, where merge conflicts are traditionally resolved on the feature side
  5. Unnamed pairing branches that are co-owned by 2 or more people and merge conflicts happen
     on a regular basis as both people merge into the branch. Usually called the same name but
     on different remotes, e.g. X and remotes/origin/X.
  (these 5 are probably irrelevant to this discussion)
  --

Of the 5 commit/tree/blobl/fname/refs:
* commits refer to past history
* blobs/trees are timeless
* file names are mutable and exist across the full git branching history
* refs are mutable, have a linear local log attached (reflog) which will never be reconciled remotely,
  and point to commits which themselves have past histories.

There's also a few more types of computed objects which gitlab/github have normalized:
6. blames, aka git blame annotated files
7. history/log, aka git log a file
8. diff/compare/difflog, and these come in 3-4 flavors
  a. A..B (summed commits of A that are not in B)
  a. A...B (symmetric difference of the literal state of A vs. B)
  a. A...B (summed commits of A that are not in the merge-base of A and B
9. Comments on files or diffs
10. Editable view of a file or raw views of a file, if the default is not that

 -- 

Going back how to link to things, let's go through all the types of things
1. Commits. Great to link to -- the contents of a commit contain a couple of metadata lines for
   parents, author, timestamp, and of course the commit message which can itself contain more links.
2. trees/blobs. These don't make as much sense to link -- doing so is akin to inlining a text blob
   or directory zip. We'll come back
4. file names - these are the best thing to link to, markdown already has syntax. HOWEVER: just saying a file name doesn't give us any content. We also need to know a version to look it up at, which can be specified by:
  a. commit hash - this makes us happy
  b. branch name - i guess we will fetch the most recent version of that branch (as far as we know locally) and use it.
  c. HEAD - We will interpret this to mean "do not change your git state from whatever it is you are using to view the current file, and look up using that".
     For instance - if i'm currently on 99999, and i see a link referring to README.md@HEAD or just plain README.md (the @head is implied), then i'll look it up based on my current commit: 999999
     ex. if i'm currently on 99999 but i see a link referring to README.md@888888, and in that doc I see a ref to PORTAL.md@HEAD, then i'm going to look up PORTAL.md@888888 -- the mental model is "in order to see README.md@8888, i had to check out an entire copy of the repo at 888888, so i should use that to resolve my HEAD
     Reasoning: Suppose we are creating a new repo from scratch (no commits) and we would like 2 documents to refer to each other circularly. Well we don't have any commit to ref, so we have to use HEAD, otherewise it's impossible to form a circular loop if we try double-committing or committing and throwing away or something.
     Reasoning: If we are looking at a past doc (e.g. digging up an old bug report) then HEAD is more helpful if it resolves to the state of the repo at that time, not the current version. Docs should never be able to link to future versions; the intention of HEAD is "look at that other doc which is probably more updated more frequently than this doc is, and so no one has to force update this doc whenever that one updates."
    Note that this is indeed a bit inconsistent with refs/heads/BRANCH which says to fetch the most recent version of that branch, especially if i've currently checked out a repo copy which is at an old state of the branch. However doing so avoids complexity -- if the branch has been force pushed, it's not a guarantee that any of the commits in its past history are in its tip's commit history anymore. And timestamps cannot be sensibly compared across unmerged branches.


 -- 
Metadata during links:
1. Linking to a generic file or commit -> links to the top of it
2. We would also like to be able to refer to a specific line of a file
   * 1-indexed as is standard. Newline terminated files help targeting the EOF
3. or a specific (line,character) location of a file
   * 1-indexed as is standard, again. May need to reserve "$" for the EOL location
4. or a specific line range eg L1-5
   * 1-indexed and inclusive, as is standard. So L1-2 includes 2 lines. Thus cannot have 0-len ranges
5. or a specific character range, eg L1,3-L2,7
   * 1-indexed ank inclusive, as is standard. So L1-2 includes 2 lines. Thus cannot have 0-len ranges
6. Or a specific searchable text - see http spec for [text fragments](...)

We might want in future to refer to a single line within a context of range, eg L3 in L1-5, but will leave that for later.

This already allows commenting on files github-style, but can be implemented in 2 different ways:

1. The base file is the content file and it includes links out to comment blobs.
   This is not as merge-friendly and it also corrupts the line numbers & content of the original file.
2. The base file is left alone and comments are stored in a separate file with references to ranges on the base file that are where the comment applies, and then comments go there.
   This enables multiple concurrent comments but necessitates a 3rd file to view the full file plus comments (since as is, the comment file does not refer to the full base file, only the ranges that get commented on)


--

Part I:

vanilla git has 3 types of things:

* hashables, which are immutable and content-addressed (commit, blob, tree)
* locally-linearly-versioned things, i.e. refs & symrefs (HEAD)
* (weakly) fully-versioned things, the only examples of which are filenames as they appear in tree contents, and only if they aren't mv'd.

These roughly correspond to the types of things a link can target:
* immutable versions of files (specify either the commit or the blob sha)
* a file at the current version of a ref or symref, for instance HEAD
* a file in genericity (hmmm. don't really think this makes sense)

--

github file url pattern is
```
https://github.com/<owner>/<repo>/<type>/<ref>/<path>
```
where 

```
| Segment   | Meaning                                           |
| --------- | ------------------------------------------------- |
| `<owner>` | GitHub username or org (e.g. `torvalds`)          |
| `<repo>`  | Repository name (e.g. `linux`)                    |
| `<type>`  | one of several resource types (see below)         |
| `<ref>`   | branch name, tag name, or commit hash             |
| `<path>`  | path to file or directory (relative to repo root) |

| Type       | Meaning                                                   | Example                                                         |
| ---------- | --------------------------------------------------------- | --------------------------------------------------------------- |
| `blob`     | A single **file** at a given commit, branch, or tag       | `blob/main/README.md` or `blob/abc1234/README.md`               |
| `tree`     | A **directory view** at a given commit, branch, or tag    | `tree/main/docs/`                                               |
| `commit`   | A **specific commit object** page (diff, metadata, etc.)  | `commit/abc1234`                                                |
| `releases` | Accesses the **releases** UI                              | `releases/tag/v1.0.0`                                           |
| `issues`   | Issues list or specific issue                             | `issues`, `issues/12`                                           |
| `pull`     | Pull requests                                             | `pull/45`, `pulls`                                              |
| `compare`  | Comparison between refs                                   | `compare/main...feature-branch`                                 |
| `actions`  | GitHub Actions view                                       | `actions`                                                       |
| `blame`    | Annotated file view (like `git blame`)                    | `blame/main/src/app.js`                                         |
| `raw`      | Raw file contents (no HTML wrapper) — **different host!** | `https://raw.githubusercontent.com/<owner>/<repo>/<ref>/<path>` |
| `edit`     | Edit-in-browser UI (if you have write perms)              | `edit/main/README.md`                                           |
| `history`  | Shows commit history for a specific file                  | `history/main/src/app.js`                                       |

```

Note that this is different from the git view, where
* blob -> raw file contents, unlike gh.blob which takes a commit and shows a file
* tree -> directory contents NOT attached to a commit, unlike gh.tree which takes a commit and shows dir
* commit -> commit message, unlike gh.commit which shows a commit and a diff

I think we instead want the following: (assume we are in a specific commit and we are in repo root)
* link to "/path/a.md" -> for markdown compatibility, this resolves to the file "path/a.md@HEAD"
* link to "path/a.md" -> again for md compat, this is "./path/a.md@HEAD". relative to curr file.
* link to "@GH/<type>/etc." -> the same as what github does. @GH here is a predefined constant in our config. it does NOT necessarily map to github.com but can if needed later.
  - except i would also add the type "raw" which is like "gh.blob" which turns a commit into a raw file. based on how gitlab does it
  - of note are also: blame, history aka log, compare aka diff
* link to ".git/objects/<hash_or_ref>"
* link to ".git/objects/<hash_or_ref>"

--
what are git things?

```
| Namespace         | Purpose                         | Typical object   | Reflog?            |
| ----------------- | ------------------------------- | ---------------- | ------------------ |
| `refs/heads/`     | Local branches                  | Commit           | Yes                |
| `refs/tags/`      | Tags (lightweight or annotated) | Commit/Tree/Blob | No                 |
| `refs/remotes/`   | Remote-tracking branches        | Commit           | Sometimes          |
| `refs/notes/`     | Commit notes                    | Tree             | No                 |
| `refs/stash/`     | Stash stack                     | Commit           | No                 |
| `refs/bisect/`    | Bisect state                    | Commit           | No                 |
| `refs/worktrees/` | Linked worktree HEADs           | Commit           | Yes (per worktree) |
| `refs/replace/`   | Replacement objects             | Commit/Tree/Blob | No                 |
| `refs/exp/`       | Experimental                    | Any              | Optional           |
| `refs/<anything>` | User-defined refs               | Any object       | Optional           |
```

and
```
| Flat ref           | Location                  | Type                   | Purpose                                    | Reflog? |
| ------------------ | ------------------------- | ---------------------- | ------------------------------------------ | ------- |
| `HEAD`             | `.git/HEAD`               | symbolic or direct SHA | current checkout                           | yes     |
| `ORIG_HEAD`        | `.git/ORIG_HEAD`          | SHA                    | previous branch tip before destructive ops | no      |
| `FETCH_HEAD`       | `.git/FETCH_HEAD`         | SHA(s)                 | last fetched commits                       | no      |
| `MERGE_HEAD`       | `.git/MERGE_HEAD`         | SHA(s)                 | merge in progress                          | no      |
| `CHERRY_PICK_HEAD` | `.git/CHERRY_PICK_HEAD`   | SHA                    | cherry-pick in progress                    | no      |
| `REBASE_HEAD`      | `.git/rebase-*/head-name` | SHA                    | rebase in progress                         | no      |
```





--
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
   And a system for managing this across repos and across clients (remember the git model:
   each writer client needs to have their own copy of the repo)
