module Version = struct
  let mingw_w64 = "v3.3.0"

  let gcc = "4.8.3"

  let binutils = "2.24"
end

module Source = struct
  let mingw_w64 =
    "mingw-w64-${VERSION}.tar.bz2", "d31eac960d42e791970697eae5724e529c81dcd6"

  let gcc =
    "gcc-${VERSION}.tar.xz", "f2f894d6652f697fede264c16c028746e9ee6243"

  let binutils =
    "binutils-${VERSION}.tar.gz", "1b2bc33003f4997d38fadaa276c1f0321329ec56"
end
