
1. Scope out a small first milestone with user flow(s)
2. Decide on table schema
3. Write down the API architecture (client/server/comms proxy layer)


4. Data ownership model (multi-repo?)
5. Runtime model (does it run cli locally, hosted webapp etc.)
6. Refine the "pitch" (potential problems we are trying to solve, e.g. josh git/doc)
7. Research some helpful subagents (a asker-for-more-info? a scope-creep-pruner?)
8. Think about CONTRIBUTING.md (forking encouraged!)
9. Think about the UI/UX flows that we will eventually do on top
10. External connectivity (APIs, webhooks etc.)

11. Problem: tasks live most naturally on the main branch, autopushed, but task deliverables (code diffs) need to be branched off of main or whatever. 
    For instance - Sculptor starting off main with a task like "Take this open MR, grab context from it and make a stacked fix on top for me to review".
