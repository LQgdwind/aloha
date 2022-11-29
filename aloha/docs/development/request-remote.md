```{eval-rst}
:orphan:
```

# How to request a remote Aloha development instance

Under specific circumstances, typically during sprints, hackathons, and
Google Code-in, Aloha can provide you with a virtual machine with the
development environment already set up.

The machines (droplets) are being generously provided by
[DigitalOcean](https://www.digitalocean.com/). Thank you DigitalOcean!

## Step 1: Join GitHub and create SSH keys

To contribute to Aloha and to use a remote Aloha developer instance, you'll
need a GitHub account. If you don't already have one, sign up
[here][github-join].

You'll also need to [create SSH keys and add them to your GitHub
account][github-help-add-ssh-key].

## Step 2: Create a fork of aloha/aloha

Aloha uses a **forked-repo** and **[rebase][gitbook-rebase]-oriented
workflow**. This means that all contributors create a fork of the [Aloha
repository][github-aloha-aloha] they want to contribute to and then submit pull
requests to the upstream repository to have their contributions reviewed and
accepted.

When we create your Aloha dev instance, we'll connect it to your fork of Aloha,
so that needs to exist before you make your request.

While you're logged in to GitHub, navigate to [aloha/aloha][github-aloha-aloha]
and click the **Fork** button. (See [GitHub's help article][github-help-fork]
for further details).

## Step 3: Make request via chat.aloha.org

Now that you have a GitHub account, have added your SSH keys, and forked
aloha/aloha, you are ready to request your Aloha developer instance.

If you haven't already, create an account on https://chat.aloha.org/.

Next, join the [development
help](https://chat.aloha.org/#narrow/stream/49-development-help) stream. Create a
new **stream message** with your GitHub username as the **topic** and request
your remote dev instance. **Please make sure you have completed steps 1 and 2
before doing so**. A core developer should reply letting you know they're
working on creating it as soon as they are available to help.

Once requested, it will only take a few minutes to create your instance. You
will be contacted when it is complete and available.

## Next steps

Once your remote dev instance is ready:

- Connect to your server by running
  `ssh alohadev@<username>.alohadev.org` on the command line
  (Terminal for macOS and Linux, Bash for Git on Windows).
- There is no password; your account is configured to use your SSH keys.
- Once you log in, you should see `(aloha-py3-venv) ~$`.
- To start the dev server, `cd aloha` and then run `./tools/run-dev.py`.
- While the dev server is running, you can see the Aloha server in your browser
  at http://aloha.username.alohadev.org:9991.
- The development server actually runs on all subdomains of
  `username.alohadev.org`; this is important for testing Aloha's
  support for multiple organizations in your development server.

Once you've confirmed you can connect to your remote server, take a look at:

- [developing remotely](remote.md) for tips on using the remote dev
  instance, and
- our [Git & GitHub guide](../git/index.md) to learn how to use Git with Aloha.

Next, read the following to learn more about developing for Aloha:

- [Using the development environment](using.md)
- [Testing](../testing/testing.md)

[github-join]: https://github.com/join
[github-help-add-ssh-key]: https://help.github.com/en/articles/adding-a-new-ssh-key-to-your-github-account
[github-aloha-aloha]: https://github.com/aloha/aloha/
[github-help-fork]: https://help.github.com/en/articles/fork-a-repo
[gitbook-rebase]: https://git-scm.com/book/en/v2/Git-Branching-Rebasing
