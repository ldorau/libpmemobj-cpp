#!/usr/bin/env bash
#
# Copyright 2018-2019, Intel Corporation
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
#
#     * Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#
#     * Redistributions in binary form must reproduce the above copyright
#       notice, this list of conditions and the following disclaimer in
#       the documentation and/or other materials provided with the
#       distribution.
#
#     * Neither the name of the copyright holder nor the names of its
#       contributors may be used to endorse or promote products derived
#       from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
# A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
# OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
# LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
# THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

set -e

TAG="1.9"
DIR="v$(echo ${TAG} | cut -d. -f1-2)"
ORIGIN="https://github.com/ldorau/libpmemobj-cpp"
UPSTREAM="https://github.com/pmem/libpmemobj-cpp"

# Clone repo
git clone ${ORIGIN}
cd libpmemobj-cpp
git remote add upstream ${UPSTREAM}
git fetch upstream --tags

git config --local user.name "Lukasz Dorau"
git config --local user.email "lukasz.dorau@intel.com"

git checkout $TAG
sed -i 's/PROJECT_NUMBER = "1.2.0"/PROJECT_NUMBER = "1.9.0"/g' doc/libpmemobj++.Doxyfile.in
cat doc/libpmemobj++.Doxyfile.in | grep -e "PROJECT_NUMBER"

# Build docs
mkdir build
cd build

cmake -DBUILD_TESTS=OFF -DBUILD_EXAMPLES=OFF ..
make -j$(nproc) doc
cp -R doc/cpp_html ../..

cd ..

# Checkout gh-pages and copy docs
git checkout -fb gh-pages upstream/gh-pages
git clean -df
mkdir -p $DIR/doxygen/
cp -r ../cpp_html/* $DIR/doxygen/

# Add and push changes.
# git commit command may fail if there is nothing to commit.
# In that case we want to force push anyway (there might be open pull request with
# changes which were reverted).
git add -A
git commit -m "doc: automatic gh-pages docs update" && true
git push -f ${ORIGIN} gh-pages

# Makes pull request.
# When there is already an open PR or there are no changes an error is thrown, which we ignore.
# hub pull-request -f -b pmem:gh-pages -h pmem-bot:gh-pages -m "doc: automatic gh-pages docs update" && true

exit 0
