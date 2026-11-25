# Third-party notices

This image compiles and packages the standalone Nextcloud Talk High Performance
Backend signaling server from official upstream Go source. The MIT license in
`LICENSE` applies only to the container packaging, patch, CI workflow, and
documentation maintained by Daniel G. Cosenza from FNX Labs.

| Component | Version | License | Source |
|---|---|---|---|
| Nextcloud Spreed Signaling (`strukturag/nextcloud-spreed-signaling`) | v2.2.0 | AGPL-3.0-or-later | https://github.com/strukturag/nextcloud-spreed-signaling |
| Go standard library & module dependencies | resolved at build time | BSD-3-Clause / Apache-2.0 / MIT (per `go.mod`) | https://go.dev/ |
| Debian 13 runtime packages | trixie | Debian Free Software Guidelines (DFSG) | https://www.debian.org/ |

Notes:

* `nextcloud-spreed-signaling` is licensed under the **GNU Affero General
  Public License v3 or later (AGPL-3.0-or-later)**, which permits compilation
  and redistribution in container form provided license notices are retained
  and corresponding source is made available.
* The upstream `LICENSE` file is preserved inside the image at
  `/usr/share/doc/signaling-notices/LICENSE`.
* Exact upstream source is available at
  <https://github.com/strukturag/nextcloud-spreed-signaling> (at the release
  tag recorded in image labels and `versions.json`), and the single Debian
  entrypoint patch (`patches/0001-debian-setpriv.patch`) is published in this
  repository.
* Nextcloud is a registered trademark of Nextcloud GmbH. This image is an
  independent build and is not endorsed by or affiliated with struktur AG or
  Nextcloud GmbH.
