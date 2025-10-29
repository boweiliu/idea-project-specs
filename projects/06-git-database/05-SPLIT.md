Part I:

vanilla git has 3 types of things:

* hashables, which are immutable and content-addressed (commit, blob, tree)
* locally-linearly-versioned things, i.e. refs & symrefs (HEAD)
* (weakly) fully-versioned things, the only examples of which are filenames as they appear in tree contents, and only if they aren't mv'd.

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
