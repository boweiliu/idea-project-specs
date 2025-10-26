
Goals

1. Enable the flow of "Just start writing/prompting/drafting" - like obsidian/notion. You don't have to "be" anywhere
2. Easy add - commit - push workflow for prompts (cuz they usu are self-committing).
3. Still enable git merge, revert workflows. retroactive branching.
4. LLM agents insta-push; if they have merges they can and should pre-resolve amongst themselves
5. Allow diffs / reviews to be sortable and have custom metadata attached. Would be nice to do this in such a way as to be compatible with preexisting vanilla git review tooling.
6. Make it easy to remember what we were working on.

Steal ideas from ideaflow.app:

1. Link stuff via "+" and then it gets embedded in a little text box. backlinks
2. Hash tags via "#"
3. Cmd-m/ctrl-m to add a new entry separated by divider to the top of the stream

Still need backcompat to directory tree....

--
Strongly consider:
* tree visualization of files (left to right as usu)
* tree visualization of commits (top flowing down as usu)
* tree visualization of TODOs (left to right)

--

I wonder if there are any tools to bring live collab editing to vim... ideally i'd like a vim buffer which acts smart like the ideaflow page.
Maybe: all we need is IDE-like ability to load changes from disk as we are editing, triggered by a file watcher


--

motivation:
* codegen an implementation of every board game i have on my shelf
* to do that, would be nice to track the database game state in a migration-friendly way as LLM agent development progresses
* so we should reuse the git model (which is very simple)
* we will also need to run a sql proxy in between the backend and the "real" database so that we can intercept all calls, instead of having to spawn a sql / WAL watcher

--

sidetrack: it would also be nice to put a filesystem proxy in between the process and the real syscalls so that we can intercept them at creation time and fire our own events. Not sure if that's possible, or would we have to recompile python/claude/c etc.

--

WHAT ARE WE DOING
1. context dumping prior ideas
  a. Could use more actual use cases if I can remember them
2. Refining scope and possibly forking into separate projects if needed
3. jotting down unrelated threads


--

Simplest db-ificiation of git ==

1. table, "files_hashed" with a view table "files_latest" . Contains every file snapshot ever
  * mayybe: drop latest?
2. table, "directories_hashed" with a view table "directories_latest". Contains every directory
  * mayybe: drop latest?
3. table, "commits_hashed". Each commit has 1 or more 


