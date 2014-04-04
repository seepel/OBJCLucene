//
//  NumericUtils.cpp
//  OBJCLucene
//
//  Created by Sean Lynch on 4/3/14.
//
//

#include "NumericUtils.h"
#include <string>

using namespace ocl;

int64_t NumericUtils::doubleToSortableLong(double val)
{
    int64_t f = doubleToRawLongBits(val);
    if(f < 0) {
        f ^= 0x7fffffffffffffffLL;
    }
    return f;
}

int64_t NumericUtils::doubleToRawLongBits(double value)
{
    int64_t longValue = 0;
    std::memcpy(&longValue, &value, sizeof(double));
    return longValue;
}

double NumericUtils::sortableLongToDouble(int64_t value)
{
    if(value < 0) {
        value ^= 0x7fffffffffffffffLL;
    }
    return longBitsToDouble(value);
}

double NumericUtils::longBitsToDouble(int64_t value)
{
    double doubleValue = 0;
    std::memcpy(&doubleValue, &value, sizeof(int64_t));
    return doubleValue;
}
