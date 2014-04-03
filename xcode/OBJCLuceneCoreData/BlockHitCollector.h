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
    typedef void (^HitCollectorBlock)(lucene::document::Document document, float_t score);
    class BlockHitCollector : public lucene::search::HitCollector {
    public:
        BlockHitCollector(FieldSelectorBlock selectorBlock, HitCollectorBlock collectorBlock, lucene::index::IndexReader *indexReader);
        void collect(const int32_t, const float_t score);
    private:
        BlockFieldSelector _fieldSelector;
        HitCollectorBlock _block;
        lucene::index::IndexReader *_indexReader;
    };
}

#endif /* defined(__OBJCLucene__BlockHitCollector__) */
