# GitWorktreeProjects

PowerShell module to manage projects using [git working trees](https://git-scm.com/docs/git-worktree) functionality.

Main purpose is to provide a set of CmdLets to make working with git working trees easier:

- Create a new working tree, either from an existing commit-ish, or from a new branch.
- Opening and switching between working trees.
- Clean-up working trees when done.
- Automatically open tools that are always required when opening a working tree.

## To Do

This project is still highly in development and not completely production ready. I use it at a daily base. But things need to be done to make it better still.

Completed:

- `Get-GitWorktree`

In progress:

- `Get-GitWorktreeProject`

To complete:

- `New-GitWorktreeProject`
- `Remove-GitWorktreeProject`
- `New-GitWorktree`
- `Open-GitWorktree`
- `Remove-GirWorktree`
- `Get-GitWorktreeDefault`
- `Set-GitWorktreeDefault`
- `about_GitWorktreeProject`

### Documentation

Add documentation to:

- `New-GitWorktreeProject`
- `New-GitWorktree`
- `Open-GitWorktree`
- `Remove-GirWorktree`
- `Get-GitWorktreeDefault`
- `Set-GitWorktreeDefault`
- `about_GitWorktreeProject`

### Finish Pester unit tests

Rethink tests for:

- `GetCanonicalPath`

Review / complete unit tests for:

- `Get-GitWorktreeProject`
- `Open-GitWorktree`
- `Remove-GirWorktree`
- `Get-GitWorktreeDefault`
- `Set-GitWorktreeDefault`
- `about_GitWorktreeProject`

Create unit tests for:

- `New-GitWorktreeProject`.
- `New-GitWorktree`.

### Complete basic functionality

- Finish `Remove-GitWorktree`.
- Add `Remove-GitWorktreeProject`.

### Rethink tools functionality

- Allow to define script in project to start when opening working tree?
- Default script in project or project settings?

## Assumptions

- git available through the path.

## Structure

Global configuration and configuration where projects can be found is stored in the .gitworktree folder in the user directory (i.e. `$HOME`).

## CmdLets

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

### Get-GitWorktreeDefault

Gets the defaults that are used when creating a new GitWorktree project.

### Set-GitWorktreeDefault

Sets the defaults to be used when creating a new GitWorktree project, such as the default git working tree projects root directory and the default initial branch name.

## Common behavior

If inside a folder, or a subfolder, for a GitWorktree project, for most CmdLets that take a `-Project` or `-ProjectFilter` parameter the value `.` can be used to select that project.
