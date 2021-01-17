# GitWorktreeProjects

PowerShell module to manage projects using Git Worktree functionality.

Main purpose is to provide a set of cmdlets to make working with git worktrees easier and in one go open tooling to work with a project.

This module is written to match my personal way of working.

## Assumptions

- git cmdline available through the path.
- All project are combined in a single root.

## Structure

Global configuration and configuration where projects can be found, and what tools to start, is stored in the .gitworktree folder in the user directory ($HOME).

## Cmdlets

The following cmdlets are supported:

### New-GitWorktree

Creates a new Git Worktree project based on a git remote repository. Checks out the repository and the initial branch (defaults to main).

### New-GitWorktreeBranch

Creates a new branch in a Git Worktree project.

### Open-GitWorktreeBranch

opens a Git Worktree project for a given branch.

### Remove-GitWorktreeBranch

Removes a branch for a Git Worktree project.

### Set-GitWorktreeConfig

Either sets a number of Git Worktree project configurations, such as the tools to open for this project,
or sets a number of Git Worktree global defaults, such as the default Git Worktree projects root directory and the default initial branch name.

## Supported tools

### Visual Studio Code

### Visual Studio

### SourceTree
