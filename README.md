# App Branching Strategy

## Permanent Trunks
* `master` -> Latest and greatest Dev Tested Code
No other permanent trunks.

> All PRs will be Squashed and Merged

## Other branches that come and go
* `feature/<feature_name>`
* `fix/<bug_title>`
* `release/v-<version.major>.<version.minor>` 
	* Temporary branch that lives while a release is being _prepared_
	* No patch number in branch name because patch number is subject to change as fixes are merged after Testing
* `auto-backmerge/<pr_number>` Used to raise PRs to master for every change pushed to release branches

## Feature Development and Bug Fixing
```mermaid
%%{init: { 'gitGraph': {'mainBranchName': 'master', 'showCommitLabel': true}} }%%

gitGraph
	commit id: "🤖 2301.25.0"
	branch fix/frames-bug
	commit id: "Fix Logic"
	commit id: "Fix UI"
	checkout master
	branch feature/dm
	commit id: "Add DB"
	commit id: "Add Socket"
	checkout master
	merge fix/frames-bug id: "PR: Frames Bug"
	commit id: "🤖 2301.25.1"
	checkout feature/dm
	merge master id: "Pull master"
	commit id: "Add UI"
	checkout master
	merge feature/dm id: "PR: Feature DM"
	commit id: "🤖 2301.25.2"
```

## Versioning Schema
`YYMM.DD.N`
`N` -> patch number

Yes. It's a date based versioning scheme that is 
* compatible with semver comparisons
* compatible with string alphabetical order comparisons ( `2301.16.0` > `2212.31.10` )
* and avoids the question - "When did we release this version" forever from anyone in the team

## App Release and Release Fixes
### Release Preparation
1. Cut the release branch from latest `master`
1. Generate Artifact(APK / IPA), and Dev Test
1. Distribute Artifact internally
1. Fix bugs in release branch, `master` branch and go to Step 2
1. Once we are 🟢 on all tests, Tag the latest commit from the release branch and upload the Artifact to App Stores

```mermaid
%%{init: { 'gitGraph': {'mainBranchName': 'master', 'showCommitLabel': true}} }%%

gitGraph
	commit id: "🤖 2301.25.2"
	branch release/v-2301.25
	checkout master
	commit id: "PR: New Feature" type:HIGHLIGHT
	commit id: "🤖 2301.26.0"
	checkout release/v-2301.25
	branch fix/release-bug
	commit id: "Fix bug"
	checkout release/v-2301.25
	merge fix/release-bug id: "PR: Release bug"
	checkout release/v-2301.25
	branch auto-backmerge/release-bug
	merge master id: "Update branch"
	checkout release/v-2301.25
	commit id: "🤖 2301.25.3" tag: "v-2301.25.3"
	checkout master
	merge auto-backmerge/release-bug id: "backmerge"
	checkout master
	commit id: "🤖 2301.26.1"
```

### Hotfix
Fixing an issue in current production build (`v-2301.16.1`)
1. Create a branch from the release tag (tag: `v-2301.16.1` -> branch: `release/v-2301.16`)
1. Fix the issue and raise PRs to release branch and master as shown below
1. Distribute Artifact Internally
1. Once we are 🟢 on all tests, Tag the latest commit from the release branch and upload the Artifact to App Stores

> Note: The second PR from `hotfix` branch to `master` will be automated

```mermaid
%%{init: { 'gitGraph': {'mainBranchName': 'release/v-2301.16', 'showCommitLabel': true}} }%%

gitGraph
	commit id: "2301.16.4" tag: "v-2301.16.4"
	branch hotfix/crash
	commit id: "Fix crash"
	checkout release/v-2301.16
	merge hotfix/crash id: "PR Crash"
	commit id: "🤖 2301.16.5"
	branch hotfix/bug
	commit id: "Fix bug"
	checkout release/v-2301.16
	merge hotfix/bug id: "PR Bug"
	commit id: "🤖 2301.16.6" tag: "v-2301.16.6"

```

## Automated Workflows
### On PR merge to `master`
🤖 [on-merge-master.yml](./.github/workflows/on-merge-master.yml)
On every merge to master we update the full version. Major, minor versions will be modified if the existing version is of a previous date, otherwise only the patch number will be increased.

**Example**:  
Existing Version: `2301.25.2`  
If a new commit is pushed on 25th Jan, 2023, the version becomes `2301.25.3`  
If a new commit is pushed on 26th Jan, 2023, the version becomes `2301.26.0`  

### On PR merge to `release/**`
🤖 [on-merge-release.yml](./.github/workflows/on-merge-release.yml)
#### Update Patch Number on `release*`
On every commit we update the patch number on `release*` branches

#### Backmerge pushes into `release/**` onto `master`
🤖 [on-merge-release.yml](./.github/workflows/on-merge-release.yml)
Every push to `release*` will trigger a corresponding PR to `master` via a `auto-backmerge/<pr_number>` branch. 

> The PR will be automatically merged if there are no conflicts

## Manually triggered workflows
### Prepare a new release
🤖 [prepare-a-release.yml](./.github/workflows/prepare-a-release.yml)
Create a release branch from latest master, with the right version in the branch name.

Actions ▶️ > Prepare a release > Run workflow

### Tag Release
Tag the latest commit in a release branch with the right version tag

