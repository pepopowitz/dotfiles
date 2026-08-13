# Strategies for small vertical slices

Distilled from [Strategies for Small, Focused Pull Requests](https://artsy.github.io/blog/2021/03/09/strategies-for-small-focused-pull-requests/) (Artsy) and [Breaking Problems Down: A Case Study](https://www.stevenhicks.me/blog/2022/11/breaking-problems-down-a-case-study/) (Steve Hicks).

## Slicing strategies

**Build a walking skeleton.** Ship a bare-bones, stripped-down implementation that connects UI to data source end-to-end with minimal functionality. Fill in features incrementally once it's merged. This is the natural follow-on from a crux prototype: the skeleton proves the path, later slices add flesh.

**Feature toggles and hidden routes.** Hide incomplete work behind a flag or an unlinked route. This lets slices merge and deploy continuously without exposing unfinished features — and keeps every slice user-testable (visit the hidden route, flip the flag).

**Slice stories smaller.** Split by CRUD operation, by user role, by edge case, or by simplified-vs-enhanced version. Ship the simple 80% case first; the enhanced version is its own slice.

**Separate risky/controversial work from routine work.** Novel work that needs discussion goes in its own slice, so review attention lands on the substance instead of being diluted across routine changes.

**Separate infrastructural work from routine implementations.** Wide, abstract enabling work (a new pattern, a seam, a config change) reviews differently from deep, narrow feature work. Split them — and land the infrastructure first: "make the change easy (warning: this may be hard), then make the easy change."

**Split along natural seams.** Versions, sections, layers, roles — boundaries that already exist in the domain. Arbitrary splits create slices that can't be verified independently. 

**Slice by architectural layer — sparingly.** An API-only PR followed by a UI PR can make review digestible, but a layer alone is usually not user-testable. Prefer thin end-to-end slices; use layer splits only when a layer is independently verifiable (e.g. an API endpoint the user can curl). This is typically a last resort, when other strategies have been applied but the work is still large.

**Use git rebase to split an already-large branch.** When work has grown multiple strands, `git rebase -i` to rename, reorder, combine, and separate commits into shippable slices.

## Principles from the case study

- **Explore early with proofs of concept** — early investigation reveals the natural decomposition before implementation begins (this is what PROTOTYPE does for cruxes).
- **Integrate incrementally**, especially during novel, uncertain phases — long-lived branches compound risk.
- **Give reviewers rich context** — videos, screenshots, comments, verification steps. Small PRs reviewed in isolation need the surrounding story.
- **Defer perfectionism aggressively** — resolve only blocking issues; edge cases and polish become follow-up slices, not scope creep in the current one.
