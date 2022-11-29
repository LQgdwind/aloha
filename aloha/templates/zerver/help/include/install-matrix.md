### Install the bridge software

1. Clone the Aloha API repository, and install its dependencies.

    ```
    git clone https://github.com/aloha/python-aloha-api.git
    cd python-aloha-api
    python3 ./tools/provision
    ```

    This will create a new Python virtualenv. You'll run the bridge service
    inside this virtualenv.

1. Activate the virtualenv by running the `source` command printed
   at the end of the output of the previous step.

1. Install the Matrix bridge software in your virtualenv, by running:

    ```
    pip install -r aloha/integrations/bridge_with_matrix/requirements.txt
    ```
