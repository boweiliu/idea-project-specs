
1. Scope out a small first milestone with user flow(s)
2. Decide on table schema
3. Write down the API architecture (client/server/comms proxy layer)


4. Data ownership model (multi-repo?)
5. Runtime model (does it run cli locally, hosted webapp etc.)
6. Refine the "pitch" (potential problems we are trying to solve, e.g. josh git/doc)
7. Research some helpful subagents (a asker-for-more-info? a scope-creep-pruner?)
8. Think about CONTRIBUTING.md (forking encouraged!)
9. Think about the UI/UX flows that we will eventually do on top (voice??)
10. External connectivity (APIs, webhooks etc.)

11. Problem: tasks live most naturally on the main branch, autopushed, but task deliverables (code diffs) need to be branched off of main or whatever. 
    For instance - Sculptor starting off main with a task like "Take this open MR, grab context from it and make a stacked fix on top for me to review".
12. Cite inspirations (zed, ideaflow, pairing mode == bidir sync everything, hypercard)
13. What are we not? (we're not linear, we're not get-shit-done app, we're not even primarily the UI)

14. How to implement the sql proxy / git converter?

15. can we get a jq-like program to just explore the "named pointer nest"?
16. Considering the ui/ux, we want to "tooltip the tooltips" and have good flows for exploring
17. as a follow-on, it seems like we would also like to store an "annotated cursor position diagram graph" as a context for tasks to reference.
