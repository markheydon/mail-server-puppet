# Mailserver for Ubuntu 14.04 LTS or Debian

This project builds on the excellent standalone puppet installation script from [mickem / mail-server-puppet](https://github.com/mickem/mail-server-puppet), and fork [ksemel / mail-server-puppet](https://github.com/ksemel/mail-server-puppet). The goal being to have a fully functioning, complete mail server with admin UI, webmail, IMAP/POP3 access solution up and running quickly and easily.

Solution includes:

* Postfix;
* Dovecot;
* pop3d;
* RainLoop; and
* Amavis+ClamAV

## Installation

See the [Quick Start](https://github.com/mhcg/mail-server-puppet/wiki/Quick-Start) page for installation details

## Usage

See the [Quick Start](https://github.com/mhcg/mail-server-puppet/wiki/Quick-Start) page for initial setup details

## History

### 1.1 (2016-03-15)

* Initial LetsEncrypt support. Uses internal webserver for validation. 
* TODO: Add LetsEncrypt renewal without killing nginx.

### 1.0 (2015-02-17)

* Consolidation of work done in original [mickem / mail-server-puppet](https://github.com/mickem/mail-server-puppet) project, and additional work in [ksemel / mail-server-puppet](https://github.com/ksemel/mail-server-puppet). Plus changes to make a little more generic.

## Credits

* [mickem](https://github.com/mickem)
* [ksemel](https://github.com/ksemel)
* MHCG Service Desk _(helped with testing)_

## License

See [LICENSE](LICENSE.md) file

