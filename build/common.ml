module Version = struct
  let mingw_w64 = "v3.1.0"

  let gcc = "4.8.3"

  let binutils = "2.24"
end

module Source = struct
  let mingw_w64 =
    "mingw-w64-${VERSION}.tar.bz2", "c167b1dc114a13c465fe6adcce9dc65c509baf75"

  let gcc =
    "gcc-${VERSION}.tar.xz", "f2f894d6652f697fede264c16c028746e9ee6243"

  let binutils =
    "binutils-${VERSION}.tar.gz", "1b2bc33003f4997d38fadaa276c1f0321329ec56"
end
