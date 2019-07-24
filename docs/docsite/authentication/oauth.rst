Oauth 101
#########

Tapis uses a form of web-based authentication and authorization known as
Oauth2. The full description of Oauth is left to other sources, but the basic
operational description of how Tapis uses it is described here.

Each user registers one or more Oauth clients using the Tapis ``clients``
service. Each ``client`` consists of a name, an API key and secret, and
a set of subscriptions. By default each Oauth client is subscribed to
(meaning they  are able to use and interact with) all public Tapis APIs.

Each HTTP request to a Tapis API includes a client API key and secret, plus
a short string known as an access (or ``Bearer``) token. This combination of
three values is sufficient to identify the user and determine which services
she has access to. In order to have these values handy, ``Tapis-CLI`` caches
some of them on the filesystem in a sessions cache directory, and generates
the others using information provided by the user (such as a password).

The following are cached only on the filesystem and cannot easily be
retrieved from the ``clients`` service:

    * API Secret - Returned only when a client is created. It must be kept safe as it is a stand-in for a password in the HTTP Basic Authentication scheme.
    * Access token - Issued by the ``token`` service when it is provided with an API key and secret and verification of the user's identity. Their password is currently used for that purpose. An access token expires after 4 hours, at which point it must be refreshed.
    * Refresh token - To avoid requesting the user's password again after 4 hours, a refresh token is returned with with the access token. It can be redeemed exactly once along with an API key and secret to generate a new access token (and new refresh token).

Oauth is pretty complicated, challenging even experienced developers, but it is
also rather secure and is thus a widely-adopted internet standard. The Tapis
CLI (and underlying AgavePy library) manage this complexity on behalf of the
user, making it possible to secure access to complex research code and data
using open standards and coding practices.
