//
//  BlockHitCollector.cpp
//  OBJCLucene
//
//  Created by Sean Lynch on 4/2/14.
//
//

#include "BlockHitCollector.h"

using namespace std;
using namespace lucene::index;
using namespace lucene::document;
using namespace ocl;

BlockHitCollector::BlockHitCollector(HitCollectorBlock collectorBlock)
{
    _block = collectorBlock;
}

void BlockHitCollector::collect(const int32_t doc, const float_t score)
{
    _block(doc, score);
}