FROM centos:7
RUN yum -y install centos-release-scl \
    && yum -y install make git wget python3 binutils-devel devtoolset-10-gcc-c++ \
    && source scl_source enable devtoolset-10 \
    && mkdir /staging && cd /staging \
    && curl -OL https://github.com/Kitware/CMake/releases/download/v3.20.2/cmake-3.20.2-linux-x86_64.sh \
    && sh cmake-3.20.2-linux-x86_64.sh --prefix=/usr/local --skip-license \
    && curl -OL https://github.com/llvm/llvm-project/releases/download/llvmorg-12.0.0/llvm-project-12.0.0.src.tar.xz \
    && tar xf llvm-project-12.0.0.src.tar.xz \
    && mkdir /staging/llvm-project-12.0.0.src/build && cd /staging/llvm-project-12.0.0.src/build \
    && cmake -G "Unix Makefiles" -DLLVM_ENABLE_PROJECTS='clang;lld;libcxx;libcxxabi' -DCMAKE_BUILD_TYPE=Release -DCLANG_DEFAULT_CXX_STDLIB=libc++ -DLIBCXX_ENABLE_STATIC_ABI_LIBRARY=ON -DLLVM_BINUTILS_INCDIR=/usr/include ../llvm \
    && make -j$(nproc) \
    && make install \
    && yum clean all \
    && curl --proto '=https' --tlsv1.2 -sSf -o rustup.sh https://sh.rustup.rs \
    && sh rustup.sh -y --default-toolchain none --profile minimal \
    && rm -rf /staging

ENV PATH="/root/.cargo/bin:${PATH}"
