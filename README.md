# GitWorktreeProjects

PowerShell module to manage projects using Git Worktree functionality.

Main purpose is to provide a set of cmdlets to make working with git worktrees easier.

This module is written to match my personal way of working.

## Assumptions

- git cmdline available through the path.

## Structure

Global configuration and configuration where projects can be found is stored in the .gitworktree folder in the user directory ($HOME).

## Cmdlets

The following cmdlets are supported:

### New-GitWorktreeProject

Creates a new Git Worktree project based on a git remote repository. Checks out the repository and the initial branch (defaults to main).

### New-GitWorktree

Creates a new branch in a Git Worktree project.

### Open-GitWorktree

opens a Git Worktree project for a given branch.

### Remove-GitWorktree

Removes a branch for a Git Worktree project.

### Set-GitWorktreeConfig

Either sets a number of Git Worktree project configurations, such as the tools to open for this project,
or sets a number of Git Worktree global defaults, such as the default Git Worktree projects root directory and the default initial branch name.
