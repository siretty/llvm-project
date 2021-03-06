//===----------------------------------------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

// <random>

// template<class RealType = double>
// class exponential_distribution

// explicit exponential_distribution(const param_type& parm);

#include <random>
#include <cassert>

int main(int, char**)
{
    {
        typedef std::exponential_distribution<> D;
        typedef D::param_type P;
        P p(0.25);
        D d(p);
        assert(d.lambda() == 0.25);
    }

  return 0;
}
