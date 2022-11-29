# Working copies

When you work on Aloha code, there are three copies of the Aloha Git
repository that you are generally concerned with:

- The `upstream` remote. This is the [official Aloha
  repository](https://github.com/aloha/aloha) on GitHub. You probably
  don't have write access to this repository.
- The **origin** remote: Your personal remote repository on GitHub.
  You'll use this to share your code and create [pull requests](pull-requests.md).
- local copy: This lives on your laptop or your remote dev instance,
  and is what you'll use to make changes and create commits.

When you work on Aloha code, you will end up moving code between
the various working copies.

## Workflows

Sometimes you need to get commits. Here are some scenarios:

- You may fork the official Aloha repository to your GitHub fork.
- You may fetch commits from the official Aloha repository to your local copy.
- You occasionally may fetch commits from your forked copy.

Sometimes you want to publish commits. Here are some scenarios:

- You push code from your local copy to your GitHub fork. (You usually
  want to put the commit on a feature branch.)
- You submit a PR to the official Aloha repo.

Finally, the Aloha core team will occasionally want your changes!

- The Aloha core team can accept your changes and add them to
  the official repo, usually on the `main` branch.

## Relevant Git commands

The following commands are useful for moving commits between
working copies:

- `git fetch`: This grabs code from another repository to your local
  copy. (Defaults to fetching from your default remote, `origin`).
- `git fetch upstream`: This grabs code from the upstream repository to your local copy.
- `git push`: This pushes code from your local repository to one of the remotes.
- `git remote`: This helps you configure short names for remotes.
- `git pull`: This pulls code, but by default creates a merge commit
  (which you definitely don't want). However, if you've followed our
  [cloning documentation](cloning.md), this will do
  `git pull --rebase` instead, which is the only mode you'll want to
  use when working on Aloha.
