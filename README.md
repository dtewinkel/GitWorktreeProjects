# GitWorktreeProjects

PowerShell module to manage projects using [git working trees](https://git-scm.com/docs/git-worktree) functionality.

Main purpose is to provide a set of CmdLets to make working with git working trees easier:

- Create a new working tree, either from an existing commit-ish, or from a new branch.
- Opening and switching between working trees.
- Clean-up working trees when done.

This module is written to match my personal way of working.

## Assumptions

- git available through the path.

## Structure

Global configuration and configuration where projects can be found is stored in the .gitworktree folder in the user directory (i.e. `$HOME`).

## Cmdlets

The following CmdLets are supported:

### Get-GitWorktreeProject

Alias: `ggwp`.

Get information about GitWorktree projects, including all the managed working trees.

### Get-GitWorktree

Alias: `ggw`.

Get information about the working trees of a GitWorktree project.

### New-GitWorktreeProject

Alias: `ngwp`.

Create a new GitWorktree project based on a git remote repository. Checks out the repository and the initial branch (defaults to main).

### New-GitWorktree

Alias: `ngw`.

In GitWorktree project, create a working tree for an existing commit-ish, or create a working tree for a new branch.

### Open-GitWorktree

Alias: `ogw`.

open a working tree in a GitWorktree project. Open the configured tools.

### Remove-GitWorktree

Alias: `rgw`.

Remove a working tree for a GitWorktree project.

### Get-GitWorktreeDefaults

Sets the defaults to be used when creating a new GitWorktree project.

### Set-GitWorktreeDefaults

Sets the defaults to be used when creating a new GitWorktree project, such as the default Git Worktree projects root directory and the default initial branch name.

## Common behavior

If inside a folder, or a subfolder, for a GitWorktree project, for most CmdLets that take a `-Project` or `-ProjectFilter` parameter the value `.` can be used to select that project.
