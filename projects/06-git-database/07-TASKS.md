
We can already build a task system on top of [##.], {##.}, <##.>, <[]##.>. Especially if it's vibe coded then we can immediately put it to use.

A typical task flow should have statuses - e.g. awaiting plan review, awaiting code review, etc. Many of these statuses are "awaiting agent" but some are "awaiting human verification."

The thing I want is: human verification issues should have clear contextless instructions. Also, each state transition should emit evidence, like here are the docs/artifacts/remarks that prove this was completed.

Question: how to handle splitting/merging of tasks? should a task have a stable identity over its state transitions? If we eventually want to automate the verifications - how to model?

How to handle 2 agents parallel-ly doing the same task and then a human compares the output?


