PonyGateway: Weaver's Gateway Server (``ponyd``)
====================================================

This directory contains the gateway server that serves Chrome DevTools.

PonyGateway is licensed under the Apache Licence, Version 2.0
(http://www.apache.org/licenses/LICENSE-2.0.html).

Installing
----------

There are two ways to install both are pretty simple and can be run in userland.
The end result is the same.

Quick userland install
``````````````````````

Follow the instructions [here](https://github.com/TextureGroup/Weaver#install-ponyd).

This installer uses a `virtualenv
<http://www.virtualenv.org/en/latest/index.html>`_ bootstrap script to install
ponyd and all its dependencies in an isolated python environment in
``~/Library/Weaver``.

Since this uses virtualenv, you can also download the script and customize the
installation options::

  curl -O https://raw.githubusercontent.com/TextureGroup/Weaver/master/scripts/bootstrap-ponyd.py
  python bootstrap-ponyd.py --help

Upgrading your installation can be done with the following commands::

  # activate your virtualenv
  source ~/Library/Weaver/bin/activate
  # update the ponyd source
  pip install -U -e git+https://github.com/TextureGroup/Weaver.git#egg=ponyd
  # updates chrome dev tools source
  ponyd update-devtools     

.. Note:: This process will be simplified in the future


Development installation
````````````````````````

If you already have Weaver git repo checked out you can can set up a
virtualenv manually and have your ponyd installation point to your existing
checkout.  For demonstration we assume ``$VENV`` is set to your intended install
path and ``$WEAVER_PATH`` is set to your Weaver git checkout::

  # if you don't already have virtualenv installed
  sudo easy_install virtualenv

  virtualenv "$VENV"
  source "$VENV/bin/activate"
  pip install -e "$WEAVER_PATH"

  # to ensure your shell knows ponyd exists
  hash -r

To run this ponyd you can either activate your environment by ``source
"$VENV/bin/activate"`` and ``ponyd`` will be added to your path.  You can also
just call it directly via ``$VENV/bin/ponyd`` without activating first.


Starting Debugging Server
-------------------------

Once installed, running Weaver's server is easy::

  ponyd serve

By default, ponyd listens on port 9000 and only on your localhost for security
reasons.

To make the server accessible by another device or computer you must have ponyd
listen on ``0.0.0.0`` which is done by::

  ponyd serve -i 0.0.0.0

To make the server listen on a different port, for example 9229::

  ponyd serve -i 0.0.0.0 -p 9229

The listen and other ports can be customized as well.  Run ``ponyd serve
--help`` for more information.


Known Issues / Improvements
---------------------------

- Relaunching the client application requires you to navigate back to the main
  page.
- Chrome DevTools shows some unnecessary tabs (such as Elements).
  ``ponyd update-devtools`` could possibly be updated to patch the incoming
  Chrome DevTools to hide these unused tabs.


## Contributing
We welcome any contributions. See the [CONTRIBUTING](https://github.com/TextureGroup/Weaver/blob/master/CONTRIBUTING.md) file for how to get involved.
