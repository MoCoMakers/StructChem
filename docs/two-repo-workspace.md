# The two-repo workspace

StructChem is worked on as **a pair of repos in one folder tree**: a public parent and a private child nested inside it. This doc explains why we do it, how it fits together, and how to work in it. It's an experiment, so the [trade-offs](#alternatives-we-considered) and [open questions](#open-questions) are at the end and feedback is welcome.

## Why two repos

We need two things that pull in opposite directions:

- **Shared context.** People and AI agents both work better with notes, scratch docs, research write-ups, raw data and papers close at hand.
- **A clean public face.** None of that informal, pre-public material belongs in a public repo. Some of it (data, PDFs) can't be redistributed at all.

So the code and polished docs are public, everything else is private, and the two live in one folder tree so nobody, human or agent, has to go looking.

| Repo | Visibility | Holds |
|---|---|---|
| [**StructChem**](https://github.com/MoCoMakers/StructChem) | public | Code, Docker images, scripts, agent skills, public-facing docs and runbooks |
| **StructChemAIDocs** | private, always | Informal notes, raw data, PDFs and extracts, working files, internal and pre-public notes |

## The rule: private by default

Anything **unrefined** is private: notes, discussion, research in progress, prototypes, planning, data and papers. Something becomes public only when it's **refined**: working code, or a doc that's ready for outside readers.

Moving something across is called **promotion**, and it is deliberate:

1. Write a **fresh** public version (e.g. a runbook in `docs/runbooks/`). Never copy and paste from private notes. Keep the method and the refined conclusions; leave out sources, data, file names, discussion and unrefined direction.
2. Open a PR on the public repo. A maintainer approves it.
3. The private original stays where it is.

Data files and third-party papers are never promoted. Public docs can describe them, or point to where anyone can get the public equivalents.

## Layout

```
StructChem/                  ← public repo (github.com/MoCoMakers/StructChem)
├── README.md, AGENTS.md     ← front doors for people and agents
├── docker/  scripts/        ← tools (every tool runs in Docker, nothing installed on the host)
├── docs/                    ← public docs and runbooks
├── data/  out/              ← your local inputs and outputs, git-ignored
└── StructChemAIDocs/        ← private repo, its own git history, ignored by StructChem
    ├── README.md, AGENTS.team.md
    ├── data/  papers/       ← restricted files, never promoted
    ├── research/  notes/    ← write-ups, working notes, team vocabulary
    ├── wayfinder/           ← planning
    ├── prototypes/          ← throwaway code
    └── results/             ← outputs worth keeping
```

Why nest it rather than keep it as a sibling folder:

- **One tree.** Agents, search and RAG indexing see public and private material together, with no links and no reading outside the repo.
- **No symlinks.** These are unreliable on Windows (Git Bash's `ln -s` silently copies unless Developer Mode is on).
- **Docker sees everything.** Our tool wrappers mount the repo root, so private data is reachable inside containers as-is.

## Who needs what

- **External users:** only StructChem. Everything in it works without the private repo. Fetch public structures with `scripts/fetch-pdb.sh <ID>`, or use your own files.
- **Team members and collaborators:** both repos. Access to StructChemAIDocs is by request to the maintainers.

## Setup (team)

```sh
git clone git@github.com:MoCoMakers/StructChem.git
cd StructChem
git clone git@github.com:MoCoMakers/StructChemAIDocs.git StructChemAIDocs
scripts/setup-workspace.sh        # run once per clone. Installs nothing.
```

Day to day:

- `git …` at the root works on the public repo. `git -C StructChemAIDocs …` works on the private one.
- The public repo's `git status` never shows private files.
- Agents read `AGENTS.md`, which tells them to read `StructChemAIDocs/AGENTS.team.md` first whenever it exists. Team-only instructions and planning live there.

## Guardrails

`scripts/setup-workspace.sh` turns these on and checks them. They're plain git hooks kept in the repos, with nothing to install.

| Guard | Stops |
|---|---|
| `.gitignore` | The private folder, `data/`, `out/`, secrets and local agent config showing up in the public repo |
| Public **pre-commit** hook | Committing private paths, data/structure/paper/trajectory files (`.pdb`, `.cif`, `.pdf`, …), or the nested repo as a submodule pointer |
| Public **pre-push** hook | Pushing the public repo to the private remote, or pushing history that contains private or data paths |
| Private **pre-push** hook | Pushing the private repo anywhere except its own private remote |
| Agent rule in `AGENTS.md` | Agents copying private content into public files, commit messages or PR text |

Hooks are local, so they protect only clones where the setup script has been run. No ignore rule can stop someone pasting private text into a public doc: reviewers should read public diffs with that in mind.

## Alternatives we considered

- **Sibling folders linked by a symlink** (`../StructChemAIDocs` linked into the public tree): breaks on Windows without extra settings, and Docker mounts don't follow the link.
- **Private repo as a git submodule:** publishes the private repo's name and commit pointers in public history, and adds submodule friction for everyone.
- **One private repo, publishing snapshots:** keeps everything together, but means public development happens out of sight and releases have to be curated by hand.
- **Private branch or folder in the public repo:** too easy to leak, since public history is forever.

## Open questions

- Is "private by default, promote when refined" the right default, or too strict for some kinds of notes?
- How should outside collaborators request access to the private repo, and who approves promotions?
- Should we add a server-side check (e.g. CI on the public repo) as a backstop for clones that skipped the setup script?
