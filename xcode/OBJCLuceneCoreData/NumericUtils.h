//
//  NumericUtils.h
//  OBJCLucene
//
//  Created by Sean Lynch on 4/3/14.
//
//

#ifndef __OBJCLucene__NumericUtils__
#define __OBJCLucene__NumericUtils__

namespace ocl {
    class NumericUtils {
    public:
        static int64_t doubleToSortableLong(double val);
        static int64_t doubleToRawLongBits(double val);

        static double sortableLongToDouble(int64_t val);
        static double longBitsToDouble(int64_t val);
    };
}

#endif /* defined(__OBJCLucene__NumericUtils__) */
