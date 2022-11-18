;;; GNU Guix --- Functional package management for GNU
;;; Copyright © 2022 Hilton Chain <hako@ultrarare.space>
;;;
;;; This file is part of GNU Guix.
;;;
;;; GNU Guix is free software; you can redistribute it and/or modify it
;;; under the terms of the GNU General Public License as published by
;;; the Free Software Foundation; either version 3 of the License, or (at
;;; your option) any later version.
;;;
;;; GNU Guix is distributed in the hope that it will be useful, but
;;; WITHOUT ANY WARRANTY; without even the implied warranty of
;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;; GNU General Public License for more details.
;;;
;;; You should have received a copy of the GNU General Public License
;;; along with GNU Guix.  If not, see <http://www.gnu.org/licenses/>.

(define-module (gnu packages apparmor)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages autotools)
  #:use-module (gnu packages base)
  #:use-module (gnu packages bison)
  #:use-module (gnu packages dejagnu)
  #:use-module (gnu packages flex)
  #:use-module (gnu packages gawk)
  #:use-module (gnu packages gettext)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages perl)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages python)
  #:use-module (gnu packages python-xyz)
  #:use-module (gnu packages ruby)
  #:use-module (gnu packages swig)
  #:use-module (guix build-system gnu)
  #:use-module (guix gexp)
  #:use-module (guix git-download)
  #:use-module (guix packages)
  #:use-module (guix utils))

(define-public libapparmor
  (package
    (name "libapparmor")
    (version "3.1.2")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url "https://gitlab.com/apparmor/apparmor")
                    (commit (string-append "v" version))))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "1h77a7ww0rxfv5nsi1iy4fffklxdr2vq6r7kdsqm15yysglhbjyi"))))
    (build-system gnu-build-system)
    (arguments
     (list #:configure-flags
           #~(list (string-append "LDFLAGS=-Wl,-rpath=" #$output "/lib")
                   "--with-perl" "--with-python" "--with-ruby")
           #:phases
           #~(modify-phases %standard-phases
               (add-after 'unpack 'fix-paths
                 (lambda* (#:key inputs #:allow-other-keys)
                   (for-each patch-shebang
                             '("common/list_af_names.sh"
                               "common/list_capabilities.sh"))
                   (for-each (lambda (file)
                               (substitute* file
                                 (("/usr") "")
                                 (("/bin/\\<(pod2man|pod2html|podchecker|prove)\\>" path)
                                  (search-input-file inputs path))
                                 (("/include/linux/capability.h" path)
                                  (search-input-file inputs path))))
                             '("common/Make-po.rules"
                               "common/Make.rules"
                               "binutils/Makefile"
                               "parser/Makefile"
                               "parser/tst/Makefile"
                               "profiles/Makefile"
                               "utils/Makefile"
                               "utils/python-tools-setup.py"
                               "utils/vim/Makefile"))))
               (add-after 'fix-paths 'change-directory
                 (lambda _
                   (chdir "libraries/libapparmor"))))))
    (native-inputs
     (list autoconf
           automake
           bison
           dejagnu
           flex
           libtool
           perl
           python-minimal
           ruby
           swig
           which))
    (home-page "https://apparmor.net")
    (synopsis "Linux kernel security module")
    (description
     "AppArmor is an effective and easy-to-use Linux application security
system.

AppArmor proactively protects the operating system and applications from
external or internal threats, even zero-day attacks, by enforcing good
behavior and preventing both known and unknown application flaws from being
exploited.

AppArmor supplements the traditional Unix discretionary access control (DAC)
model by providing mandatory access control (MAC).  It has been included in
the mainline Linux kernel since version 2.6.36 and its development has been
supported by Canonical since 2009.")
    (license license:lgpl2.1)))
