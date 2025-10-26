
Goals

1. Enable the flow of "Just start writing/prompting/drafting" - like obsidian/notion. You don't have to "be" anywhere
2. Easy add - commit - push workflow for prompts (cuz they usu are self-committing).
3. Still enable git merge, revert workflows. retroactive branching.
4. LLM agents insta-push; if they have merges they can and should pre-resolve amongst themselves
5. Allow diffs / reviews to be sortable and have custom metadata attached. Would be nice to do this in such a way as to be compatible with preexisting vanilla git review tooling.
6. Make it easy to remember what we were working on.

Steal ideas from ideaflow.app:

1. Link stuff via "+" and then it gets embedded in a little text box
2. Hash tags via "#"

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


