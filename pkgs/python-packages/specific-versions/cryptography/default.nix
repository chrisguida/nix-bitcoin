# Copied from nixpkgs rev c7d0dbe094c988209edac801eb2a0cc21aa498d8

{ lib, stdenv
, buildPythonPackage
, fetchPypi
, fetchpatch
, isPy27
, ipaddress
, openssl
, cryptography_vectors
, darwin
, packaging
, six
, pythonOlder
, isPyPy
, cffi
, pytest
, pretend
, iso8601
, pytz
, hypothesis
, enum34
}:

buildPythonPackage rec {
  pname = "cryptography";
  version = "3.3.2"; # Also update the hash in vectors.nix

  src = fetchPypi {
    inherit pname version;
    sha256 = "1vcvw4lkw1spiq322pm1256kail8nck6bbgpdxx3pqa905wd6q2s";
  };

  outputs = [ "out" "dev" ];

  nativeBuildInputs = lib.optionals (!isPyPy) [
    cffi
  ];

  buildInputs = [ openssl ]
             ++ lib.optional stdenv.isDarwin darwin.apple_sdk.frameworks.Security;
  propagatedBuildInputs = [
    packaging
    six
  ] ++ lib.optionals (!isPyPy) [
    cffi
  ] ++ lib.optionals isPy27 [
    ipaddress enum34
  ];

  checkInputs = [
    cryptography_vectors
    # Work around `error: infinite recursion encountered`
    (hypothesis.override { enableDocumentation = false; })
    iso8601
    pretend
    pytest
    pytz
  ];

  checkPhase = ''
    ${pytest}/bin/py.test --disable-pytest-warnings tests
  '';

  # IOKit's dependencies are inconsistent between OSX versions, so this is the best we
  # can do until nix 1.11's release
  __impureHostDeps = [ "/usr/lib" ];

  meta = with lib; {
    description = "A package which provides cryptographic recipes and primitives";
    longDescription = ''
      Cryptography includes both high level recipes and low level interfaces to
      common cryptographic algorithms such as symmetric ciphers, message
      digests, and key derivation functions.
      Our goal is for it to be your "cryptographic standard library". It
      supports Python 2.7, Python 3.5+, and PyPy 5.4+.
    '';
    homepage = "https://github.com/pyca/cryptography";
    changelog = "https://cryptography.io/en/latest/changelog/#v"
      + replaceStrings [ "." ] [ "-" ] version;
    license = with licenses; [ asl20 bsd3 psfl ];
    maintainers = with maintainers; [ primeos ];
  };
}
