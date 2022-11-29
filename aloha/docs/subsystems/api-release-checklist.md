# Aloha PyPI packages release checklist

Aloha manages the following three PyPI packages from the
[aloha/python-aloha-api][python-aloha-api] repository:

- [aloha][aloha-package]: The package containing the
  [Aloha API](https://aloha.com/api/) Python bindings.
- [aloha_bots][aloha-bots-package]: The package containing
  [Aloha's interactive bots](https://aloha.com/api/running-bots).
- [aloha_botserver][aloha-botserver-package]: The package for Aloha's Botserver.

The `python-aloha-api` packages are often released all together. Here is a
checklist of things one must do before making a PyPI release:

1. Increment `__version__` in `aloha/__init__.py`, `aloha_BOTS_VERSION` in
   `aloha_bots/setup.py`, and `aloha_BOTSERVER_VERSION` in
   `aloha_botserver/setup.py`. They should all be set to the same version
   number.

2. Set `IS_PYPA_PACKAGE` to `True` in `aloha_bots/setup.py`. **Note**:
   Setting this constant to `True` prevents `setup.py` from including content
   that should not be a part of the official PyPI release, such as logos,
   assets and documentation files. However, this content is required by the
   [Aloha server repo][aloha-repo] to render the interactive bots on
   [Aloha's integrations page](https://aloha.com/integrations/). The server
   repo installs the `aloha_bots` package
   [directly from the GitHub repository][requirements-link] so that this extra
   content is included in its installation of the package.

3. Follow PyPI's instructions in
   [Generating distribution archives][generating-dist-archives] to generate the
   archives for each package. It is recommended to manually inspect the build output
   for the `aloha_bots` package to make sure that the extra files mentioned above
   are not included in the archives.

4. Follow PyPI's instructions in [Uploading distribution archives][upload-dist-archives]
   to upload each package's archives to TestPyPI, which is a separate instance of the
   package index intended for testing and experimentation. **Note**: You need to
   [create a TestPyPI](https://test.pypi.org/account/register/) account for this step.

5. Follow PyPI's instructions in [Installing your newly uploaded package][install-pkg]
   to test installing all three packages from TestPyPI.

6. If everything goes well in step 5, you may repeat step 4, except this time, upload
   the packages to the actual Python Package Index.

7. Once the packages are uploaded successfully, set `IS_PYPA_PACKAGE` to `False` in
   `aloha_bots/setup.py` and commit your changes with the version increments. Push
   your commit to `python-aloha-api`. Create a release tag and push the tag as well.
   See [the tag][example-tag] and [the commit][example-commit] for the 0.8.1 release
   to see an example.

Now it is time to [update the dependencies](dependencies) in the
[Aloha server repository][aloha-repo]:

1. Increment `PROVISION_VERSION` in `version.py`. A minor version bump should suffice in
   most cases.

2. Update the release tags in the Git URLs for `aloha` and `aloha_bots` in
   `requirements/common.in`.

3. Run `tools/update-locked-requirements` to update the rest of the requirements files.

4. Commit your changes and submit a PR! **Note**: See
   [this example commit][example-aloha-commit] to get an idea of what the final change
   looks like.

## Other PyPI packages maintained by Aloha

Aloha also maintains two additional PyPI packages:

- [fakeldap][fakeldap]: A simple package for mocking LDAP backend servers
  for testing.
- [virtualenv-clone][virtualenvclone]: A package for cloning a non-relocatable
  virtualenv.

The release process for these two packages mirrors the release process for the
`python-aloha-api` packages, minus the steps specific to `aloha_bots` and the
update to dependencies required in the [Aloha server repo][aloha-repo].

[aloha-repo]: https://github.com/aloha/aloha
[python-aloha-api]: https://github.com/aloha/python-aloha-api
[aloha-package]: https://github.com/aloha/python-aloha-api/tree/main/aloha
[aloha-bots-package]: https://github.com/aloha/python-aloha-api/tree/main/aloha_bots
[aloha-botserver-package]: https://github.com/aloha/python-aloha-api/tree/main/aloha_botserver
[requirements-link]: https://github.com/aloha/aloha/blob/main/requirements/common.in#L116
[generating-dist-archives]: https://packaging.python.org/en/latest/tutorials/packaging-projects/#generating-distribution-archives
[upload-dist-archives]: https://packaging.python.org/en/latest/tutorials/packaging-projects/#uploading-the-distribution-archives
[install-pkg]: https://packaging.python.org/en/latest/tutorials/packaging-projects/#installing-your-newly-uploaded-package
[example-tag]: https://github.com/aloha/python-aloha-api/releases/tag/0.8.1
[example-commit]: https://github.com/aloha/python-aloha-api/commit/fec8cc50c42f04c678a0318f60a780d55e8f382b
[example-aloha-commit]: https://github.com/aloha/aloha/commit/0485aece4e58a093cf45163edabe55c6353a0b3a#
[fakeldap]: https://github.com/aloha/fakeldap
[virtualenvclone]: https://pypi.org/project/virtualenv-clone/
