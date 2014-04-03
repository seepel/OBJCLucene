//
//  BlockHitCollector.h
//  OBJCLucene
//
//  Created by Sean Lynch on 4/2/14.
//
//

#ifndef __OBJCLucene__BlockHitCollector__
#define __OBJCLucene__BlockHitCollector__

#include "CLucene.h"
#include "BlockFieldSelector.h"


namespace ocl {
    typedef void (^HitCollectorBlock)(int32_t doc, float_t score);
    class BlockHitCollector : public lucene::search::HitCollector {
    public:
        BlockHitCollector(HitCollectorBlock collectorBlock);
        void collect(const int32_t, const float_t score);
    private:
        HitCollectorBlock _block;
    };
}

#endif /* defined(__OBJCLucene__BlockHitCollector__) */
