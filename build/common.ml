module Version = struct
  let mingw_w64 = "v3.3.0"

  let gcc = "4.8.3"

  let binutils = "2.24"

  let efl = "1.11.2"

  let elementary = "1.11.2"
end

module Source = struct
  let mingw_w64 =
    "mingw-w64-${VERSION}.tar.bz2", "d31eac960d42e791970697eae5724e529c81dcd6"

  let gcc =
    "gcc-${VERSION}.tar.xz", "f2f894d6652f697fede264c16c028746e9ee6243"

  let binutils =
    "binutils-${VERSION}.tar.gz", "1b2bc33003f4997d38fadaa276c1f0321329ec56"

  let efl =
    "${PACKAGE}-${VERSION}.tar.xz", "81007abb130e087d01101d082661ada0a8879568"

  let elementary =
    "${PACKAGE}-${VERSION}.tar.xz", "d756b9c4763beebfbf494b9d2ee42cc2828dd4d8"
end
