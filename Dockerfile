FROM centos:7
RUN yum -y install make gcc-c++ git wget bzip2 python3 binutils-devel \
    && mkdir /staging && cd /staging \
    && curl -O https://ftp.gnu.org/gnu/gcc/gcc-11.1.0/gcc-11.1.0.tar.xz \
    && tar xf gcc-11.1.0.tar.xz \
    && cd /staging/gcc-11.1.0 \
    && contrib/download_prerequisites \
    && mkdir /staging/gcc-11.1.0-build && cd /staging/gcc-11.1.0-build \
    && /staging/gcc-11.1.0/configure --disable-bootstrap --disable-multilib --enable-languages=c,c++ \
    && make -j$(nproc) \
    && make install \
    && yum -y remove gcc cpp gcc-c++ libgomp libmpc mpfr wget bzip2 \
    && ln -sf /usr/local/lib64/libstdc++.so.6 /usr/lib64/libstdc++.so.6 \
    && ln -s /usr/local/bin/gcc /usr/local/bin/cc \
    && cd /staging \
    && curl -OL https://github.com/Kitware/CMake/releases/download/v3.20.2/cmake-3.20.2.tar.gz \
    && tar xf cmake-3.20.2.tar.gz \
    && cd /staging/cmake-3.20.2 \
    && ./bootstrap --parallel=$(nproc) -- -DCMAKE_BUILD_TYPE:STRING=Release -DCMAKE_USE_OPENSSL=OFF \
    && make -j$(nproc) \
    && make install/strip \
    && cd /staging \
    && curl -OL https://github.com/llvm/llvm-project/releases/download/llvmorg-12.0.0/llvm-project-12.0.0.src.tar.xz \
    && tar xf llvm-project-12.0.0.src.tar.xz \
    && mkdir /staging/llvm-project-12.0.0.src/build && cd /staging/llvm-project-12.0.0.src/build \
    && cmake -G "Unix Makefiles" -DLLVM_ENABLE_PROJECTS='clang;lld;libcxx;libcxxabi' -DCMAKE_BUILD_TYPE=Release -DCLANG_DEFAULT_CXX_STDLIB=libc++ -DLIBCXX_ENABLE_STATIC_ABI_LIBRARY=ON -DLLVM_BINUTILS_INCDIR=/usr/include ../llvm \
    && make -j$(nproc) \
    && make install \
    && yum -y remove python3 binutils-devel \
    && yum clean all \
    && curl --proto '=https' --tlsv1.2 -sSf -o rustup.sh https://sh.rustup.rs \
    && sh rustup.sh -y --default-toolchain none --profile minimal \
    && rm -rf /staging

ENV PATH="/root/.cargo/bin:${PATH}"
